import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/l10n/l10n_ext.dart';

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
        SnackBar(content: Text(context.l10n.manualConnectInvalidHostPort)),
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.manualConnectTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.manualConnectBody),
            const SizedBox(height: 16),
            TextField(
              controller: _hostController,
              decoration: InputDecoration(
                labelText: l10n.manualConnectHostLabel,
                hintText: l10n.manualConnectHostHint,
              ),
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: l10n.manualConnectPortLabel,
                hintText: l10n.manualConnectPortHint,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.manualConnectLabelOptional,
                hintText: l10n.manualConnectLabelHint,
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
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.commonConnect)),
      ],
    );
  }
}
