import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/local_network.dart';

void main() {
  group('Subnet', () {
    test('contains peers on the same /24 segment', () {
      final subnet = Subnet.fromAddress(_v4(192, 168, 1, 10), 24);
      expect(subnet.contains(_v4(192, 168, 1, 99)), isTrue);
      expect(subnet.contains(_v4(192, 168, 2, 10)), isFalse);
    });

    test('does not treat all of 192.168.0.0/16 as one segment', () {
      final subnet = Subnet.fromAddress(_v4(192, 168, 1, 10), 24);
      expect(subnet.contains(_v4(192, 168, 5, 10)), isFalse);
    });

    test('respects /16 prefix when configured', () {
      final subnet = Subnet.fromAddress(_v4(192, 168, 1, 10), 16);
      expect(subnet.contains(_v4(192, 168, 5, 10)), isTrue);
      expect(subnet.contains(_v4(192, 169, 1, 10)), isFalse);
    });

    test('contains peers on the same /24 in 10.0.0.0 space', () {
      final subnet = Subnet.fromAddress(_v4(10, 0, 1, 5), 24);
      expect(subnet.contains(_v4(10, 0, 1, 200)), isTrue);
      expect(subnet.contains(_v4(10, 0, 2, 5)), isFalse);
    });

    test('IPv6 link-local uses /64', () {
      final subnet = Subnet.fromAddress(
        InternetAddress('fe80::1'),
        64,
      );
      expect(
        subnet.contains(InternetAddress('fe80::abcd:1')),
        isTrue,
      );
      expect(
        subnet.contains(InternetAddress('fe80:1::1')),
        isFalse,
      );
    });
  });

  group('LocalNetwork', () {
    test('isOnActiveSubnet uses cached active subnets', () {
      final subnet = Subnet.fromAddress(_v4(192, 168, 77, 1), 24);
      LocalNetwork.setActiveSubnetsForTesting([subnet]);

      expect(LocalNetwork.isOnActiveSubnet(_v4(192, 168, 77, 42)), isTrue);
      expect(LocalNetwork.isOnActiveSubnet(_v4(192, 168, 78, 42)), isFalse);
      expect(LocalNetwork.isOnActiveSubnet(_v4(8, 8, 8, 8)), isFalse);

      LocalNetwork.clearActiveSubnetsForTesting();
    });

    test('isLanReachableHost parses literals against cache', () {
      LocalNetwork.setActiveSubnetsForTesting([
        Subnet.fromAddress(_v4(192, 168, 3, 1), 24),
      ]);

      expect(LocalNetwork.isLanReachableHost('192.168.3.50'), isTrue);
      expect(LocalNetwork.isLanReachableHost('192.168.4.50'), isFalse);
      expect(LocalNetwork.isLanReachableHost('203.0.113.5'), isFalse);

      LocalNetwork.clearActiveSubnetsForTesting();
    });

    test('isOnActiveSubnet falls back to same /24 when cache is empty', () {
      LocalNetwork.clearActiveSubnetsForTesting();
      LocalNetwork.setLocalPrivateAddressesForTesting([_v4(192, 168, 5, 1)]);

      expect(LocalNetwork.isOnActiveSubnet(_v4(192, 168, 5, 42)), isTrue);
      expect(LocalNetwork.isOnActiveSubnet(_v4(192, 168, 6, 42)), isFalse);

      LocalNetwork.clearActiveSubnetsForTesting();
    });

    test('isLanReachable trusts private LAN when interface cache is empty', () {
      LocalNetwork.clearActiveSubnetsForTesting();

      expect(LocalNetwork.isLanReachable(_v4(192, 168, 9, 10)), isTrue);
      expect(LocalNetwork.isLanReachable(_v4(8, 8, 8, 8)), isFalse);
      expect(LocalNetwork.isLanReachable(_v4(100, 64, 0, 1)), isFalse);

      LocalNetwork.clearActiveSubnetsForTesting();
    });

    test('isLanReachable allows 10.x peers on same /16 segment', () {
      LocalNetwork.setActiveSubnetsForTesting([
        Subnet.fromAddress(_v4(10, 82, 68, 136), 16),
      ]);
      LocalNetwork.setLocalPrivateAddressesForTesting([_v4(10, 82, 68, 136)]);

      expect(LocalNetwork.isLanReachable(_v4(10, 82, 71, 102)), isTrue);
      expect(LocalNetwork.isLanReachable(_v4(10, 83, 71, 102)), isFalse);
      expect(LocalNetwork.isLanReachable(_v4(192, 168, 71, 102)), isFalse);

      LocalNetwork.clearActiveSubnetsForTesting();
    });

    test('isLikelySameLanSegment uses /24 for 192.168.x', () {
      LocalNetwork.setLocalPrivateAddressesForTesting([_v4(192, 168, 1, 10)]);

      expect(LocalNetwork.isLanReachable(_v4(192, 168, 1, 99)), isTrue);
      expect(LocalNetwork.isLanReachable(_v4(192, 168, 2, 99)), isFalse);

      LocalNetwork.clearActiveSubnetsForTesting();
    });

    test('isCarrierGradeNat identifies 100.64/10', () {
      expect(LocalNetwork.isCarrierGradeNat(_v4(100, 64, 0, 1)), isTrue);
      expect(LocalNetwork.isCarrierGradeNat(_v4(192, 168, 1, 1)), isFalse);
    });
  });
}

InternetAddress _v4(int a, int b, int c, int d) {
  return InternetAddress.fromRawAddress(Uint8List.fromList([a, b, c, d]));
}
