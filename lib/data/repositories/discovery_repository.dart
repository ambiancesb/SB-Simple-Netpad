import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/services/local_server.dart';

class DiscoveryRepository extends ChangeNotifier {
  DiscoveryRepository({
    required this.instanceId,
    required String displayName,
    required LocalServer localServer,
  }) : _displayName = displayName,
       _localServer = localServer;

  final String instanceId;
  String _displayName;
  final LocalServer _localServer;

  String get displayName => _displayName;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;
  Timer? _refreshTimer;

  final Map<String, Peer> _discovered = {};
  final Map<String, Peer> _connected = {};
  final Map<String, BonsoirService> _servicesByKey = {};
  final Map<String, int> _resolveAttempts = {};

  static const _maxResolveAttempts = 5;
  static const _refreshInterval = Duration(seconds: 12);

  List<Peer> get discoveredPeers =>
      _discovered.values.toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

  List<Peer> get connectedPeers =>
      _connected.values.toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

  int? get serverPort => _localServer.port;

  Future<void> start() async {
    final port = await _localServer.start();
    await _startBroadcast(port);
    await _startDiscovery();
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _refreshAllServices(),
    );
    notifyListeners();
  }

  Future<void> _startBroadcast(int port) async {
    final shortId = instanceId.replaceAll('-', '').substring(0, 8);
    final service = BonsoirService(
      name: 'SBNetpad-$shortId',
      type: kServiceType,
      port: port,
      attributes: {
        'id': instanceId,
        'name': _displayName,
        'port': port.toString(),
      },
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();
  }

  /// Updates Bonsoir advertisement after the user changes device name.
  Future<void> updateDisplayName(String name) async {
    _displayName = name;
    final port = _localServer.port;
    if (port == null) return;
    await _broadcast?.stop();
    _broadcast = null;
    await _startBroadcast(port);
    notifyListeners();
  }

  /// Adds or updates a peer entered by IP/hostname (no mDNS).
  Peer registerManualPeer({
    required String host,
    required int port,
    String? displayName,
  }) {
    final peer = Peer.manual(host: host, port: port, displayName: displayName);
    _discovered[peer.id] = peer;
    notifyListeners();
    return peer;
  }

  Future<void> _startDiscovery() async {
    _discovery = BonsoirDiscovery(type: kServiceType, printLogs: kDebugMode);
    await _discovery!.initialize();
    _discoverySub = _discovery!.eventStream!.listen(_onDiscoveryEvent);
    await _discovery!.start();
  }

  String _serviceKey(BonsoirService service) =>
      '${service.name}|${service.type}';

  void _trackService(BonsoirService service) {
    _servicesByKey[_serviceKey(service)] = service;
  }

  void _requestResolve(BonsoirService service) {
    final discovery = _discovery;
    if (discovery == null) return;
    try {
      service.resolve(discovery.serviceResolver);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Bonsoir resolve failed for ${service.name}: $e');
      }
    }
  }

  void _scheduleResolveRetry(BonsoirService service) {
    final key = _serviceKey(service);
    final attempts = (_resolveAttempts[key] ?? 0) + 1;
    _resolveAttempts[key] = attempts;
    if (attempts > _maxResolveAttempts) {
      _markPeerResolveFailed(service);
      return;
    }
    final delay = Duration(seconds: attempts.clamp(1, 4));
    Future.delayed(delay, () {
      if (_discovery != null && _servicesByKey.containsKey(key)) {
        _requestResolve(_servicesByKey[key]!);
      }
    });
  }

  void _refreshAllServices() {
    for (final service in _servicesByKey.values) {
      _requestResolve(service);
    }
  }

  void _upsertPeer(BonsoirService service) {
    final peer = Peer.fromBonsoirService(service);
    if (peer == null || peer.id == instanceId) return;

    final existing = _discovered[peer.id];
    _discovered[peer.id] = peer.copyWith(
      connectionState: _connected.containsKey(peer.id)
          ? PeerConnectionState.connected
          : (existing?.connectionState ?? PeerConnectionState.discovered),
      resolveState:
          peer.hostAddresses.isNotEmpty ||
              (peer.hostname != null && peer.hostname!.isNotEmpty)
          ? PeerResolveState.resolved
          : (existing?.resolveState ?? PeerResolveState.resolving),
    );
    notifyListeners();
  }

  void _markPeerResolveFailed(BonsoirService service) {
    final peer = Peer.fromBonsoirService(
      service,
      resolveState: PeerResolveState.failed,
    );
    if (peer == null || peer.id == instanceId) return;
    final existing = _discovered[peer.id];
    if (existing != null) {
      _discovered[peer.id] = existing.copyWith(
        resolveState: PeerResolveState.failed,
      );
      notifyListeners();
    }
  }

  void _onDiscoveryEvent(BonsoirDiscoveryEvent event) {
    switch (event) {
      case BonsoirDiscoveryServiceFoundEvent():
        final service = event.service;
        _trackService(service);
        _requestResolve(service);
      case BonsoirDiscoveryServiceResolvedEvent():
      case BonsoirDiscoveryServiceUpdatedEvent():
        final service = event.service;
        if (service == null) return;
        _trackService(service);
        _resolveAttempts.remove(_serviceKey(service));
        _upsertPeer(service);
        if (!_hasEndpoint(service)) {
          _scheduleResolveRetry(service);
        }
      case BonsoirDiscoveryServiceResolveFailedEvent():
        // Linux Avahi does not identify which service failed; retry all known.
        for (final service in _servicesByKey.values) {
          _scheduleResolveRetry(service);
        }
      case BonsoirDiscoveryServiceLostEvent():
        final id = event.service.attributes['id'];
        if (id != null && id != instanceId) {
          _resolveAttempts.removeWhere((key, _) {
            final svc = _servicesByKey[key];
            return svc?.attributes['id'] == id;
          });
          _servicesByKey.removeWhere((_, svc) => svc.attributes['id'] == id);
          if (!_connected.containsKey(id)) {
            _discovered.remove(id);
            notifyListeners();
          }
        }
      default:
        break;
    }
  }

  bool _hasEndpoint(BonsoirService service) =>
      service.hostAddresses.isNotEmpty ||
      (service.hostname != null && service.hostname!.isNotEmpty);

  /// Re-resolve a peer before connecting (helps stale Linux Avahi cache).
  Future<Peer?> refreshPeerForConnect(String peerId) async {
    final peer = _discovered[peerId] ?? _connected[peerId];
    if (peer?.bonsoirName == null) return peer;

    final service = _servicesByKey.values
        .where((s) => s.name == peer!.bonsoirName)
        .firstOrNull;
    if (service != null) {
      _requestResolve(service);
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    return _discovered[peerId] ?? _connected[peerId];
  }

  void markPeerConnected(Peer peer) {
    _connected[peer.id] = peer.copyWith(
      connectionState: PeerConnectionState.connected,
      resolveState: PeerResolveState.resolved,
    );
    _discovered[peer.id] = _connected[peer.id]!;
    notifyListeners();
  }

  void markPeerDisconnected(String peerId) {
    _connected.remove(peerId);
    final discovered = _discovered[peerId];
    if (discovered != null) {
      _discovered[peerId] = discovered.copyWith(
        connectionState: PeerConnectionState.discovered,
      );
    }
    notifyListeners();
  }

  void markPeerConnecting(String peerId) {
    final peer = _discovered[peerId];
    if (peer != null) {
      _discovered[peerId] = peer.copyWith(
        connectionState: PeerConnectionState.connecting,
      );
      notifyListeners();
    }
  }

  Peer? peerById(String id) => _connected[id] ?? _discovered[id];

  Future<void> shutdown() async {
    _refreshTimer?.cancel();
    await _discoverySub?.cancel();
    await _discovery?.stop();
    await _broadcast?.stop();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
