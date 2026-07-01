/// Tie-break when both peers initiate pairing at the same time.
///
/// The lexicographically smaller [localInstanceId] keeps its outbound request
/// and rejects the peer's inbound request; the larger id drops outbound and
/// accepts the peer's inbound flow.
bool outboundPairingWins(String localInstanceId, String remoteInstanceId) {
  return localInstanceId.compareTo(remoteInstanceId) < 0;
}
