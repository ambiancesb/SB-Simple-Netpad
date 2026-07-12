import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/pair_request.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/reconnect_backoff.dart';
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
    bool Function()? isStandard,
  }) : _sync = sync,
       _discovery = discovery,
       _trustStore = trustStore,
       _isStandard = isStandard ?? (() => false) {
    _connectionLog = connectionLog;
    _sync.onIncomingPairRequest = _onIncomingPairRequest;
    _sync.onPairRequestResolved = _onPairRequestResolved;
  }

  final SyncRepository _sync;
  final DiscoveryRepository _discovery;
  final TrustStore _trustStore;
  final bool Function() _isStandard;
  late final ConnectionLogRepository _connectionLog;

  final List<PairRequest> _pendingIncoming = [];
  final Set<String> _reconnectInFlight = {};
  final Map<String, DateTime> _reconnectBackoffUntil = {};
  final Map<String, int> _reconnectFailureCount = {};
  Timer? _reconnectDebounce;
  Timer? _backoffUiTimer;
  bool _watchingTrustedReconnect = false;

  List<PairRequest> get pendingIncoming => List.unmodifiable(_pendingIncoming);

  bool isReconnectInFlight(String peerId) => _reconnectInFlight.contains(peerId);

  DateTime? reconnectBackoffUntil(String peerId) => _reconnectBackoffUntil[peerId];

  /// Human-readable auto-reconnect status for trusted peers in the drawer.
  String trustedReconnectStatus({
    required String peerId,
    required bool connected,
    required bool autoSyncEnabled,
  }) {
    if (connected) return 'Connected';
    if (!_isStandard() || !autoSyncEnabled) return 'Manual only';
    if (_reconnectInFlight.contains(peerId)) return 'Reconnecting…';
    final backoff = _reconnectBackoffUntil[peerId];
    if (backoff != null && backoff.isAfter(DateTime.now())) {
      final seconds = backoff.difference(DateTime.now()).inSeconds.clamp(1, 999);
      return 'Retry in ${seconds}s';
    }
    final livePeer = _discovery.peerById(peerId);
    if (livePeer == null) return 'Not on network';
    if (livePeer.connectionState == PeerConnectionState.connecting ||
        livePeer.connectionState == PeerConnectionState.pendingOutgoing) {
      return 'Connecting…';
    }
    return 'Auto-reconnect';
  }

  /// Watches discovery and trust changes to auto-reconnect trusted peers.
  void startTrustedReconnectWatcher() {
    if (_watchingTrustedReconnect) return;
    _watchingTrustedReconnect = true;
    _discovery.addListener(_scheduleTrustedReconnectScan);
    _trustStore.addListener(_scheduleTrustedReconnectScan);
    _scheduleTrustedReconnectScan(immediate: true);
  }

  void stopTrustedReconnectWatcher() {
    if (!_watchingTrustedReconnect) return;
    _watchingTrustedReconnect = false;
    _discovery.removeListener(_scheduleTrustedReconnectScan);
    _trustStore.removeListener(_scheduleTrustedReconnectScan);
    _reconnectDebounce?.cancel();
    _reconnectDebounce = null;
    _backoffUiTimer?.cancel();
    _backoffUiTimer = null;
  }

  void _scheduleTrustedReconnectScan({bool immediate = false}) {
    _reconnectDebounce?.cancel();
    if (immediate) {
      unawaited(_attemptTrustedReconnects());
      return;
    }
    _reconnectDebounce = Timer(kTrustedReconnectDebounce, () {
      unawaited(_attemptTrustedReconnects());
    });
  }

  Future<void> _attemptTrustedReconnects() async {
    if (!_discovery.canDiscoverPeers) return;

    _sync.reconcileDiscoveryConnectionState();

    final now = DateTime.now();
    final targets = <Peer>[];
    for (final peer in _discovery.discoveredPeers) {
      if (!_isStandard()) continue;
      if (!_trustStore.canAutoSync(peer.id)) continue;
      if (_sync.isPeerAuthenticated(peer.id)) continue;
      if (peer.connectionState == PeerConnectionState.connected) continue;
      if (peer.connectionState == PeerConnectionState.connecting ||
          peer.connectionState == PeerConnectionState.pendingOutgoing) {
        continue;
      }
      if (_sync.isPeerLinkBusy(peer.id)) continue;
      if (_reconnectInFlight.contains(peer.id)) continue;
      final backoffUntil = _reconnectBackoffUntil[peer.id];
      if (backoffUntil != null && backoffUntil.isAfter(now)) continue;
      if (!peer.isManual &&
          !peer.isConnectable &&
          peer.resolveState != PeerResolveState.failed) {
        continue;
      }
      targets.add(peer);
    }

    if (targets.isEmpty) return;

    await Future.wait(targets.map(_reconnectTrustedPeer));
  }

  Future<void> _reconnectTrustedPeer(Peer peer) async {
    final now = DateTime.now();
    _reconnectInFlight.add(peer.id);
    notifyListeners();
    try {
      await _sync.connectAndRequestPair(peer);
      _clearReconnectFailure(peer.id);
    } catch (e) {
      if (e is StateError &&
          e.message.startsWith('Already connected to ')) {
        _recordReconnectFailure(
          peer.id,
          now,
          alreadyConnected: true,
        );
        _sync.reconcileDiscoveryConnectionState();
        return;
      }
      _connectionLog.add(
        'Auto-reconnect failed: ${_friendlyConnectError(e)}',
        peerId: peer.id,
        peerName: peer.displayName,
      );
      _recordReconnectFailure(
        peer.id,
        now,
        connectionRefused:
            e is SocketException && isConnectionRefusedException(e),
      );
      if (!_sync.isPeerAuthenticated(peer.id)) {
        _discovery.markPeerDisconnected(peer.id);
      }
    } finally {
      _reconnectInFlight.remove(peer.id);
      notifyListeners();
    }
  }

  void _recordReconnectFailure(
    String peerId,
    DateTime now, {
    bool connectionRefused = false,
    bool alreadyConnected = false,
  }) {
    final count = (_reconnectFailureCount[peerId] ?? 0) + 1;
    _reconnectFailureCount[peerId] = count;
    _reconnectBackoffUntil[peerId] = now.add(
      reconnectBackoffDuration(
        failureCount: count,
        connectionRefused: connectionRefused,
        alreadyConnected: alreadyConnected,
      ),
    );
    _scheduleBackoffUiRefresh();
    notifyListeners();
  }

  void _clearReconnectFailure(String peerId) {
    _reconnectFailureCount.remove(peerId);
    _reconnectBackoffUntil.remove(peerId);
    _scheduleBackoffUiRefresh();
  }

  void _scheduleBackoffUiRefresh() {
    final hasActiveBackoff = _reconnectBackoffUntil.values
        .any((until) => until.isAfter(DateTime.now()));
    if (!hasActiveBackoff) {
      _backoffUiTimer?.cancel();
      _backoffUiTimer = null;
      return;
    }
    _backoffUiTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final stillWaiting = _reconnectBackoffUntil.values
          .any((until) => until.isAfter(DateTime.now()));
      if (stillWaiting) {
        notifyListeners();
      } else {
        _backoffUiTimer?.cancel();
        _backoffUiTimer = null;
        notifyListeners();
      }
    });
  }

  Future<void> requestConnection(Peer peer) async {
    _clearReconnectFailure(peer.id);
    try {
      await _sync.connectAndRequestPair(peer);
    } catch (e) {
      _connectionLog.add(
        'Connect failed: ${_friendlyConnectError(e)}',
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
    _clearReconnectFailure(peerId);
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
    if (!enabled) {
      _clearReconnectFailure(peerId);
    }
    notifyListeners();
    if (enabled) {
      _scheduleTrustedReconnectScan(immediate: true);
    }
  }

  /// Drops any active connection, forgets the pinned cert, and refuses re-pair.
  Future<void> blockPeer(String peerId, String displayName) async {
    _clearReconnectFailure(peerId);
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
      _clearReconnectFailure(peerId);
      _sync.markPeerConnectedFromLink(peerId);
    } else if (!_sync.isPeerAuthenticated(peerId)) {
      _discovery.markPeerDisconnected(peerId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    stopTrustedReconnectWatcher();
    super.dispose();
  }

  static String _friendlyConnectError(Object e) {
    if (e is SocketException) {
      if (isConnectionRefusedException(e)) {
        return 'Connection refused — the other device is not listening. '
            'Confirm it shows a port under This device and both devices are '
            'on the same Wi‑Fi with sync enabled (no "Local network required" banner).';
      }
      return e.message;
    }
    if (e is HandshakeException) {
      return 'TLS handshake failed — ${e.message}. '
          'If both devices are on the same Wi‑Fi, try Connect by IP with the '
          'address shown under This device on the other side.';
    }
    if (e is TlsException) {
      return 'TLS error — ${e.message}';
    }
    if (e is WebSocketException) {
      return 'WebSocket failed — ${e.message}';
    }
    if (e is StateError) return e.message;
    return e.toString();
  }
}
