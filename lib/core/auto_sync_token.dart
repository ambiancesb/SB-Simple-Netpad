import 'dart:convert';
import 'dart:math';

/// Generates a cryptographically random auto-sync token (32 bytes, base64url).
String generateAutoSyncToken() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}
