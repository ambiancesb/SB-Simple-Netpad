import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:netpad/core/qr_connect_payload.dart';
import 'package:netpad/core/qr_image_decode.dart';
import 'package:netpad/features/peers/manual_connect_dialog.dart';
import 'package:netpad/l10n/l10n_ext.dart';

/// Opens a scanner (camera and/or photo) and returns a parsed connect result.
Future<ManualConnectResult?> showQrScanDialog(BuildContext context) {
  return showDialog<ManualConnectResult>(
    context: context,
    builder: (ctx) => const _QrScanDialog(),
  );
}

bool get supportsLiveQrCamera {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

class _QrScanDialog extends StatefulWidget {
  const _QrScanDialog();

  @override
  State<_QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<_QrScanDialog> {
  MobileScannerController? _controller;
  var _handling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (supportsLiveQrCamera) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        formats: const [BarcodeFormat.qrCode],
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleRaw(String? raw) async {
    if (_handling || raw == null) return;
    final parsed = QrConnectPayload.tryParse(raw);
    if (parsed == null) {
      if (mounted) {
        setState(() => _error = context.l10n.qrScanInvalid);
      }
      return;
    }
    _handling = true;
    if (mounted) Navigator.pop(context, parsed);
  }

  Future<void> _pickImage() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: context.l10n.qrScanPickImage,
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      setState(() => _error = context.l10n.qrScanInvalid);
      return;
    }

    final raw = decodeQrFromImageBytes(bytes);
    await _handleRaw(raw);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;

    return AlertDialog(
      title: Text(l10n.qrScanTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              controller != null
                  ? l10n.qrScanBody
                  : l10n.qrScanCameraUnavailable,
            ),
            const SizedBox(height: 12),
            if (controller != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      final raw = capture.barcodes
                          .map((b) => b.rawValue)
                          .whereType<String>()
                          .firstOrNull;
                      _handleRaw(raw);
                    },
                    errorBuilder: (context, error) {
                      return ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.qrScanCameraUnavailable,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: _pickImage,
          child: Text(l10n.qrScanPickImage),
        ),
      ],
    );
  }
}
