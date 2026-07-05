import 'dart:io';
import 'dart:typed_data';

InternetAddress _maskedAddress(InternetAddress addr, int prefixLength) {
  final bytes = List<int>.from(addr.rawAddress);
  final maxBits = bytes.length * 8;
  final clamped = prefixLength.clamp(0, maxBits);

  for (var bit = clamped; bit < maxBits; bit++) {
    bytes[bit ~/ 8] &= ~(1 << (7 - (bit % 8)));
  }

  return InternetAddress.fromRawAddress(Uint8List.fromList(bytes));
}

bool _addressEquals(InternetAddress a, InternetAddress b) {
  if (a.type != b.type) return false;
  final left = a.rawAddress;
  final right = b.rawAddress;
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

/// A single IPv4 or IPv6 network prefix derived from an active interface.
final class Subnet {
  Subnet({required this.base, required this.prefixLength})
    : assert(
        prefixLength >= 0 &&
            prefixLength <= (base.type == InternetAddressType.IPv4 ? 32 : 128),
      );

  final InternetAddress base;
  final int prefixLength;

  factory Subnet.fromAddress(InternetAddress addr, int prefixLength) {
    return Subnet(
      base: _maskedAddress(addr, prefixLength),
      prefixLength: prefixLength,
    );
  }

  bool contains(InternetAddress addr) {
    if (addr.type != base.type) return false;
    return _addressEquals(_maskedAddress(addr, prefixLength), base);
  }

  @override
  bool operator ==(Object other) =>
      other is Subnet &&
      other.prefixLength == prefixLength &&
      _addressEquals(other.base, base);

  @override
  int get hashCode => Object.hash(base.address, prefixLength);
}

/// Local-network address policy for Netpad sync.
///
/// Peers must be on one of this device's **active subnets** (for example the
/// same `192.168.1.0/24` Wi‑Fi segment). Cellular interfaces are excluded
/// entirely — Netpad does not scan, advertise, or listen on mobile data.
abstract final class LocalNetwork {
  /// Seconds to wait for a valid Netpad `pair_request` before closing a socket.
  static const prePairTimeout = Duration(seconds: 8);

  static List<Subnet> _activeSubnets = [];

  static List<Subnet> get activeSubnets => List.unmodifiable(_activeSubnets);

  /// Replaces cached subnets in unit tests.
  static void setActiveSubnetsForTesting(List<Subnet> subnets) {
    _activeSubnets = List<Subnet>.from(subnets);
  }

  /// Clears cached subnets in unit tests.
  static void clearActiveSubnetsForTesting() {
    _activeSubnets = [];
  }

  /// Rebuilds cached subnets from current non-cellular interfaces.
  static Future<void> refreshActiveSubnets() async {
    final subnets = <Subnet>{};
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (final iface in interfaces) {
        if (isCellularInterfaceName(iface.name)) continue;
        for (final addr in iface.addresses) {
          final subnet = _subnetForInterfaceAddress(addr);
          if (subnet != null) subnets.add(subnet);
        }
      }
    } catch (_) {
      // Keep the previous cache when enumeration fails.
      return;
    }
    _activeSubnets = subnets.toList();
  }

  /// Returns true when [addr] lies on a currently active local subnet.
  static bool isOnActiveSubnet(InternetAddress addr) {
    if (addr.isLoopback || _activeSubnets.isEmpty) return false;
    return _activeSubnets.any((subnet) => subnet.contains(addr));
  }

  /// Returns true when [host] is an IP literal on an active subnet.
  static bool isOnActiveSubnetHost(String host) {
    final parsed = InternetAddress.tryParse(stripZoneId(host));
    if (parsed == null) return false;
    return isOnActiveSubnet(parsed);
  }

  /// Resolves [host] and returns true only when every address is on an active
  /// subnet.
  static Future<bool> resolvesToActiveSubnet(String host) async {
    await refreshActiveSubnets();
    final literal = InternetAddress.tryParse(stripZoneId(host));
    if (literal != null) return isOnActiveSubnet(literal);

    try {
      final results = await InternetAddress.lookup(host);
      if (results.isEmpty) return false;
      return results.every(isOnActiveSubnet);
    } catch (_) {
      return false;
    }
  }

  static String stripZoneId(String host) {
    final zoneIndex = host.indexOf('%');
    if (zoneIndex == -1) return host.trim();
    return host.substring(0, zoneIndex).trim();
  }

  /// Carrier-grade NAT (`100.64.0.0/10`) on a cellular interface — not LAN.
  static bool isCarrierGradeNat(InternetAddress addr) {
    if (addr.type != InternetAddressType.IPv4) return false;
    final o = addr.rawAddress;
    return o.length == 4 && o[0] == 100 && o[1] >= 64 && o[1] <= 127;
  }

  static bool isCellularInterfaceName(String name) {
    final n = name.toLowerCase();
    return n.startsWith('rmnet') ||
        n.startsWith('pdp_ip') ||
        n.startsWith('wwan') ||
        n.startsWith('cellular') ||
        n.startsWith('ccmni') ||
        n.contains('lte');
  }

  static Subnet? _subnetForInterfaceAddress(InternetAddress addr) {
    if (addr.isLoopback) return null;

    return switch (addr.type) {
      InternetAddressType.IPv4 => _subnetForIpv4(addr),
      InternetAddressType.IPv6 => _subnetForIpv6(addr),
      _ => null,
    };
  }

  static Subnet? _subnetForIpv4(InternetAddress addr) {
    final o = addr.rawAddress;
    if (o.length != 4) return null;
    if (o[0] == 169 && o[1] == 254) return null;
    if (!_isPrivateIpv4(addr)) return null;

    return Subnet.fromAddress(addr, _defaultPrefixLength(addr));
  }

  static Subnet? _subnetForIpv6(InternetAddress addr) {
    if (_isLinkLocalIpv6(addr)) {
      return Subnet.fromAddress(addr, 64);
    }
    if (_isUlaIpv6(addr)) {
      return Subnet.fromAddress(addr, 64);
    }
    return null;
  }

  static int _defaultPrefixLength(InternetAddress addr) {
    if (addr.type == InternetAddressType.IPv6) return 64;
    final o = addr.rawAddress;
    if (o.length != 4) return 24;
    if (o[0] == 100 && o[1] >= 64 && o[1] <= 127) return 32;
    return 24;
  }

  static bool _isPrivateIpv4(InternetAddress addr) {
    final o = addr.rawAddress;
    if (o.length != 4) return false;
    if (o[0] == 10) return true;
    if (o[0] == 172 && o[1] >= 16 && o[1] <= 31) return true;
    if (o[0] == 192 && o[1] == 168) return true;
    if (o[0] == 100 && o[1] >= 64 && o[1] <= 127) return true;
    return false;
  }

  static bool _isLinkLocalIpv6(InternetAddress addr) {
    final o = addr.rawAddress;
    return o.length == 16 && o[0] == 0xfe && (o[1] & 0xc0) == 0x80;
  }

  static bool _isUlaIpv6(InternetAddress addr) {
    final o = addr.rawAddress;
    return o.length == 16 && (o[0] & 0xfe) == 0xfc;
  }
}
