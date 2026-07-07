import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mdns_dart/mdns_dart.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/local_network.dart';
import 'package:netpad/core/models/peer.dart';

/// Maps an mDNS [ServiceEntry] to a [Peer] using our TXT attributes.
Peer? peerFromMdnsEntry(ServiceEntry entry) {
  final attrs = MDNSService.parseTXTRecords(entry.infoFields);
  final id = attrs['id'];
  if (id == null || id.isEmpty) return null;

  final name = attrs['name'] ?? entry.name;
  final portFromTxt = int.tryParse(attrs['port'] ?? '');
  final port = entry.port > 0
      ? entry.port
      : ((portFromTxt != null && portFromTxt > 0) ? portFromTxt : 0);
  if (port <= 0) return null;

  final hosts = entry.allAddresses.map((a) => a.address).toList();
  var hostname = entry.host.isNotEmpty ? entry.host : null;
  if (hostname != null) {
    if (hostname.endsWith('.')) {
      hostname = hostname.substring(0, hostname.length - 1);
    }
    if (hostname.endsWith('.local')) {
      hostname = hostname.substring(0, hostname.length - '.local'.length);
    }
  }
  final hasEndpoint =
      hosts.isNotEmpty || (hostname != null && hostname.isNotEmpty);

  return Peer(
    id: id,
    displayName: name,
    port: port,
    hostAddresses: hosts,
    hostname: hostname,
    bonsoirName: entry.name,
    resolveState: hasEndpoint
        ? PeerResolveState.resolved
        : PeerResolveState.resolving,
  );
}

/// Raw mDNS advertise/discover (Linux fallback and Android primary path).
class LinuxMdnsBackend {
  LinuxMdnsBackend({
    required this.instanceId,
    required this.onPeerDiscovered,
    required this.onPeerLost,
  });

  final String instanceId;
  final void Function(Peer peer) onPeerDiscovered;
  final void Function(String peerId) onPeerLost;

  MDNSServer? _server;
  Timer? _discoverTimer;
  NetworkInterface? _networkInterface;
  String _displayName = '';
  String _roomId = kDefaultRoom;
  final Set<String> _seenPeerIds = {};

  static const _discoverInterval = Duration(seconds: 12);
  static const _discoverTimeout = Duration(seconds: 5);

  Future<void> start({
    required int port,
    required String displayName,
    required String roomId,
    bool bindWifiInterface = false,
  }) async {
    _displayName = displayName;
    _roomId = roomId;
    if (bindWifiInterface) {
      _networkInterface = await LocalNetwork.preferredLanInterface();
      if (kDebugMode && _networkInterface != null) {
        debugPrint(
          'mDNS binding to ${_networkInterface!.name} '
          '(${_networkInterface!.addresses.map((a) => a.address).join(", ")})',
        );
      }
    }
    await _startBroadcast(port);
    _discoverTimer?.cancel();
    _discoverTimer = Timer.periodic(
      _discoverInterval,
      (_) => unawaited(scan()),
    );
    await scan();
  }

  Future<void> updateAdvertisement(
    int port, {
    required String displayName,
    required String roomId,
  }) async {
    _displayName = displayName;
    _roomId = roomId;
    await _server?.stop();
    _server = null;
    await _startBroadcast(port);
  }

  Future<void> scan() async {
    final results = await MDNSClient.discover(
      kServiceType,
      timeout: _discoverTimeout,
      networkInterface: _networkInterface,
      reuseAddress: true,
      reusePort: false,
      logger: kDebugMode ? debugPrint : null,
    );
    final foundIds = <String>{};
    for (final entry in results) {
      final peer = peerFromMdnsEntry(entry);
      if (peer == null || peer.id == instanceId) continue;

      final attrs = MDNSService.parseTXTRecords(entry.infoFields);
      final peerRoom = attrs['room'] ?? kDefaultRoom;
      if (peerRoom != _roomId) continue;

      if (kDebugMode) {
        debugPrint(
          'mDNS peer ${peer.displayName} at '
          '${peer.hostAddresses.join(",")}:${peer.port}',
        );
      }

      foundIds.add(peer.id);
      onPeerDiscovered(peer);
    }

    for (final id in _seenPeerIds.difference(foundIds)) {
      onPeerLost(id);
    }
    _seenPeerIds
      ..clear()
      ..addAll(foundIds);
  }

  Future<void> stop() async {
    _discoverTimer?.cancel();
    _discoverTimer = null;
    await _server?.stop();
    _server = null;
    _networkInterface = null;
    _seenPeerIds.clear();
  }

  Future<void> _startBroadcast(int port) async {
    final shortId = instanceId.replaceAll('-', '').substring(0, 8);
    final service = await MDNSService.create(
      instance: 'SBNetpad-$shortId',
      service: kServiceType,
      port: port,
      txt: MDNSService.createTXTRecords({
        'id': instanceId,
        'name': _displayName,
        'port': port.toString(),
        'room': _roomId,
      }),
    );
    _server = MDNSServer(
      MDNSServerConfig(
        zone: service,
        networkInterface: _networkInterface,
        reuseAddress: true,
        reusePort: false,
        logger: kDebugMode ? debugPrint : null,
      ),
    );
    await _server!.start();
  }
}
