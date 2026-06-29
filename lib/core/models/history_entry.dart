/// A local point-in-time snapshot of a note, kept so text clobbered by a newer
/// remote revision (or a file open) can be recovered.
class HistoryEntry {
  const HistoryEntry({
    required this.text,
    required this.revision,
    required this.savedAt,
    required this.label,
  });

  final String text;
  final int revision;
  final DateTime savedAt;

  /// Short reason the snapshot was taken (e.g. "Before remote update").
  final String label;

  /// First non-empty line, trimmed for display in the history list.
  String get preview {
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        return trimmed.length > 80 ? '${trimmed.substring(0, 80)}…' : trimmed;
      }
    }
    return '(empty)';
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'revision': revision,
    'savedAt': savedAt.millisecondsSinceEpoch,
    'label': label,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    text: json['text'] as String? ?? '',
    revision: json['revision'] as int? ?? 0,
    savedAt: DateTime.fromMillisecondsSinceEpoch(json['savedAt'] as int? ?? 0),
    label: json['label'] as String? ?? 'Snapshot',
  );
}
