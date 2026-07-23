import 'dart:async';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextSelection;
import 'package:netpad/core/agent_debug_log.dart';
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
    this.maxCharacters,
    List<HistoryEntry> history = const [],
  }) : _storage = storage,
       _title = title,
       _revision = revision,
       _history = List.of(history) {
    _lastKnownText = text;
    controller.text = text;
    controller.addListener(_onControllerChanged);
  }

  final String instanceId;
  final String id;

  /// Reports a ready-to-send local edit: (docId, revision, text, originId).
  final void Function(String docId, int revision, String text, String originId)
  onLocalEditReady;

  /// Free-tier character cap; `null` means unlimited. Remote applies ignore this.
  final int? Function()? maxCharacters;
  final NoteStorageService _storage;

  /// Reports the local cursor position so it can be shared with peers.
  void Function(int line, int column)? onCursorMoved;

  late final CodeController controller = CodeController(
    text: '',
    modifiers: const [],
  );

  String _title;
  int _revision;
  final List<HistoryEntry> _history;
  DateTime? _lastAutoSnapshot;

  Timer? _debounce;
  Timer? _saveDebounce;
  Timer? _presenceDebounce;
  bool _applyingRemote = false;
  bool _applyingDictation = false;
  bool _clampingCharacters = false;
  late String _lastKnownText;
  int? _lastLine;
  int? _lastColumn;

  String get title => _title;
  int get revision => _revision;
  String get text => controller.text;
  List<HistoryEntry> get history => List.unmodifiable(_history.reversed);

  /// True while sync/dictation/restore/clamp code is writing the controller.
  bool get isApplyingProgrammatic =>
      _applyingRemote || _applyingDictation || _clampingCharacters;

  StoredDocument toStored() => StoredDocument(
    id: id,
    title: _title,
    text: controller.text,
    revision: _revision,
    history: List.of(_history),
  );

  void rename(String title) {
    final next = title.trim().isEmpty ? kDefaultNoteTitle : title.trim();
    if (next == _title) return;
    _title = next;
    _revision++;
    _scheduleSave();
    notifyListeners();
  }

  /// Inserts [text] at the current selection, replacing any selected range.
  void insertAtSelection(String text) {
    if (text.isEmpty || _applyingRemote) return;
    final sel = controller.selection;
    applyDictation(
      anchorOffset: sel.start,
      previousSpan: sel.textInside(controller.text),
      recognizedWords: text,
      isFinal: true,
    );
  }

  /// Applies live or final speech recognition at [anchorOffset].
  /// Returns the text span that was written (for dictation tracking).
  String applyDictation({
    required int anchorOffset,
    required String previousSpan,
    required String recognizedWords,
    required bool isFinal,
  }) {
    if (recognizedWords.isEmpty || _applyingRemote) return previousSpan;

    final body = controller.text;
    final start = anchorOffset.clamp(0, body.length);
    final end = (start + previousSpan.length).clamp(start, body.length);
    final existing = body.substring(start, end);
    final spanMatches = existing == previousSpan;
    final prefix = previousSpan.isNotEmpty
        ? (previousSpan.startsWith(' ') ? ' ' : '')
        : (start > 0 && body[start - 1] != ' ' && body[start - 1] != '\n'
            ? ' '
            : '');
    final insertion = '$prefix$recognizedWords';
    var updated = body.replaceRange(start, end, insertion);
    final limit = maxCharacters?.call();
    var truncated = false;
    if (limit != null && updated.length > limit) {
      updated = updated.substring(0, limit);
      truncated = true;
    }
    final writtenEnd = truncated
        ? updated.length.clamp(start, updated.length)
        : (start + insertion.length).clamp(0, updated.length);
    final writtenSpan = start < updated.length
        ? updated.substring(start, writtenEnd)
        : '';
    final caret = writtenEnd;
    final lostBefore =
        start > 0 && !spanMatches && existing.isNotEmpty;
    final bodyShrunk = updated.length < body.length && !truncated;
    // #region agent log
    agentDebugLog(
      location: 'document_repository.dart:applyDictation',
      message: 'apply dictation span replace',
      hypothesisId: truncated
          ? 'H5'
          : (!spanMatches
              ? 'H3'
              : (anchorOffset <= 0 && body.isNotEmpty ? 'H2' : 'H1')),
      data: {
        'anchorOffset': anchorOffset,
        'start': start,
        'end': end,
        'bodyLen': body.length,
        'updatedLen': updated.length,
        'prevSpanLen': previousSpan.length,
        'insertionLen': insertion.length,
        'writtenSpanLen': writtenSpan.length,
        'recognizedLen': recognizedWords.length,
        'isFinal': isFinal,
        'spanMatches': spanMatches,
        'truncated': truncated,
        'limit': limit,
        'caret': caret,
        'selectionValid': controller.selection.isValid,
        'selectionStart': controller.selection.start,
        'lostBefore': lostBefore,
        'bodyShrunk': bodyShrunk,
        'existingTail': existing.length > 60
            ? existing.substring(existing.length - 60)
            : existing,
        'insertionTail': insertion.length > 60
            ? insertion.substring(insertion.length - 60)
            : insertion,
        'prefixBeforeStart': body.substring(
          start > 40 ? start - 40 : 0,
          start,
        ),
      },
    );
    // #endregion
    _applyingDictation = true;
    _setControllerText(updated, caret);
    _applyingDictation = false;
    if (isFinal) {
      onLocalEdit();
    } else {
      notifyListeners();
    }
    // Track what is actually in the buffer so the next replace cannot extend
    // past EOF via an inflated span after character-limit truncation.
    return writtenSpan;
  }

  /// Restores [text] after a blocked IME voice insert (no sync / history bump).
  void revertUnauthorizedEdit(String text, {required int caret}) {
    _applyingRemote = true;
    _setControllerText(text, caret);
    _lastKnownText = text;
    _applyingRemote = false;
    notifyListeners();
  }

  int dictationAnchorOffset() {
    final sel = controller.selection;
    final textLen = controller.text.length;
    // Invalid / unfocused selection used to clamp to 0 and overwrite the note
    // from the start. Prefer appending at the end for dictation.
    final start = (!sel.isValid || sel.start < 0)
        ? textLen
        : sel.start.clamp(0, textLen);
    final end = (!sel.isValid || sel.end < 0)
        ? textLen
        : sel.end.clamp(0, textLen);
    // #region agent log
    agentDebugLog(
      location: 'document_repository.dart:dictationAnchorOffset',
      message: 'read dictation anchor',
      hypothesisId: 'H2',
      data: {
        'selValid': sel.isValid,
        'selStart': sel.start,
        'selEnd': sel.end,
        'clamped': start,
        'textLen': textLen,
        'usedEndFallback': !sel.isValid || sel.start < 0,
      },
    );
    // #endregion
    if (start != end) return start;
    return start;
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
    final limit = maxCharacters?.call();
    final next = (limit != null && text.length > limit)
        ? text.substring(0, limit)
        : text;
    _applyingRemote = true;
    _setControllerText(next, 0);
    _applyingRemote = false;
    _revision++;
    onLocalEditReady(id, _revision, next, instanceId);
    _scheduleSave();
    notifyListeners();
  }

  void _onControllerChanged() {
    var currentText = controller.text;
    if (_applyingRemote || _clampingCharacters) {
      _lastKnownText = currentText;
      _notifyCursorMoved();
      return;
    }

    final limit = maxCharacters?.call();
    if (limit != null && currentText.length > limit) {
      final caret = controller.selection.baseOffset.clamp(0, limit);
      _clampingCharacters = true;
      _setControllerText(currentText.substring(0, limit), caret);
      _clampingCharacters = false;
      currentText = controller.text;
    }

    if (currentText != _lastKnownText) {
      _lastKnownText = currentText;
      notifyListeners();
      onLocalEdit();
    }

    _notifyCursorMoved();
  }

  void _notifyCursorMoved() {
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
  void forceApplyRemote({
    required int revision,
    required String text,
    String? title,
  }) {
    _apply(
      revision,
      text,
      snapshotLabel: 'Before using peer version',
      title: title,
    );
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

  /// Whether [revision] from [originId] should win over the local revision.
  bool remoteRevisionWins(int revision, String originId) {
    if (revision > _revision) return true;
    if (revision == _revision && originId.compareTo(instanceId) > 0) {
      return true;
    }
    return false;
  }

  /// True when a peer edit collides at the same revision with different text.
  bool isLiveEditConflict({
    required int revision,
    required String text,
    required String originId,
  }) {
    return revision == _revision &&
        text != controller.text &&
        originId != instanceId;
  }

  bool applyRemote({
    required int revision,
    required String text,
    required String originId,
    String? title,
  }) {
    if (!remoteRevisionWins(revision, originId)) return false;
    _apply(revision, text, snapshotLabel: 'Before remote update', title: title);
    return true;
  }

  /// Applies a title-only change from a peer when their revision wins.
  bool applyRemoteRename({
    required int revision,
    required String title,
    required String originId,
  }) {
    if (!remoteRevisionWins(revision, originId)) return false;
    _revision = revision;
    _title = title.trim().isEmpty ? kDefaultNoteTitle : title.trim();
    _scheduleSave();
    notifyListeners();
    return true;
  }

  void _apply(
    int revision,
    String text, {
    String? snapshotLabel,
    String? title,
  }) {
    _snapshot(snapshotLabel ?? 'Before remote update');
    _revision = revision;
    if (title != null) {
      final next = title.trim().isEmpty ? kDefaultNoteTitle : title.trim();
      _title = next;
    }
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
  /// duplicate the most recent snapshot, the note is empty, or storage caps apply.
  void _snapshot(String label) {
    final current = controller.text;
    if (current.trim().isEmpty) return;
    if (current.length > kMaxHistorySnapshotChars) return;
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
    _trimHistoryTotalChars();
  }

  void _trimHistoryTotalChars() {
    var total = 0;
    for (final entry in _history) {
      total += entry.text.length;
    }
    while (total > kMaxHistoryTotalChars && _history.isNotEmpty) {
      total -= _history.first.text.length;
      _history.removeAt(0);
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
