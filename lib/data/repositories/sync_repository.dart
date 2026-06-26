import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/models/divergence_choice.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/models/peer_presence.dart';
import 'package:netpad/core/models/protocol_message.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
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
    this.inboundConnectionId,
    this.outboundConnectionId,
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
}

class SyncRepository extends ChangeNotifier {
  SyncRepository({
    required this.instanceId,
    required String displayName,
    required LocalServer localServer,
    required DiscoveryRepository discovery,
    required DocumentRepository document,
    required ConnectionLogRepository connectionLog,
    required TrustStore trustStore,
  }) : _displayName = displayName,
       _server = localServer,
       _discovery = discovery,
       _document = document,
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
  final DocumentRepository _document;
  final ConnectionLogRepository _connectionLog;
  final TrustStore _trustStore;

  bool _divergencePromptActive = false;

  final Map<String, _PeerLink> _linksByPeerId = {};
  final Map<String, String> _connectionToPeerId = {};
  final Map<String, String> _pendingOutboundRequestId = {};
  final Map<String, PeerPresence> _presence = {};

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
  void Function()? onConflictMerged;

  /// Asked when a reconnecting peer's note diverges from the local one.
  Future<DivergenceChoice> Function(
    String peerName,
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
        type == MessageTypes.peerDisconnect ||
        type == MessageTypes.presence;
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
  }) sync* {
    for (final link in _linksByPeerId.values) {
      if (!link.authenticated) continue;
      if (link.peerId == exceptPeerId) continue;

      final inbound = link.inboundConnectionId;
      if (inbound != null && inbound != exceptConnectionId) {
        yield inbound;
      }

      final outbound = link.outboundConnectionId;
      if (outbound != null && outbound != exceptConnectionId) {
        yield outbound;
      }
    }
  }

  Future<void> connectAndRequestPair(Peer peer) async {
    if (_trustStore.isBlocked(peer.id)) {
      throw StateError('${peer.displayName} is blocked. Unblock it to connect.');
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

    // Pin the server certificate (TOFU): accept any cert the first time and
    // remember its fingerprint; afterwards require it to match the pin.
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
      socket = await WebSocket.connect(uri.toString(), customClient: httpClient);
    } catch (e) {
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

    final link = _PeerLink(
      peerId: peer.id,
      displayName: peer.displayName,
      outboundConnectionId: connectionId,
    );
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
        },
      ),
    );
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
      final link = _PeerLink(
        peerId: fromId,
        displayName: fromName,
        inboundConnectionId: connectionId,
      );
      link.sessionToken = token;
      link.authenticated = true;
      _linksByPeerId[fromId] = link;
      _connectionToPeerId[connectionId] = fromId;

      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {'requestId': requestId, 'accepted': true},
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

  void broadcastDocUpdate(int revision, String text, String originId) {
    final message = ProtocolMessage(
      type: MessageTypes.docUpdate,
      payload: {'revision': revision, 'text': text, 'originId': originId},
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastPresence(int line, int column) {
    if (_linksByPeerId.isEmpty) return;
    final message = ProtocolMessage(
      type: MessageTypes.presence,
      payload: {
        'peerId': instanceId,
        'name': _displayName,
        'line': line,
        'column': column,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void disconnectPeer(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;

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
        onIncomingPairRequest?.call(fromId, fromName, requestId, connectionId);
      case MessageTypes.pairResponse:
        final accepted = message.payload['accepted'] as bool? ?? false;
        final peerId = _connectionToPeerId[connectionId];
        if (peerId != null) {
          final peerName = _discovery.peerById(peerId)?.displayName ?? peerId;
          _connectionLog.add(
            accepted
                ? 'Pairing accepted by $peerName'
                : 'Pairing rejected by $peerName',
            peerId: peerId,
            peerName: peerName,
          );
          onPairRequestResolved?.call(peerId, accepted);
          if (!accepted) {
            _cleanupConnection(connectionId);
          }
        }
        _pendingOutboundRequestId.remove(connectionId);
      case MessageTypes.pairComplete:
        final token = message.payload['sessionToken'] as String? ?? '';
        final peerId = _connectionToPeerId[connectionId];
        if (peerId == null) return;
        var link = _linksByPeerId[peerId];
        link ??= _PeerLink(
          peerId: peerId,
          displayName: _discovery.peerById(peerId)?.displayName ?? peerId,
          outboundConnectionId: isOutbound ? connectionId : null,
          inboundConnectionId: isOutbound ? null : connectionId,
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
        _handleDocMessage(message, connectionId);
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
      default:
        break;
    }
  }

  void _handlePresence(ProtocolMessage message) {
    final peerId = message.payload['peerId'] as String? ?? '';
    if (peerId.isEmpty || peerId == instanceId) return;
    final line = message.payload['line'] as int? ?? 1;
    final column = message.payload['column'] as int? ?? 1;
    _presence[peerId] = PeerPresence(
      line: line,
      column: column,
      updatedAt: DateTime.now(),
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
    final localText = _document.text;

    final diverged =
        text != localText &&
        localText.trim().isNotEmpty &&
        text.trim().isNotEmpty;

    // Only the lexicographically-smaller instance prompts, so both devices
    // converge on one decision instead of fighting.
    final shouldPrompt =
        diverged &&
        onSnapshotDivergence != null &&
        !_divergencePromptActive &&
        instanceId.compareTo(originId) < 0;

    if (!shouldPrompt) {
      _handleDocMessage(message, fromConnectionId);
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
        _document.revision,
        localText,
        revision,
        text,
      );
    } finally {
      _divergencePromptActive = false;
    }

    if (choice == DivergenceChoice.takeTheirs) {
      _document.forceApplyRemote(revision: revision, text: text);
      _relay(message, fromConnectionId);
      _connectionLog.add(
        'Reconnect divergence: used $peerName\'s version',
        peerId: peerId,
        peerName: peerName,
        revision: revision,
      );
    } else {
      _document.bumpAndBroadcast(revision);
      _connectionLog.add(
        'Reconnect divergence: kept local version',
        peerId: peerId,
        peerName: peerName,
      );
    }
  }

  void _handleDocMessage(ProtocolMessage message, String fromConnectionId) {
    final revision = message.payload['revision'] as int? ?? 0;
    final text = message.payload['text'] as String? ?? '';
    final originId = message.payload['originId'] as String? ?? '';

    final hadConflict = revision == _document.revision;
    final applied = _document.applyRemote(
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
      if (hadConflict && originId != instanceId) {
        onConflictMerged?.call();
      }
      _relay(message, fromConnectionId);
    }
  }

  void _relay(ProtocolMessage message, String fromConnectionId) {
    final fromPeerId = _connectionToPeerId[fromConnectionId];
    for (final connId in _authenticatedConnectionIds(
      exceptConnectionId: fromConnectionId,
      exceptPeerId: fromPeerId,
    )) {
      _sendOnConnection(connId, message);
    }
  }

  void _sendDocSnapshot(String connectionId) {
    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.docSnapshot,
        payload: _document.snapshotPayload(),
      ),
    );
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
    if (peerId == null) return;
    final link = _linksByPeerId[peerId];
    if (link == null) return;

    if (link.inboundConnectionId == connectionId) {
      link.inboundConnectionId = null;
    }
    if (link.outboundConnectionId == connectionId) {
      link.outboundConnectionId = null;
      unawaited(link.outboundSub?.cancel());
      link.outboundSocket = null;
    }

    if (link.inboundConnectionId == null && link.outboundSocket == null) {
      _linksByPeerId.remove(peerId);
      _presence.remove(peerId);
      _discovery.markPeerDisconnected(peerId);
      notifyListeners();
    }
  }

  void _handleDisconnectByPeerId(String peerId) {
    disconnectPeer(peerId);
  }

  void _cleanupConnection(String connectionId) {
    final peerId = _connectionToPeerId.remove(connectionId);
    if (peerId != null) {
      final link = _linksByPeerId.remove(peerId);
      _presence.remove(peerId);
      unawaited(link?.outboundSocket?.close());
      _discovery.markPeerDisconnected(peerId);
      notifyListeners();
    }
    unawaited(_server.closeConnection(connectionId));
  }
}
