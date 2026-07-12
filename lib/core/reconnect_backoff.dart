import 'dart:io';

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

/// True when [e] means the peer TCP port is not accepting connections.
bool isConnectionRefusedException(SocketException e) {
  final code = e.osError?.errorCode;
  // Linux/Android ECONNREFUSED=111, Windows WSAECONNREFUSED=10061.
  if (code == 111 || code == 10061) return true;
  return e.message.toLowerCase().contains('refused');
}
