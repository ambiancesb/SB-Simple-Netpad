import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/ime_voice_gate.dart';

void main() {
  group('ImeVoiceGate.insertedSpan', () {
    test('detects append', () {
      expect(ImeVoiceGate.insertedSpan('Hello', 'Hello world'), ' world');
    });

    test('detects insert in the middle', () {
      expect(ImeVoiceGate.insertedSpan('Hello!', 'Hello there!'), ' there');
    });

    test('returns null for deletion', () {
      expect(ImeVoiceGate.insertedSpan('Hello world', 'Hello'), isNull);
    });

    test('returns null when unchanged', () {
      expect(ImeVoiceGate.insertedSpan('same', 'same'), isNull);
    });
  });

  group('ImeVoiceGate.looksLikeVoiceDictation', () {
    test('multi-word inserts look like voice', () {
      expect(ImeVoiceGate.looksLikeVoiceDictation('hello world'), isTrue);
      expect(ImeVoiceGate.looksLikeVoiceDictation(' one two '), isTrue);
    });

    test('single tokens are allowed (typing / swipe)', () {
      expect(ImeVoiceGate.looksLikeVoiceDictation('hello'), isFalse);
      expect(ImeVoiceGate.looksLikeVoiceDictation('a'), isFalse);
      expect(ImeVoiceGate.looksLikeVoiceDictation(''), isFalse);
    });
  });

  group('ImeVoiceGate.looksLikePaste', () {
    test('matches clipboard contents', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const channel = SystemChannels.platform;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      String? clipText;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'Clipboard.setData') {
          final args = call.arguments as Map<dynamic, dynamic>?;
          clipText = args?['text'] as String?;
          return null;
        }
        if (call.method == 'Clipboard.getData') {
          if (clipText == null) return null;
          return <String, dynamic>{'text': clipText};
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await Clipboard.setData(const ClipboardData(text: 'hello world'));
      expect(await ImeVoiceGate.looksLikePaste('hello world'), isTrue);
      expect(await ImeVoiceGate.looksLikePaste('other text here'), isFalse);
    });
  });
}
