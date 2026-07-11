/// Shared product / entitlement ids across store backends.
abstract final class EntitlementConstants {
  /// RevenueCat entitlement identifier (Apple + Google).
  static const proEntitlementId = 'pro';

  /// Store product id for the one-time Pro unlock (all three stores).
  static const proProductId = 'netpad_pro';

  /// RevenueCat offering that contains the Pro package.
  static const defaultOfferingId = 'default';

  /// Free tier local note creation cap (synced peer notes may exceed this).
  static const freeNoteLimit = 5;

  /// Method channel for Microsoft Store durable purchases.
  static const windowsStoreChannel = 'com.sb.netpad/windows_store';
}
