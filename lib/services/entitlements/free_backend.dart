import 'package:netpad/services/entitlements/entitlement_backend.dart';

/// Linux / sideload / unsupported platforms — no store IAP.
class FreeBackend implements EntitlementBackend {
  FreeBackend({this.forcePro = false});

  /// Debug override via `--dart-define=NETPAD_PRO_OVERRIDE=true`.
  final bool forcePro;

  @override
  bool get purchasesSupported => false;

  @override
  Future<bool> refreshIsPro() async => forcePro;

  @override
  Future<String?> loadPriceString() async => null;

  @override
  Future<bool> purchasePro() async => forcePro;

  @override
  Future<bool> restorePurchases() async => forcePro;
}
