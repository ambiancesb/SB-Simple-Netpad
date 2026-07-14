import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/free_backend.dart';
import 'package:netpad/services/entitlements/revenue_cat_backend.dart';
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

    test('free synced note limit blocks at cap', () {
      expect(
        StandardFeatures.canEnableNoteSync(
          entitlements: free,
          currentSyncedNoteCount:
              EntitlementConstants.freeSyncedNoteLimit - 1,
        ),
        isTrue,
      );
      expect(
        StandardFeatures.canEnableNoteSync(
          entitlements: free,
          currentSyncedNoteCount: EntitlementConstants.freeSyncedNoteLimit,
        ),
        isFalse,
      );
      expect(
        StandardFeatures.canEnableNoteSync(
          entitlements: standard,
          currentSyncedNoteCount: 100,
        ),
        isTrue,
      );
    });

    test('free peer limit blocks at cap', () {
      expect(EntitlementConstants.freeSyncedNoteLimit, 3);
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

  group('RevenueCat key resolution', () {
    test('prefers platform Apple keys over legacy', () {
      expect(
        RevenueCatBackend.resolveApiKey(
          isIOS: true,
          isMacOS: false,
          isAndroid: false,
          appleApiKey: 'appl_legacy',
          iosApiKey: 'appl_ios',
          macosApiKey: 'appl_mac',
          googleApiKey: '',
        ),
        'appl_ios',
      );
      expect(
        RevenueCatBackend.resolveApiKey(
          isIOS: false,
          isMacOS: true,
          isAndroid: false,
          appleApiKey: 'appl_legacy',
          iosApiKey: 'appl_ios',
          macosApiKey: 'appl_mac',
          googleApiKey: '',
        ),
        'appl_mac',
      );
    });

    test('falls back to legacy Apple key', () {
      expect(
        RevenueCatBackend.resolveApiKey(
          isIOS: true,
          isMacOS: false,
          isAndroid: false,
          appleApiKey: 'appl_legacy',
          iosApiKey: '',
          macosApiKey: '',
          googleApiKey: '',
        ),
        'appl_legacy',
      );
      expect(
        RevenueCatBackend.resolveApiKey(
          isIOS: false,
          isMacOS: true,
          isAndroid: false,
          appleApiKey: 'appl_legacy',
          iosApiKey: '',
          macosApiKey: '',
          googleApiKey: '',
        ),
        'appl_legacy',
      );
    });

    test('uses Google key on Android', () {
      expect(
        RevenueCatBackend.resolveApiKey(
          isIOS: false,
          isMacOS: false,
          isAndroid: true,
          appleApiKey: 'appl_x',
          iosApiKey: '',
          macosApiKey: '',
          googleApiKey: 'goog_x',
        ),
        'goog_x',
      );
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
