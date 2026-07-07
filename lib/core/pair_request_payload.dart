import 'package:netpad/core/constants.dart';

/// Builds the `pair_request` payload for an outbound connect.
Map<String, dynamic> buildPairRequestPayload({
  required String requestId,
  required String fromId,
  required String fromName,
  required String certFingerprint,
  String? autoSyncToken,
}) {
  final payload = <String, dynamic>{
    'requestId': requestId,
    'fromId': fromId,
    'fromName': fromName,
    'protocolVersion': kProtocolVersion,
    'certFingerprint': certFingerprint,
  };
  if (autoSyncToken != null && autoSyncToken.isNotEmpty) {
    payload['autoSyncToken'] = autoSyncToken;
  }
  return payload;
}

/// Whether [trustStore] will attach an auto-sync token for [peerId].
bool shouldSendAutoSyncToken({
  required bool canAutoSync,
  String? autoSyncToken,
}) {
  return canAutoSync && autoSyncToken != null && autoSyncToken.isNotEmpty;
}
