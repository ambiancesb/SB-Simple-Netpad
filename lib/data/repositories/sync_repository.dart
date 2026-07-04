import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/divergence_choice.dart';
import 'package:netpad/core/pairing_negotiation.dart';
import 'package:netpad/core/reconnect_divergence.dart';
import 'package:netpad/core/sync_relay.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/models/peer_presence.dart';
import 'package:netpad/core/models/protocol_message.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/pairing_verification_code.dart';
import 'package:netpad/services/peer_host_resolver.dart';
import 'package:netpad/services/protocol_codec.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:uuid/uuid.dart';

class _PeerLink {
  _PeerLink({
    required this.peerId,
    required this.displayName,
  });

  final String peerId;
  final String displayName;
  String? sessionToken;
  bool authenticated = false;
  String? inboundConnectionId;
  String? outboundConnectionId;
  WebSocket? outboundSocket;
  StreamSubscription<dynamic>? outboundSub;

  /// Server cert fingerprint captured during the TLS handshake, pinned on
  /// successful pairing (TOFU).
  String? pendingCertFingerprint;

  DateTime? lastPongAt;
  Timer? heartbeatTimer;
}

class SyncRepository extends ChangeNotifier {
  SyncRepository({
    required this.instanceId,
    required String displayName,
    required LocalServer localServer,
    required DiscoveryRepository discovery,
    required WorkspaceRepository workspace,
    required ConnectionLogRepository connectionLog,
    required TrustStore trustStore,
  }) : _displayName = displayName,
       _server = localServer,
       _discovery = discovery,
       _workspace = workspace,
       _connectionLog = connectionLog,
       _trustStore = trustStore {
    _server.onMessage = _onInboundMessage;
    _server.onConnectionClosed = _onInboundClosed;
  }

  final String instanceId;
  String _displayName;
  String get displayName => _displayName;
  final LocalServer _server;
  final DiscoveryRepository _discovery;
  final WorkspaceRepository _workspace;
  final ConnectionLogRepository _connectionLog;
  final TrustStore _trustStore;

  bool _divergencePromptActive = false;
  bool _liveConflictPromptActive = false;

  final Map<String, _PeerLink> _linksByPeerId = {};
  final Map<String, String> _connectionToPeerId = {};
  final Map<String, String> _pendingOutboundRequestId = {};
  final Map<String, Timer> _pairingTimeouts = {};
  final Map<String, PeerPresence> _presence = {};

  static const _connectTimeout = Duration(seconds: 20);
  static const _pairingTimeout = Duration(seconds: 45);

  /// Last-known cursor position of each connected peer.
  Map<String, PeerPresence> get presence => Map.unmodifiable(_presence);

  void Function(
    String fromId,
    String fromName,
    String requestId,
    String connectionId,
  )?
  onIncomingPairRequest;
  void Function(String peerId, bool accepted)? onPairRequestResolved;

  /// Asked when a live edit collides at the same revision as the local note.
  Future<DivergenceChoice> Function(
    String peerName,
    String docTitle,
    int revision,
    String localText,
    String remoteText,
  )?
  onLiveConflict;

  /// Asked when a reconnecting peer's note diverges from the local one.
  Future<DivergenceChoice> Function(
    String peerName,
    String docTitle,
    int localRevision,
    String localText,
    int remoteRevision,
    String remoteText,
  )?
  onSnapshotDivergence;

  void updateDisplayName(String name) {
    _displayName = name;
  }

  bool _requiresSessionToken(String type) {
    return type == MessageTypes.docSnapshot ||
        type == MessageTypes.docUpdate ||
        type == MessageTypes.docCreate ||
        type == MessageTypes.docRename ||
        type == MessageTypes.docCatalog ||
        type == MessageTypes.docReorder ||
        type == MessageTypes.docDelete ||
        type == MessageTypes.peerDisconnect ||
        type == MessageTypes.presence ||
        type == MessageTypes.ping ||
        type == MessageTypes.pong;
  }

  ProtocolMessage _messageForConnection(
    String connectionId,
    ProtocolMessage message,
  ) {
    if (!_requiresSessionToken(message.type)) return message;

    final peerId = _connectionToPeerId[connectionId];
    final token = peerId == null ? null : _linksByPeerId[peerId]?.sessionToken;
    if (token == null || token.isEmpty) return message;

    return ProtocolMessage(
      type: message.type,
      payload: {...message.payload, 'sessionToken': token},
    );
  }

  bool _hasValidSessionToken(String connectionId, ProtocolMessage message) {
    final peerId = _connectionToPeerId[connectionId];
    if (peerId == null) return false;

    final link = _linksByPeerId[peerId];
    if (link == null || !link.authenticated) return false;

    final expectedToken = link.sessionToken;
    final actualToken = message.payload['sessionToken'] as String?;
    return expectedToken != null &&
        expectedToken.isNotEmpty &&
        actualToken == expectedToken;
  }

  Iterable<String> _authenticatedConnectionIds({
    String? exceptConnectionId,
    String? exceptPeerId,
  }) {
    return authenticatedConnectionIds(
      links: _syncPeerLinks(),
      exceptConnectionId: exceptConnectionId,
      exceptPeerId: exceptPeerId,
    );
  }

  Iterable<SyncPeerLink> _syncPeerLinks() sync* {
    for (final link in _linksByPeerId.values) {
      yield SyncPeerLink(
        peerId: link.peerId,
        authenticated: link.authenticated,
        inboundConnectionId: link.inboundConnectionId,
        outboundConnectionId: link.outboundConnectionId,
      );
    }
  }

  Future<void> connectAndRequestPair(Peer peer) async {
    if (_trustStore.isBlocked(peer.id)) {
      throw StateError('${peer.displayName} is blocked. Unblock it to connect.');
    }
    final existing = _linksByPeerId[peer.id];
    if (existing?.authenticated == true) {
      throw StateError('Already connected to ${peer.displayName}.');
    }
    if (existing?.outboundSocket != null) {
      throw StateError('Already connecting to ${peer.displayName}.');
    }

    final refreshed = peer.isManual
        ? peer
        : await _discovery.refreshPeerForConnect(peer.id) ?? peer;
    final host = await PeerHostResolver.resolveConnectHost(refreshed);
    if (host == null) {
      throw StateError(
        'Peer ${peer.displayName} has no resolved address. '
        'On Linux, ensure Avahi is running and both devices are on the same subnet.',
      );
    }
    _discovery.markPeerConnecting(peer.id);
    final requestId = const Uuid().v4();
    final hostInUri = PeerHostResolver.formatForWebSocket(host);
    final uri = Uri.parse('wss://$hostInUri:${refreshed.port}/ws');

    final httpClient = HttpClient(
      context: SecurityContext(withTrustedRoots: false),
    );
    String? capturedFingerprint;
    var pinMismatch = false;
    httpClient.badCertificateCallback = (cert, certHost, certPort) {
      final fingerprint = fingerprintFromDer(cert.der);
      final pinned = _trustStore.pinnedFingerprint(peer.id);
      if (pinned != null && pinned != fingerprint) {
        pinMismatch = true;
        return false;
      }
      capturedFingerprint = fingerprint;
      return true;
    };

    final WebSocket socket;
    try {
      socket = await WebSocket.connect(
        uri.toString(),
        customClient: httpClient,
      ).timeout(
        _connectTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Timed out reaching ${peer.displayName} at $hostInUri:${refreshed.port}',
          );
        },
      );
    } catch (e) {
      httpClient.close(force: true);
      _discovery.markPeerDisconnected(peer.id);
      if (pinMismatch) {
        throw StateError(
          'Certificate for ${peer.displayName} does not match the pinned one. '
          'Possible impersonation — connection refused.',
        );
      }
      rethrow;
    }

    final connectionId = 'out_${peer.id}';
    _pendingOutboundRequestId[connectionId] = requestId;

    final link = _linksByPeerId[peer.id] ??
        _PeerLink(peerId: peer.id, displayName: peer.displayName);
    link.outboundConnectionId = connectionId;
    link.outboundSocket = socket;
    link.pendingCertFingerprint = capturedFingerprint;
    _linksByPeerId[peer.id] = link;
    _connectionToPeerId[connectionId] = peer.id;

    link.outboundSub = socket.listen(
      (data) {
        if (data is String) {
          final msg = ProtocolCodec.decode(data);
          if (msg != null) _handleMessage(connectionId, msg, isOutbound: true);
        }
      },
      onDone: () => _handleDisconnect(connectionId),
      onError: (_) => _handleDisconnect(connectionId),
      cancelOnError: true,
    );

    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.pairRequest,
        payload: {
          'requestId': requestId,
          'fromId': instanceId,
          'fromName': _displayName,
          'protocolVersion': kProtocolVersion,
        },
      ),
    );
    _startPairingTimeout(connectionId, peer.id, peer.displayName);

    final verificationCode = peer.isManual
        ? null
        : PairingVerificationCode.generate(instanceId, peer.id);
    _connectionLog.add(
      verificationCode == null
          ? 'Pairing request sent to ${peer.displayName}'
          : 'Pairing request sent to ${peer.displayName} (code $verificationCode)',
      peerId: peer.id,
      peerName: peer.displayName,
    );
  }

  void respondToPairRequest({
    required String connectionId,
    required String requestId,
    required String fromId,
    required String fromName,
    required bool accepted,
  }) {
    if (accepted) {
      final token = const Uuid().v4();
      final link = _linksByPeerId[fromId] ??
          _PeerLink(peerId: fromId, displayName: fromName);
      link.inboundConnectionId = connectionId;
      link.sessionToken = token;
      link.authenticated = true;
      _linksByPeerId[fromId] = link;
      _connectionToPeerId[connectionId] = fromId;
      _cancelPairingTimeoutForPeer(fromId);

      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {
            'requestId': requestId,
            'accepted': true,
            'protocolVersion': kProtocolVersion,
          },
        ),
      );
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairComplete,
          payload: {'sessionToken': token},
        ),
      );

      _discovery.markPeerConnected(
        Peer(
          id: fromId,
          displayName: fromName,
          port: _discovery.serverPort ?? 0,
          connectionState: PeerConnectionState.connected,
        ),
      );
      _connectionLog.add(
        'Accepted pairing with $fromName',
        peerId: fromId,
        peerName: fromName,
      );
      _sendDocSnapshot(connectionId);
      _startHeartbeat(fromId);
    } else {
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {'requestId': requestId, 'accepted': false},
        ),
      );
      _connectionLog.add(
        'Rejected pairing with $fromName',
        peerId: fromId,
        peerName: fromName,
      );
      unawaited(_server.closeConnection(connectionId));
    }
  }

  void broadcastDocUpdate(
    String docId,
    String title,
    int revision,
    String text,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docUpdate,
      payload: {
        'docId': docId,
        'title': title,
        'revision': revision,
        'text': text,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocCreate(
    String docId,
    String title,
    int revision,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docCreate,
      payload: {
        'docId': docId,
        'title': title,
        'revision': revision,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocRename(
    String docId,
    String title,
    int revision,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docRename,
      payload: {
        'docId': docId,
        'title': title,
        'revision': revision,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocReorder(
    List<String> order,
    int orderRevision,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docReorder,
      payload: {
        'originId': originId,
        'orderRevision': orderRevision,
        'order': order,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocDelete(String docId, String originId) {
    final message = ProtocolMessage(
      type: MessageTypes.docDelete,
      payload: {'docId': docId, 'originId': originId},
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastPresence(String docId, int line, int column) {
    if (_linksByPeerId.isEmpty) return;
    final message = ProtocolMessage(
      type: MessageTypes.presence,
      payload: {
        'peerId': instanceId,
        'name': _displayName,
        'docId': docId,
        'line': line,
        'column': column,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void disconnectPeer(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;

    _stopHeartbeat(link);
    final message = ProtocolMessage(
      type: MessageTypes.peerDisconnect,
      payload: {'peerId': instanceId},
    );

    if (link.inboundConnectionId != null) {
      _sendOnConnection(link.inboundConnectionId!, message);
      unawaited(_server.closeConnection(link.inboundConnectionId!));
    }
    if (link.outboundSocket != null) {
      _sendOnConnection(link.outboundConnectionId!, message);
      unawaited(link.outboundSocket?.close());
    }

    if (link.inboundConnectionId != null) {
      _connectionToPeerId.remove(link.inboundConnectionId);
    }
    if (link.outboundConnectionId != null) {
      _connectionToPeerId.remove(link.outboundConnectionId);
    }

    _linksByPeerId.remove(peerId);
    _presence.remove(peerId);
    _discovery.markPeerDisconnected(peerId);
    _connectionLog.add(
      'Disconnected from ${link.displayName}',
      peerId: peerId,
      peerName: link.displayName,
    );
    notifyListeners();
  }

  void _onInboundMessage(String connectionId, ProtocolMessage message) {
    _handleMessage(connectionId, message, isOutbound: false);
  }

  void _onInboundClosed(String connectionId) {
    _handleDisconnect(connectionId);
  }

  void _handleMessage(
    String connectionId,
    ProtocolMessage message, {
    required bool isOutbound,
  }) {
    switch (message.type) {
      case MessageTypes.pairRequest:
        final requestId = message.payload['requestId'] as String? ?? '';
        final fromId = message.payload['fromId'] as String? ?? '';
        final fromName = message.payload['fromName'] as String? ?? 'Unknown';
        final peerProtocol = message.payload['protocolVersion'] as int? ?? 1;
        _connectionToPeerId[connectionId] = fromId;
        if (_trustStore.isBlocked(fromId)) {
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.pairResponse,
              payload: {'requestId': requestId, 'accepted': false},
            ),
          );
          _connectionLog.add(
            'Refused blocked peer $fromName',
            peerId: fromId,
            peerName: fromName,
          );
          unawaited(_server.closeConnection(connectionId));
          return;
        }
        if (peerProtocol != kProtocolVersion) {
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.pairResponse,
              payload: {
                'requestId': requestId,
                'accepted': false,
                'protocolVersion': kProtocolVersion,
                'reason': 'protocol_mismatch',
              },
            ),
          );
          _connectionLog.add(
            'Refused $fromName: protocol v$peerProtocol '
            '(requires v$kProtocolVersion)',
            peerId: fromId,
            peerName: fromName,
          );
          unawaited(_server.closeConnection(connectionId));
          return;
        }
        final existingLink = _linksByPeerId[fromId];
        if (existingLink?.authenticated == true) {
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.pairResponse,
              payload: {
                'requestId': requestId,
                'accepted': false,
                'reason': 'already_connected',
              },
            ),
          );
          _connectionLog.add(
            'Refused duplicate pairing from $fromName (already connected)',
            peerId: fromId,
            peerName: fromName,
          );
          unawaited(_server.closeConnection(connectionId));
          return;
        }
        final outboundId = existingLink?.outboundConnectionId;
        if (outboundId != null &&
            _pendingOutboundRequestId.containsKey(outboundId) &&
            existingLink?.outboundSocket != null) {
          if (outboundPairingWins(instanceId, fromId)) {
            _sendOnConnection(
              connectionId,
              ProtocolMessage(
                type: MessageTypes.pairResponse,
                payload: {
                  'requestId': requestId,
                  'accepted': false,
                  'reason': 'simultaneous_connect',
                },
              ),
            );
            _connectionLog.add(
              'Declined inbound pairing from $fromName '
              '(outbound request in progress)',
              peerId: fromId,
              peerName: fromName,
            );
            unawaited(_server.closeConnection(connectionId));
            return;
          }
          _connectionLog.add(
            'Dropped outbound pairing to $fromName (accepting their request)',
            peerId: fromId,
            peerName: fromName,
          );
          _abandonOutbound(fromId);
        }
        onIncomingPairRequest?.call(fromId, fromName, requestId, connectionId);
      case MessageTypes.pairResponse:
        final accepted = message.payload['accepted'] as bool? ?? false;
        final peerId = _connectionToPeerId[connectionId];
        if (peerId != null) {
          final peerName = _discovery.peerById(peerId)?.displayName ?? peerId;
          if (accepted) {
            final peerProtocol =
                message.payload['protocolVersion'] as int? ?? 1;
            if (peerProtocol != kProtocolVersion) {
              _connectionLog.add(
                'Pairing failed with $peerName: protocol v$peerProtocol '
                '(requires v$kProtocolVersion)',
                peerId: peerId,
                peerName: peerName,
              );
              onPairRequestResolved?.call(peerId, false);
              _cleanupConnection(connectionId);
              _pendingOutboundRequestId.remove(connectionId);
              return;
            }
          }
          _connectionLog.add(
            accepted
                ? 'Pairing accepted by $peerName'
                : 'Pairing rejected by $peerName'
                    '${message.payload['reason'] != null ? ' (${message.payload['reason']})' : ''}',
            peerId: peerId,
            peerName: peerName,
          );
          onPairRequestResolved?.call(peerId, accepted);
          if (!accepted) {
            _cleanupConnection(connectionId);
          } else {
            _startPairingTimeout(connectionId, peerId, peerName);
          }
        }
        _pendingOutboundRequestId.remove(connectionId);
      case MessageTypes.pairComplete:
        final token = message.payload['sessionToken'] as String? ?? '';
        final peerId = _connectionToPeerId[connectionId];
        if (peerId == null || token.isEmpty) return;
        _cancelPairingTimeout(connectionId);

        final link = _linksByPeerId[peerId] ??
            _PeerLink(
              peerId: peerId,
              displayName:
                  _discovery.peerById(peerId)?.displayName ?? peerId,
            );
        link.sessionToken = token;
        link.authenticated = true;
        if (isOutbound) {
          link.outboundConnectionId = connectionId;
        } else {
          link.inboundConnectionId = connectionId;
        }
        _linksByPeerId[peerId] = link;

        final peer = _discovery.peerById(peerId);
        if (peer != null) {
          _discovery.markPeerConnected(peer);
        }
        // TOFU: pin the server cert we saw when we initiated this connection.
        if (isOutbound && link.pendingCertFingerprint != null) {
          final fingerprint = link.pendingCertFingerprint!;
          final isNew = !_trustStore.hasPin(peerId);
          unawaited(_trustStore.pin(peerId, fingerprint));
          _connectionLog.add(
            '${isNew ? 'Pinned' : 'Verified'} ${link.displayName} security code '
            '${shortFingerprint(fingerprint)}',
            peerId: peerId,
            peerName: link.displayName,
          );
        }
        _connectionLog.add(
          'Pairing complete with ${link.displayName}',
          peerId: peerId,
          peerName: link.displayName,
        );
        _sendDocSnapshot(connectionId);
        _startHeartbeat(peerId);
      case MessageTypes.docSnapshot:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        unawaited(_handleSnapshot(message, connectionId));
      case MessageTypes.docUpdate:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        unawaited(_handleDocMessage(message, connectionId));
      case MessageTypes.docCreate:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        _handleDocCreate(message, connectionId);
      case MessageTypes.docRename:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        _handleDocRename(message, connectionId);
      case MessageTypes.docCatalog:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        _handleDocCatalog(message, connectionId);
      case MessageTypes.docReorder:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        _handleDocReorder(message, connectionId);
      case MessageTypes.docDelete:
        if (!_hasValidSessionToken(connectionId, message)) {
          _logTokenRejected(connectionId, message.type);
          return;
        }
        final docId = message.payload['docId'] as String? ?? '';
        if (docId.isNotEmpty) {
          if (!_workspace.shouldIgnoreInboundSync(docId)) {
            _workspace.removeDocumentRemote(docId);
            _relay(message, connectionId);
          }
        }
      case MessageTypes.peerDisconnect:
        if (!_hasValidSessionToken(connectionId, message)) {
          final peerId = _connectionToPeerId[connectionId];
          _connectionLog.add(
            'Rejected disconnect: invalid session token',
            peerId: peerId,
            peerName: peerId == null
                ? null
                : _linksByPeerId[peerId]?.displayName,
          );
          return;
        }
        final remoteId = message.payload['peerId'] as String? ?? '';
        if (remoteId.isNotEmpty) {
          _handleDisconnectByPeerId(remoteId);
        }
      case MessageTypes.presence:
        if (!_hasValidSessionToken(connectionId, message)) return;
        _handlePresence(message);
      case MessageTypes.ping:
        if (!_hasValidSessionToken(connectionId, message)) return;
        _handlePing(message, connectionId);
      case MessageTypes.pong:
        if (!_hasValidSessionToken(connectionId, message)) return;
        _handlePong(connectionId);
      default:
        break;
    }
  }

  void _handlePresence(ProtocolMessage message) {
    final peerId = message.payload['peerId'] as String? ?? '';
    if (peerId.isEmpty || peerId == instanceId) return;
    final line = message.payload['line'] as int? ?? 1;
    final column = message.payload['column'] as int? ?? 1;
    final docId = message.payload['docId'] as String?;
    final docTitle = docId == null
        ? null
        : _workspace.documentById(docId)?.title;
    _presence[peerId] = PeerPresence(
      line: line,
      column: column,
      updatedAt: DateTime.now(),
      docId: docId,
      docTitle: docTitle,
    );
    notifyListeners();
  }

  void _logTokenRejected(String connectionId, String type) {
    final peerId = _connectionToPeerId[connectionId];
    _connectionLog.add(
      'Rejected $type: invalid session token',
      peerId: peerId,
      peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
    );
  }

  /// Handles a document snapshot received at pair/reconnect time. If the local
  /// note has diverged from the peer's, prompt the user (on one deterministic
  /// side) instead of silently merging.
  Future<void> _handleSnapshot(
    ProtocolMessage message,
    String fromConnectionId,
  ) async {
    final revision = message.payload['revision'] as int? ?? 0;
    final text = message.payload['text'] as String? ?? '';
    final originId = message.payload['originId'] as String? ?? '';
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    if (docId.isEmpty) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;
    final document = _workspace.ensureDocument(docId, title: title);
    final localText = document.text;

    final diverged = noteTextsDiverged(localText, text);

    // Only the lexicographically-smaller instance prompts, so both devices
    // converge on one decision instead of fighting.
    final shouldPrompt =
        diverged &&
        onSnapshotDivergence != null &&
        !_divergencePromptActive &&
        isReconnectDivergencePromptDevice(
          localInstanceId: instanceId,
          remoteOriginId: originId,
          localText: localText,
          remoteText: text,
        );

    if (!shouldPrompt) {
      unawaited(_handleDocMessage(message, fromConnectionId));
      return;
    }

    final peerId = _connectionToPeerId[fromConnectionId];
    final peerName = peerId == null
        ? 'peer'
        : (_linksByPeerId[peerId]?.displayName ?? 'peer');

    _divergencePromptActive = true;
    final DivergenceChoice choice;
    try {
      choice = await onSnapshotDivergence!(
        peerName,
        document.title,
        document.revision,
        localText,
        revision,
        text,
      );
    } finally {
      _divergencePromptActive = false;
    }

    if (choice == DivergenceChoice.takeTheirs) {
      document.forceApplyRemote(revision: revision, text: text, title: title);
      _relay(message, fromConnectionId);
      _connectionLog.add(
        'Reconnect divergence: used $peerName\'s version',
        peerId: peerId,
        peerName: peerName,
        revision: revision,
      );
    } else {
      document.bumpAndBroadcast(revision);
      _connectionLog.add(
        'Reconnect divergence: kept local version',
        peerId: peerId,
        peerName: peerName,
      );
    }
  }

  Future<void> _handleDocMessage(
    ProtocolMessage message,
    String fromConnectionId,
  ) async {
    final revision = message.payload['revision'] as int? ?? 0;
    final text = message.payload['text'] as String? ?? '';
    final originId = message.payload['originId'] as String? ?? '';
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    if (docId.isEmpty) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;

    final document = _workspace.documentById(docId);
    final shouldPrompt =
        document != null &&
        document.isLiveEditConflict(
          revision: revision,
          text: text,
          originId: originId,
        ) &&
        onLiveConflict != null &&
        !_liveConflictPromptActive &&
        instanceId.compareTo(originId) < 0;

    if (shouldPrompt) {
      final peerId = _connectionToPeerId[fromConnectionId];
      final peerName = peerId == null
          ? 'peer'
          : (_linksByPeerId[peerId]?.displayName ?? 'peer');

      _liveConflictPromptActive = true;
      final DivergenceChoice choice;
      try {
        choice = await onLiveConflict!(
          peerName,
          document.title,
          revision,
          document.text,
          text,
        );
      } finally {
        _liveConflictPromptActive = false;
      }

      if (choice == DivergenceChoice.takeTheirs) {
        document.forceApplyRemote(
          revision: revision,
          text: text,
          title: title,
        );
        _connectionLog.add(
          'Live conflict: used $peerName\'s version',
          peerId: peerId,
          peerName: peerName,
          revision: revision,
        );
        _relay(message, fromConnectionId);
      } else {
        document.bumpAndBroadcast(revision);
        _connectionLog.add(
          'Live conflict: kept local version',
          peerId: peerId,
          peerName: peerName,
        );
      }
      return;
    }

    final applied = _workspace.receiveRemoteContent(
      docId: docId,
      title: title,
      revision: revision,
      text: text,
      originId: originId,
    );
    if (applied) {
      final peerId = _connectionToPeerId[fromConnectionId];
      final peerName = peerId == null
          ? null
          : _linksByPeerId[peerId]?.displayName;
      _connectionLog.add(
        'Applied ${message.type} revision $revision',
        peerId: peerId,
        peerName: peerName,
        revision: revision,
      );
      _relay(message, fromConnectionId);
    }
  }

  void _handleDocCreate(ProtocolMessage message, String fromConnectionId) {
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    final revision = message.payload['revision'] as int? ?? 0;
    final originId = message.payload['originId'] as String? ?? '';
    if (docId.isEmpty || originId == instanceId) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;

    final existed = _workspace.hasDocument(docId);
    _workspace.receiveRemoteCreate(
      docId: docId,
      title: title,
      revision: revision,
      originId: originId,
    );

    final peerId = _connectionToPeerId[fromConnectionId];
    _connectionLog.add(
      existed ? 'Updated note "$title"' : 'Learned new note "$title"',
      peerId: peerId,
      peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
      revision: revision,
    );
    _relay(message, fromConnectionId);
  }

  void _handleDocRename(ProtocolMessage message, String fromConnectionId) {
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    final revision = message.payload['revision'] as int? ?? 0;
    final originId = message.payload['originId'] as String? ?? '';
    if (docId.isEmpty || originId == instanceId) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;

    final before = _workspace.documentById(docId)?.title;
    _workspace.receiveRemoteRename(
      docId: docId,
      title: title,
      revision: revision,
      originId: originId,
    );
    final after = _workspace.documentById(docId)?.title;
    if (before != after) {
      final peerId = _connectionToPeerId[fromConnectionId];
      _connectionLog.add(
        'Renamed note to "$title"',
        peerId: peerId,
        peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
        revision: revision,
      );
      _relay(message, fromConnectionId);
    }
  }

  void _handleDocCatalog(ProtocolMessage message, String fromConnectionId) {
    final originId = message.payload['originId'] as String? ?? '';
    if (originId.isEmpty || originId == instanceId) return;

    final rawNotes = message.payload['notes'] as List<dynamic>? ?? const [];
    final entries = [
      for (final n in rawNotes) Map<String, dynamic>.from(n as Map),
    ];
    final orderRevision = message.payload['orderRevision'] as int? ?? 0;
    final beforeCount = _workspace.documents.length;
    final beforeOrder = _workspace.noteOrder;
    _workspace.mergeCatalog(
      entries,
      originId,
      orderRevision: orderRevision,
    );
    final afterCount = _workspace.documents.length;
    final afterOrder = _workspace.noteOrder;
    if (afterCount > beforeCount || !_ordersEqual(beforeOrder, afterOrder)) {
      final peerId = _connectionToPeerId[fromConnectionId];
      _connectionLog.add(
        afterCount > beforeCount
            ? 'Synced ${afterCount - beforeCount} note(s) from peer catalog'
            : 'Synced note order from peer catalog',
        peerId: peerId,
        peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
      );
    }
    _relay(message, fromConnectionId);
  }

  void _handleDocReorder(ProtocolMessage message, String fromConnectionId) {
    final originId = message.payload['originId'] as String? ?? '';
    if (originId.isEmpty || originId == instanceId) return;

    final orderRevision = message.payload['orderRevision'] as int? ?? 0;
    final rawOrder = message.payload['order'] as List<dynamic>? ?? const [];
    final order = [for (final id in rawOrder) id as String];
    if (_workspace.applyRemoteOrder(order, orderRevision, originId)) {
      final peerId = _connectionToPeerId[fromConnectionId];
      _connectionLog.add(
        'Synced note order from peer',
        peerId: peerId,
        peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
      );
      _relay(message, fromConnectionId);
    }
  }

  bool _ordersEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _relay(ProtocolMessage message, String fromConnectionId) {
    for (final connId in relayConnectionTargets(
      links: _syncPeerLinks(),
      connectionToPeerId: _connectionToPeerId,
      fromConnectionId: fromConnectionId,
    )) {
      _sendOnConnection(connId, message);
    }
  }

  void _sendDocSnapshot(String connectionId) {
    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.docCatalog,
        payload: {
          'originId': instanceId,
          'orderRevision': _workspace.orderRevision,
          'notes': _workspace.catalogPayload(),
        },
      ),
    );
    for (final doc in _workspace.documents) {
      if (!_workspace.isSyncEnabled(doc.id)) continue;
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.docSnapshot,
          payload: doc.snapshotPayload(),
        ),
      );
    }
  }

  void _fanOut(
    ProtocolMessage message, {
    String? exceptConnectionId,
    String? exceptPeerId,
  }) {
    for (final connId in _authenticatedConnectionIds(
      exceptConnectionId: exceptConnectionId,
      exceptPeerId: exceptPeerId,
    )) {
      _sendOnConnection(connId, message);
    }
  }

  void _sendOnConnection(String connectionId, ProtocolMessage message) {
    final outboundMessage = _messageForConnection(connectionId, message);
    if (connectionId.startsWith('out_')) {
      final peerId = _connectionToPeerId[connectionId];
      final socket = peerId != null
          ? _linksByPeerId[peerId]?.outboundSocket
          : null;
      if (socket != null && socket.readyState == WebSocket.open) {
        socket.add(ProtocolCodec.encode(outboundMessage));
      }
    } else {
      _server.send(connectionId, outboundMessage);
    }
  }

  void _handleDisconnect(String connectionId) {
    final peerId = _connectionToPeerId.remove(connectionId);
    _cancelPairingTimeout(connectionId);
    if (peerId == null) return;
    final link = _linksByPeerId[peerId];
    if (link == null) return;

    final wasPending = !link.authenticated;
    if (link.inboundConnectionId == connectionId) {
      link.inboundConnectionId = null;
    }
    if (link.outboundConnectionId == connectionId) {
      link.outboundConnectionId = null;
      unawaited(link.outboundSub?.cancel());
      link.outboundSocket = null;
      _pendingOutboundRequestId.remove(connectionId);
    }

    if (link.inboundConnectionId == null && link.outboundSocket == null) {
      _stopHeartbeat(link);
      _linksByPeerId.remove(peerId);
      _presence.remove(peerId);
      _discovery.markPeerDisconnected(peerId);
      if (wasPending) {
        _connectionLog.add(
          'Pairing interrupted with ${link.displayName}',
          peerId: peerId,
          peerName: link.displayName,
        );
      }
      notifyListeners();
    }
  }

  void _handleDisconnectByPeerId(String peerId) {
    disconnectPeer(peerId);
  }

  void _cleanupConnection(String connectionId) {
    _cancelPairingTimeout(connectionId);
    final peerId = _connectionToPeerId.remove(connectionId);
    if (peerId != null) {
      final link = _linksByPeerId.remove(peerId);
      if (link != null) _stopHeartbeat(link);
      _presence.remove(peerId);
      unawaited(link?.outboundSub?.cancel());
      unawaited(link?.outboundSocket?.close());
      _discovery.markPeerDisconnected(peerId);
      notifyListeners();
    }
    _pendingOutboundRequestId.remove(connectionId);
    if (connectionId.startsWith('out_')) {
      return;
    }
    unawaited(_server.closeConnection(connectionId));
  }

  void _startPairingTimeout(
    String connectionId,
    String peerId,
    String peerName,
  ) {
    _cancelPairingTimeout(connectionId);
    _pairingTimeouts[connectionId] = Timer(_pairingTimeout, () {
      _pairingTimeouts.remove(connectionId);
      final link = _linksByPeerId[peerId];
      if (link == null || link.authenticated) return;
      _connectionLog.add(
        'Pairing timed out with $peerName',
        peerId: peerId,
        peerName: peerName,
      );
      onPairRequestResolved?.call(peerId, false);
      _cleanupConnection(connectionId);
    });
  }

  void _cancelPairingTimeout(String connectionId) {
    _pairingTimeouts.remove(connectionId)?.cancel();
  }

  void _cancelPairingTimeoutForPeer(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;
    if (link.inboundConnectionId != null) {
      _cancelPairingTimeout(link.inboundConnectionId!);
    }
    if (link.outboundConnectionId != null) {
      _cancelPairingTimeout(link.outboundConnectionId!);
    }
  }

  void _abandonOutbound(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;

    final outId = link.outboundConnectionId;
    if (outId != null) {
      _cancelPairingTimeout(outId);
      _pendingOutboundRequestId.remove(outId);
      _connectionToPeerId.remove(outId);
    }
    unawaited(link.outboundSub?.cancel());
    link.outboundSub = null;
    unawaited(link.outboundSocket?.close());
    link.outboundSocket = null;
    link.outboundConnectionId = null;
    link.pendingCertFingerprint = null;

    if (link.inboundConnectionId == null && !link.authenticated) {
      _linksByPeerId.remove(peerId);
      _discovery.markPeerDisconnected(peerId);
      notifyListeners();
    }
  }

  void _startHeartbeat(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null || !link.authenticated) return;
    _stopHeartbeat(link);
    link.lastPongAt = DateTime.now();
    link.heartbeatTimer = Timer.periodic(kHeartbeatInterval, (_) {
      _tickHeartbeat(peerId);
    });
  }

  void _stopHeartbeat(_PeerLink link) {
    link.heartbeatTimer?.cancel();
    link.heartbeatTimer = null;
  }

  void _tickHeartbeat(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null || !link.authenticated) return;

    final last = link.lastPongAt;
    if (last != null &&
        DateTime.now().difference(last) > kHeartbeatTimeout) {
      _connectionLog.add(
        'Peer unresponsive (heartbeat timeout)',
        peerId: peerId,
        peerName: link.displayName,
      );
      disconnectPeer(peerId);
      return;
    }

    final message = ProtocolMessage(
      type: MessageTypes.ping,
      payload: {
        'peerId': instanceId,
        'sentAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
    if (link.inboundConnectionId != null) {
      _sendOnConnection(link.inboundConnectionId!, message);
    }
    if (link.outboundConnectionId != null) {
      _sendOnConnection(link.outboundConnectionId!, message);
    }
  }

  void _handlePing(ProtocolMessage message, String connectionId) {
    final peerId = _connectionToPeerId[connectionId];
    if (peerId == null) return;
    final link = _linksByPeerId[peerId];
    if (link == null) return;
    link.lastPongAt = DateTime.now();
    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.pong,
        payload: {
          'peerId': instanceId,
          'sentAt': DateTime.now().millisecondsSinceEpoch,
        },
      ),
    );
  }

  void _handlePong(String connectionId) {
    final peerId = _connectionToPeerId[connectionId];
    if (peerId == null) return;
    final link = _linksByPeerId[peerId];
    if (link == null) return;
    link.lastPongAt = DateTime.now();
  }
}
