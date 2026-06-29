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
  int _orderRevision = 0;

  /// Broadcasts that a new note was created locally.
  void Function(String docId, String title, int revision, String originId)?
  onDocCreate;

  /// Broadcasts that a note was renamed locally.
  void Function(String docId, String title, int revision, String originId)?
  onDocRename;

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

  /// Broadcasts the current note order (names follow each note's revision).
  void Function(List<String> order, int orderRevision, String originId)?
  onOrderChanged;

  List<DocumentRepository> get documents => [
    for (final id in _order)
      if (_docs.containsKey(id)) _docs[id]!,
  ];

  String? get activeId => _activeId;
  DocumentRepository? get active =>
      _activeId == null ? null : _docs[_activeId];
  bool hasDocument(String id) => _docs.containsKey(id);
  DocumentRepository? documentById(String id) => _docs[id];

  List<String> get noteOrder => List.unmodifiable(_order);
  int get orderRevision => _orderRevision;

  List<Map<String, dynamic>> catalogPayload() => [
    for (final id in _order)
      if (_docs.containsKey(id))
        {
          'docId': id,
          'title': _docs[id]!.title,
          'revision': _docs[id]!.revision,
        },
  ];

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
      _orderRevision = data.orderRevision;
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
    onDocCreate?.call(doc.id, doc.title, doc.revision, instanceId);
    _broadcastOrder();
    notifyListeners();
    return doc;
  }

  void renameNote(String id, String title) {
    final doc = _docs[id];
    if (doc == null) return;
    doc.rename(title);
    onDocRename?.call(id, doc.title, doc.revision, instanceId);
    unawaited(_persistIndex());
    notifyListeners();
  }

  void selectNote(String id) {
    if (!_docs.containsKey(id) || id == _activeId) return;
    _activeId = id;
    unawaited(_persistIndex());
    notifyListeners();
  }

  /// Moves a note within the drawer list and syncs the new order to peers.
  void reorderNote(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _order.length ||
        newIndex < 0 ||
        newIndex > _order.length) {
      return;
    }
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;
    final id = _order.removeAt(oldIndex);
    _order.insert(newIndex, id);
    _broadcastOrder();
    notifyListeners();
  }

  void deleteNote(String id) {
    final doc = _docs[id];
    if (doc == null) return;
    _removeFromState(id);
    onDocDeleted?.call(id, instanceId);
    unawaited(_storage.deleteDocument(id));
    _ensureAtLeastOneNote();
    _broadcastOrder();
    notifyListeners();
  }

  // ----- Remote-driven changes ------------------------------------------------

  /// Ensures a note shell exists locally (does not change an existing title).
  DocumentRepository ensureDocument(String docId, {String title = ''}) {
    final existing = _docs[docId];
    if (existing != null) return existing;
    final doc = _createLocal(
      id: docId,
      title: title.isEmpty ? kDefaultNoteTitle : title,
      text: '',
      revision: 0,
    );
    unawaited(_storage.saveDocument(doc.toStored()));
    unawaited(_persistIndex());
    notifyListeners();
    return doc;
  }

  /// Creates a note advertised by a peer, or bumps metadata if theirs is newer.
  void receiveRemoteCreate({
    required String docId,
    required String title,
    required int revision,
    required String originId,
  }) {
    final existing = _docs[docId];
    if (existing == null) {
      final doc = _createLocal(
        id: docId,
        title: title.isEmpty ? kDefaultNoteTitle : title,
        text: '',
        revision: revision,
      );
      unawaited(_storage.saveDocument(doc.toStored()));
      unawaited(_persistIndex());
      notifyListeners();
      return;
    }
    existing.applyRemoteRename(
      revision: revision,
      title: title,
      originId: originId,
    );
    unawaited(_persistIndex());
    notifyListeners();
  }

  /// Applies a peer rename when their revision wins.
  void receiveRemoteRename({
    required String docId,
    required String title,
    required int revision,
    required String originId,
  }) {
    final doc = ensureDocument(docId, title: title);
    if (doc.applyRemoteRename(
      revision: revision,
      title: title,
      originId: originId,
    )) {
      unawaited(_persistIndex());
      notifyListeners();
    }
  }

  /// Merges a peer's note catalog on connect: names, revisions, and list order.
  void mergeCatalog(
    List<Map<String, dynamic>> entries,
    String originId, {
    required int orderRevision,
  }) {
    var metadataChanged = false;
    for (final entry in entries) {
      final docId = entry['docId'] as String? ?? '';
      if (docId.isEmpty) continue;
      final title = entry['title'] as String? ?? '';
      final revision = entry['revision'] as int? ?? 0;
      if (!_docs.containsKey(docId)) {
        _createLocal(
          id: docId,
          title: title.isEmpty ? kDefaultNoteTitle : title,
          text: '',
          revision: revision,
        );
        metadataChanged = true;
        continue;
      }
      final doc = _docs[docId]!;
      if (doc.applyRemoteRename(
        revision: revision,
        title: title,
        originId: originId,
      )) {
        metadataChanged = true;
      }
    }

    final peerOrder = [
      for (final entry in entries)
        entry['docId'] as String? ?? '',
    ].where((id) => id.isNotEmpty).toList();
    applyRemoteOrder(peerOrder, orderRevision, originId);

    if (metadataChanged) {
      unawaited(_persistIndex());
      notifyListeners();
    }
  }

  /// Applies a peer's note order when their [orderRevision] wins.
  bool applyRemoteOrder(
    List<String> peerOrder,
    int orderRevision,
    String originId,
  ) {
    if (!_remoteOrderWins(orderRevision, originId)) return false;

    final merged = <String>[];
    for (final id in peerOrder) {
      if (_docs.containsKey(id)) merged.add(id);
    }
    for (final id in _order) {
      if (!merged.contains(id)) merged.add(id);
    }

    final orderChanged = !_listsEqual(merged, _order);
    if (orderChanged) {
      _order
        ..clear()
        ..addAll(merged);
    }
    _orderRevision = orderRevision;
    unawaited(_persistIndex());
    if (orderChanged) notifyListeners();
    return orderChanged;
  }

  /// Applies remote document content; creates the note if this is the first
  /// time we hear about it. Returns whether the content revision was applied.
  bool receiveRemoteContent({
    required String docId,
    required String title,
    required int revision,
    required String text,
    required String originId,
  }) {
    final created = !_docs.containsKey(docId);
    final doc = ensureDocument(docId, title: title);
    final applied = doc.applyRemote(
      revision: revision,
      text: text,
      originId: originId,
      title: title,
    );
    if (created || applied) {
      unawaited(_storage.saveDocument(doc.toStored()));
      unawaited(_persistIndex());
      notifyListeners();
    }
    return applied;
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

  Future<void> _persistIndex() => _storage.saveIndex(
    _order,
    _activeId,
    orderRevision: _orderRevision,
  );

  void _broadcastOrder() {
    _orderRevision++;
    onOrderChanged?.call(List.of(_order), _orderRevision, instanceId);
    unawaited(_persistIndex());
  }

  bool _remoteOrderWins(int revision, String originId) {
    if (revision > _orderRevision) return true;
    if (revision == _orderRevision && originId.compareTo(instanceId) > 0) {
      return true;
    }
    return false;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

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
