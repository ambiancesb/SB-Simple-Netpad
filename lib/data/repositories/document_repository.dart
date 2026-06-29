import 'dart:async';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextSelection;
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/history_entry.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:netpad/services/text_position.dart';

/// A single note: its text controller, replicated revision, and local version
/// history. The owning [WorkspaceRepository] wires the broadcast callbacks.
class DocumentRepository extends ChangeNotifier {
  DocumentRepository({
    required this.instanceId,
    required this.id,
    required String title,
    required int revision,
    required String text,
    required NoteStorageService storage,
    required this.onLocalEditReady,
    List<HistoryEntry> history = const [],
  }) : _storage = storage,
       _title = title,
       _revision = revision,
       _history = List.of(history) {
    controller.text = text;
    controller.addListener(_onControllerChanged);
  }

  final String instanceId;
  final String id;

  /// Reports a ready-to-send local edit: (docId, revision, text, originId).
  final void Function(String docId, int revision, String text, String originId)
  onLocalEditReady;
  final NoteStorageService _storage;

  /// Reports the local cursor position so it can be shared with peers.
  void Function(int line, int column)? onCursorMoved;

  late final CodeController controller = CodeController(text: '');

  String _title;
  int _revision;
  final List<HistoryEntry> _history;
  DateTime? _lastAutoSnapshot;

  Timer? _debounce;
  Timer? _saveDebounce;
  Timer? _presenceDebounce;
  bool _applyingRemote = false;
  int? _lastLine;
  int? _lastColumn;

  String get title => _title;
  int get revision => _revision;
  String get text => controller.text;
  List<HistoryEntry> get history => List.unmodifiable(_history.reversed);

  StoredDocument toStored() => StoredDocument(
    id: id,
    title: _title,
    text: controller.text,
    revision: _revision,
    history: List.of(_history),
  );

  /// Updates the title from a remote peer without bumping the revision or
  /// rebroadcasting (the change already came from the network).
  void applyTitle(String title) {
    final next = title.trim().isEmpty ? kDefaultNoteTitle : title.trim();
    if (next == _title) return;
    _title = next;
    _scheduleSave();
    notifyListeners();
  }

  void rename(String title) {
    final next = title.trim().isEmpty ? kDefaultNoteTitle : title.trim();
    if (next == _title) return;
    _title = next;
    _revision++;
    onLocalEditReady(id, _revision, controller.text, instanceId);
    _scheduleSave();
    notifyListeners();
  }

  void onLocalEdit() {
    if (_applyingRemote) return;
    _debounce?.cancel();
    _debounce = Timer(kDocDebounce, () {
      _maybeAutoSnapshot('Edit checkpoint');
      _revision++;
      onLocalEditReady(id, _revision, controller.text, instanceId);
      _scheduleSave();
      notifyListeners();
    });
  }

  /// Replaces the whole document with [text] as a local edit (e.g. opening a
  /// file or restoring a version) and broadcasts it immediately.
  void replaceLocal(String text, {String snapshotLabel = 'Before replace'}) {
    _snapshot(snapshotLabel);
    _applyingRemote = true;
    _setControllerText(text, 0);
    _applyingRemote = false;
    _revision++;
    onLocalEditReady(id, _revision, text, instanceId);
    _scheduleSave();
    notifyListeners();
  }

  void _onControllerChanged() {
    if (_applyingRemote) return;
    final callback = onCursorMoved;
    if (callback == null) return;
    _presenceDebounce?.cancel();
    _presenceDebounce = Timer(kPresenceDebounce, () {
      final offset = controller.selection.baseOffset;
      if (offset < 0) return;
      final pos = lineColumnForOffset(controller.text, offset);
      if (pos.line == _lastLine && pos.column == _lastColumn) return;
      _lastLine = pos.line;
      _lastColumn = pos.column;
      callback(pos.line, pos.column);
    });
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_storage.saveDocument(toStored()));
    });
  }

  /// Persists immediately (e.g. app backgrounded).
  Future<void> flushSave() async {
    _saveDebounce?.cancel();
    await _storage.saveDocument(toStored());
  }

  /// Applies a remote document unconditionally (used to resolve a reconnect
  /// divergence in favour of the peer).
  void forceApplyRemote({required int revision, required String text}) {
    _apply(revision, text, snapshotLabel: 'Before using peer version');
  }

  /// Bumps the revision above [atLeastRevision] and rebroadcasts the local text
  /// (used to resolve a reconnect divergence in favour of this device).
  void bumpAndBroadcast(int atLeastRevision) {
    _revision = (atLeastRevision > _revision ? atLeastRevision : _revision) + 1;
    onLocalEditReady(id, _revision, controller.text, instanceId);
    _scheduleSave();
    notifyListeners();
  }

  /// Restores a saved version, broadcasting it as a fresh local edit.
  void restore(HistoryEntry entry) {
    replaceLocal(entry.text, snapshotLabel: 'Before restore');
  }

  bool applyRemote({
    required int revision,
    required String text,
    required String originId,
  }) {
    if (revision > _revision) {
      _apply(revision, text);
      return true;
    }
    if (revision == _revision && originId.compareTo(instanceId) > 0) {
      _apply(revision, text);
      return true;
    }
    return false;
  }

  void _apply(int revision, String text, {String? snapshotLabel}) {
    _snapshot(snapshotLabel ?? 'Before remote update');
    _revision = revision;
    _applyingRemote = true;
    _setControllerText(text, controller.selection.baseOffset);
    _applyingRemote = false;
    _scheduleSave();
    notifyListeners();
  }

  /// Replaces the controller text + caret, first normalising any invalid
  /// (-1) selection so code_text_field's auto-close detection can't index out
  /// of range when the text grows by exactly one character.
  void _setControllerText(String text, int caret) {
    final safeOld = controller.selection.baseOffset.clamp(
      0,
      controller.text.length,
    );
    if (controller.selection.baseOffset != safeOld) {
      controller.selection = TextSelection.collapsed(offset: safeOld);
    }
    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: caret.clamp(0, text.length)),
    );
  }

  /// Records the current text as a recoverable version, unless it would
  /// duplicate the most recent snapshot or the note is empty.
  void _snapshot(String label) {
    final current = controller.text;
    if (current.trim().isEmpty) return;
    if (_history.isNotEmpty && _history.last.text == current) return;
    _history.add(
      HistoryEntry(
        text: current,
        revision: _revision,
        savedAt: DateTime.now(),
        label: label,
      ),
    );
    if (_history.length > kMaxHistoryEntries) {
      _history.removeRange(0, _history.length - kMaxHistoryEntries);
    }
  }

  void _maybeAutoSnapshot(String label) {
    final now = DateTime.now();
    if (_lastAutoSnapshot != null &&
        now.difference(_lastAutoSnapshot!) < kHistoryMinInterval) {
      return;
    }
    _lastAutoSnapshot = now;
    _snapshot(label);
  }

  Map<String, dynamic> snapshotPayload() => {
    'docId': id,
    'title': _title,
    'revision': _revision,
    'text': controller.text,
    'originId': instanceId,
  };

  @override
  void dispose() {
    _debounce?.cancel();
    _saveDebounce?.cancel();
    _presenceDebounce?.cancel();
    controller.removeListener(_onControllerChanged);
    unawaited(_storage.saveDocument(toStored()));
    controller.dispose();
    super.dispose();
  }
}
