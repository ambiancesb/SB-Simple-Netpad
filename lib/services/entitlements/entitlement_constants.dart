/// Shared product / entitlement ids across store backends.
abstract final class EntitlementConstants {
  /// RevenueCat entitlement identifier (Apple + Google).
  ///
  /// Legacy id `pro` maps to the **Standard** unlock (not a future Pro tier).
  static const standardEntitlementId = 'pro';

  /// Store product id for the one-time Standard unlock (all three stores).
  ///
  /// Legacy SKU `netpad_pro` — do not rename; existing purchases restore against it.
  static const standardProductId = 'netpad_pro';

  /// RevenueCat offering that contains the Standard package.
  static const defaultOfferingId = 'default';

  /// Free tier max notes with peer sync enabled (local notes are unlimited).
  static const freeSyncedNoteLimit = 3;

  /// Free tier simultaneous authenticated peer connections.
  static const freePeerLimit = 3;

  /// Method channel for Microsoft Store durable purchases.
  static const windowsStoreChannel = 'com.spencerbeaumier.sbnetpad/windows_store';
}
