import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/auto_sync_token.dart';
import 'package:netpad/core/auto_sync_validation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/peer_disconnect_validation.dart';
import 'package:netpad/core/pair_request_payload.dart';
import 'package:netpad/core/local_network.dart';
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
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/pairing_verification_code.dart';
import 'package:netpad/services/peer_host_resolver.dart';
import 'package:netpad/services/protocol_codec.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:uuid/uuid.dart';

import 'package:netpad/data/repositories/peer_connection.dart';

part 'sync_repository_pairing.dart';
part 'sync_repository_heartbeat.dart';
part 'sync_repository_documents.dart';

class SyncRepository extends ChangeNotifier {
  SyncRepository({
    required this.instanceId,
    required String displayName,
    required LocalServer localServer,
    required DiscoveryRepository discovery,
    required WorkspaceRepository workspace,
    required ConnectionLogRepository connectionLog,
    required TrustStore trustStore,
    required TlsIdentity tlsIdentity,
    bool Function()? isPro,
  }) : _displayName = displayName,
       _server = localServer,
       _discovery = discovery,
       _workspace = workspace,
       _connectionLog = connectionLog,
       _trustStore = trustStore,
       _tlsIdentity = tlsIdentity,
       _isPro = isPro ?? (() => false) {
    _server.onMessage = _onInboundMessage;
    _server.onConnectionClosed = _onInboundClosed;
    _server.onConnectionOpened = _onInboundOpened;
    _server.onInboundRejected = _onInboundRejected;
  }

  final String instanceId;
  String _displayName;
  String get displayName => _displayName;
  final LocalServer _server;
  final DiscoveryRepository _discovery;
  final WorkspaceRepository _workspace;
  final ConnectionLogRepository _connectionLog;
  final TrustStore _trustStore;
  final TlsIdentity _tlsIdentity;
  final bool Function() _isPro;

  bool _divergencePromptActive = false;
  bool _liveConflictPromptActive = false;

  final Map<String, PeerConnection> _linksByPeerId = {};
  final Map<String, String> _connectionToPeerId = {};
  final Map<String, String> _pendingOutboundRequestId = {};
  final Map<String, Timer> _pairingTimeouts = {};
  final Map<String, Timer> _prePairTimeouts = {};
  final Map<String, PeerPresence> _presence = {};

  bool _disposed = false;

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

  /// True when [peerId] is connected or a pairing handshake is in progress.
  bool isPeerLinkBusy(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return false;
    if (link.authenticated) return true;
    return link.outboundSocket != null || link.inboundConnectionId != null;
  }

  /// True when [peerId] has a completed pairing session.
  bool isPeerAuthenticated(String peerId) =>
      _linksByPeerId[peerId]?.authenticated == true;

  /// Count of peers with an authenticated sync session.
  int get authenticatedPeerCount =>
      _linksByPeerId.values.where((link) => link.authenticated).length;

  /// Aligns discovery UI state with authenticated links (e.g. after inbound accept).
  void reconcileDiscoveryConnectionState() {
    for (final entry in _linksByPeerId.entries) {
      if (!entry.value.authenticated) continue;
      markPeerConnectedFromLink(entry.key);
    }
  }

  /// Preserves nearby peer addresses when a session becomes connected.
  void markPeerConnectedFromLink(
    String peerId, {
    String? displayName,
    String? inboundConnectionId,
  }) {
    final link = _linksByPeerId[peerId];
    final inboundId = inboundConnectionId ?? link?.inboundConnectionId;
    final inboundRemote = inboundId != null
        ? _server.remoteAddressFor(inboundId)
        : null;
    final peer =
        _discovery.peerById(peerId) ??
        Peer(
          id: peerId,
          displayName: displayName ?? link?.displayName ?? peerId,
          port: link?.remotePort ?? 0,
        );
    _discovery.markPeerConnected(
      peer,
      remoteHost: link?.remoteHost ?? inboundRemote?.address,
      remotePort: link?.remotePort,
    );
  }

  /// Notifies listeners; used by [SyncRepository] part modules.
  void notifyPeersChanged() => notifyListeners();

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

  void _onInboundMessage(String connectionId, ProtocolMessage message) {
    _handleMessage(connectionId, message, isOutbound: false);
  }

  void _onInboundClosed(String connectionId) {
    _cancelPrePairTimeout(connectionId);
    _handleDisconnect(connectionId);
  }

  void _onInboundOpened(String connectionId) {
    _cancelPrePairTimeout(connectionId);
    _prePairTimeouts[connectionId] = Timer(LocalNetwork.prePairTimeout, () {
      _prePairTimeouts.remove(connectionId);
      if (_connectionToPeerId.containsKey(connectionId)) return;
      _connectionLog.add(
        'Closed inbound connection with no Netpad pairing handshake',
      );
      unawaited(_server.closeConnection(connectionId));
    });
  }

  void _onInboundRejected(String reason, InternetAddress? remoteAddress) {
    final remote = remoteAddress?.address;
    _connectionLog.add(
      remote == null ? reason : '$reason ($remote)',
    );
  }

  void _cancelPrePairTimeout(String connectionId) {
    _prePairTimeouts.remove(connectionId)?.cancel();
  }

  void _handleMessage(
    String connectionId,
    ProtocolMessage message, {
    required bool isOutbound,
  }) {
    switch (message.type) {
      case MessageTypes.pairRequest:
      case MessageTypes.pairResponse:
      case MessageTypes.pairComplete:
        _handlePairingMessage(connectionId, message, isOutbound: isOutbound);
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
        final senderPeerId = _connectionToPeerId[connectionId];
        final payloadPeerId = message.payload['peerId'] as String? ?? '';
        if (!shouldHonorPeerDisconnect(
          senderPeerId: senderPeerId,
          payloadPeerId: payloadPeerId,
        )) {
          _connectionLog.add(
            'Rejected disconnect: peerId mismatch',
            peerId: senderPeerId,
            peerName: senderPeerId == null
                ? null
                : _linksByPeerId[senderPeerId]?.displayName,
          );
          return;
        }
        _handleDisconnectByPeerId(payloadPeerId);
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
    if (_disposed) return;
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
      tearDownPeerOutbound(link);
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
      notifyPeersChanged();
    }
  }

  void _handleDisconnectByPeerId(String peerId) {
    disconnectPeer(peerId);
  }

  void _cleanupConnection(String connectionId) {
    _cancelPairingTimeout(connectionId);
    _cancelPrePairTimeout(connectionId);
    _pendingOutboundRequestId.remove(connectionId);

    final peerId = _connectionToPeerId.remove(connectionId);
    if (peerId == null) {
      if (!connectionId.startsWith('out_')) {
        unawaited(_server.closeConnection(connectionId));
      }
      return;
    }

    if (connectionId.startsWith('out_')) {
      final link = _linksByPeerId[peerId];
      if (link != null) {
        tearDownPeerOutbound(link);
        if (link.inboundConnectionId == null && !link.authenticated) {
          _stopHeartbeat(link);
          _linksByPeerId.remove(peerId);
          _presence.remove(peerId);
          _discovery.markPeerDisconnected(peerId);
          notifyPeersChanged();
        }
      }
      return;
    }

    final link = _linksByPeerId.remove(peerId);
    if (link != null) {
      _stopHeartbeat(link);
      tearDownPeerOutbound(link);
    }
    _presence.remove(peerId);
    _discovery.markPeerDisconnected(peerId);
    notifyPeersChanged();
    unawaited(_server.closeConnection(connectionId));
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _server.onMessage = null;
    _server.onConnectionClosed = null;
    _server.onConnectionOpened = null;
    _server.onInboundRejected = null;

    for (final timer in _pairingTimeouts.values) {
      timer.cancel();
    }
    _pairingTimeouts.clear();
    for (final timer in _prePairTimeouts.values) {
      timer.cancel();
    }
    _prePairTimeouts.clear();

    for (final link in _linksByPeerId.values) {
      _stopHeartbeat(link);
      tearDownPeerOutbound(link);
      final inboundId = link.inboundConnectionId;
      if (inboundId != null) {
        unawaited(_server.closeConnection(inboundId));
      }
    }

    _linksByPeerId.clear();
    _connectionToPeerId.clear();
    _pendingOutboundRequestId.clear();
    _presence.clear();

    super.dispose();
  }
}
