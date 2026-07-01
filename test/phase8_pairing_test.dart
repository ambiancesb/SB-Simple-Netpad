import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/pairing_negotiation.dart';

void main() {
  group('outboundPairingWins', () {
    test('smaller instance id keeps outbound pairing', () {
      expect(
        outboundPairingWins('aaa-instance', 'zzz-instance'),
        isTrue,
      );
      expect(
        outboundPairingWins('zzz-instance', 'aaa-instance'),
        isFalse,
      );
    });

    test('tie-break is deterministic for equal-length ids', () {
      const a = '00000000-0000-4000-8000-000000000001';
      const b = '00000000-0000-4000-8000-000000000002';
      expect(outboundPairingWins(a, b), isTrue);
      expect(outboundPairingWins(b, a), isFalse);
    });
  });
}
