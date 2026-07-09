/// Computes how long to wait before retrying a trusted auto-reconnect.
Duration reconnectBackoffDuration({
  required int failureCount,
  required bool connectionRefused,
  required bool alreadyConnected,
}) {
  if (alreadyConnected) return const Duration(seconds: 30);
  if (connectionRefused) return const Duration(seconds: 20);
  const steps = [5, 10, 20, 30];
  final index = (failureCount - 1).clamp(0, steps.length - 1);
  return Duration(seconds: steps[index]);
}
