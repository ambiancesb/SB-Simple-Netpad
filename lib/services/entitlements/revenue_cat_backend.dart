import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/services/entitlements/entitlement_backend.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Apple App Store + Google Play billing via RevenueCat.
class RevenueCatBackend implements EntitlementBackend {
  RevenueCatBackend({
    required this.appleApiKey,
    required this.googleApiKey,
  });

  final String appleApiKey;
  final String googleApiKey;

  bool _configured = false;
  Offerings? _offerings;

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
  }

  String? get _apiKey {
    if (Platform.isIOS || Platform.isMacOS) {
      return appleApiKey.isEmpty ? null : appleApiKey;
    }
    if (Platform.isAndroid) {
      return googleApiKey.isEmpty ? null : googleApiKey;
    }
    return null;
  }

  @override
  bool get purchasesSupported => _apiKey != null;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    final key = _apiKey;
    if (key == null) {
      throw StateError('RevenueCat API key not configured for this platform');
    }
    final config = PurchasesConfiguration(key);
    await Purchases.configure(config);
    _configured = true;
  }

  @override
  Future<bool> refreshIsStandard() async {
    if (!purchasesSupported) return false;
    await _ensureConfigured();
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(
      EntitlementConstants.standardEntitlementId,
    );
  }

  @override
  Future<String?> loadPriceString() async {
    if (!purchasesSupported) return null;
    await _ensureConfigured();
    _offerings = await Purchases.getOfferings();
    final package = _standardPackage(_offerings);
    return package?.storeProduct.priceString;
  }

  @override
  Future<bool> purchaseStandard() async {
    if (!purchasesSupported) return false;
    await _ensureConfigured();
    _offerings ??= await Purchases.getOfferings();
    final package = _standardPackage(_offerings);
    if (package == null) {
      throw StateError('Standard package not found in RevenueCat offerings');
    }
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo.entitlements.active.containsKey(
      EntitlementConstants.standardEntitlementId,
    );
  }

  @override
  Future<bool> restorePurchases() async {
    if (!purchasesSupported) return false;
    await _ensureConfigured();
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(
      EntitlementConstants.standardEntitlementId,
    );
  }

  Package? _standardPackage(Offerings? offerings) {
    if (offerings == null) return null;
    final offering =
        offerings.getOffering(EntitlementConstants.defaultOfferingId) ??
        offerings.current;
    if (offering == null) return null;
    for (final package in offering.availablePackages) {
      if (package.storeProduct.identifier ==
          EntitlementConstants.standardProductId) {
        return package;
      }
    }
    if (offering.lifetime != null) return offering.lifetime;
    if (offering.availablePackages.isNotEmpty) {
      return offering.availablePackages.first;
    }
    return null;
  }
}
