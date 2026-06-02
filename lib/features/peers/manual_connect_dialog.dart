import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualConnectResult {
  const ManualConnectResult({
    required this.host,
    required this.port,
    this.displayName,
  });

  final String host;
  final int port;
  final String? displayName;
}

/// Dialog to connect to a peer by IP/hostname and port (no mDNS).
Future<ManualConnectResult?> showManualConnectDialog(BuildContext context) {
  return showDialog<ManualConnectResult>(
    context: context,
    builder: (ctx) => const _ManualConnectDialog(),
  );
}

class _ManualConnectDialog extends StatefulWidget {
  const _ManualConnectDialog();

  @override
  State<_ManualConnectDialog> createState() => _ManualConnectDialogState();
}

class _ManualConnectDialogState extends State<_ManualConnectDialog> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim());
    if (host.isEmpty || port == null || port < 1 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid host and port (1–65535)')),
      );
      return;
    }
    Navigator.pop(
      context,
      ManualConnectResult(
        host: host,
        port: port,
        displayName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect by address'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use when discovery cannot find peers (guest Wi‑Fi, VPN, etc.).',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host or IP',
                hintText: '192.168.1.42',
              ),
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '54321',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                hintText: 'Living room PC',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Connect')),
      ],
    );
  }
}
