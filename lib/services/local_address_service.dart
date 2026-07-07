import 'dart:io';

import 'package:netpad/core/local_network.dart';

/// Finds a likely LAN IPv4 address for this device.
class LocalAddressService {
  static Future<String?> getLanIpv4() async {
    await LocalNetwork.refreshActiveSubnets();
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: true,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        if (LocalNetwork.isCellularInterfaceName(iface.name)) continue;
        for (final addr in iface.addresses) {
          if (addr.isLoopback) continue;
          if (LocalNetwork.isLanReachable(addr)) return addr.address;
        }
      }
      // Last resort: first private IPv4 on a non-cellular interface.
      for (final iface in interfaces) {
        if (LocalNetwork.isCellularInterfaceName(iface.name)) continue;
        for (final addr in iface.addresses) {
          if (addr.isLoopback) continue;
          if (LocalNetwork.isPrivateLanAddress(addr) &&
              !LocalNetwork.isCarrierGradeNat(addr)) {
            return addr.address;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
