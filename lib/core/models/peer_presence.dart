import 'package:netpad/l10n/app_localizations.dart';

/// Last-known cursor position reported by a connected peer, including which
/// note they were editing.
class PeerPresence {
  const PeerPresence({
    required this.line,
    required this.column,
    required this.updatedAt,
    this.docId,
    this.docTitle,
  });

  final int line;
  final int column;
  final DateTime updatedAt;

  /// Id of the note the peer's cursor is in (null for legacy peers).
  final String? docId;

  /// Title of that note, resolved locally for display.
  final String? docTitle;

  String localizedLabel(AppLocalizations l10n) {
    final position = l10n.peersPresenceLineCol(line, column);
    if (docTitle != null && docTitle!.isNotEmpty) {
      return l10n.peersPresenceInNote(docTitle!, position);
    }
    return position;
  }

  /// English fallback for non-UI callers.
  String get label {
    final position = 'line $line, col $column';
    if (docTitle != null && docTitle!.isNotEmpty) {
      return '"$docTitle" · $position';
    }
    return position;
  }
}
