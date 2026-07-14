/// Inbound mid-session trust offer awaiting Accept / Decline.
class TrustOffer {
  const TrustOffer({
    required this.requestId,
    required this.fromId,
    required this.fromName,
    required this.connectionId,
    required this.verificationCode,
  });

  final String requestId;
  final String fromId;
  final String fromName;

  /// Authenticated WebSocket connection id used to send the response.
  final String connectionId;

  /// Display-only code both devices can compare (same as pairing).
  final String verificationCode;
}
