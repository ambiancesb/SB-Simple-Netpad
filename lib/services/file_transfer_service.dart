import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

/// Handles open/save/share of the note text using native dialogs.
///
/// Kept platform-aware so the UI stays thin: desktop gets a real save dialog,
/// while mobile relies on the share sheet to export content.
class FileTransferService {
  static const _textGroup = XTypeGroup(
    label: 'Text',
    extensions: ['txt', 'md', 'text'],
  );

  /// True on desktop, where a native "save as" location can be chosen.
  bool get canSaveToDisk =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  /// Opens a text file and returns its contents, or null if cancelled.
  Future<String?> openTextFile() async {
    final file = await openFile(acceptedTypeGroups: const [_textGroup]);
    if (file == null) return null;
    return file.readAsString();
  }

  /// Saves [text] to a user-chosen path. Returns false if cancelled.
  Future<bool> saveTextFile(
    String text, {
    String suggestedName = 'note.txt',
  }) async {
    final location = await getSaveLocation(suggestedName: suggestedName);
    if (location == null) return false;
    await File(location.path).writeAsString(text);
    return true;
  }

  /// Shares [text] through the platform share sheet.
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
