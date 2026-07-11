import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/theme/app_skin.dart';

/// Soft freemium gates shared by UI and repositories.
abstract final class ProFeatures {
  static bool canCreateNote({
    required EntitlementService entitlements,
    required int currentNoteCount,
  }) {
    if (entitlements.isPro) return true;
    return currentNoteCount < EntitlementConstants.freeNoteLimit;
  }

  static int get freeNoteLimit => EntitlementConstants.freeNoteLimit;

  static bool isSkinAvailable(AppSkin skin, EntitlementService entitlements) {
    if (entitlements.isPro) return true;
    return skin == AppSkin.defaultBlue;
  }

  static Iterable<AppSkin> availableSkins(EntitlementService entitlements) {
    if (entitlements.isPro) return AppSkin.values;
    return const [AppSkin.defaultBlue];
  }

  static bool canUseVersionHistory(EntitlementService entitlements) =>
      entitlements.isPro;

  static bool canUseTrustedAutoSync(EntitlementService entitlements) =>
      entitlements.isPro;

  static bool canUseVoiceInput(EntitlementService entitlements) =>
      entitlements.isPro;

  /// If a free user somehow has a Pro skin selected, fall back to default.
  static AppSkin effectiveSkin(
    AppSkin preferred,
    EntitlementService entitlements,
  ) {
    if (isSkinAvailable(preferred, entitlements)) return preferred;
    return AppSkin.defaultBlue;
  }
}
