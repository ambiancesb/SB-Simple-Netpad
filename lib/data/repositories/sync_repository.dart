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

  final Map<String, PeerConnection> _linksByPeerId = {};
  final Map<String, String> _connectionToPeerId = {};
  final Map<String, String> _pendingOutboundRequestId = {};
  final Map<String, Timer> _pairingTimeouts = {};
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
    _handleDisconnect(connectionId);
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
    final peerId = _connectionToPeerId.remove(connectionId);
    if (peerId != null) {
      final link = _linksByPeerId.remove(peerId);
      if (link != null) {
        _stopHeartbeat(link);
        tearDownPeerOutbound(link);
      }
      _presence.remove(peerId);
      _discovery.markPeerDisconnected(peerId);
      notifyPeersChanged();
    }
    _pendingOutboundRequestId.remove(connectionId);
    if (connectionId.startsWith('out_')) {
      return;
    }
    unawaited(_server.closeConnection(connectionId));
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    _server.onMessage = null;
    _server.onConnectionClosed = null;

    for (final timer in _pairingTimeouts.values) {
      timer.cancel();
    }
    _pairingTimeouts.clear();

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
