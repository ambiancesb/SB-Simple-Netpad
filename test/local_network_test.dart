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

    test('isOnActiveSubnetHost parses literals against cache', () {
      LocalNetwork.setActiveSubnetsForTesting([
        Subnet.fromAddress(_v4(192, 168, 3, 1), 24),
      ]);

      expect(LocalNetwork.isOnActiveSubnetHost('192.168.3.50'), isTrue);
      expect(LocalNetwork.isOnActiveSubnetHost('192.168.4.50'), isFalse);
      expect(LocalNetwork.isOnActiveSubnetHost('203.0.113.5'), isFalse);

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
