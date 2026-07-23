import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Temporary debug-session logger (session 240d60). Remove after verification.
void agentDebugLog({
  required String location,
  required String message,
  required String hypothesisId,
  Map<String, Object?> data = const {},
}) {
  // #region agent log
  final payload = <String, Object?>{
    'sessionId': '240d60',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  final line = jsonEncode(payload);
  debugPrint('[DBG240d60] $line');
  try {
    File(
      '/home/spencer/Coding Projects/SB-Simple-Netpad/.cursor/debug-240d60.log',
    ).writeAsStringSync('$line\n', mode: FileMode.append);
  } catch (_) {}
  for (final host in ['127.0.0.1', '10.0.2.2']) {
    () async {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(milliseconds: 400);
        final req = await client.postUrl(
          Uri.parse(
            'http://$host:7877/ingest/8e21d020-7821-4dd7-89ad-aa9e7ae70f27',
          ),
        );
        req.headers.set('Content-Type', 'application/json');
        req.headers.set('X-Debug-Session-Id', '240d60');
        req.write(line);
        final resp = await req.close();
        await resp.drain<void>();
        client.close(force: true);
      } catch (_) {}
    }();
  }
  // #endregion
}
