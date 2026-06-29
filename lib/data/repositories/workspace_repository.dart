import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:uuid/uuid.dart';

/// A note matched by a cross-note search, with where/how often it matched.
class NoteSearchHit {
  NoteSearchHit({
    required this.doc,
    required this.matchCount,
    required this.snippet,
  });

  final DocumentRepository doc;
  final int matchCount;
  final String snippet;
}

/// Owns every note, the active selection, and routing of remote document
/// messages to the right note. Persists the note index + active selection.
class WorkspaceRepository extends ChangeNotifier {
  WorkspaceRepository({
    required this.instanceId,
    required NoteStorageService storage,
  }) : _storage = storage;

  final String instanceId;
  final NoteStorageService _storage;
  final _uuid = const Uuid();

  final Map<String, DocumentRepository> _docs = {};
  final List<String> _order = [];
  String? _activeId;

  /// Broadcasts a local document edit; wired to [SyncRepository].
  void Function(
    String docId,
    String title,
    int revision,
    String text,
    String originId,
  )?
  onDocUpdate;

  /// Broadcasts the local cursor position for the active note.
  void Function(String docId, int line, int column)? onPresence;

  /// Broadcasts a note deletion.
  void Function(String docId, String originId)? onDocDeleted;

  List<DocumentRepository> get documents => [
    for (final id in _order)
      if (_docs.containsKey(id)) _docs[id]!,
  ];

  String? get activeId => _activeId;
  DocumentRepository? get active =>
      _activeId == null ? null : _docs[_activeId];
  DocumentRepository? documentById(String id) => _docs[id];

  Future<void> load() async {
    final data = await _storage.loadWorkspace();
    if (data.documents.isEmpty) {
      _createLocal(
        id: _uuid.v4(),
        title: kDefaultNoteTitle,
        text: '',
        revision: 0,
      );
      _activeId = _order.first;
      await _persistIndex();
      await _storage.saveDocument(_docs[_activeId]!.toStored());
    } else {
      for (final stored in data.documents) {
        _register(
          DocumentRepository(
            instanceId: instanceId,
            id: stored.id,
            title: stored.title,
            text: stored.text,
            revision: stored.revision,
            history: stored.history,
            storage: _storage,
            onLocalEditReady: _handleLocalEdit,
          ),
        );
      }
      _activeId = data.activeId != null && _docs.containsKey(data.activeId)
          ? data.activeId
          : _order.first;
    }
  }

  // ----- Local user actions ---------------------------------------------------

  DocumentRepository createNote({String? title}) {
    final doc = _createLocal(
      id: _uuid.v4(),
      title: title ?? kDefaultNoteTitle,
      text: '',
      revision: 1,
    );
    _activeId = doc.id;
    unawaited(_storage.saveDocument(doc.toStored()));
    unawaited(_persistIndex());
    // Tell peers about the new (empty) note so it shows up in their list.
    onDocUpdate?.call(doc.id, doc.title, doc.revision, '', instanceId);
    notifyListeners();
    return doc;
  }

  void renameNote(String id, String title) {
    _docs[id]?.rename(title);
    unawaited(_persistIndex());
    notifyListeners();
  }

  void selectNote(String id) {
    if (!_docs.containsKey(id) || id == _activeId) return;
    _activeId = id;
    unawaited(_persistIndex());
    notifyListeners();
  }

  void deleteNote(String id) {
    final doc = _docs[id];
    if (doc == null) return;
    _removeFromState(id);
    onDocDeleted?.call(id, instanceId);
    unawaited(_storage.deleteDocument(id));
    _ensureAtLeastOneNote();
    unawaited(_persistIndex());
    notifyListeners();
  }

  // ----- Remote-driven changes ------------------------------------------------

  /// Returns the note with [docId], creating it (with [title]) if a peer is the
  /// first to mention it. Updates the title if it changed remotely.
  DocumentRepository ensureDocument(String docId, String title) {
    final existing = _docs[docId];
    if (existing != null) {
      if (title.isNotEmpty && title != existing.title) {
        existing.applyTitle(title);
        unawaited(_persistIndex());
        notifyListeners();
      }
      return existing;
    }
    final doc = _createLocal(
      id: docId,
      title: title.isEmpty ? kDefaultNoteTitle : title,
      text: '',
      revision: 0,
    );
    unawaited(_persistIndex());
    notifyListeners();
    return doc;
  }

  void removeDocumentRemote(String docId) {
    if (!_docs.containsKey(docId)) return;
    _removeFromState(docId);
    unawaited(_storage.deleteDocument(docId));
    _ensureAtLeastOneNote();
    unawaited(_persistIndex());
    notifyListeners();
  }

  // ----- Search ---------------------------------------------------------------

  List<NoteSearchHit> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return [
        for (final doc in documents)
          NoteSearchHit(doc: doc, matchCount: 0, snippet: ''),
      ];
    }
    final hits = <NoteSearchHit>[];
    for (final doc in documents) {
      final title = doc.title.toLowerCase();
      final body = doc.text.toLowerCase();
      final count = _countMatches(body, q) + _countMatches(title, q);
      if (count == 0) continue;
      hits.add(
        NoteSearchHit(
          doc: doc,
          matchCount: count,
          snippet: _snippet(doc.text, body, q),
        ),
      );
    }
    hits.sort((a, b) => b.matchCount.compareTo(a.matchCount));
    return hits;
  }

  int _countMatches(String haystack, String needle) {
    if (needle.isEmpty) return 0;
    var count = 0;
    var index = haystack.indexOf(needle);
    while (index != -1) {
      count++;
      index = haystack.indexOf(needle, index + needle.length);
    }
    return count;
  }

  String _snippet(String text, String lowerText, String q) {
    final index = lowerText.indexOf(q);
    if (index == -1) return '';
    final start = (index - 24).clamp(0, text.length);
    final end = (index + q.length + 40).clamp(0, text.length);
    final raw = text.substring(start, end).replaceAll('\n', ' ').trim();
    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';
    return '$prefix$raw$suffix';
  }

  // ----- Persistence ----------------------------------------------------------

  Future<void> flushSaveAll() async {
    for (final doc in _docs.values) {
      await doc.flushSave();
    }
    await _persistIndex();
  }

  Future<void> _persistIndex() => _storage.saveIndex(_order, _activeId);

  // ----- Internals ------------------------------------------------------------

  DocumentRepository _createLocal({
    required String id,
    required String title,
    required String text,
    required int revision,
  }) {
    final doc = DocumentRepository(
      instanceId: instanceId,
      id: id,
      title: title,
      text: text,
      revision: revision,
      storage: _storage,
      onLocalEditReady: _handleLocalEdit,
    );
    _register(doc);
    return doc;
  }

  void _register(DocumentRepository doc) {
    doc.onCursorMoved = (line, column) {
      if (doc.id == _activeId) onPresence?.call(doc.id, line, column);
    };
    doc.addListener(_onDocChanged);
    _docs[doc.id] = doc;
    _order.add(doc.id);
  }

  void _handleLocalEdit(
    String docId,
    int revision,
    String text,
    String originId,
  ) {
    final title = _docs[docId]?.title ?? '';
    onDocUpdate?.call(docId, title, revision, text, originId);
  }

  void _onDocChanged() => notifyListeners();

  void _removeFromState(String id) {
    final doc = _docs.remove(id);
    _order.remove(id);
    doc?.removeListener(_onDocChanged);
    doc?.dispose();
    if (_activeId == id) {
      _activeId = _order.isNotEmpty ? _order.first : null;
    }
  }

  void _ensureAtLeastOneNote() {
    if (_docs.isNotEmpty) return;
    final doc = _createLocal(
      id: _uuid.v4(),
      title: kDefaultNoteTitle,
      text: '',
      revision: 0,
    );
    _activeId = doc.id;
    unawaited(_storage.saveDocument(doc.toStored()));
  }

  @override
  void dispose() {
    for (final doc in _docs.values) {
      doc.removeListener(_onDocChanged);
      doc.dispose();
    }
    super.dispose();
  }
}
