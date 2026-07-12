/// Platform-specific billing / license backend for Standard unlock.
abstract class EntitlementBackend {
  /// Whether this backend can initiate store purchases on this device.
  bool get purchasesSupported;

  /// Refresh Standard status from the store / cache.
  Future<bool> refreshIsStandard();

  /// Localized price string for Standard, or null if unavailable.
  Future<String?> loadPriceString();

  /// Start the store purchase flow for Standard.
  /// Returns true if Standard is unlocked after the attempt.
  Future<bool> purchaseStandard();

  /// Restore previous purchases (no-op where the store has no restore step).
  Future<bool> restorePurchases();
}
