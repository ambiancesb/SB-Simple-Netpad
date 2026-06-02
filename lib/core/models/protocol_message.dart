class ProtocolMessage {
  const ProtocolMessage({required this.type, required this.payload});

  final String type;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {'type': type, 'v': 1, ...payload};

  factory ProtocolMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final payload = Map<String, dynamic>.from(json)
      ..remove('type')
      ..remove('v');
    return ProtocolMessage(type: type, payload: payload);
  }
}

/// Message type constants.
abstract final class MessageTypes {
  static const pairRequest = 'pair_request';
  static const pairResponse = 'pair_response';
  static const pairComplete = 'pair_complete';
  static const docSnapshot = 'doc_snapshot';
  static const docUpdate = 'doc_update';
  static const peerDisconnect = 'peer_disconnect';
}
