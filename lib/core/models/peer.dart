import 'package:bonsoir/bonsoir.dart';

enum PeerConnectionState {
  discovered,
  connecting,
  pendingOutgoing,
  connected,
}

class Peer {
  Peer({
    required this.id,
    required this.displayName,
    required this.port,
    this.hostAddresses = const [],
    this.connectionState = PeerConnectionState.discovered,
    this.bonsoirName,
  });

  final String id;
  final String displayName;
  final int port;
  final List<String> hostAddresses;
  final PeerConnectionState connectionState;
  final String? bonsoirName;

  String? get primaryHost =>
      hostAddresses.isNotEmpty ? hostAddresses.first : null;

  Peer copyWith({
    String? displayName,
    int? port,
    List<String>? hostAddresses,
    PeerConnectionState? connectionState,
    String? bonsoirName,
  }) {
    return Peer(
      id: id,
      displayName: displayName ?? this.displayName,
      port: port ?? this.port,
      hostAddresses: hostAddresses ?? this.hostAddresses,
      connectionState: connectionState ?? this.connectionState,
      bonsoirName: bonsoirName ?? this.bonsoirName,
    );
  }

  static Peer? fromBonsoirService(BonsoirService service) {
    final id = service.attributes['id'];
    if (id == null || id.isEmpty) return null;
    final name = service.attributes['name'] ?? service.name;
    final portStr = service.attributes['port'];
    final port = portStr != null ? int.tryParse(portStr) : null;
    if (port == null) return null;
    return Peer(
      id: id,
      displayName: name,
      port: port,
      hostAddresses: List<String>.from(service.hostAddresses),
      bonsoirName: service.name,
    );
  }
}
