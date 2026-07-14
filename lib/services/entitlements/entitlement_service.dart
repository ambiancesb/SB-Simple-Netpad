import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/services/entitlements/entitlement_backend.dart';
import 'package:netpad/services/entitlements/free_backend.dart';
import 'package:netpad/services/entitlements/revenue_cat_backend.dart';
import 'package:netpad/services/entitlements/windows_store_backend.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide Standard entitlement state backed by the active store.
class EntitlementService extends ChangeNotifier {
  EntitlementService({
    required SharedPreferences prefs,
    EntitlementBackend? backend,
  }) : _prefs = prefs,
       _backend = backend ?? createDefaultBackend();

  static const _cacheKey = 'entitlement_is_standard';
  static const _legacyCacheKey = 'entitlement_is_pro';
  static const _debugForceStandardKey = 'entitlement_debug_force_standard';
  static const _legacyDebugForceKey = 'entitlement_debug_force_pro';

  final SharedPreferences _prefs;
  final EntitlementBackend _backend;

  bool _isStandard = false;
  bool _debugForceStandard = false;
  bool _loading = true;
  String? _priceString;
  String? _lastError;

  bool get isStandard => _debugForceStandard || _isStandard;
  bool get loading => _loading;
  bool get purchasesSupported => _backend.purchasesSupported;
  String? get priceString => _priceString;
  String? get lastError => _lastError;

  /// Debug-only unlock persisted for local testing. Always false in release.
  bool get debugForceStandard => kDebugMode && _debugForceStandard;

  /// Factory used by [main] and tests.
  static EntitlementBackend createDefaultBackend({
    String appleApiKey = const String.fromEnvironment(
      'REVENUECAT_APPLE_API_KEY',
    ),
    String iosApiKey = const String.fromEnvironment(
      'REVENUECAT_IOS_API_KEY',
    ),
    String macosApiKey = const String.fromEnvironment(
      'REVENUECAT_MACOS_API_KEY',
    ),
    String googleApiKey = const String.fromEnvironment(
      'REVENUECAT_GOOGLE_API_KEY',
    ),
    bool forceStandard =
        const bool.fromEnvironment('NETPAD_STANDARD_OVERRIDE') ||
        const bool.fromEnvironment('NETPAD_PRO_OVERRIDE'),
  }) {
    if (forceStandard) {
      return FreeBackend(forceStandard: true);
    }
    if (kIsWeb) {
      return FreeBackend();
    }
    if (Platform.isWindows) {
      return WindowsStoreBackend();
    }
    if (RevenueCatBackend.isSupportedPlatform) {
      return RevenueCatBackend(
        appleApiKey: appleApiKey,
        iosApiKey: iosApiKey,
        macosApiKey: macosApiKey,
        googleApiKey: googleApiKey,
      );
    }
    return FreeBackend();
  }

  Future<void> initialize() async {
    _isStandard = _prefs.getBool(_cacheKey) ??
        _prefs.getBool(_legacyCacheKey) ??
        false;
    if (kDebugMode) {
      _debugForceStandard = _prefs.getBool(_debugForceStandardKey) ??
          _prefs.getBool(_legacyDebugForceKey) ??
          false;
    }
    _loading = true;
    notifyListeners();
    try {
      _isStandard = await _backend.refreshIsStandard();
      await _prefs.setBool(_cacheKey, _isStandard);
      await _prefs.remove(_legacyCacheKey);
      if (_backend.purchasesSupported) {
        _priceString = await _backend.loadPriceString();
      }
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Debug builds only: force Standard without talking to a store.
  Future<void> setDebugForceStandard(bool enabled) async {
    if (!kDebugMode) return;
    _debugForceStandard = enabled;
    await _prefs.setBool(_debugForceStandardKey, enabled);
    await _prefs.remove(_legacyDebugForceKey);
    notifyListeners();
  }

  Future<bool> purchaseStandard() async {
    _lastError = null;
    notifyListeners();
    try {
      final unlocked = await _backend.purchaseStandard();
      _isStandard = unlocked || await _backend.refreshIsStandard();
      await _prefs.setBool(_cacheKey, _isStandard);
      await _prefs.remove(_legacyCacheKey);
      _priceString ??= await _backend.loadPriceString();
      notifyListeners();
      return _isStandard;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    _lastError = null;
    notifyListeners();
    try {
      _isStandard = await _backend.restorePurchases();
      await _prefs.setBool(_cacheKey, _isStandard);
      await _prefs.remove(_legacyCacheKey);
      notifyListeners();
      return _isStandard;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshPrice() async {
    if (!_backend.purchasesSupported) return;
    try {
      _priceString = await _backend.loadPriceString();
      notifyListeners();
    } catch (_) {}
  }
}
