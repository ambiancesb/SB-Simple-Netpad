import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Shares note text through the platform share sheet when available.
class ShareService {
  const ShareService();

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  Future<void> shareNote({
    required String text,
    required String title,
    BuildContext? context,
  }) async {
    final origin = _shareOrigin(context);
    final safeTitle = _safeFileName(title);

    if (_isMobile) {
      final temp = File(
        '${Directory.systemTemp.path}/netpad-$safeTitle-${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await temp.writeAsString(text);
      try {
        await Share.shareXFiles(
          [XFile(temp.path, mimeType: 'text/plain', name: '$safeTitle.txt')],
          text: text,
          subject: title,
          sharePositionOrigin: origin,
        );
        return;
      } on PlatformException {
        // Fall through to plain-text share below.
      } catch (_) {
        // Fall through to plain-text share below.
      } finally {
        if (await temp.exists()) {
          await temp.delete();
        }
      }
    }

    try {
      await Share.share(
        text,
        subject: title,
        sharePositionOrigin: origin,
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      rethrow;
    }
  }

  Rect? _shareOrigin(BuildContext? context) {
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  String _safeFileName(String title) {
    final cleaned = title.replaceAll(RegExp(r'[^\w\- ]'), '').trim();
    return cleaned.isEmpty ? 'netpad-note' : cleaned;
  }
}
