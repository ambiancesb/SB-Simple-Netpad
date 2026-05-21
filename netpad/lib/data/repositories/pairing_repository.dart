import 'package:flutter/foundation.dart';
import 'package:netpad/core/models/pair_request.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';

class PairingRepository extends ChangeNotifier {
  PairingRepository({
    required SyncRepository sync,
    required DiscoveryRepository discovery,
  })  : _sync = sync,
        _discovery = discovery {
    _sync.onIncomingPairRequest = _onIncomingPairRequest;
    _sync.onPairRequestResolved = _onPairRequestResolved;
  }

  final SyncRepository _sync;
  final DiscoveryRepository _discovery;

  final List<PairRequest> _pendingIncoming = [];

  List<PairRequest> get pendingIncoming => List.unmodifiable(_pendingIncoming);

  Future<void> requestConnection(Peer peer) async {
    try {
      await _sync.connectAndRequestPair(peer);
    } catch (e) {
      _discovery.markPeerDisconnected(peer.id);
      rethrow;
    }
  }

  void acceptRequest(PairRequest request) {
    _pendingIncoming.removeWhere((r) => r.requestId == request.requestId);
    _sync.respondToPairRequest(
      connectionId: request.connectionId,
      requestId: request.requestId,
      fromId: request.fromId,
      fromName: request.fromName,
      accepted: true,
    );
    notifyListeners();
  }

  void rejectRequest(PairRequest request) {
    _pendingIncoming.removeWhere((r) => r.requestId == request.requestId);
    _sync.respondToPairRequest(
      connectionId: request.connectionId,
      requestId: request.requestId,
      fromId: request.fromId,
      fromName: request.fromName,
      accepted: false,
    );
    notifyListeners();
  }

  void disconnectPeer(String peerId) {
    _sync.disconnectPeer(peerId);
  }

  void _onIncomingPairRequest(
    String fromId,
    String fromName,
    String requestId,
    String connectionId,
  ) {
    final existing = _pendingIncoming.any((r) => r.requestId == requestId);
    if (existing) return;

    _pendingIncoming.add(
      PairRequest(
        requestId: requestId,
        fromId: fromId,
        fromName: fromName,
        connectionId: connectionId,
      ),
    );
    notifyListeners();
  }

  void _onPairRequestResolved(String peerId, bool accepted) {
    if (accepted) {
      final peer = _discovery.peerById(peerId);
      if (peer != null) {
        _discovery.markPeerConnected(peer);
      }
    } else {
      _discovery.markPeerDisconnected(peerId);
    }
    notifyListeners();
  }
}
