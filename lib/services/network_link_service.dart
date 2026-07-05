import 'dart:io';

import 'package:netpad/core/local_network.dart';

/// Describes whether this device can participate in LAN peer sync right now.
class NetworkLinkStatus {
  const NetworkLinkStatus({required this.canSync, this.note});

  final bool canSync;
  final String? note;
}

/// Classifies active network interfaces (Wi‑Fi vs cellular) for sync policy.
class NetworkLinkService {
  static Future<NetworkLinkStatus> evaluate() async {
    try {
      await LocalNetwork.refreshActiveSubnets();
      if (LocalNetwork.activeSubnets.isNotEmpty) {
        return const NetworkLinkStatus(canSync: true);
      }

      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );

      var hasCellular = false;
      for (final iface in interfaces) {
        if (!LocalNetwork.isCellularInterfaceName(iface.name)) continue;
        if (iface.addresses.isEmpty) continue;
        hasCellular = true;
      }

      if (hasCellular) {
        return const NetworkLinkStatus(
          canSync: false,
          note:
              'Cellular data is not used for peer discovery. Netpad does not '
              'scan or advertise on mobile networks — connect to Wi‑Fi or a '
              'personal hotspot first.',
        );
      }

      // Desktop offline, or interfaces not classified — allow discovery to try.
      return const NetworkLinkStatus(canSync: true);
    } catch (_) {
      return const NetworkLinkStatus(canSync: true);
    }
  }
}
