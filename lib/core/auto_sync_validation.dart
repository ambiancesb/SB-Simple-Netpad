import 'package:netpad/core/constants.dart';

/// Whether an inbound [pair_request] may be auto-accepted without a dialog.
bool canAutoAcceptPairRequest({
  required bool isBlocked,
  required int peerProtocol,
  required bool alreadyConnected,
  required bool canAutoSync,
  required String? storedToken,
  required String? requestToken,
  required String? pinnedFingerprint,
  required String? requestFingerprint,
}) {
  if (isBlocked || alreadyConnected) return false;
  if (peerProtocol != kProtocolVersion) return false;
  if (requestToken == null || requestToken.isEmpty) return false;
  if (!canAutoSync) return false;
  if (storedToken == null || storedToken.isEmpty) return false;
  if (storedToken != requestToken) return false;
  if (pinnedFingerprint == null || pinnedFingerprint.isEmpty) return false;
  if (requestFingerprint == null || requestFingerprint.isEmpty) return false;
  return pinnedFingerprint == requestFingerprint;
}

/// Refuses a trusted reconnect when the request carries a token but the cert
/// fingerprint does not match the stored pin (possible impersonation).
bool shouldRefuseTrustedReconnect({
  required String? requestToken,
  required String? pinnedFingerprint,
  required String? requestFingerprint,
}) {
  if (requestToken == null || requestToken.isEmpty) return false;
  if (pinnedFingerprint == null || pinnedFingerprint.isEmpty) return false;
  if (requestFingerprint == null || requestFingerprint.isEmpty) return false;
  return pinnedFingerprint != requestFingerprint;
}
