import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/services/local_server.dart';

class DiscoveryRepository extends ChangeNotifier {
  DiscoveryRepository({
    required this.instanceId,
    required this.displayName,
    required LocalServer localServer,
  }) : _localServer = localServer;

  final String instanceId;
  final String displayName;
  final LocalServer _localServer;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;

  final Map<String, Peer> _discovered = {};
  final Map<String, Peer> _connected = {};

  List<Peer> get discoveredPeers => _discovered.values.toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));

  List<Peer> get connectedPeers => _connected.values.toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));

  int? get serverPort => _localServer.port;

  Future<void> start() async {
    final port = await _localServer.start();
    await _startBroadcast(port);
    await _startDiscovery();
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
        'name': displayName,
        'port': port.toString(),
      },
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();
  }

  Future<void> _startDiscovery() async {
    _discovery = BonsoirDiscovery(type: kServiceType);
    await _discovery!.initialize();
    _discoverySub = _discovery!.eventStream!.listen(_onDiscoveryEvent);
    await _discovery!.start();
  }

  void _onDiscoveryEvent(BonsoirDiscoveryEvent event) {
    switch (event) {
      case BonsoirDiscoveryServiceFoundEvent():
        event.service.resolve(_discovery!.serviceResolver);
      case BonsoirDiscoveryServiceResolvedEvent():
      case BonsoirDiscoveryServiceUpdatedEvent():
        final service = event.service;
        if (service == null) return;
        final peer = Peer.fromBonsoirService(service);
        if (peer == null || peer.id == instanceId) return;
        final existing = _discovered[peer.id];
        _discovered[peer.id] = peer.copyWith(
          connectionState: _connected.containsKey(peer.id)
              ? PeerConnectionState.connected
              : (existing?.connectionState ?? PeerConnectionState.discovered),
        );
        notifyListeners();
      case BonsoirDiscoveryServiceLostEvent():
        final id = event.service.attributes['id'];
        if (id != null && id != instanceId) {
          if (!_connected.containsKey(id)) {
            _discovered.remove(id);
            notifyListeners();
          }
        }
      default:
        break;
    }
  }

  void markPeerConnected(Peer peer) {
    _connected[peer.id] = peer.copyWith(
      connectionState: PeerConnectionState.connected,
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
    await _discoverySub?.cancel();
    await _discovery?.stop();
    await _broadcast?.stop();
  }
}
