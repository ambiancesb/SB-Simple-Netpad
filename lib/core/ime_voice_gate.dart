import 'package:flutter/services.dart';

/// Detects system-keyboard voice typing (Gboard / iOS dictation) so freemium
/// can gate it the same way as the in-app mic.
abstract final class ImeVoiceGate {
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

  /// Multi-word bulk inserts are typical of IME voice typing (and paste).
  /// Single-token inserts (typing, swipe-to-type, autocorrect) are allowed.
  static bool looksLikeVoiceDictation(String inserted) {
    final trimmed = inserted.trim();
    if (trimmed.length < 2) return false;
    return trimmed.contains(RegExp(r'\s'));
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
