import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class LoadedFile {
  const LoadedFile({required this.name, required this.text});

  final String name;
  final String text;
}

/// Native save / open dialogs for exporting and importing the note.
///
/// Unsupported on iOS (use Share instead). Available on Android and desktop.
class FileService {
  const FileService();

  /// True when Save / Open file dialogs are offered in the UI.
  static bool get supportsImportExport {
    if (kIsWeb) return false;
    return !Platform.isIOS;
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  /// Saves [text] to a user-chosen path. Returns the saved path, or null if
  /// the dialog was cancelled / unsupported.
  Future<String?> saveText(
    String text, {
    String suggestedName = 'netpad-note.txt',
  }) async {
    if (!supportsImportExport) return null;

    final bytes = Uint8List.fromList(utf8.encode(text));
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save note',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['txt', 'md'],
      // On mobile, file_picker writes the bytes itself; on desktop it only
      // returns the chosen path and we write the file ourselves.
      bytes: _isMobile ? bytes : null,
    );
    if (path == null) return null;
    if (!_isMobile) {
      await File(path).writeAsString(text);
    }
    return path;
  }

  /// Prompts the user to pick a text file. Returns its contents, or null if
  /// the dialog was cancelled / unsupported.
  Future<LoadedFile?> openText() async {
    if (!supportsImportExport) return null;

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open note',
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    String? content;
    if (file.bytes != null) {
      content = utf8.decode(file.bytes!, allowMalformed: true);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    }
    if (content == null) return null;
    return LoadedFile(name: file.name, text: content);
  }
}
