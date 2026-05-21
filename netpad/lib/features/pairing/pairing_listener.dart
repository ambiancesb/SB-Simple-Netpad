import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/features/pairing/pairing_dialog.dart';
import 'package:provider/provider.dart';

/// Shows incoming pairing dialogs as requests arrive.
class PairingListener extends StatefulWidget {
  const PairingListener({super.key, required this.child});

  final Widget child;

  @override
  State<PairingListener> createState() => _PairingListenerState();
}

class _PairingListenerState extends State<PairingListener> {
  final Set<String> _shownRequestIds = {};

  @override
  Widget build(BuildContext context) {
    final pairing = context.watch<PairingRepository>();

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

    return widget.child;
  }
}
