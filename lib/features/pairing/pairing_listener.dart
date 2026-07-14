import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/features/pairing/pairing_dialog.dart';
import 'package:netpad/features/pairing/trust_offer_dialog.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:provider/provider.dart';

/// Shows incoming pairing and trust-offer dialogs as requests arrive.
class PairingListener extends StatefulWidget {
  const PairingListener({super.key, required this.child});

  final Widget child;

  @override
  State<PairingListener> createState() => _PairingListenerState();
}

class _PairingListenerState extends State<PairingListener> {
  final Set<String> _shownRequestIds = {};
  final Set<String> _shownTrustOfferIds = {};

  @override
  Widget build(BuildContext context) {
    final pairing = context.watch<PairingRepository>();
    final l10n = context.l10n;

    for (final request in pairing.pendingIncoming) {
      if (_shownRequestIds.contains(request.requestId)) continue;
      _shownRequestIds.add(request.requestId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PairingRequestDialog(request: request),
        ).then((_) {
          _shownRequestIds.remove(request.requestId);
        });
      });
    }

    for (final offer in pairing.pendingTrustOffers) {
      if (_shownTrustOfferIds.contains(offer.requestId)) continue;
      _shownTrustOfferIds.add(offer.requestId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => TrustOfferDialog(offer: offer),
        ).then((_) {
          _shownTrustOfferIds.remove(offer.requestId);
        });
      });
    }

    final outcome = pairing.lastTrustOfferOutcome;
    if (outcome != null) {
      final (_, peerName, accepted) = outcome;
      pairing.clearLastTrustOfferOutcome();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger == null) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              accepted
                  ? l10n.pairingTrustAcceptedSnack(peerName)
                  : l10n.pairingTrustDeclinedSnack(peerName),
            ),
          ),
        );
      });
    }

    return widget.child;
  }
}
