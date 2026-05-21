import 'package:flutter/material.dart';
import 'package:netpad/core/models/pair_request.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:provider/provider.dart';

class PairingRequestDialog extends StatelessWidget {
  const PairingRequestDialog({super.key, required this.request});

  final PairRequest request;

  @override
  Widget build(BuildContext context) {
    final pairing = context.read<PairingRepository>();

    return AlertDialog(
      title: const Text('Connection request'),
      content: Text(
        'Allow ${request.fromName} to connect and share this note?',
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
