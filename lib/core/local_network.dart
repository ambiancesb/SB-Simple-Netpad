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
  static List<InternetAddress> _localPrivateAddresses = [];

  static List<Subnet> get activeSubnets => List.unmodifiable(_activeSubnets);

  /// Replaces cached subnets in unit tests.
  static void setActiveSubnetsForTesting(List<Subnet> subnets) {
    _activeSubnets = List<Subnet>.from(subnets);
  }

  /// Replaces cached private LAN addresses in unit tests.
  static void setLocalPrivateAddressesForTesting(List<InternetAddress> addresses) {
    _localPrivateAddresses = List<InternetAddress>.from(addresses);
  }

  /// Clears cached subnets in unit tests.
  static void clearActiveSubnetsForTesting() {
    _activeSubnets = [];
    _localPrivateAddresses = [];
  }

  /// True for RFC1918 / CGNAT IPv4 and link-local or ULA IPv6.
  static bool isPrivateLanAddress(InternetAddress addr) {
    return switch (addr.type) {
      InternetAddressType.IPv4 => _isPrivateIpv4(addr),
      InternetAddressType.IPv6 =>
        _isLinkLocalIpv6(addr) || _isUlaIpv6(addr),
      _ => false,
    };
  }

  /// True when [addr] is on an active subnet or the same private LAN segment.
  static bool isLanReachable(InternetAddress addr) {
    if (isOnActiveSubnet(addr)) return true;
    if (isLikelySameLanSegment(addr)) return true;
    // Interface cache can be empty on Android while mDNS already resolves peers.
    if (_activeSubnets.isEmpty &&
        _localPrivateAddresses.isEmpty &&
        isPrivateLanAddress(addr) &&
        !isCarrierGradeNat(addr)) {
      return true;
    }
    return false;
  }

  /// True when [addr] shares a private LAN segment with a local interface.
  ///
  /// Uses /16 for `10.0.0.0/8` (common on large Wi‑Fi deployments with mDNS
  /// reflectors) and /24 for other RFC1918 IPv4; /64 for private IPv6.
  static bool isLikelySameLanSegment(InternetAddress addr) {
    if (addr.isLoopback || !isPrivateLanAddress(addr) || isCarrierGradeNat(addr)) {
      return false;
    }
    if (addr.type == InternetAddressType.IPv4) {
      return _localPrivateAddresses.any(
        (local) =>
            local.type == InternetAddressType.IPv4 &&
            _sameIpv4PrivateSegment(local, addr),
      );
    }
    if (addr.type == InternetAddressType.IPv6) {
      return _localPrivateAddresses.any(
        (local) =>
            local.type == InternetAddressType.IPv6 &&
            _sameIpv6Prefix64(local, addr),
      );
    }
    return false;
  }

  /// True when a Wi‑Fi, AP, or Ethernet interface has an IPv4 address.
  static Future<bool> hasWifiOrEthernetIpv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        if (isCellularInterfaceName(iface.name)) continue;
        final name = iface.name.toLowerCase();
        if (!_isLanInterfaceName(name)) continue;
        if (iface.addresses.any((a) => !a.isLoopback)) return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Wi‑Fi/Ethernet interface with a private IPv4, for mDNS bind on mobile.
  static Future<NetworkInterface?> preferredLanInterface() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      NetworkInterface? fallback;
      for (final iface in interfaces) {
        if (isCellularInterfaceName(iface.name)) continue;
        final hasPrivate = iface.addresses.any(
          (a) =>
              !a.isLoopback &&
              isPrivateLanAddress(a) &&
              !isCarrierGradeNat(a),
        );
        if (!hasPrivate) continue;
        if (_isLanInterfaceName(iface.name)) return iface;
        fallback ??= iface;
      }
      return fallback;
    } catch (_) {
      return null;
    }
  }

  static bool _isLanInterfaceName(String name) {
    final n = name.toLowerCase();
    return n.startsWith('wlan') ||
        n.startsWith('wifi') ||
        n.startsWith('swlan') ||
        n.startsWith('ap') ||
        n.startsWith('eth') ||
        n.startsWith('en') ||
        n.startsWith('bond') ||
        n.contains('p2p');
  }

  /// True when a non-cellular interface currently has a private LAN address.
  static Future<bool> hasNonCellularPrivateAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (final iface in interfaces) {
        if (isCellularInterfaceName(iface.name)) continue;
        for (final addr in iface.addresses) {
          if (isPrivateLanAddress(addr) && !isCarrierGradeNat(addr)) {
            return true;
          }
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Rebuilds cached subnets from current non-cellular interfaces.
  static Future<void> refreshActiveSubnets() async {
    final subnets = <Subnet>{};
    final privateAddresses = <InternetAddress>[];
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (final iface in interfaces) {
        if (isCellularInterfaceName(iface.name)) continue;
        for (final addr in iface.addresses) {
          if (isPrivateLanAddress(addr) && !isCarrierGradeNat(addr)) {
            privateAddresses.add(addr);
          }
          final subnet = _subnetForInterfaceAddress(addr);
          if (subnet != null) subnets.add(subnet);
        }
      }
    } catch (_) {
      // Keep the previous cache when enumeration fails.
      return;
    }
    _localPrivateAddresses = privateAddresses;
    _activeSubnets = subnets.toList();
  }

  /// Returns true when [addr] lies on a currently active local subnet.
  static bool isOnActiveSubnet(InternetAddress addr) {
    if (addr.isLoopback) return false;
    if (_activeSubnets.isNotEmpty) {
      return _activeSubnets.any((subnet) => subnet.contains(addr));
    }
    // Subnet cache can lag on mobile (Wi‑Fi up before routes are enumerated).
    if (!isPrivateLanAddress(addr) || isCarrierGradeNat(addr)) return false;
    if (addr.type == InternetAddressType.IPv4) {
      return _localPrivateAddresses.any(
        (local) =>
            local.type == InternetAddressType.IPv4 &&
            _sameIpv4PrivateSegment(local, addr),
      );
    }
    if (addr.type == InternetAddressType.IPv6) {
      return _localPrivateAddresses.any(
        (local) =>
            local.type == InternetAddressType.IPv6 &&
            _sameIpv6Prefix64(local, addr),
      );
    }
    return false;
  }

  /// Returns true when [host] is an IP literal on the LAN.
  static bool isLanReachableHost(String host) {
    final parsed = InternetAddress.tryParse(stripZoneId(host));
    if (parsed == null) return false;
    return isLanReachable(parsed);
  }

  /// Resolves [host] and returns true only when every address is on an active
  /// subnet.
  static Future<bool> resolvesToActiveSubnet(String host) async {
    await refreshActiveSubnets();
    final literal = InternetAddress.tryParse(stripZoneId(host));
    if (literal != null) return isLanReachable(literal);

    try {
      final results = await InternetAddress.lookup(host);
      if (results.isEmpty) return false;
      return results.every(isLanReachable);
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
    if (o[0] == 10) return 16;
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

  static bool _sameIpv4Prefix24(InternetAddress a, InternetAddress b) {
    if (a.type != InternetAddressType.IPv4 || b.type != InternetAddressType.IPv4) {
      return false;
    }
    final la = a.rawAddress;
    final lb = b.rawAddress;
    if (la.length != 4 || lb.length != 4) return false;
    return la[0] == lb[0] && la[1] == lb[1] && la[2] == lb[2];
  }

  static int _ipv4PrivateSegmentPrefixBits(InternetAddress a, InternetAddress b) {
    if (a.type != InternetAddressType.IPv4 || b.type != InternetAddressType.IPv4) {
      return 24;
    }
    final la = a.rawAddress;
    final lb = b.rawAddress;
    if (la.length != 4 || lb.length != 4) return 24;
    if (la[0] == 10 && lb[0] == 10) return 16;
    return 24;
  }

  static bool _sameIpv4PrivateSegment(InternetAddress a, InternetAddress b) {
    final bits = _ipv4PrivateSegmentPrefixBits(a, b);
    if (bits == 16) {
      final la = a.rawAddress;
      final lb = b.rawAddress;
      return la[0] == lb[0] && la[1] == lb[1];
    }
    return _sameIpv4Prefix24(a, b);
  }

  static bool _sameIpv6Prefix64(InternetAddress a, InternetAddress b) {
    if (a.type != InternetAddressType.IPv6 || b.type != InternetAddressType.IPv6) {
      return false;
    }
    final la = a.rawAddress;
    final lb = b.rawAddress;
    if (la.length != 16 || lb.length != 16) return false;
    for (var i = 0; i < 8; i++) {
      if (la[i] != lb[i]) return false;
    }
    return true;
  }
}
