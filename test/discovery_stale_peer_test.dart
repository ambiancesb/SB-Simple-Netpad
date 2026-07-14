import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/local_network.dart';
import 'package:netpad/core/models/peer.dart';

void main() {
  group('Peer stale helpers', () {
    test('manual peers are identifiable for TTL exemption', () {
      final peer = Peer.manual(host: '192.168.1.10', port: 12345);
      expect(peer.isManual, isTrue);
      expect(peer.id.startsWith('manual:'), isTrue);
    });

    test('discovered peers are not manual', () {
      final peer = Peer(
        id: 'abc',
        displayName: 'Phone',
        port: 12345,
        hostAddresses: const ['192.168.1.20'],
      );
      expect(peer.isManual, isFalse);
    });
  });

  group('NetworkMonitor signature stability', () {
    tearDown(LocalNetwork.clearActiveSubnetsForTesting);

    test('active subnet signature ignores address-order-only churn', () {
      final a = Subnet.fromAddress(
        InternetAddress('192.168.1.10'),
        24,
      );
      final b = Subnet.fromAddress(
        InternetAddress('10.0.0.5'),
        16,
      );
      LocalNetwork.setActiveSubnetsForTesting([a, b]);
      final first = _subnetSignature();
      LocalNetwork.setActiveSubnetsForTesting([b, a]);
      expect(_subnetSignature(), first);
    });

    test('active subnet signature changes when LAN segment changes', () {
      LocalNetwork.setActiveSubnetsForTesting([
        Subnet.fromAddress(InternetAddress('192.168.1.10'), 24),
      ]);
      final first = _subnetSignature();
      LocalNetwork.setActiveSubnetsForTesting([
        Subnet.fromAddress(InternetAddress('192.168.2.10'), 24),
      ]);
      expect(_subnetSignature(), isNot(first));
    });
  });
}

/// Mirrors DiscoveryRepository / NetworkMonitor subnet signature formatting.
String _subnetSignature() {
  final parts = LocalNetwork.activeSubnets
      .map((s) => '${s.base.address}/${s.prefixLength}')
      .toList()
    ..sort();
  return parts.join(',');
}
