import 'package:flutter/material.dart';
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
        ? 'Purchase was not completed.'
        : 'Purchase failed.';
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
        const SnackBar(content: Text('Pro restored')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No previous Pro purchase found')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Unlock Netpad Pro',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'One-time purchase. Core editing and LAN sync stay free.',
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
            const _Benefit(icon: Icons.note_add, label: 'Unlimited notes'),
            const _Benefit(icon: Icons.hub, label: 'Unlimited connected peers'),
            const _Benefit(icon: Icons.palette, label: 'Extra color skins'),
            const _Benefit(icon: Icons.history, label: 'Version history'),
            const _Benefit(
              icon: Icons.sync,
              label: 'Trusted peer auto-sync',
            ),
            const _Benefit(icon: Icons.mic, label: 'Voice dictation'),
            const SizedBox(height: 20),
            if (!supported)
              Text(
                'In-app purchases are not available on this platform. '
                'Install from the App Store, Google Play, or Microsoft Store '
                'to unlock Pro.',
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
                    : Text(price == null ? 'Buy Pro' : 'Buy Pro · $price'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : _restore,
                child: const Text('Restore purchases'),
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
