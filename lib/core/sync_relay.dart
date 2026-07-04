/// One peer link and its authenticated connection ids (inbound and/or outbound).
class SyncPeerLink {
  const SyncPeerLink({
    required this.peerId,
    required this.authenticated,
    this.inboundConnectionId,
    this.outboundConnectionId,
  });

  final String peerId;
  final bool authenticated;
  final String? inboundConnectionId;
  final String? outboundConnectionId;
}

/// Authenticated connections that should receive a relayed message.
///
/// Excludes the sender connection and every connection belonging to the sender
/// peer so edits are not echoed back to the origin device.
Iterable<String> relayConnectionTargets({
  required Iterable<SyncPeerLink> links,
  required Map<String, String> connectionToPeerId,
  required String fromConnectionId,
}) {
  final fromPeerId = connectionToPeerId[fromConnectionId];
  return authenticatedConnectionIds(
    links: links,
    exceptConnectionId: fromConnectionId,
    exceptPeerId: fromPeerId,
  );
}

/// All authenticated connections except optional sender filters.
Iterable<String> authenticatedConnectionIds({
  required Iterable<SyncPeerLink> links,
  String? exceptConnectionId,
  String? exceptPeerId,
}) sync* {
  for (final link in links) {
    if (!link.authenticated) continue;
    if (link.peerId == exceptPeerId) continue;

    final inbound = link.inboundConnectionId;
    if (inbound != null && inbound != exceptConnectionId) {
      yield inbound;
    }

    final outbound = link.outboundConnectionId;
    if (outbound != null && outbound != exceptConnectionId) {
      yield outbound;
    }
  }
}
