import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/qr_connect_payload.dart';
import 'package:netpad/core/qr_image_encode.dart';
import 'package:netpad/l10n/l10n_ext.dart';

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
  final png = encodeQrPng(payload);
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => _QrShowDialog(
      host: host,
      port: port,
      pngBytes: png,
    ),
  );
}

class _QrShowDialog extends StatelessWidget {
  const _QrShowDialog({
    required this.host,
    required this.port,
    required this.pngBytes,
  });

  final String host;
  final int port;
  final Uint8List pngBytes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final address = '$host:$port';

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.qrShowTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.qrShowBody,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.memory(
                    pngBytes,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                address,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: address));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.discoveryCopiedAddress(address),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(l10n.commonCopy),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonClose),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
