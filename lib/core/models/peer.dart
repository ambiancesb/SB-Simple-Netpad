import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

/// Maps [BonsoirService.host] (bonsoir 6.x) to [Peer] endpoint fields.
extension BonsoirServiceEndpoints on BonsoirService {
  List<String> get resolvedHostAddresses {
    final h = host;
    if (h == null || h.isEmpty) return const [];
    final stripped = h.contains('%') ? h.substring(0, h.indexOf('%')) : h;
    if (InternetAddress.tryParse(stripped) != null) return [h];
    return const [];
  }

  String? get resolvedHostname {
    final h = host;
    if (h == null || h.isEmpty) return null;
    final stripped = h.contains('%') ? h.substring(0, h.indexOf('%')) : h;
    if (InternetAddress.tryParse(stripped) != null) return null;
    return h;
  }

  bool get hasResolvedEndpoint =>
      resolvedHostAddresses.isNotEmpty ||
      (resolvedHostname != null && resolvedHostname!.isNotEmpty);
}

enum PeerConnectionState { discovered, connecting, pendingOutgoing, connected }

enum PeerResolveState { resolving, resolved, failed }

class Peer {
  Peer({
    required this.id,
    required this.displayName,
    required this.port,
    this.hostAddresses = const [],
    this.hostname,
    this.connectionState = PeerConnectionState.discovered,
    this.bonsoirName,
    this.resolveState = PeerResolveState.resolved,
  });

  final String id;
  final String displayName;
  final int port;
  final List<String> hostAddresses;
  final String? hostname;
  final PeerConnectionState connectionState;
  final String? bonsoirName;
  final PeerResolveState resolveState;

  /// True for peers added via IP/hostname (not Bonjour).
  bool get isManual => id.startsWith('manual:');

  bool get isConnectable =>
      resolveState == PeerResolveState.resolved &&
      (hostAddresses.isNotEmpty || (hostname != null && hostname!.isNotEmpty));

  String? get primaryHost =>
      hostAddresses.isNotEmpty ? hostAddresses.first : hostname;

  /// Registers a peer entered manually (host + port).
  static Peer manual({
    required String host,
    required int port,
    String? displayName,
  }) {
    final trimmedHost = host.trim();
    final id = 'manual:$trimmedHost:$port';
    return Peer(
      id: id,
      displayName: displayName ?? trimmedHost,
      port: port,
      hostAddresses: [trimmedHost],
      resolveState: PeerResolveState.resolved,
    );
  }

  Peer copyWith({
    String? displayName,
    int? port,
    List<String>? hostAddresses,
    String? hostname,
    PeerConnectionState? connectionState,
    String? bonsoirName,
    PeerResolveState? resolveState,
  }) {
    return Peer(
      id: id,
      displayName: displayName ?? this.displayName,
      port: port ?? this.port,
      hostAddresses: hostAddresses ?? this.hostAddresses,
      hostname: hostname ?? this.hostname,
      connectionState: connectionState ?? this.connectionState,
      bonsoirName: bonsoirName ?? this.bonsoirName,
      resolveState: resolveState ?? this.resolveState,
    );
  }

  static Peer? fromBonsoirService(
    BonsoirService service, {
    PeerResolveState resolveState = PeerResolveState.resolved,
  }) {
    final id = service.attributes['id'];
    if (id == null || id.isEmpty) return null;

    final name = service.attributes['name'] ?? service.name;
    final portFromTxt = int.tryParse(service.attributes['port'] ?? '');
    final port = (portFromTxt != null && portFromTxt > 0)
        ? portFromTxt
        : (service.port > 0 ? service.port : null);
    if (port == null) return null;

    final hosts = service.resolvedHostAddresses;
    final hostname = service.resolvedHostname;
    final hasEndpoint = service.hasResolvedEndpoint;

    return Peer(
      id: id,
      displayName: name,
      port: port,
      hostAddresses: hosts,
      hostname: hostname,
      bonsoirName: service.name,
      resolveState: hasEndpoint ? resolveState : PeerResolveState.resolving,
    );
  }
}
