/// Case-insensitive find/replace helpers for the in-note editor bar.
class FindReplace {
  const FindReplace._();

  /// Returns the start offset of every non-overlapping match of [needle] in
  /// [haystack], compared case-insensitively.
  static List<int> matchOffsets(String haystack, String needle) {
    if (needle.isEmpty) return const [];
    final lowerHay = haystack.toLowerCase();
    final lowerNeedle = needle.toLowerCase();
    final matches = <int>[];
    var index = lowerHay.indexOf(lowerNeedle);
    while (index != -1) {
      matches.add(index);
      index = lowerHay.indexOf(lowerNeedle, index + lowerNeedle.length);
    }
    return matches;
  }

  /// Replaces every non-overlapping match of [needle] in [text].
  static String replaceAll(String text, String needle, String replacement) {
    if (needle.isEmpty) return text;
    final lowerText = text.toLowerCase();
    final lowerNeedle = needle.toLowerCase();
    final buffer = StringBuffer();
    var start = 0;
    var index = lowerText.indexOf(lowerNeedle, start);
    while (index != -1) {
      buffer.write(text.substring(start, index));
      buffer.write(replacement);
      start = index + needle.length;
      index = lowerText.indexOf(lowerNeedle, start);
    }
    buffer.write(text.substring(start));
    return buffer.toString();
  }

  /// Replaces the match at [matchIndex] in [matches] and returns the updated
  /// text plus the next match index to select (or -1 when none remain).
  static ({String text, int nextMatchIndex}) replaceOne({
    required String text,
    required String needle,
    required String replacement,
    required List<int> matches,
    required int matchIndex,
  }) {
    if (needle.isEmpty || matches.isEmpty) {
      return (text: text, nextMatchIndex: -1);
    }
    final start = matches[matchIndex];
    final end = start + needle.length;
    final updated =
        '${text.substring(0, start)}$replacement${text.substring(end)}';
    final delta = replacement.length - needle.length;
    final nextMatches = <int>[];
    for (var i = 0; i < matches.length; i++) {
      if (i == matchIndex) continue;
      final offset = matches[i];
      nextMatches.add(offset > start ? offset + delta : offset);
    }
    final nextIndex = matchIndex < nextMatches.length ? matchIndex : -1;
    return (text: updated, nextMatchIndex: nextIndex);
  }
}
