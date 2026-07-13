import 'package:flutter/material.dart';
import 'package:netpad/core/models/pair_request.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/features/entitlements/standard_gate.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';

class PairingRequestDialog extends StatefulWidget {
  const PairingRequestDialog({super.key, required this.request});

  final PairRequest request;

  @override
  State<PairingRequestDialog> createState() => _PairingRequestDialogState();
}

class _PairingRequestDialogState extends State<PairingRequestDialog> {
  bool _trustForAutoSync = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pairing = context.read<PairingRepository>();
    final tls = context.read<TlsIdentity>();
    final request = widget.request;

    return AlertDialog(
      title: Text(l10n.pairingConnectionRequest),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pairingAllowPeer(request.fromName)),
          const SizedBox(height: 16),
          Text(
            l10n.pairingVerificationCode,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          SelectableText(
            request.verificationCode,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFeatures: const [],
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pairingConfirmCode,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.pairingThisDeviceSecurityCode,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          SelectableText(
            shortFingerprint(tls.fingerprint),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.pairingOtherDevicePins,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _trustForAutoSync,
            onChanged: _onTrustForAutoSyncChanged,
            title: Text(l10n.pairingTrustForAutoSync),
            subtitle: Text(l10n.pairingTrustForAutoSyncHint),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            pairing.rejectRequest(request);
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonReject),
        ),
        FilledButton(
          onPressed: () async {
            final sync = context.read<SyncRepository>();
            final allowed = await StandardGate.connectPeerAllowed(
              context,
              currentConnectedCount: sync.authenticatedPeerCount,
            );
            if (!allowed || !context.mounted) return;
            if (_trustForAutoSync) {
              final autoSyncAllowed =
                  await StandardGate.trustedAutoSyncAllowed(context);
              if (!autoSyncAllowed || !context.mounted) return;
            }
            pairing.acceptRequest(
              request,
              enableAutoSync: _trustForAutoSync,
            );
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonAccept),
        ),
      ],
    );
  }

  Future<void> _onTrustForAutoSyncChanged(bool? value) async {
    if (value != true) {
      setState(() => _trustForAutoSync = false);
      return;
    }
    final allowed = await StandardGate.trustedAutoSyncAllowed(context);
    if (!allowed || !mounted) return;
    setState(() => _trustForAutoSync = true);
  }
}
