/// Last-known cursor position reported by a connected peer.
class PeerPresence {
  const PeerPresence({
    required this.line,
    required this.column,
    required this.updatedAt,
  });

  final int line;
  final int column;
  final DateTime updatedAt;

  String get label => 'line $line, col $column';
}
