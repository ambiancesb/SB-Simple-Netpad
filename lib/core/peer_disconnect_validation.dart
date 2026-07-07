/// Whether a [peer_disconnect] message may disconnect [payloadPeerId].
///
/// The payload must name the sender's own peer id — a hub peer cannot
/// disconnect an unrelated third party.
bool shouldHonorPeerDisconnect({
  required String? senderPeerId,
  required String payloadPeerId,
}) {
  if (payloadPeerId.isEmpty || senderPeerId == null) return false;
  return senderPeerId == payloadPeerId;
}
