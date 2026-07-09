import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/local_network.dart';
import 'package:netpad/core/peer_endpoint.dart';
import 'package:netpad/services/android_networking.dart';
import 'package:netpad/services/linux_dbus_availability.dart';
import 'package:netpad/services/linux_mdns_backend.dart';
import 'package:netpad/services/local_address_service.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/network_link_service.dart';
import 'package:netpad/services/network_monitor.dart';

class DiscoveryRepository extends ChangeNotifier {
  DiscoveryRepository({
    required this.instanceId,
    required String displayName,
    required String roomId,
    required LocalServer localServer,
    NetworkMonitor? networkMonitor,
  }) : _displayName = displayName,
       _roomId = roomId,
       _localServer = localServer,
       _networkMonitor = networkMonitor ?? NetworkMonitor();

  final String instanceId;
  String _displayName;
  String _roomId;
  final LocalServer _localServer;
  final NetworkMonitor _networkMonitor;

  String get displayName => _displayName;
  String get roomId => _roomId;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;
  Timer? _refreshTimer;
  Timer? _retryDebounce;
  LinuxMdnsBackend? _linuxMdns;
  bool _useLinuxMdns = false;
  String? _activeBonsoirSubnetSignature;

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

  /// Set when mDNS advertise/discover fails (e.g. D-Bus or Avahi unavailable).
  String? get networkingError => _networkingError;
  String? _networkingError;

  /// Informational note when a non-default discovery path is active.
  String? get networkingNote => _networkingNote;
  String? _networkingNote;

  /// Set when sync is paused because only a cellular link is available.
  String? get networkingPolicyNote => _networkingPolicyNote;
  String? _networkingPolicyNote;

  bool get canDiscoverPeers => _canDiscoverPeers;
  bool _canDiscoverPeers = true;

  Future<void> start() async {
    _networkMonitor.start(_onNetworkChanged);
    await _applyNetworkPolicy();
    notifyListeners();
    if (Platform.isAndroid) {
      unawaited(_retryAndroidNetworkingWhenReady());
    }
  }

  /// Android often reports cellular before Wi‑Fi subnets are ready at cold start.
  Future<void> _retryAndroidNetworkingWhenReady() async {
    const waits = [2, 3, 5, 5, 5, 5, 5, 5];
    for (final seconds in waits) {
      await Future<void>.delayed(Duration(seconds: seconds));
      if (!_canDiscoverPeers ||
          _localServer.port == null ||
          _networkingError != null) {
        await _applyNetworkPolicy();
        notifyListeners();
      }
      if (_canDiscoverPeers &&
          _localServer.port != null &&
          _networkingError == null) {
        return;
      }
    }
  }

  /// Retries Bonsoir advertise/discover after a failure.
  Future<void> retryNetworking() async {
    _retryDebounce?.cancel();
    _retryDebounce = null;
    await _applyNetworkPolicy();
    notifyListeners();
  }

  /// Debounced retry for Android connectivity callbacks (avoids NSD churn).
  void scheduleRetryNetworking() {
    if (!Platform.isAndroid) {
      unawaited(retryNetworking());
      return;
    }
    _retryDebounce?.cancel();
    _retryDebounce = Timer(const Duration(milliseconds: 1500), () {
      unawaited(retryNetworking());
    });
  }

  bool get _bonsoirIsActive =>
      _broadcast != null && _discovery != null && _networkingError == null;

  bool get _lanDiscoveryIsActive =>
      (_bonsoirIsActive || _useLinuxMdns) && _networkingError == null;

  static String _subnetSignature() {
    final parts = LocalNetwork.activeSubnets
        .map((s) => '${s.base.address}/${s.prefixLength}')
        .toList()
      ..sort();
    return parts.join(',');
  }

  /// Starts, pauses, or restarts peer sync based on the active link type.
  Future<void> _applyNetworkPolicy() async {
    _networkingError = null;
    _networkingNote = null;
    _networkingPolicyNote = null;

    await LocalNetwork.refreshActiveSubnets();
    final subnetSig = _subnetSignature();
    final linkStatus = await NetworkLinkService.evaluate();
    final priorCanDiscover = _canDiscoverPeers;
    _canDiscoverPeers = linkStatus.canSync;

    if (!linkStatus.canSync) {
      _networkingPolicyNote = linkStatus.note;
      _activeBonsoirSubnetSignature = null;
      await _pauseLanSync();
      return;
    }

    int port;
    try {
      port = await _localServer.start();
    } catch (e, st) {
      _networkingError = 'Could not start listener: $e';
      if (kDebugMode) {
        debugPrint('Local server bind failed: $e\n$st');
      }
      return;
    }

    if (_lanDiscoveryIsActive &&
        priorCanDiscover &&
        subnetSig == _activeBonsoirSubnetSignature) {
      _ensureRefreshTimer();
      return;
    }

    if (Platform.isAndroid) {
      await AndroidNetworking.acquireMulticastLock();
      final started = await _startLinuxMdns(port, bindWifiInterface: true);
      if (started) {
        _activeBonsoirSubnetSignature = subnetSig;
        _ensureRefreshTimer();
        return;
      }
    }

    await _stopBonsoir();
    await _stopLinuxMdns();

    if (Platform.isLinux && !isLinuxSystemDBusAvailable()) {
      final started = await _startLinuxMdns(port);
      if (started) {
        _ensureRefreshTimer();
        return;
      }
    }

    final errors = <String>[];
    try {
      await _startBroadcast(port);
    } catch (e, st) {
      errors.add(_formatNetworkingError(e));
      if (kDebugMode) {
        debugPrint('Bonsoir broadcast failed: $e\n$st');
      }
    }
    try {
      await _startDiscovery();
    } catch (e, st) {
      final msg = _formatNetworkingError(e);
      if (!errors.contains(msg)) errors.add(msg);
      if (kDebugMode) {
        debugPrint('Bonsoir discovery failed: $e\n$st');
      }
    }

    if (errors.isNotEmpty &&
        Platform.isLinux &&
        errors.any((msg) => msg.contains('D-Bus'))) {
      final started = await _startLinuxMdns(port);
      if (started) {
        _ensureRefreshTimer();
        return;
      }
    }

    _useLinuxMdns = false;
    _networkingError = errors.isEmpty ? null : errors.join('\n');
    if (errors.isEmpty) {
      _activeBonsoirSubnetSignature = subnetSig;
    }
    _ensureRefreshTimer();
  }

  Future<void> _pauseLanSync() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await _stopBonsoir();
    await _stopLinuxMdns();
    await _localServer.stop();
  }

  void _ensureRefreshTimer() {
    if (!_canDiscoverPeers) return;
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _refreshAllServices(),
    );
  }

  Future<bool> _startLinuxMdns(
    int port, {
    bool bindWifiInterface = false,
  }) async {
    await _stopBonsoir();
    await _stopLinuxMdns();
    try {
      _linuxMdns = LinuxMdnsBackend(
        instanceId: instanceId,
        onPeerDiscovered: _upsertMdnsPeer,
        onPeerLost: _removeMdnsPeer,
      );
      await _linuxMdns!.start(
        port: port,
        displayName: _displayName,
        roomId: _roomId,
        bindWifiInterface: bindWifiInterface,
      );
      _useLinuxMdns = true;
      if (!bindWifiInterface) {
        _networkingNote =
            'Peer discovery uses direct mDNS (D-Bus/Avahi unavailable on this system).';
      }
      if (kDebugMode) {
        debugPrint(
          bindWifiInterface
              ? 'Using direct mDNS backend on Android'
              : 'Using direct mDNS backend on Linux',
        );
      }
      return true;
    } catch (e, st) {
      _useLinuxMdns = false;
      _linuxMdns = null;
      _networkingError = 'Peer discovery unavailable: $e';
      if (kDebugMode) {
        debugPrint('Direct mDNS fallback failed: $e\n$st');
      }
      return false;
    }
  }

  Future<void> _stopBonsoir() async {
    await _discoverySub?.cancel();
    _discoverySub = null;
    await _discovery?.stop();
    _discovery = null;
    await _broadcast?.stop();
    _broadcast = null;
    _servicesByKey.clear();
    _resolveAttempts.clear();
  }

  Future<void> _stopLinuxMdns() async {
    await _linuxMdns?.stop();
    _linuxMdns = null;
    _useLinuxMdns = false;
  }

  static String _formatNetworkingError(Object e) {
    if (isDbusNetworkingError(e)) {
      return 'D-Bus is not available (Linux needs it for Avahi/mDNS). '
          'Install and start dbus and avahi-daemon, or use Connect by IP.';
    }
    return 'Peer discovery unavailable: $e';
  }

  Future<void> _onNetworkChanged() async {
    if (kDebugMode) {
      debugPrint('Network change detected — restarting discovery/broadcast');
    }
    _discovered.removeWhere((id, _) => !_connected.containsKey(id));
    if (Platform.isAndroid) {
      scheduleRetryNetworking();
      return;
    }
    await _applyNetworkPolicy();
    notifyListeners();
  }

  Future<void> _startBroadcast(int port) async {
    final shortId = instanceId.replaceAll('-', '').substring(0, 8);
    final lanIp = await LocalAddressService.getLanIpv4();
    final attributes = <String, String>{
      'id': instanceId,
      'name': _displayName,
      'port': port.toString(),
      'room': _roomId,
    };
    if (lanIp != null) attributes['ip'] = lanIp;

    final service = BonsoirService(
      name: 'SBNetpad-$shortId',
      type: kServiceType,
      port: port,
      attributes: attributes,
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();
  }

  /// Updates Bonsoir advertisement after the user changes device name.
  Future<void> updateDisplayName(String name) async {
    _displayName = name;
    if (!_canDiscoverPeers) {
      notifyListeners();
      return;
    }
    final port = _localServer.port;
    if (port == null) {
      notifyListeners();
      return;
    }
    if (_useLinuxMdns) {
      await _linuxMdns?.updateAdvertisement(
        port,
        displayName: name,
        roomId: _roomId,
      );
    } else {
      await _broadcast?.stop();
      _broadcast = null;
      await _startBroadcast(port);
    }
    notifyListeners();
  }

  /// Switches the advertised session/room and re-filters discovered peers.
  Future<void> updateRoom(String room) async {
    _roomId = room;
    // Drop discovered peers that are not connected; they will reappear only if
    // they advertise the new room.
    _discovered.removeWhere((id, _) => !_connected.containsKey(id));
    if (!_canDiscoverPeers) {
      notifyListeners();
      return;
    }
    final port = _localServer.port;
    if (port != null) {
      if (_useLinuxMdns) {
        await _linuxMdns?.updateAdvertisement(
          port,
          displayName: _displayName,
          roomId: _roomId,
        );
      } else {
        await _broadcast?.stop();
        _broadcast = null;
        await _startBroadcast(port);
      }
    }
    if (_useLinuxMdns) {
      unawaited(_linuxMdns?.scan());
    } else {
      _refreshAllServices();
    }
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
    _discovery = BonsoirDiscovery(
      type: kServiceType,
      printLogs: kDebugMode || Platform.isAndroid,
    );
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
    if (!_canDiscoverPeers) return;
    if (_useLinuxMdns) {
      unawaited(_linuxMdns?.scan());
      return;
    }
    for (final service in _servicesByKey.values) {
      _requestResolve(service);
    }
  }

  bool _peerIsOnActiveSubnet(Peer peer) {
    if (peer.hostAddresses.isEmpty) return true;
    return peer.hostAddresses.any((raw) {
      final addr = InternetAddress.tryParse(LocalNetwork.stripZoneId(raw));
      return addr != null && LocalNetwork.isLanReachable(addr);
    });
  }

  void _upsertMdnsPeer(Peer peer) {
    if (peer.id == instanceId) return;
    if (!_peerIsOnActiveSubnet(peer)) {
      if (!_connected.containsKey(peer.id)) {
        _discovered.remove(peer.id);
        notifyListeners();
      }
      return;
    }

    final existing = _discovered[peer.id];
    _discovered[peer.id] = Peer.mergeDiscovery(peer, existing).copyWith(
      connectionState: _connected.containsKey(peer.id)
          ? PeerConnectionState.connected
          : (existing?.connectionState ?? PeerConnectionState.discovered),
    );
    notifyListeners();
  }

  void _removeMdnsPeer(String peerId) {
    if (_connected.containsKey(peerId)) return;
    if (_discovered.remove(peerId) != null) {
      notifyListeners();
    }
  }

  void _upsertPeer(BonsoirService service) {
    final peer = Peer.fromBonsoirService(service);
    if (peer == null || peer.id == instanceId) return;

    if (kDebugMode && peer.hostAddresses.isNotEmpty) {
      final visible = _peerIsOnActiveSubnet(peer);
      if (!visible) {
        debugPrint(
          'Filtered discovered peer ${peer.displayName} '
          '(${peer.hostAddresses.join(", ")}) — not on active LAN segment',
        );
      }
    }

    // Only surface peers advertising the same room. Peers without a room
    // attribute are treated as the default room for backward compatibility.
    final peerRoom = service.attributes['room'] ?? kDefaultRoom;
    if (peerRoom != _roomId) {
      if (!_connected.containsKey(peer.id)) {
        _discovered.remove(peer.id);
        notifyListeners();
      }
      return;
    }

    if (!_peerIsOnActiveSubnet(peer)) {
      if (!_connected.containsKey(peer.id)) {
        _discovered.remove(peer.id);
        notifyListeners();
      }
      return;
    }

    final existing = _discovered[peer.id];
    _discovered[peer.id] = Peer.mergeDiscovery(peer, existing).copyWith(
      connectionState: _connected.containsKey(peer.id)
          ? PeerConnectionState.connected
          : (existing?.connectionState ?? PeerConnectionState.discovered),
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

  bool _hasEndpoint(BonsoirService service) => service.hasResolvedEndpoint;

  /// Re-resolve a peer before connecting (helps stale Linux Avahi cache).
  Future<Peer?> refreshPeerForConnect(String peerId) async {
    final peer = _discovered[peerId] ?? _connected[peerId];
    if (!_canDiscoverPeers) return peer;
    if (_useLinuxMdns) {
      await _linuxMdns?.scan();
      return _discovered[peerId] ?? _connected[peerId];
    }
    if (peer?.bonsoirName == null) return peer;

    final service = _servicesByKey.values
        .where((s) => s.name == peer!.bonsoirName)
        .firstOrNull;
    if (service != null) {
      final alreadyConnectable =
          peer != null &&
          peer.resolveState == PeerResolveState.resolved &&
          peer.isConnectable;
      if (!alreadyConnectable) {
        _requestResolve(service);
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
    }
    return _discovered[peerId] ?? _connected[peerId];
  }

  void markPeerConnected(
    Peer peer, {
    String? remoteHost,
    int? remotePort,
  }) {
    final existing = _connected[peer.id] ?? _discovered[peer.id];
    var merged = Peer.mergeDiscovery(peer, existing);
    if (remoteHost != null && remoteHost.isNotEmpty) {
      final hosts = PeerEndpoint.usableAddresses(
        merged.hostAddresses,
        txtIp: remoteHost,
      );
      merged = merged.copyWith(
        hostAddresses: hosts,
        port: remotePort != null && remotePort > 0 ? remotePort : merged.port,
      );
    } else if (remotePort != null && remotePort > 0 && merged.port <= 0) {
      merged = merged.copyWith(port: remotePort);
    }
    _connected[peer.id] = merged.copyWith(
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
    _retryDebounce?.cancel();
    _networkMonitor.stop();
    await _stopBonsoir();
    await _stopLinuxMdns();
    await _localServer.stop();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
