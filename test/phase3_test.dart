import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/models/peer_presence.dart';
import 'package:netpad/services/text_position.dart';

void main() {
  group('lineColumnForOffset', () {
    test('start of document is line 1, column 1', () {
      expect(lineColumnForOffset('hello', 0), (line: 1, column: 1));
    });

    test('counts columns on a single line', () {
      expect(lineColumnForOffset('hello', 3), (line: 1, column: 4));
    });

    test('advances line after newline', () {
      const text = 'ab\ncd';
      expect(lineColumnForOffset(text, 3), (line: 2, column: 1));
      expect(lineColumnForOffset(text, 5), (line: 2, column: 3));
    });

    test('clamps out-of-range offsets', () {
      expect(lineColumnForOffset('ab', 99), (line: 1, column: 3));
      expect(lineColumnForOffset('ab', -5), (line: 1, column: 1));
    });
  });

  test('PeerPresence label is human readable', () {
    final presence = PeerPresence(
      line: 4,
      column: 2,
      updatedAt: DateTime(2026),
    );
    expect(presence.label, 'line 4, col 2');
  });
}
