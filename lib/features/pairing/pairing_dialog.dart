import 'package:flutter/material.dart';
import 'package:netpad/core/models/pair_request.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';

class PairingRequestDialog extends StatelessWidget {
  const PairingRequestDialog({super.key, required this.request});

  final PairRequest request;

  @override
  Widget build(BuildContext context) {
    final pairing = context.read<PairingRepository>();
    final tls = context.read<TlsIdentity>();

    return AlertDialog(
      title: const Text('Connection request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allow ${request.fromName} to connect and share this note?'),
          const SizedBox(height: 16),
          Text(
            'Verification code',
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
            'Confirm this code matches on both devices before accepting.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'This device security code',
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
            'The other device pins this on first connect.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            pairing.rejectRequest(request);
            Navigator.of(context).pop();
          },
          child: const Text('Reject'),
        ),
        FilledButton(
          onPressed: () {
            pairing.acceptRequest(request);
            Navigator.of(context).pop();
          },
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
