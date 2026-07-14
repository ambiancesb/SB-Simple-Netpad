import 'package:flutter/material.dart';
import 'package:netpad/core/models/trust_offer.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/features/entitlements/standard_gate.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';

/// Accept / Decline dialog for a mid-session mutual trust offer.
class TrustOfferDialog extends StatelessWidget {
  const TrustOfferDialog({super.key, required this.offer});

  final TrustOffer offer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pairing = context.read<PairingRepository>();
    final tls = context.read<TlsIdentity>();

    return AlertDialog(
      title: Text(l10n.pairingTrustOfferTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pairingTrustOfferBody(offer.fromName)),
          const SizedBox(height: 16),
          Text(
            l10n.pairingVerificationCode,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          SelectableText(
            offer.verificationCode,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            pairing.declineTrustOffer(offer);
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonReject),
        ),
        FilledButton(
          onPressed: () async {
            final allowed = await StandardGate.trustedAutoSyncAllowed(context);
            if (!allowed || !context.mounted) return;
            pairing.acceptTrustOffer(offer);
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonAccept),
        ),
      ],
    );
  }
}
