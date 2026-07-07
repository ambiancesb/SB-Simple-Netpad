import 'dart:io';

import 'package:netpad/core/local_network.dart';
import 'package:netpad/core/models/peer.dart';

/// Resolves a connectable host for LAN WebSocket URLs (Linux/Avahi friendly).
class PeerHostResolver {
  /// Picks the best local-network address from mDNS results and falls back to
  /// hostname lookup.
  static Future<String?> resolveConnectHost(Peer peer) async {
    final fromList = _pickBestAddress(peer.hostAddresses);
    if (fromList != null) return fromList;

    final hostname = peer.hostname;
    if (hostname != null && hostname.isNotEmpty) {
      final lookedUp = await _lookupHostname(hostname);
      if (lookedUp != null) return lookedUp;
    }

    if (peer.isManual) {
      final manualHost = peer.primaryHost;
      if (manualHost != null && manualHost.isNotEmpty) {
        if (LocalNetwork.isLanReachableHost(manualHost)) {
          return manualHost;
        }
        return _lookupHostname(manualHost);
      }
    }

    return null;
  }

  /// Formats host for `ws://` — brackets IPv6, strips zone IDs.
  static String formatForWebSocket(String host) {
    var h = LocalNetwork.stripZoneId(host);

    final addr = InternetAddress.tryParse(h);
    if (addr != null && addr.type == InternetAddressType.IPv6) {
      return '[$h]';
    }
    return h;
  }

  static String? _pickBestAddress(List<String> addresses) {
    String? ipv4;
    String? ipv6;

    for (final raw in addresses) {
      final host = LocalNetwork.stripZoneId(raw);
      final addr = InternetAddress.tryParse(host);
      if (addr == null) continue;

      if (!LocalNetwork.isLanReachable(addr)) continue;

      if (addr.type == InternetAddressType.IPv4) {
        ipv4 = host;
        break;
      } else if (addr.type == InternetAddressType.IPv6) {
        ipv6 ??= host;
      }
    }

    return ipv4 ?? ipv6;
  }

  static Future<String?> _lookupHostname(String hostname) async {
    try {
      final results = await InternetAddress.lookup(
        hostname,
        type: InternetAddressType.IPv4,
      );
      if (results.isEmpty) {
        final v6 = await InternetAddress.lookup(hostname);
        return _pickBestAddress(v6.map((a) => a.address).toList());
      }
      return _pickBestAddress(results.map((a) => a.address).toList());
    } catch (_) {
      return null;
    }
  }
}
