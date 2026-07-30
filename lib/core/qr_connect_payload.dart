import 'package:netpad/features/peers/manual_connect_dialog.dart';

/// Encodes / decodes peer connection details for QR invite codes.
///
/// Preferred form: `sbnetpad://connect?host=…&port=…&name=…`
/// Also accepts plain `host:port` (same as the This device copy format).
abstract final class QrConnectPayload {
  static const scheme = 'sbnetpad';
  static const hostConnect = 'connect';

  static String encode({
    required String host,
    required int port,
    String? displayName,
  }) {
    final params = <String, String>{
      'host': host,
      'port': '$port',
    };
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      params['name'] = name;
    }
    return Uri(
      scheme: scheme,
      host: hostConnect,
      queryParameters: params,
    ).toString();
  }

  static ManualConnectResult? tryParse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final uri = Uri.tryParse(text);
    if (uri != null && uri.scheme == scheme) {
      return _fromUri(uri);
    }

    // Accept wss://host:port/ws (or similar) copied from tooling.
    if (uri != null &&
        (uri.scheme == 'wss' || uri.scheme == 'ws' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.hasPort) {
      return ManualConnectResult(
        host: uri.host,
        port: uri.port,
      );
    }

    return _fromHostPort(text);
  }

  static ManualConnectResult? _fromUri(Uri uri) {
    final host = uri.queryParameters['host']?.trim() ?? '';
    final port = int.tryParse(uri.queryParameters['port']?.trim() ?? '');
    if (host.isEmpty || port == null || port < 1 || port > 65535) {
      return null;
    }
    final name = uri.queryParameters['name']?.trim();
    return ManualConnectResult(
      host: host,
      port: port,
      displayName: (name == null || name.isEmpty) ? null : name,
    );
  }

  /// Parses `192.168.1.42:54321` or `[fe80::1]:54321`.
  static ManualConnectResult? _fromHostPort(String text) {
    if (text.startsWith('[')) {
      final end = text.indexOf(']');
      if (end <= 1 || end + 1 >= text.length || text[end + 1] != ':') {
        return null;
      }
      final host = text.substring(1, end);
      final port = int.tryParse(text.substring(end + 2));
      if (host.isEmpty || port == null || port < 1 || port > 65535) {
        return null;
      }
      return ManualConnectResult(host: host, port: port);
    }

    final sep = text.lastIndexOf(':');
    if (sep <= 0 || sep == text.length - 1) return null;
    final host = text.substring(0, sep).trim();
    final port = int.tryParse(text.substring(sep + 1).trim());
    if (host.isEmpty || port == null || port < 1 || port > 65535) {
      return null;
    }
    // Reject URLs accidentally missing a scheme that still contain '/'.
    if (host.contains('/')) return null;
    return ManualConnectResult(host: host, port: port);
  }
}
