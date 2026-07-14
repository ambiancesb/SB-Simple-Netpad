import 'package:netpad/services/entitlements/entitlement_backend.dart';

/// Sideload / unsupported platforms — no store IAP.
class FreeBackend implements EntitlementBackend {
  FreeBackend({this.forceStandard = false});

  /// Debug override via `--dart-define=NETPAD_STANDARD_OVERRIDE=true`
  /// (or legacy `NETPAD_PRO_OVERRIDE=true`).
  final bool forceStandard;

  @override
  bool get purchasesSupported => false;

  @override
  Future<bool> refreshIsStandard() async => forceStandard;

  @override
  Future<String?> loadPriceString() async => null;

  @override
  Future<bool> purchaseStandard() async => forceStandard;

  @override
  Future<bool> restorePurchases() async => forceStandard;
}
