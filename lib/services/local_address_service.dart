import 'dart:io';

import 'package:netpad/core/local_network.dart';

/// Finds a likely LAN IPv4 address for this device.
class LocalAddressService {
  static Future<String?> getLanIpv4() async {
    await LocalNetwork.refreshActiveSubnets();
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.isLoopback) continue;
          if (LocalNetwork.isOnActiveSubnet(addr)) return addr.address;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
