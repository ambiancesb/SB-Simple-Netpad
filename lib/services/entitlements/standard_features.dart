import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/theme/app_skin.dart';

/// Soft freemium gates shared by UI and repositories.
abstract final class StandardFeatures {
  /// Free users may enable sync on up to [freeSyncedNoteLimit] notes.
  /// [currentSyncedNoteCount] is the number already syncing (exclude the note
  /// being enabled if it is currently local-only).
  static bool canEnableNoteSync({
    required EntitlementService entitlements,
    required int currentSyncedNoteCount,
  }) {
    if (entitlements.isStandard) return true;
    return currentSyncedNoteCount < EntitlementConstants.freeSyncedNoteLimit;
  }

  static int get freeSyncedNoteLimit =>
      EntitlementConstants.freeSyncedNoteLimit;

  static bool canConnectPeer({
    required EntitlementService entitlements,
    required int currentConnectedCount,
  }) {
    if (entitlements.isStandard) return true;
    return currentConnectedCount < EntitlementConstants.freePeerLimit;
  }

  static int get freePeerLimit => EntitlementConstants.freePeerLimit;

  /// Max note length for free users; `null` means unlimited (Standard).
  static int? noteCharacterLimit(EntitlementService entitlements) {
    if (entitlements.isStandard) return null;
    return EntitlementConstants.freeNoteCharLimit;
  }

  static int get freeNoteCharLimit => EntitlementConstants.freeNoteCharLimit;

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
