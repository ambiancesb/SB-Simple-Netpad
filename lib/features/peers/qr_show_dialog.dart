import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/qr_connect_payload.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows a QR code another device can scan to connect to this endpoint.
Future<void> showQrConnectDialog(
  BuildContext context, {
  required String host,
  required int port,
  String? displayName,
}) {
  final payload = QrConnectPayload.encode(
    host: host,
    port: port,
    displayName: displayName,
  );
  return showDialog<void>(
    context: context,
    builder: (ctx) => _QrShowDialog(
      host: host,
      port: port,
      payload: payload,
    ),
  );
}

class _QrShowDialog extends StatelessWidget {
  const _QrShowDialog({
    required this.host,
    required this.port,
    required this.payload,
  });

  final String host;
  final int port;
  final String payload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final address = '$host:$port';
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.qrShowTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.qrShowBody),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: payload,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: colorScheme.onSurface,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              address,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: address));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.discoveryCopiedAddress(address))),
              );
            }
          },
          child: Text(l10n.commonCopy),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
