import 'dart:io';

/// Finds a likely LAN IPv4 address for this device.
class LocalAddressService {
  static Future<String?> getLanIpv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.isLoopback) continue;
          if (_isPrivateIpv4(addr)) return addr.address;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static bool _isPrivateIpv4(InternetAddress addr) {
    final o = addr.rawAddress;
    if (o.length != 4) return false;
    if (o[0] == 10) return true;
    if (o[0] == 172 && o[1] >= 16 && o[1] <= 31) return true;
    if (o[0] == 192 && o[1] == 168) return true;
    return false;
  }
}
