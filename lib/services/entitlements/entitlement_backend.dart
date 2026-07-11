/// Platform-specific billing / license backend for Pro unlock.
abstract class EntitlementBackend {
  /// Whether this backend can initiate store purchases on this device.
  bool get purchasesSupported;

  /// Refresh Pro status from the store / cache.
  Future<bool> refreshIsPro();

  /// Localized price string for Pro, or null if unavailable.
  Future<String?> loadPriceString();

  /// Start the store purchase flow for Pro.
  /// Returns true if Pro is unlocked after the attempt.
  Future<bool> purchasePro();

  /// Restore previous purchases (no-op where the store has no restore step).
  Future<bool> restorePurchases();
}
