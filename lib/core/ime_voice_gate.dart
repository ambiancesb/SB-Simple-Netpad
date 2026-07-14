import 'package:flutter/services.dart';

/// Detects system-keyboard voice typing (Gboard / iOS dictation) so freemium
/// can gate it the same way as the in-app mic.
abstract final class ImeVoiceGate {
  static final _cjk = RegExp(
    r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uac00-\ud7af]',
  );

  /// Returns the inserted span when [after] is [before] with one contiguous
  /// insertion (or replacement). Returns null for pure deletions or complex
  /// multi-region edits.
  static String? insertedSpan(String before, String after) {
    if (after == before) return null;
    if (after.length < before.length) return null;

    var prefix = 0;
    final maxPrefix = before.length < after.length ? before.length : after.length;
    while (prefix < maxPrefix && before[prefix] == after[prefix]) {
      prefix++;
    }

    var beforeSuffix = before.length;
    var afterSuffix = after.length;
    while (beforeSuffix > prefix &&
        afterSuffix > prefix &&
        before[beforeSuffix - 1] == after[afterSuffix - 1]) {
      beforeSuffix--;
      afterSuffix--;
    }

    // Replacement or insert in the middle / at the caret.
    final inserted = after.substring(prefix, afterSuffix);
    if (inserted.isEmpty) return null;
    return inserted;
  }

  /// Bulk inserts typical of IME voice typing (and paste).
  ///
  /// Allows single-token typing / swipe-to-type / single-key input. Catches:
  /// - multi-word phrases
  /// - word commits with surrounding whitespace (Gboard / iOS often send `word `)
  /// - CJK dictation phrases (no spaces between words)
  /// - very large atomic inserts
  static bool looksLikeVoiceDictation(String inserted) {
    if (inserted.isEmpty) return false;

    final nonWhitespace = inserted.replaceAll(RegExp(r'\s'), '');
    if (nonWhitespace.isEmpty) return false;

    // Any insert that mixes content with whitespace in one update — including
    // trailing-space word commits from keyboard mic — looks like dictation.
    if (inserted.contains(RegExp(r'\s')) && nonWhitespace.length >= 2) {
      return true;
    }

    final trimmed = inserted.trim();
    if (trimmed.isEmpty) return false;

    // CJK scripts rarely insert multiple glyphs in one keypress; 4+ is typical
    // of voice (or paste, which is filtered separately via clipboard).
    if (_cjk.hasMatch(trimmed) && trimmed.runes.length >= 4) {
      return true;
    }

    // Extremely large single-token inserts are not typing / swipe.
    if (trimmed.length >= 32) return true;

    return false;
  }

  /// True when [inserted] matches the current clipboard (user paste).
  static Future<bool> looksLikePaste(String inserted) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final clip = data?.text?.trim();
    if (clip == null || clip.isEmpty) return false;
    final span = inserted.trim();
    if (span.isEmpty) return false;
    return span == clip || span.contains(clip) || clip.contains(span);
  }
}
