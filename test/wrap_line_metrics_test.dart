import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/features/editor/wrap_line_metrics.dart';

void main() {
  const style = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    height: 1.4,
  );

  group('wrapAwareLineNumbers', () {
    test('returns one row per logical line without wrap width', () {
      expect(
        wrapAwareLineNumbers(
          logicalLines: const ['alpha', 'beta'],
          textStyle: style,
          contentWidth: 0,
        ),
        ['1', '2'],
      );
    });

    test('adds blank gutter rows for wrapped logical lines', () {
      const longLine =
          'this is a much longer line that should wrap across multiple rows';
      final rows = wrapAwareLineNumbers(
        logicalLines: const ['short', longLine],
        textStyle: style,
        contentWidth: 120,
      );
      final wrappedCount = countWrappedVisualLines(longLine, style, 120);

      expect(rows.first, '1');
      expect(rows[1], '2');
      expect(wrappedCount, greaterThan(1));
      expect(rows.length, 2 + (wrappedCount - 1));
      expect(rows.where((row) => row.isEmpty).length, wrappedCount - 1);
    });

    test('empty logical lines stay single gutter rows', () {
      expect(
        wrapAwareLineNumbers(
          logicalLines: const [''],
          textStyle: style,
          contentWidth: 200,
        ),
        ['1'],
      );
    });
  });
}
