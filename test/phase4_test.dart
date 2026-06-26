import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('fingerprint helpers', () {
    test('fingerprintFromDer is stable, colon-separated uppercase hex', () {
      final fp = fingerprintFromDer([1, 2, 3]);
      // SHA-256 is 32 bytes -> 32 hex pairs separated by 31 colons.
      expect(fp.split(':'), hasLength(32));
      expect(fp, matches(RegExp(r'^([0-9A-F]{2}:){31}[0-9A-F]{2}$')));
      expect(fingerprintFromDer([1, 2, 3]), fp);
      expect(fingerprintFromDer([3, 2, 1]), isNot(fp));
    });

    test('shortFingerprint keeps the first 8 bytes', () {
      final fp = fingerprintFromDer([9, 9, 9]);
      final short = shortFingerprint(fp);
      expect(short.split(':'), hasLength(8));
      expect(fp.startsWith(short), isTrue);
    });

    test('certFingerprintFromPem handles CRLF line endings', () {
      // basic_utils emits CRLF-terminated PEM; the parser must strip all
      // whitespace before base64-decoding (regression for FormatException).
      const der = [1, 2, 3, 4, 5];
      final b64 = base64.encode(der);
      final pem = '-----BEGIN CERTIFICATE-----\r\n$b64\r\n'
          '-----END CERTIFICATE-----\r\n';
      expect(certFingerprintFromPem(pem), fingerprintFromDer(der));
    });
  });

  group('TrustStore', () {
    test('pins and unpins certificate fingerprints', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final trust = TrustStore(prefs);

      expect(trust.hasPin('peer-1'), isFalse);
      await trust.pin('peer-1', 'AB:CD');
      expect(trust.pinnedFingerprint('peer-1'), 'AB:CD');
      expect(trust.hasPin('peer-1'), isTrue);

      await trust.unpin('peer-1');
      expect(trust.hasPin('peer-1'), isFalse);
    });

    test('blocks and unblocks peers and persists across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final trust = TrustStore(prefs);

      await trust.block('peer-2', 'Laptop');
      expect(trust.isBlocked('peer-2'), isTrue);
      expect(trust.blocked['peer-2'], 'Laptop');

      // A fresh store backed by the same prefs should see the block.
      final reloaded = TrustStore(prefs);
      expect(reloaded.isBlocked('peer-2'), isTrue);

      await reloaded.unblock('peer-2');
      expect(reloaded.isBlocked('peer-2'), isFalse);
    });
  });
}
