import 'dart:io';

/// Whether the D-Bus system bus socket is present (needed by Avahi via Bonsoir).
bool isLinuxSystemDBusAvailable() {
  if (!Platform.isLinux) return true;

  final fromEnv = Platform.environment['DBUS_SYSTEM_BUS_ADDRESS'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    final path = fromEnv.startsWith('unix:path=')
        ? fromEnv.substring('unix:path='.length)
        : fromEnv;
    if (File(path).existsSync()) return true;
  }

  for (final path in [
    '/run/dbus/system_bus_socket',
    '/var/run/dbus/system_bus_socket',
  ]) {
    if (File(path).existsSync()) return true;
  }
  return false;
}

bool isDbusNetworkingError(Object e) {
  final text = e.toString();
  return (e is SocketException && text.contains('system_bus_socket')) ||
      text.contains('system_bus_socket') ||
      text.contains('/var/run/dbus') ||
      text.contains('/run/dbus');
}
