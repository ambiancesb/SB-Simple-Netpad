/// Merges successive speech-recognition hypotheses for in-app dictation.
///
/// Platforms sometimes emit:
/// - cumulative growth (`hello` → `hello world`)
/// - corrections (`hello world` → `hello`)
/// - sliding windows (`the quick brown fox` → `brown fox jumps`)
/// - disjoint phrases (`hello` then `world`)
///
/// Blind span-replace of the previous hypothesis with the latest string drops
/// earlier words in the sliding-window and disjoint cases — which shows up as
/// “same line overwrite” when word wrap is on and there is no `\n`.
library;

enum DictationMergeKind {
  /// Replace the current live span with [DictationMerge.recognizedWords].
  replace,

  /// Commit the current span as-is and start a new span with [recognizedWords].
  newSegment,
}

class DictationMerge {
  const DictationMerge.replace(this.recognizedWords)
      : kind = DictationMergeKind.replace;

  const DictationMerge.newSegment(this.recognizedWords)
      : kind = DictationMergeKind.newSegment;

  final DictationMergeKind kind;
  final String recognizedWords;
}

/// Resolves how [nextRecognized] relates to [previousRecognized].
DictationMerge resolveDictationHypothesis({
  required String previousRecognized,
  required String nextRecognized,
}) {
  final prev = previousRecognized.trim();
  final next = nextRecognized.trim();
  if (next.isEmpty) {
    return DictationMerge.replace(prev);
  }
  if (prev.isEmpty) {
    return DictationMerge.replace(next);
  }
  if (next.startsWith(prev) || prev.startsWith(next)) {
    return DictationMerge.replace(next);
  }

  final overlap = _longestSuffixPrefixOverlap(prev, next);
  // Prefer word-sized overlaps so tiny accidental matches don't merge phrases.
  if (overlap >= 3 && _overlapLooksMeaningful(prev, next, overlap)) {
    return DictationMerge.replace(prev.substring(0, prev.length - overlap) + next);
  }
  return DictationMerge.newSegment(next);
}

int _longestSuffixPrefixOverlap(String prev, String next) {
  final max = prev.length < next.length ? prev.length : next.length;
  for (var len = max; len > 0; len--) {
    if (prev.endsWith(next.substring(0, len))) return len;
  }
  return 0;
}

bool _overlapLooksMeaningful(String prev, String next, int overlap) {
  final piece = next.substring(0, overlap);
  // Whole-word or whitespace-bounded overlap.
  if (piece.contains(' ')) return true;
  final prevBefore = prev.length == overlap || prev[prev.length - overlap - 1] == ' ';
  final nextAfter = next.length == overlap || next[overlap] == ' ';
  return prevBefore && nextAfter;
}
