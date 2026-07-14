import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Live dictation update for a single phrase segment at [anchorOffset].
class DictationUpdate {
  const DictationUpdate({
    required this.anchorOffset,
    required this.previousSpan,
    required this.recognizedWords,
    required this.isFinal,
  });

  final int anchorOffset;
  final String previousSpan;
  final String recognizedWords;
  final bool isFinal;
}

/// Wraps platform speech recognition for dictating into the editor on mobile.
class SpeechInputService extends ChangeNotifier {
  SpeechInputService();

  /// Native speech plugin — created lazily and only on supported platforms so
  /// Desktop debug builds never load speech_to_text_windows (which can
  /// trip CRT debug assertions just by constructing the plugin).
  SpeechToText? _speech;

  bool _initialized = false;
  bool _listening = false;
  String? _lastError;
  String _liveText = '';
  int? _segmentAnchor;
  String _segmentSpan = '';

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isListening => _listening;
  String? get lastError => _lastError;
  String get liveText => _liveText;

  /// Returns the text actually written into the document for span tracking.
  String Function(DictationUpdate update)? onDictationUpdate;

  /// Supplies the text offset where the current phrase should be inserted.
  int Function()? getDictationAnchor;

  /// Freemium gate — return false to block starting dictation (e.g. show paywall).
  Future<bool> Function()? ensureVoiceAllowed;

  SpeechToText get _speechOrThrow {
    return _speech ??= SpeechToText();
  }

  Future<bool> initialize() async {
    if (!isSupported) return false;
    if (_initialized) return _speechOrThrow.isAvailable;

    _initialized = true;
    final ok = await _speechOrThrow.initialize(
      onError: (error) {
        _lastError = error.errorMsg;
        _setListening(false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _setListening(false);
        }
      },
    );
    if (!ok) {
      _lastError = 'Speech recognition is not available on this device';
    }
    notifyListeners();
    return ok;
  }

  Future<bool> toggleListening() async {
    if (_listening) {
      await stopListening();
      return false;
    }
    return startListening();
  }

  Future<bool> startListening() async {
    if (!isSupported) return false;
    if (_listening) return true;

    final ensure = ensureVoiceAllowed;
    if (ensure != null && !await ensure()) return false;

    final ready = await initialize();
    final speech = _speech;
    if (!ready || speech == null || !speech.isAvailable) return false;

    _lastError = null;
    _liveText = '';
    _segmentAnchor = getDictationAnchor?.call();
    _segmentSpan = '';

    final started = await speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: Platform.isIOS,
      ),
    );
    _setListening(started);
    return started;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    _liveText = words;

    final anchor = _segmentAnchor;
    if (anchor != null && words.isNotEmpty) {
      final inserted = onDictationUpdate?.call(
        DictationUpdate(
          anchorOffset: anchor,
          previousSpan: _segmentSpan,
          recognizedWords: words,
          isFinal: result.finalResult,
        ),
      );
      _segmentSpan = inserted ?? words;
    }

    if (result.finalResult) {
      _segmentSpan = '';
      _liveText = '';
      _segmentAnchor = getDictationAnchor?.call();
    }

    notifyListeners();
  }

  Future<void> stopListening() async {
    if (!_listening) return;
    await _speech?.stop();
    _resetSession();
    _setListening(false);
  }

  void _resetSession() {
    _liveText = '';
    _segmentAnchor = null;
    _segmentSpan = '';
  }

  void _setListening(bool value) {
    if (_listening == value) return;
    _listening = value;
    if (!value) _resetSession();
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stopListening());
    super.dispose();
  }
}
