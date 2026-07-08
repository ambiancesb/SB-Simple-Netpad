import 'package:flutter/material.dart';

/// Editor text-area colors derived from the active Material [ColorScheme].
///
/// Keeps the notepad surface in sync with System / Light / Dark and skins.
class EditorColors {
  const EditorColors({
    required this.background,
    required this.foreground,
    required this.lineNumber,
    required this.cursor,
    required this.selection,
  });

  final Color background;
  final Color foreground;
  final Color lineNumber;
  final Color cursor;
  final Color selection;

  factory EditorColors.of(ColorScheme scheme) {
    return EditorColors(
      background: scheme.surface,
      foreground: scheme.onSurface,
      lineNumber: scheme.outline,
      cursor: scheme.primary,
      selection: scheme.primary.withValues(alpha: 0.28),
    );
  }
}
