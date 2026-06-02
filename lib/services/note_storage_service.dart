import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedNote {
  const SavedNote({required this.text, required this.revision});

  final String text;
  final int revision;
}

/// Persists the local note via [SharedPreferences] (no JNI / path_provider on Linux).
class NoteStorageService {
  NoteStorageService(this._prefs);

  final SharedPreferences _prefs;
  static const _keyText = 'note_text';
  static const _keyRevision = 'note_revision';

  Future<SavedNote?> load() async {
    final migrated = await _migrateLegacyFileIfNeeded();
    final text = _prefs.getString(_keyText);
    if (text == null && !migrated) return null;
    return SavedNote(
      text: text ?? '',
      revision: _prefs.getInt(_keyRevision) ?? 0,
    );
  }

  Future<void> save(String text, int revision) async {
    await _prefs.setString(_keyText, text);
    await _prefs.setInt(_keyRevision, revision);
  }

  /// One-time import from Phase 1 file storage (path_provider era).
  Future<bool> _migrateLegacyFileIfNeeded() async {
    if (_prefs.containsKey(_keyText)) return false;

    final legacyFile = await _legacyNoteFile();
    if (legacyFile == null || !await legacyFile.exists()) return false;

    try {
      final text = await legacyFile.readAsString();
      var revision = 0;
      final meta = File('${legacyFile.parent.path}/note_meta.json');
      if (await meta.exists()) {
        final json =
            jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
        revision = json['revision'] as int? ?? 0;
      }
      await save(text, revision);
      if (kDebugMode) {
        debugPrint('Migrated note from ${legacyFile.path}');
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<File?> _legacyNoteFile() async {
    if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
      return null;
    }
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return null;

    // Matches path_provider_linux + application id com.sb.netpad
    final candidates = <String>[
      if (Platform.isLinux) '$home/.local/share/netpad',
      if (Platform.isMacOS) '$home/Library/Application Support/com.sb.netpad',
      if (Platform.isWindows)
        '${Platform.environment['APPDATA'] ?? '$home\\AppData\\Roaming'}\\netpad',
    ];

    for (final dir in candidates) {
      final file = File('$dir/note.txt');
      if (await file.exists()) return file;
    }
    return null;
  }
}
