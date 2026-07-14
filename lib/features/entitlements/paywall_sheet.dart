import 'package:flutter/material.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/theme/app_spacing.dart';
import 'package:netpad/widgets/app_logo.dart';
import 'package:provider/provider.dart';

/// Shows the one-time Standard paywall. Returns true if Standard was unlocked.
Future<bool> showPaywallSheet(
  BuildContext context, {
  String? highlight,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _PaywallSheet(highlight: highlight),
  );
  return result ?? false;
}

class _PaywallSheet extends StatefulWidget {
  const _PaywallSheet({this.highlight});

  final String? highlight;

  @override
  State<_PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<_PaywallSheet> {
  bool _busy = false;

  Future<void> _buy() async {
    final entitlements = context.read<EntitlementService>();
    setState(() => _busy = true);
    final ok = await entitlements.purchaseStandard();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    final message = entitlements.lastError == null
        ? context.l10n.paywallPurchaseNotCompleted
        : context.l10n.paywallPurchaseFailed;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _restore() async {
    final entitlements = context.read<EntitlementService>();
    setState(() => _busy = true);
    final ok = await entitlements.restorePurchases();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paywallStandardRestored)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.paywallNoPreviousStandard)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entitlements = context.watch<EntitlementService>();
    final theme = Theme.of(context);
    final price = entitlements.priceString;
    final supported = entitlements.purchasesSupported;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AppLogo(size: 64)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.paywallTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.paywallSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.highlight != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.highlight!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _Benefit(label: l10n.paywallBenefitUnlimitedNotes),
            _Benefit(label: l10n.paywallBenefitUnlimitedPeers),
            _Benefit(label: l10n.paywallBenefitUnlimitedLength),
            _Benefit(label: l10n.paywallBenefitSkins),
            _Benefit(label: l10n.paywallBenefitHistory),
            _Benefit(label: l10n.paywallBenefitAutoSync),
            _Benefit(label: l10n.paywallBenefitVoice),
            const SizedBox(height: AppSpacing.xl),
            if (!supported)
              Text(
                l10n.paywallPurchasesUnsupported,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              FilledButton(
                onPressed: _busy ? null : _buy,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        price == null
                            ? l10n.paywallBuyStandard
                            : l10n.paywallBuyStandardPrice(price),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _busy ? null : _restore,
                child: Text(l10n.paywallRestorePurchases),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_rounded,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
