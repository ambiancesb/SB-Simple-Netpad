import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/free_backend.dart';
import 'package:netpad/services/entitlements/standard_features.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StandardFeatures', () {
    late EntitlementService free;
    late EntitlementService standard;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      free = EntitlementService(prefs: prefs, backend: FreeBackend());
      await free.initialize();
      SharedPreferences.setMockInitialValues({});
      final standardPrefs = await SharedPreferences.getInstance();
      standard = EntitlementService(
        prefs: standardPrefs,
        backend: FreeBackend(forceStandard: true),
      );
      await standard.initialize();
    });

    test('free note limit blocks at cap', () {
      expect(
        StandardFeatures.canCreateNote(
          entitlements: free,
          currentNoteCount: EntitlementConstants.freeNoteLimit - 1,
        ),
        isTrue,
      );
      expect(
        StandardFeatures.canCreateNote(
          entitlements: free,
          currentNoteCount: EntitlementConstants.freeNoteLimit,
        ),
        isFalse,
      );
      expect(
        StandardFeatures.canCreateNote(
          entitlements: standard,
          currentNoteCount: 100,
        ),
        isTrue,
      );
    });

    test('free peer limit blocks at cap', () {
      expect(EntitlementConstants.freeNoteLimit, 3);
      expect(EntitlementConstants.freePeerLimit, 3);
      expect(
        StandardFeatures.canConnectPeer(
          entitlements: free,
          currentConnectedCount: EntitlementConstants.freePeerLimit - 1,
        ),
        isTrue,
      );
      expect(
        StandardFeatures.canConnectPeer(
          entitlements: free,
          currentConnectedCount: EntitlementConstants.freePeerLimit,
        ),
        isFalse,
      );
      expect(
        StandardFeatures.canConnectPeer(
          entitlements: standard,
          currentConnectedCount: 100,
        ),
        isTrue,
      );
    });

    test('only default skin is free', () {
      expect(StandardFeatures.isSkinAvailable(AppSkin.defaultBlue, free), isTrue);
      expect(StandardFeatures.isSkinAvailable(AppSkin.ocean, free), isFalse);
      expect(StandardFeatures.isSkinAvailable(AppSkin.ocean, standard), isTrue);
      expect(StandardFeatures.effectiveSkin(AppSkin.forest, free), AppSkin.defaultBlue);
      expect(StandardFeatures.effectiveSkin(AppSkin.forest, standard), AppSkin.forest);
    });

    test('standard-only features', () {
      expect(StandardFeatures.canUseVersionHistory(free), isFalse);
      expect(StandardFeatures.canUseVersionHistory(standard), isTrue);
      expect(StandardFeatures.canUseTrustedAutoSync(free), isFalse);
      expect(StandardFeatures.canUseVoiceInput(free), isFalse);
      expect(StandardFeatures.canUseVoiceInput(standard), isTrue);
    });
  });

  group('FreeBackend', () {
    test('forceStandard unlocks without store', () async {
      final backend = FreeBackend(forceStandard: true);
      expect(backend.purchasesSupported, isFalse);
      expect(await backend.refreshIsStandard(), isTrue);
      expect(await backend.restorePurchases(), isTrue);
    });
  });

  group('debug Standard unlock', () {
    test('debug force Standard unlocks in debug', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = EntitlementService(prefs: prefs, backend: FreeBackend());
      await service.initialize();
      expect(service.isStandard, isFalse);
      await service.setDebugForceStandard(true);
      expect(service.debugForceStandard, isTrue);
      expect(service.isStandard, isTrue);
      await service.setDebugForceStandard(false);
      expect(service.isStandard, isFalse);
    });
  });
}
