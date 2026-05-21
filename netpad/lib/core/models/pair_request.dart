class PairRequest {
  const PairRequest({
    required this.requestId,
    required this.fromId,
    required this.fromName,
    required this.connectionId,
  });

  final String requestId;
  final String fromId;
  final String fromName;

  /// Inbound WebSocket connection id (server-side).
  final String connectionId;
}
