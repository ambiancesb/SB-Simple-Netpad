import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/services/entitlements/entitlement_backend.dart';
import 'package:netpad/services/entitlements/free_backend.dart';
import 'package:netpad/services/entitlements/revenue_cat_backend.dart';
import 'package:netpad/services/entitlements/windows_store_backend.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// App-wide Pro entitlement state backed by the active store.
class EntitlementService extends ChangeNotifier {
  EntitlementService({
    required SharedPreferences prefs,
    EntitlementBackend? backend,
  }) : _prefs = prefs,
       _backend = backend ?? createDefaultBackend();

  static const _cacheKey = 'entitlement_is_pro';

  final SharedPreferences _prefs;
  final EntitlementBackend _backend;

  bool _isPro = false;
  bool _loading = true;
  String? _priceString;
  String? _lastError;

  bool get isPro => _isPro;
  bool get loading => _loading;
  bool get purchasesSupported => _backend.purchasesSupported;
  String? get priceString => _priceString;
  String? get lastError => _lastError;

  /// Factory used by [main] and tests.
  static EntitlementBackend createDefaultBackend({
    String appleApiKey = const String.fromEnvironment(
      'REVENUECAT_APPLE_API_KEY',
    ),
    String googleApiKey = const String.fromEnvironment(
      'REVENUECAT_GOOGLE_API_KEY',
    ),
    bool forcePro = const bool.fromEnvironment('NETPAD_PRO_OVERRIDE'),
  }) {
    if (forcePro) {
      return FreeBackend(forcePro: true);
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
        googleApiKey: googleApiKey,
      );
    }
    return FreeBackend();
  }

  Future<void> initialize() async {
    _isPro = _prefs.getBool(_cacheKey) ?? false;
    _loading = true;
    notifyListeners();
    try {
      _isPro = await _backend.refreshIsPro();
      await _prefs.setBool(_cacheKey, _isPro);
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

  Future<bool> purchasePro() async {
    _lastError = null;
    notifyListeners();
    try {
      final unlocked = await _backend.purchasePro();
      _isPro = unlocked || await _backend.refreshIsPro();
      await _prefs.setBool(_cacheKey, _isPro);
      _priceString ??= await _backend.loadPriceString();
      notifyListeners();
      return _isPro;
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
      _isPro = await _backend.restorePurchases();
      await _prefs.setBool(_cacheKey, _isPro);
      notifyListeners();
      return _isPro;
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
