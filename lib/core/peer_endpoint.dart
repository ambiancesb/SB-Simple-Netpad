import 'dart:io';

import 'package:netpad/core/local_network.dart';

/// Normalizes peer connect addresses from mDNS / TXT records.
abstract final class PeerEndpoint {
  static bool isLoopbackHost(String host) {
    final parsed = InternetAddress.tryParse(LocalNetwork.stripZoneId(host));
    if (parsed != null) return parsed.isLoopback;
    final lower = host.trim().toLowerCase();
    return lower == 'localhost' || lower.endsWith('.localhost');
  }

  /// Merges a TXT `ip` hint with resolved addresses, dropping loopback hosts.
  static List<String> usableAddresses(
    Iterable<String> addresses, {
    String? txtIp,
  }) {
    final out = <String>[];
    void add(String? raw) {
      if (raw == null || raw.isEmpty) return;
      final host = LocalNetwork.stripZoneId(raw);
      if (isLoopbackHost(host)) return;
      if (!LocalNetwork.isLanReachableHost(host)) return;
      if (!out.contains(host)) out.add(host);
    }

    add(txtIp);
    for (final raw in addresses) {
      add(raw);
    }
    return out;
  }

  static String? usableHostname(String? hostname) {
    if (hostname == null || hostname.isEmpty) return null;
    if (isLoopbackHost(hostname)) return null;
    return hostname;
  }
}
