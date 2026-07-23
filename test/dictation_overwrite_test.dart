import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show TextSelection;
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/dictation_hypothesis.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NoteStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return NoteStorageService(await SharedPreferences.getInstance());
}

void _dbg(String message, Map<String, Object?> data, {String hypothesisId = 'H1'}) {
  final payload = <String, Object?>{
    'sessionId': '240d60',
    'runId': 'unit-repro',
    'hypothesisId': hypothesisId,
    'location': 'dictation_overwrite_test.dart',
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  File(
    '/home/spencer/Coding Projects/SB-Simple-Netpad/.cursor/debug-240d60.log',
  ).writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
}

/// Mirrors [SpeechInputService._onSpeechResult] span tracking against a doc.
class _DictationHarness {
  _DictationHarness(this.doc) {
    anchor = doc.dictationAnchorOffset();
  }

  final DocumentRepository doc;
  int anchor = 0;
  String span = '';

  void applyWords(String words, {required bool isFinal}) {
    final decision = resolveDictationHypothesis(
      previousRecognized: span.trim(),
      nextRecognized: words,
    );
    if (decision.kind == DictationMergeKind.newSegment) {
      anchor = doc.dictationAnchorOffset();
      span = '';
    }
    final recognized = decision.kind == DictationMergeKind.replace
        ? decision.recognizedWords
        : words;
    span = doc.applyDictation(
      anchorOffset: anchor,
      previousSpan: span,
      recognizedWords: recognized,
      isFinal: isFinal,
    );
    if (isFinal) {
      span = '';
      anchor = doc.dictationAnchorOffset();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveDictationHypothesis', () {
    test('treats cumulative growth as replace', () {
      final d = resolveDictationHypothesis(
        previousRecognized: 'hello',
        nextRecognized: 'hello world',
      );
      expect(d.kind, DictationMergeKind.replace);
      expect(d.recognizedWords, 'hello world');
    });

    test('treats shrinking correction as replace', () {
      final d = resolveDictationHypothesis(
        previousRecognized: 'hello world',
        nextRecognized: 'hello',
      );
      expect(d.kind, DictationMergeKind.replace);
      expect(d.recognizedWords, 'hello');
    });

    test('merges sliding recognition windows without dropping the head', () {
      final d = resolveDictationHypothesis(
        previousRecognized: 'the quick brown fox',
        nextRecognized: 'brown fox jumps',
      );
      expect(d.kind, DictationMergeKind.replace);
      expect(d.recognizedWords, 'the quick brown fox jumps');
    });

    test('starts a new segment for disjoint phrases', () {
      final d = resolveDictationHypothesis(
        previousRecognized: 'hello',
        nextRecognized: 'world',
      );
      expect(d.kind, DictationMergeKind.newSegment);
      expect(d.recognizedWords, 'world');
    });
  });

  group('dictation overwrite edge cases', () {
    test('BUG repro: naive span replace loses earlier words on non-cumulative results',
        () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: '',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      doc.controller.selection = const TextSelection.collapsed(offset: 0);

      // Naive SpeechInputService behavior (fixed anchor + replace previous span).
      var anchor = 0;
      var span = '';
      for (final words in ['alpha', 'beta', 'gamma']) {
        span = doc.applyDictation(
          anchorOffset: anchor,
          previousSpan: span,
          recognizedWords: words,
          isFinal: false,
        );
      }
      _dbg('naive non-cumulative result', {
        'text': doc.text,
        'lostAlpha': !doc.text.contains('alpha'),
      });
      expect(doc.text.contains('alpha'), isFalse);
      expect(doc.text.trim(), 'gamma');
    });

    test('inflated previousSpan length can eat trailing neighbors', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'AAHELLOBB',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      // Span tracker claims a longer range than what is actually at the anchor.
      doc.applyDictation(
        anchorOffset: 2,
        previousSpan: 'HELLOXXXXX',
        recognizedWords: 'Y',
        isFinal: false,
      );
      _dbg('inflated span eats trailing', {
        'text': doc.text,
        'lostBB': !doc.text.contains('BB'),
      }, hypothesisId: 'H5');
      expect(doc.text.contains('BB'), isFalse);
    });

    test('written span length matches buffer after truncation', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'PREFIX',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
        maxCharacters: () => 10,
      );
      doc.controller.selection = const TextSelection.collapsed(offset: 6);

      final span = doc.applyDictation(
        anchorOffset: 6,
        previousSpan: '',
        recognizedWords: 'ABCDEFGHIJ',
        isFinal: false,
      );
      _dbg('written span after truncation', {
        'text': doc.text,
        'span': span,
        'spanLen': span.length,
        'expected': doc.text.length - 6,
      }, hypothesisId: 'H5');
      expect(doc.text.length, 10);
      expect(span, doc.text.substring(6));
    });

    test('fixed harness keeps prior words across non-cumulative results', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: '',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      doc.controller.selection = const TextSelection.collapsed(offset: 0);
      final harness = _DictationHarness(doc);

      harness.applyWords('alpha', isFinal: false);
      harness.applyWords('beta', isFinal: false);
      harness.applyWords('gamma', isFinal: true);

      _dbg('fixed non-cumulative result', {'text': doc.text});
      expect(doc.text, contains('alpha'));
      expect(doc.text, contains('beta'));
      expect(doc.text, contains('gamma'));
    });

    test('fixed harness merges sliding windows on one logical line', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: '',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      doc.controller.selection = const TextSelection.collapsed(offset: 0);
      final harness = _DictationHarness(doc);

      harness.applyWords('the quick brown fox', isFinal: false);
      harness.applyWords('brown fox jumps over', isFinal: false);
      harness.applyWords('fox jumps over the lazy dog', isFinal: true);

      _dbg('fixed sliding window', {'text': doc.text});
      expect(doc.text, contains('the quick'));
      expect(doc.text, contains('lazy dog'));
      expect(doc.text.contains('brown fox brown fox'), isFalse);
    });

    test('invalid selection anchor should not clamp to zero for dictation', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'existing note body',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      doc.controller.selection = const TextSelection.collapsed(offset: -1);
      final anchor = doc.dictationAnchorOffset();
      _dbg('invalid selection anchor', {
        'anchor': anchor,
        'textLen': doc.text.length,
      }, hypothesisId: 'H2');
      expect(anchor, doc.text.length);
    });
  });
}
