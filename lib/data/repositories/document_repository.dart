import 'dart:async';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextSelection;
import 'package:netpad/core/constants.dart';
import 'package:netpad/services/note_storage_service.dart';

class DocumentRepository extends ChangeNotifier {
  DocumentRepository({
    required this.instanceId,
    required this.onLocalEditReady,
    NoteStorageService? storage,
  }) : _storage = storage ?? NoteStorageService();

  final String instanceId;
  final void Function(int revision, String text, String originId) onLocalEditReady;
  final NoteStorageService _storage;

  late final CodeController controller = CodeController(text: '');

  int _revision = 0;
  Timer? _debounce;
  Timer? _saveDebounce;
  bool _applyingRemote = false;

  int get revision => _revision;
  String get text => controller.text;

  /// Restores a previously saved note from disk.
  void loadSaved(SavedNote saved) {
    _revision = saved.revision;
    controller.text = saved.text;
    notifyListeners();
  }

  void onLocalEdit() {
    if (_applyingRemote) return;
    _debounce?.cancel();
    _debounce = Timer(kDocDebounce, () {
      _revision++;
      onLocalEditReady(_revision, controller.text, instanceId);
      _scheduleSave();
      notifyListeners();
    });
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_storage.save(controller.text, _revision));
    });
  }

  /// Persists immediately (e.g. app backgrounded).
  Future<void> flushSave() async {
    _saveDebounce?.cancel();
    await _storage.save(controller.text, _revision);
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

  void _apply(int revision, String text) {
    _revision = revision;
    _applyingRemote = true;
    final selection = controller.selection;
    final offset = selection.baseOffset.clamp(0, text.length);
    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
    _applyingRemote = false;
    _scheduleSave();
    notifyListeners();
  }

  Map<String, dynamic> snapshotPayload() => {
        'revision': _revision,
        'text': controller.text,
        'originId': instanceId,
      };

  @override
  void dispose() {
    _debounce?.cancel();
    _saveDebounce?.cancel();
    unawaited(_storage.save(controller.text, _revision));
    controller.dispose();
    super.dispose();
  }
}
