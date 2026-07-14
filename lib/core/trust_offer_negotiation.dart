import 'package:netpad/core/pairing_negotiation.dart';

/// Whether this device owns auto-sync token issuance for a simultaneous
/// mid-session trust offer (lexicographically smaller instance id).
bool ownsTrustTokenIssuance(String localInstanceId, String remoteInstanceId) {
  return outboundPairingWins(localInstanceId, remoteInstanceId);
}

/// How to handle an inbound [trust_offer] when an outbound offer is also pending.
enum SimultaneousTrustAction {
  /// Issue token, store trust, respond to the peer's requestId.
  completeAsIssuer,

  /// Do not show a dialog; wait for [trust_response] to our outbound offer.
  waitForPeerResponse,
}

SimultaneousTrustAction simultaneousTrustAction({
  required String localInstanceId,
  required String remoteInstanceId,
}) {
  return ownsTrustTokenIssuance(localInstanceId, remoteInstanceId)
      ? SimultaneousTrustAction.completeAsIssuer
      : SimultaneousTrustAction.waitForPeerResponse;
}
