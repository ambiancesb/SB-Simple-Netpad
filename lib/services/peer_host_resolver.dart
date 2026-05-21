import 'dart:io';

import 'package:netpad/core/models/peer.dart';

/// Resolves a connectable host for LAN WebSocket URLs (Linux/Avahi friendly).
class PeerHostResolver {
  /// Picks the best address from mDNS results and falls back to hostname lookup.
  static Future<String?> resolveConnectHost(Peer peer) async {
    final fromList = _pickBestAddress(peer.hostAddresses);
    if (fromList != null) return fromList;

    final hostname = peer.hostname;
    if (hostname != null && hostname.isNotEmpty) {
      final lookedUp = await _lookupHostname(hostname);
      if (lookedUp != null) return lookedUp;
    }

    return null;
  }

  /// Formats host for `ws://` — brackets IPv6, strips zone IDs.
  static String formatForWebSocket(String host) {
    var h = host.trim();
    final zoneIndex = h.indexOf('%');
    if (zoneIndex != -1) {
      h = h.substring(0, zoneIndex);
    }

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
      final zoneIndex = raw.indexOf('%');
      final host = zoneIndex == -1 ? raw : raw.substring(0, zoneIndex);
      final addr = InternetAddress.tryParse(host);
      if (addr == null) continue;

      if (addr.type == InternetAddressType.IPv4) {
        if (_isUsableLanIpv4(addr)) {
          ipv4 = host;
          break;
        }
        ipv4 ??= host;
      } else if (addr.type == InternetAddressType.IPv6) {
        if (!_isLoopback(addr)) {
          ipv6 ??= host;
        }
      }
    }

    return ipv4 ?? ipv6;
  }

  static bool _isUsableLanIpv4(InternetAddress addr) {
    if (addr.isLoopback) return false;
    final o = addr.rawAddress;
    if (o[0] == 169 && o[1] == 254) return false; // link-local APIPA
    return true;
  }

  static bool _isLoopback(InternetAddress addr) => addr.isLoopback;

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
