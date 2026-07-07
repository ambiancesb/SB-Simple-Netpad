import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/pair_request.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/services/pairing_verification_code.dart';

class PairingRepository extends ChangeNotifier {
  PairingRepository({
    required SyncRepository sync,
    required DiscoveryRepository discovery,
    required ConnectionLogRepository connectionLog,
    required TrustStore trustStore,
  }) : _sync = sync,
       _discovery = discovery,
       _trustStore = trustStore {
    _connectionLog = connectionLog;
    _sync.onIncomingPairRequest = _onIncomingPairRequest;
    _sync.onPairRequestResolved = _onPairRequestResolved;
  }

  final SyncRepository _sync;
  final DiscoveryRepository _discovery;
  final TrustStore _trustStore;
  late final ConnectionLogRepository _connectionLog;

  final List<PairRequest> _pendingIncoming = [];
  final Set<String> _reconnectInFlight = {};
  Timer? _reconnectDebounce;
  bool _watchingTrustedReconnect = false;

  List<PairRequest> get pendingIncoming => List.unmodifiable(_pendingIncoming);

  /// Watches discovery and trust changes to auto-reconnect trusted peers.
  void startTrustedReconnectWatcher() {
    if (_watchingTrustedReconnect) return;
    _watchingTrustedReconnect = true;
    _discovery.addListener(_scheduleTrustedReconnectScan);
    _trustStore.addListener(_scheduleTrustedReconnectScan);
    _scheduleTrustedReconnectScan();
  }

  void stopTrustedReconnectWatcher() {
    if (!_watchingTrustedReconnect) return;
    _watchingTrustedReconnect = false;
    _discovery.removeListener(_scheduleTrustedReconnectScan);
    _trustStore.removeListener(_scheduleTrustedReconnectScan);
    _reconnectDebounce?.cancel();
    _reconnectDebounce = null;
  }

  void _scheduleTrustedReconnectScan() {
    _reconnectDebounce?.cancel();
    _reconnectDebounce = Timer(kTrustedReconnectDebounce, () {
      unawaited(_attemptTrustedReconnects());
    });
  }

  Future<void> _attemptTrustedReconnects() async {
    if (!_discovery.canDiscoverPeers) return;

    for (final peer in _discovery.discoveredPeers) {
      if (!_trustStore.canAutoSync(peer.id)) continue;
      if (peer.connectionState == PeerConnectionState.connected) continue;
      if (peer.connectionState == PeerConnectionState.connecting ||
          peer.connectionState == PeerConnectionState.pendingOutgoing) {
        continue;
      }
      if (_sync.isPeerLinkBusy(peer.id)) continue;
      if (_reconnectInFlight.contains(peer.id)) continue;
      if (!peer.isManual &&
          !peer.isConnectable &&
          peer.resolveState != PeerResolveState.failed) {
        continue;
      }

      _reconnectInFlight.add(peer.id);
      try {
        await _sync.connectAndRequestPair(peer);
      } catch (e) {
        _connectionLog.add(
          'Auto-reconnect failed: $e',
          peerId: peer.id,
          peerName: peer.displayName,
        );
        _discovery.markPeerDisconnected(peer.id);
      } finally {
        _reconnectInFlight.remove(peer.id);
      }
    }
  }

  Future<void> requestConnection(Peer peer) async {
    try {
      await _sync.connectAndRequestPair(peer);
    } catch (e) {
      _connectionLog.add(
        'Connect failed: $e',
        peerId: peer.id,
        peerName: peer.displayName,
      );
      _discovery.markPeerDisconnected(peer.id);
      rethrow;
    }
  }

  void acceptRequest(PairRequest request) {
    _pendingIncoming.removeWhere((r) => r.requestId == request.requestId);
    _connectionLog.add(
      'Accepted request from ${request.fromName}',
      peerId: request.fromId,
      peerName: request.fromName,
    );
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
    _connectionLog.add(
      'Rejected request from ${request.fromName}',
      peerId: request.fromId,
      peerName: request.fromName,
    );
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

  /// Forgets the auto-sync token; the cert pin is kept.
  Future<void> revokeTrustedPeer(String peerId) async {
    final name = _trustStore.trustedPeer(peerId)?.displayName ?? peerId;
    await _trustStore.revokeAutoSync(peerId);
    _connectionLog.add(
      'Revoked auto-sync for $name',
      peerId: peerId,
      peerName: name,
    );
    notifyListeners();
  }

  Future<void> setPeerAutoSyncEnabled(String peerId, bool enabled) async {
    await _trustStore.setAutoSyncEnabled(peerId, enabled);
    notifyListeners();
    if (enabled) {
      _scheduleTrustedReconnectScan();
    }
  }

  /// Drops any active connection, forgets the pinned cert, and refuses re-pair.
  Future<void> blockPeer(String peerId, String displayName) async {
    _sync.disconnectPeer(peerId);
    await _trustStore.unpin(peerId);
    await _trustStore.block(peerId, displayName);
    _connectionLog.add('Blocked $displayName', peerId: peerId, peerName: displayName);
    notifyListeners();
  }

  Future<void> unblockPeer(String peerId) async {
    final name = _trustStore.blocked[peerId] ?? peerId;
    await _trustStore.unblock(peerId);
    _connectionLog.add('Unblocked $name', peerId: peerId, peerName: name);
    notifyListeners();
  }

  void _onIncomingPairRequest(
    String fromId,
    String fromName,
    String requestId,
    String connectionId,
  ) {
    final existing = _pendingIncoming.any((r) => r.requestId == requestId);
    if (existing) return;

    final verificationCode = PairingVerificationCode.generate(
      _sync.instanceId,
      fromId,
    );
    _pendingIncoming.add(
      PairRequest(
        requestId: requestId,
        fromName: fromName,
        fromId: fromId,
        connectionId: connectionId,
        verificationCode: verificationCode,
      ),
    );
    _connectionLog.add(
      'Incoming request from $fromName (code $verificationCode)',
      peerId: fromId,
      peerName: fromName,
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

  @override
  void dispose() {
    stopTrustedReconnectWatcher();
    super.dispose();
  }
}
