import 'dart:io';

import 'package:netpad/core/local_network.dart';
import 'package:netpad/services/android_networking.dart';

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

      final hasNonCellularPrivate =
          await LocalNetwork.hasNonCellularPrivateAddress();
      final hasWifi = await LocalNetwork.hasWifiOrEthernetIpv4();
      final hasNativeLan =
          Platform.isAndroid && await AndroidNetworking.hasLanTransport();
      if (hasNonCellularPrivate || hasWifi || hasNativeLan) {
        // Wi‑Fi or Ethernet is up but subnet cache missed it (common on
        // Android when mobile data is also active).
        return const NetworkLinkStatus(canSync: true);
      }

      final hasCellular = await _hasActiveCellularInterface();
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

  /// Testable policy given precomputed interface facts.
  static NetworkLinkStatus evaluateFromFacts({
    required bool hasActiveSubnets,
    required bool hasNonCellularPrivate,
    required bool hasWifiOrEthernet,
    required bool hasCellular,
    bool hasNativeLan = false,
  }) {
    if (hasActiveSubnets ||
        hasNonCellularPrivate ||
        hasWifiOrEthernet ||
        hasNativeLan) {
      return const NetworkLinkStatus(canSync: true);
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
    return const NetworkLinkStatus(canSync: true);
  }

  static Future<bool> _hasActiveCellularInterface() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.any,
    );
    for (final iface in interfaces) {
      if (!LocalNetwork.isCellularInterfaceName(iface.name)) continue;
      if (iface.addresses.isEmpty) continue;
      return true;
    }
    return false;
  }
}
