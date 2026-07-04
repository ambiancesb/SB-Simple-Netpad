import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps platform speech recognition for dictating into the editor on mobile.
class SpeechInputService extends ChangeNotifier {
  SpeechInputService() : _speech = SpeechToText();

  final SpeechToText _speech;

  bool _initialized = false;
  bool _listening = false;
  String? _lastError;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isListening => _listening;
  String? get lastError => _lastError;

  /// Called with each finalized phrase while listening.
  void Function(String phrase)? onFinalPhrase;

  Future<bool> initialize() async {
    if (!isSupported) return false;
    if (_initialized) return _speech.isAvailable;

    _initialized = true;
    final ok = await _speech.initialize(
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

    final ready = await initialize();
    if (!ready || !_speech.isAvailable) return false;

    _lastError = null;
    final started = await _speech.listen(
      onResult: (result) {
        if (!result.finalResult) return;
        final phrase = result.recognizedWords.trim();
        if (phrase.isEmpty) return;
        onFinalPhrase?.call(phrase);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        cancelOnError: true,
      ),
    );
    _setListening(started);
    return started;
  }

  Future<void> stopListening() async {
    if (!_listening) return;
    await _speech.stop();
    _setListening(false);
  }

  void _setListening(bool value) {
    if (_listening == value) return;
    _listening = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stopListening());
    super.dispose();
  }
}
