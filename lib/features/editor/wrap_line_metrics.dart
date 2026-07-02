import 'package:flutter/material.dart';

/// Counts how many visual rows [line] occupies when soft-wrapped at [maxWidth].
int countWrappedVisualLines(String line, TextStyle style, double maxWidth) {
  if (maxWidth <= 0) return 1;
  if (line.isEmpty) return 1;

  final painter = TextPainter(
    text: TextSpan(text: line, style: style),
    textDirection: TextDirection.ltr,
    strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
  )..layout(maxWidth: maxWidth);

  final metrics = painter.computeLineMetrics();
  return metrics.isEmpty ? 1 : metrics.length;
}

/// Builds gutter rows: one line number per logical line, blank rows for wraps.
List<String> wrapAwareLineNumbers({
  required List<String> logicalLines,
  required TextStyle textStyle,
  required double contentWidth,
}) {
  if (contentWidth <= 0) {
    return [for (var i = 0; i < logicalLines.length; i++) '${i + 1}'];
  }

  final rows = <String>[];
  for (var i = 0; i < logicalLines.length; i++) {
    rows.add('${i + 1}');
    final extra =
        countWrappedVisualLines(logicalLines[i], textStyle, contentWidth) - 1;
    for (var j = 0; j < extra; j++) {
      rows.add('');
    }
  }
  return rows;
}

/// Horizontal inset applied inside each [TextField] used by the editor gutter.
double editorFieldContentPaddingHorizontal(BuildContext context) {
  final padding =
      Theme.of(context).inputDecorationTheme.contentPadding ??
      const EdgeInsets.fromLTRB(12, 16, 12, 16);
  return padding.horizontal;
}
