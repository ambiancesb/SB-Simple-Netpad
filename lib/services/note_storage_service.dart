import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single note as persisted on disk.
class StoredDocument {
  StoredDocument({
    required this.id,
    required this.title,
    required this.text,
    required this.revision,
    this.history = const [],
  });

  final String id;
  String title;
  String text;
  int revision;
  List<HistoryEntry> history;

  Map<String, dynamic> toJson() => {
    'title': title,
    'text': text,
    'revision': revision,
    'history': [for (final h in history) h.toJson()],
  };

  factory StoredDocument.fromJson(String id, Map<String, dynamic> json) {
    final rawHistory = json['history'] as List<dynamic>? ?? const [];
    return StoredDocument(
      id: id,
      title: json['title'] as String? ?? kDefaultNoteTitle,
      text: json['text'] as String? ?? '',
      revision: json['revision'] as int? ?? 0,
      history: [
        for (final h in rawHistory)
          HistoryEntry.fromJson(Map<String, dynamic>.from(h as Map)),
      ],
    );
  }
}

/// The full set of notes plus which one was last active.
class WorkspaceData {
  WorkspaceData({required this.documents, required this.activeId});

  final List<StoredDocument> documents;
  final String? activeId;
}

/// Persists notes via [SharedPreferences] (no JNI / path_provider on Linux).
class NoteStorageService {
  NoteStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyIndex = 'docs_index';
  static const _keyActive = 'docs_active';
  static const _docPrefix = 'doc_';

  // Legacy single-note keys (Phase 1–4).
  static const _legacyKeyText = 'note_text';
  static const _legacyKeyRevision = 'note_revision';

  Future<WorkspaceData> loadWorkspace() async {
    await _migrateIfNeeded();

    final ids = _prefs.getStringList(_keyIndex) ?? const [];
    final documents = <StoredDocument>[];
    for (final id in ids) {
      final raw = _prefs.getString('$_docPrefix$id');
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        documents.add(StoredDocument.fromJson(id, json));
      } catch (_) {
        // Skip a corrupt entry rather than failing the whole load.
      }
    }
    return WorkspaceData(
      documents: documents,
      activeId: _prefs.getString(_keyActive),
    );
  }

  Future<void> saveDocument(StoredDocument doc) async {
    await _prefs.setString('$_docPrefix${doc.id}', jsonEncode(doc.toJson()));
  }

  Future<void> deleteDocument(String id) async {
    await _prefs.remove('$_docPrefix$id');
  }

  Future<void> saveIndex(List<String> ids, String? activeId) async {
    await _prefs.setStringList(_keyIndex, ids);
    if (activeId != null) {
      await _prefs.setString(_keyActive, activeId);
    } else {
      await _prefs.remove(_keyActive);
    }
  }

  /// Migrates a Phase 1–4 single note (prefs or legacy file) into the
  /// multi-document layout. Runs once; afterwards `docs_index` exists.
  Future<void> _migrateIfNeeded() async {
    if (_prefs.containsKey(_keyIndex)) return;

    String? text = _prefs.getString(_legacyKeyText);
    var revision = _prefs.getInt(_legacyKeyRevision) ?? 0;

    if (text == null) {
      final legacy = await _readLegacyFile();
      if (legacy != null) {
        text = legacy.text;
        revision = legacy.revision;
      }
    }

    if (text == null) return; // Fresh install — let the workspace seed a note.

    const id = 'migrated-note';
    final doc = StoredDocument(
      id: id,
      title: 'Note',
      text: text,
      revision: revision,
    );
    await saveDocument(doc);
    await saveIndex([id], id);
    if (kDebugMode) {
      debugPrint('Migrated legacy note into multi-document storage');
    }
  }

  Future<({String text, int revision})?> _readLegacyFile() async {
    final file = await _legacyNoteFile();
    if (file == null || !await file.exists()) return null;
    try {
      final text = await file.readAsString();
      var revision = 0;
      final meta = File('${file.parent.path}/note_meta.json');
      if (await meta.exists()) {
        final json =
            jsonDecode(await meta.readAsString()) as Map<String, dynamic>;
        revision = json['revision'] as int? ?? 0;
      }
      return (text: text, revision: revision);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _legacyNoteFile() async {
    if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
      return null;
    }
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) return null;

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
