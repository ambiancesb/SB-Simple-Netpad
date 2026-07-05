part of 'sync_repository.dart';

extension SyncRepositoryHeartbeat on SyncRepository {
  void _startHeartbeat(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null || !link.authenticated) return;
    _stopHeartbeat(link);
    link.lastPongAt = DateTime.now();
    link.heartbeatTimer = Timer.periodic(kHeartbeatInterval, (_) {
      _tickHeartbeat(peerId);
    });
  }

  void _stopHeartbeat(PeerConnection link) {
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
