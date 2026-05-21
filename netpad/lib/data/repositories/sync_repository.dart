import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/models/protocol_message.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/protocol_codec.dart';
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
}

class SyncRepository extends ChangeNotifier {
  SyncRepository({
    required this.instanceId,
    required this.displayName,
    required LocalServer localServer,
    required DiscoveryRepository discovery,
    required DocumentRepository document,
  })  : _server = localServer,
        _discovery = discovery,
        _document = document {
    _server.onMessage = _onInboundMessage;
    _server.onConnectionClosed = _onInboundClosed;
  }

  final String instanceId;
  final String displayName;
  final LocalServer _server;
  final DiscoveryRepository _discovery;
  final DocumentRepository _document;

  final Map<String, _PeerLink> _linksByPeerId = {};
  final Map<String, String> _connectionToPeerId = {};
  final Map<String, String> _pendingOutboundRequestId = {};

  void Function(
    String fromId,
    String fromName,
    String requestId,
    String connectionId,
  )? onIncomingPairRequest;
  void Function(String peerId, bool accepted)? onPairRequestResolved;
  void Function()? onConflictMerged;

  Future<void> connectAndRequestPair(Peer peer) async {
    final host = peer.primaryHost;
    if (host == null) {
      throw StateError('Peer ${peer.displayName} has no resolved address');
    }
    _discovery.markPeerConnecting(peer.id);
    final requestId = const Uuid().v4();
    final uri = Uri.parse('ws://$host:${peer.port}/ws');
    final socket = await WebSocket.connect(uri.toString());
    final connectionId = 'out_${peer.id}';
    _pendingOutboundRequestId[connectionId] = requestId;

    final link = _PeerLink(
      peerId: peer.id,
      displayName: peer.displayName,
      outboundConnectionId: connectionId,
    );
    link.outboundSocket = socket;
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
          'fromName': displayName,
        },
      ),
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
      _sendDocSnapshot(connectionId);
    } else {
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {'requestId': requestId, 'accepted': false},
        ),
      );
      unawaited(_server.closeConnection(connectionId));
    }
  }

  void broadcastDocUpdate(int revision, String text, String originId) {
    final message = ProtocolMessage(
      type: MessageTypes.docUpdate,
      payload: {
        'revision': revision,
        'text': text,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void disconnectPeer(String peerId) {
    final link = _linksByPeerId.remove(peerId);
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

    _discovery.markPeerDisconnected(peerId);
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
        onIncomingPairRequest?.call(fromId, fromName, requestId, connectionId);
        _connectionToPeerId[connectionId] = fromId;
      case MessageTypes.pairResponse:
        final accepted = message.payload['accepted'] as bool? ?? false;
        final peerId = _connectionToPeerId[connectionId];
        if (peerId != null) {
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
        _sendDocSnapshot(connectionId);
      case MessageTypes.docSnapshot:
      case MessageTypes.docUpdate:
        if (!_isAuthenticated(connectionId)) return;
        _handleDocMessage(message, connectionId);
      case MessageTypes.peerDisconnect:
        final remoteId = message.payload['peerId'] as String? ?? '';
        if (remoteId.isNotEmpty) {
          _handleDisconnectByPeerId(remoteId);
        }
      default:
        break;
    }
  }

  bool _isAuthenticated(String connectionId) {
    final peerId = _connectionToPeerId[connectionId];
    if (peerId == null) return false;
    return _linksByPeerId[peerId]?.authenticated ?? false;
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
      if (hadConflict && originId != instanceId) {
        onConflictMerged?.call();
      }
      _relay(message, fromConnectionId);
    }
  }

  void _relay(ProtocolMessage message, String fromConnectionId) {
    _server.broadcastExcept(fromConnectionId, message);
    final fromPeerId = _connectionToPeerId[fromConnectionId];
    for (final entry in _linksByPeerId.entries) {
      if (entry.key == fromPeerId) continue;
      final connId = entry.value.outboundConnectionId;
      if (connId != null && connId != fromConnectionId) {
        _sendOnConnection(connId, message);
      }
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
    if (exceptConnectionId != null) {
      _server.broadcastExcept(exceptConnectionId, message);
    } else {
      _server.broadcastToAll(message);
    }

    for (final link in _linksByPeerId.values) {
      if (!link.authenticated) continue;
      if (link.peerId == exceptPeerId) continue;
      final connId = link.outboundConnectionId;
      if (connId != null && connId != exceptConnectionId) {
        _sendOnConnection(connId, message);
      }
    }
  }

  void _sendOnConnection(String connectionId, ProtocolMessage message) {
    if (connectionId.startsWith('out_')) {
      final peerId = _connectionToPeerId[connectionId];
      final socket = peerId != null ? _linksByPeerId[peerId]?.outboundSocket : null;
      if (socket != null && socket.readyState == WebSocket.open) {
        socket.add(ProtocolCodec.encode(message));
      }
    } else {
      _server.send(connectionId, message);
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
      unawaited(link?.outboundSocket?.close());
      _discovery.markPeerDisconnected(peerId);
      notifyListeners();
    }
    unawaited(_server.closeConnection(connectionId));
  }
}
