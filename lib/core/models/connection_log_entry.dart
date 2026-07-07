class ConnectionLogEntry {
  const ConnectionLogEntry({
    required this.timestamp,
    required this.message,
    this.peerId,
    this.peerName,
    this.revision,
  });

  final DateTime timestamp;
  final String message;
  final String? peerId;
  final String? peerName;
  final int? revision;

  String get timeLabel {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return [
      twoDigits(timestamp.hour),
      twoDigits(timestamp.minute),
      twoDigits(timestamp.second),
    ].join(':');
  }

  /// One line for clipboard export (chronological blocks use [timeLabel]).
  String get clipboardLine {
    final suffix = revision == null ? '' : ' (revision $revision)';
    return '[$timeLabel] $message$suffix';
  }
}
