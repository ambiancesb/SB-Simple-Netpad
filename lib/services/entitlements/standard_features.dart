import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/theme/app_skin.dart';

/// Soft freemium gates shared by UI and repositories.
abstract final class StandardFeatures {
  static bool canCreateNote({
    required EntitlementService entitlements,
    required int currentNoteCount,
  }) {
    if (entitlements.isStandard) return true;
    return currentNoteCount < EntitlementConstants.freeNoteLimit;
  }

  static int get freeNoteLimit => EntitlementConstants.freeNoteLimit;

  static bool canConnectPeer({
    required EntitlementService entitlements,
    required int currentConnectedCount,
  }) {
    if (entitlements.isStandard) return true;
    return currentConnectedCount < EntitlementConstants.freePeerLimit;
  }

  static int get freePeerLimit => EntitlementConstants.freePeerLimit;

  static bool isSkinAvailable(AppSkin skin, EntitlementService entitlements) {
    if (entitlements.isStandard) return true;
    return skin == AppSkin.defaultBlue;
  }

  static Iterable<AppSkin> availableSkins(EntitlementService entitlements) {
    if (entitlements.isStandard) return AppSkin.values;
    return const [AppSkin.defaultBlue];
  }

  static bool canUseVersionHistory(EntitlementService entitlements) =>
      entitlements.isStandard;

  static bool canUseTrustedAutoSync(EntitlementService entitlements) =>
      entitlements.isStandard;

  static bool canUseVoiceInput(EntitlementService entitlements) =>
      entitlements.isStandard;

  /// If a free user somehow has a Standard skin selected, fall back to default.
  static AppSkin effectiveSkin(
    AppSkin preferred,
    EntitlementService entitlements,
  ) {
    if (isSkinAvailable(preferred, entitlements)) return preferred;
    return AppSkin.defaultBlue;
  }
}
