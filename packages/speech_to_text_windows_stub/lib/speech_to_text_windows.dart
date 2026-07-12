import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

/// No-op Windows implementation — Netpad only uses speech on Android/iOS.
class SpeechToTextWindows extends SpeechToTextPlatform {
  static void registerWith() {
    SpeechToTextPlatform.instance = SpeechToTextWindows();
  }

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> initialize({
    debugLogging = false,
    List<SpeechConfigOption>? options,
  }) async =>
      false;

  @override
  Future<bool> listen({
    String? localeId,
    partialResults = true,
    onDevice = false,
    int listenMode = 0,
    sampleRate = 0,
    SpeechListenOptions? options,
  }) async =>
      false;

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<List<dynamic>> locales() async => const [];
}
