import 'package:flutter/services.dart';
import 'package:netpad/services/entitlements/entitlement_backend.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';

/// Microsoft Store durable add-on via WinRT StoreContext (MSIX identity required).
class WindowsStoreBackend implements EntitlementBackend {
  WindowsStoreBackend({
    MethodChannel? channel,
  }) : _channel = channel ??
            const MethodChannel(EntitlementConstants.windowsStoreChannel);

  final MethodChannel _channel;

  @override
  bool get purchasesSupported => true;

  @override
  Future<bool> refreshIsPro() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPro');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<String?> loadPriceString() async {
    try {
      return await _channel.invokeMethod<String>('getPrice');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> purchasePro() async {
    try {
      final result = await _channel.invokeMethod<bool>('purchase');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      if (e.code == 'cancelled') return false;
      rethrow;
    }
  }

  @override
  Future<bool> restorePurchases() => refreshIsPro();
}
