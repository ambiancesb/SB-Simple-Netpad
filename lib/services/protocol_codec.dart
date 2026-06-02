import 'dart:convert';

import 'package:netpad/core/models/protocol_message.dart';

class ProtocolCodec {
  static String encode(ProtocolMessage message) => jsonEncode(message.toJson());

  static ProtocolMessage? decode(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return ProtocolMessage.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
