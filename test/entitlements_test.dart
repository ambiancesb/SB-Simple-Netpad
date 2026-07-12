import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/free_backend.dart';
import 'package:netpad/services/entitlements/pro_features.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProFeatures', () {
    late EntitlementService free;
    late EntitlementService pro;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      free = EntitlementService(prefs: prefs, backend: FreeBackend());
      await free.initialize();
      SharedPreferences.setMockInitialValues({});
      final proPrefs = await SharedPreferences.getInstance();
      pro = EntitlementService(
        prefs: proPrefs,
        backend: FreeBackend(forcePro: true),
      );
      await pro.initialize();
    });

    test('free note limit blocks at cap', () {
      expect(
        ProFeatures.canCreateNote(
          entitlements: free,
          currentNoteCount: EntitlementConstants.freeNoteLimit - 1,
        ),
        isTrue,
      );
      expect(
        ProFeatures.canCreateNote(
          entitlements: free,
          currentNoteCount: EntitlementConstants.freeNoteLimit,
        ),
        isFalse,
      );
      expect(
        ProFeatures.canCreateNote(
          entitlements: pro,
          currentNoteCount: 100,
        ),
        isTrue,
      );
    });

    test('free peer limit blocks at cap', () {
      expect(EntitlementConstants.freeNoteLimit, 3);
      expect(EntitlementConstants.freePeerLimit, 3);
      expect(
        ProFeatures.canConnectPeer(
          entitlements: free,
          currentConnectedCount: EntitlementConstants.freePeerLimit - 1,
        ),
        isTrue,
      );
      expect(
        ProFeatures.canConnectPeer(
          entitlements: free,
          currentConnectedCount: EntitlementConstants.freePeerLimit,
        ),
        isFalse,
      );
      expect(
        ProFeatures.canConnectPeer(
          entitlements: pro,
          currentConnectedCount: 100,
        ),
        isTrue,
      );
    });

    test('only default skin is free', () {
      expect(ProFeatures.isSkinAvailable(AppSkin.defaultBlue, free), isTrue);
      expect(ProFeatures.isSkinAvailable(AppSkin.ocean, free), isFalse);
      expect(ProFeatures.isSkinAvailable(AppSkin.ocean, pro), isTrue);
      expect(ProFeatures.effectiveSkin(AppSkin.forest, free), AppSkin.defaultBlue);
      expect(ProFeatures.effectiveSkin(AppSkin.forest, pro), AppSkin.forest);
    });

    test('pro-only features', () {
      expect(ProFeatures.canUseVersionHistory(free), isFalse);
      expect(ProFeatures.canUseVersionHistory(pro), isTrue);
      expect(ProFeatures.canUseTrustedAutoSync(free), isFalse);
      expect(ProFeatures.canUseVoiceInput(free), isFalse);
      expect(ProFeatures.canUseVoiceInput(pro), isTrue);
    });
  });

  group('FreeBackend', () {
    test('forcePro unlocks without store', () async {
      final backend = FreeBackend(forcePro: true);
      expect(backend.purchasesSupported, isFalse);
      expect(await backend.refreshIsPro(), isTrue);
      expect(await backend.restorePurchases(), isTrue);
    });
  });

  group('debug Pro unlock', () {
    test('debug force Pro unlocks in debug', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = EntitlementService(prefs: prefs, backend: FreeBackend());
      await service.initialize();
      expect(service.isPro, isFalse);
      await service.setDebugForcePro(true);
      expect(service.debugForcePro, isTrue);
      expect(service.isPro, isTrue);
      await service.setDebugForcePro(false);
      expect(service.isPro, isFalse);
    });
  });
}
