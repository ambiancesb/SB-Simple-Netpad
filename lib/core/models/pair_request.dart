class PairRequest {
  const PairRequest({
    required this.requestId,
    required this.fromId,
    required this.fromName,
    required this.connectionId,
    required this.verificationCode,
  });

  final String requestId;
  final String fromId;
  final String fromName;

  /// Inbound WebSocket connection id (server-side).
  final String connectionId;

  /// Display-only code both devices can compare before accepting.
  final String verificationCode;
}
