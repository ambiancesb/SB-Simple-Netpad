import 'package:netpad/core/constants.dart';

class ProtocolMessage {
  const ProtocolMessage({required this.type, required this.payload});

  final String type;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
    'type': type,
    'v': kProtocolVersion,
    ...payload,
  };

  factory ProtocolMessage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final payload = Map<String, dynamic>.from(json)
      ..remove('type')
      ..remove('v');
    return ProtocolMessage(type: type, payload: payload);
  }

  /// Wire protocol version from the top-level `v` field (defaults to 1).
  static int versionFromJson(Map<String, dynamic> json) =>
      json['v'] as int? ?? 1;
}

/// Message type constants.
abstract final class MessageTypes {
  static const pairRequest = 'pair_request';
  static const pairResponse = 'pair_response';
  static const pairComplete = 'pair_complete';
  static const trustOffer = 'trust_offer';
  static const trustResponse = 'trust_response';
  static const docSnapshot = 'doc_snapshot';
  static const docUpdate = 'doc_update';
  static const docCreate = 'doc_create';
  static const docRename = 'doc_rename';
  static const docCatalog = 'doc_catalog';
  static const docReorder = 'doc_reorder';
  static const docDelete = 'doc_delete';
  static const peerDisconnect = 'peer_disconnect';
  static const presence = 'presence';
  static const ping = 'ping';
  static const pong = 'pong';
}
