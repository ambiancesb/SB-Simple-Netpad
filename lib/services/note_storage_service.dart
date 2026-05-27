import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SavedNote {
  const SavedNote({required this.text, required this.revision});

  final String text;
  final int revision;
}

/// Persists the local note under the app documents directory.
class NoteStorageService {
  static const _noteFileName = 'note.txt';
  static const _metaFileName = 'note_meta.json';

  Future<File> get _noteFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_noteFileName');
  }

  Future<File> get _metaFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_metaFileName');
  }

  Future<SavedNote?> load() async {
    try {
      final noteFile = await _noteFile;
      if (!await noteFile.exists()) return null;

      final text = await noteFile.readAsString();
      var revision = 0;

      final metaFile = await _metaFile;
      if (await metaFile.exists()) {
        final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
        revision = meta['revision'] as int? ?? 0;
      }

      return SavedNote(text: text, revision: revision);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String text, int revision) async {
    final noteFile = await _noteFile;
    final metaFile = await _metaFile;
    await noteFile.writeAsString(text);
    await metaFile.writeAsString(
      jsonEncode({
        'revision': revision,
        'savedAt': DateTime.now().toIso8601String(),
      }),
    );
  }
}
