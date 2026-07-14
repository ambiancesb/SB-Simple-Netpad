import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:netpad/services/tls_secret_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TlsIdentity', () {
    test('persists and reloads from prefs-only store', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = TlsSecretStore.prefsOnly(prefs);

      final first = await TlsIdentity.loadOrCreate(prefs, secretStore: store);
      final second = await TlsIdentity.loadOrCreate(prefs, secretStore: store);

      expect(second.certPem, first.certPem);
      expect(second.keyPem, first.keyPem);
      expect(second.fingerprint, first.fingerprint);
    });

    test('migrates legacy prefs PEM into Keychain-like secure backend', () async {
      SharedPreferences.setMockInitialValues({});
      final seedPrefs = await SharedPreferences.getInstance();
      final original = await TlsIdentity.loadOrCreate(
        seedPrefs,
        secretStore: TlsSecretStore.prefsOnly(seedPrefs),
      );

      SharedPreferences.setMockInitialValues({
        'tls_cert_pem': original.certPem,
        'tls_key_pem': original.keyPem,
      });
      final prefs = await SharedPreferences.getInstance();
      final memory = MemorySecureBackend();
      final store = TlsSecretStore.withSecure(prefs: prefs, secure: memory);

      final reloaded = await TlsIdentity.loadOrCreate(
        prefs,
        secretStore: store,
      );

      expect(reloaded.fingerprint, original.fingerprint);
      expect(memory.values['tls_cert_pem'], original.certPem);
      expect(memory.values['tls_key_pem'], original.keyPem);
      expect(prefs.getString('tls_cert_pem'), isNull);
      expect(prefs.getString('tls_key_pem'), isNull);
    });
  });
}
