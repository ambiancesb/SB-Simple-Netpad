import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class LoadedFile {
  const LoadedFile({required this.name, required this.text});

  final String name;
  final String text;
}

/// Native save / open dialogs for exporting and importing the note.
class FileService {
  const FileService();

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  /// Saves [text] to a user-chosen path. Returns the saved path, or null if
  /// the dialog was cancelled.
  Future<String?> saveText(
    String text, {
    String suggestedName = 'netpad-note.txt',
  }) async {
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
  /// the dialog was cancelled.
  Future<LoadedFile?> openText() async {
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
