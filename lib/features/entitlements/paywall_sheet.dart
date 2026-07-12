import 'package:flutter/material.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:provider/provider.dart';

/// Shows the one-time Pro paywall. Returns true if Pro was unlocked.
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
    final ok = await entitlements.purchasePro();
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
        SnackBar(content: Text(context.l10n.paywallProRestored)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.paywallNoPreviousPro)),
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
          24,
          8,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.paywallTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paywallSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.highlight != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.highlight!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _Benefit(icon: Icons.note_add, label: l10n.paywallBenefitUnlimitedNotes),
            _Benefit(icon: Icons.hub, label: l10n.paywallBenefitUnlimitedPeers),
            _Benefit(icon: Icons.palette, label: l10n.paywallBenefitSkins),
            _Benefit(icon: Icons.history, label: l10n.paywallBenefitHistory),
            _Benefit(icon: Icons.sync, label: l10n.paywallBenefitAutoSync),
            _Benefit(icon: Icons.mic, label: l10n.paywallBenefitVoice),
            const SizedBox(height: 20),
            if (!supported)
              Text(
                l10n.paywallPurchasesUnsupported,
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
                            ? l10n.paywallBuyPro
                            : l10n.paywallBuyProPrice(price),
                      ),
              ),
              const SizedBox(height: 8),
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
  const _Benefit({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
