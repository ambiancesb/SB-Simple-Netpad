import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/services/network_link_service.dart';

void main() {
  group('NetworkLinkService.evaluateFromFacts', () {
    test('allows sync when subnets or non-cellular private LAN exist', () {
      expect(
        NetworkLinkService.evaluateFromFacts(
          hasActiveSubnets: true,
          hasNonCellularPrivate: false,
          hasWifiOrEthernet: false,
          hasCellular: true,
        ).canSync,
        isTrue,
      );
      expect(
        NetworkLinkService.evaluateFromFacts(
          hasActiveSubnets: false,
          hasNonCellularPrivate: true,
          hasWifiOrEthernet: false,
          hasCellular: true,
        ).canSync,
        isTrue,
      );
      expect(
        NetworkLinkService.evaluateFromFacts(
          hasActiveSubnets: false,
          hasNonCellularPrivate: false,
          hasWifiOrEthernet: true,
          hasCellular: true,
        ).canSync,
        isTrue,
      );
    });

    test('allows sync when native Android LAN transport is reported', () {
      expect(
        NetworkLinkService.evaluateFromFacts(
          hasActiveSubnets: false,
          hasNonCellularPrivate: false,
          hasWifiOrEthernet: false,
          hasCellular: true,
          hasNativeLan: true,
        ).canSync,
        isTrue,
      );
    });

    test('pauses sync only on cellular with no LAN', () {
      final status = NetworkLinkService.evaluateFromFacts(
        hasActiveSubnets: false,
        hasNonCellularPrivate: false,
        hasWifiOrEthernet: false,
        hasCellular: true,
      );
      expect(status.canSync, isFalse);
      expect(status.note, isNotNull);
    });

    test('allows sync when offline with no cellular', () {
      expect(
        NetworkLinkService.evaluateFromFacts(
          hasActiveSubnets: false,
          hasNonCellularPrivate: false,
          hasWifiOrEthernet: false,
          hasCellular: false,
        ).canSync,
        isTrue,
      );
    });
  });
}
