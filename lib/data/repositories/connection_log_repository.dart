import 'package:flutter/foundation.dart';
import 'package:netpad/core/models/connection_log_entry.dart';

class ConnectionLogRepository extends ChangeNotifier {
  ConnectionLogRepository({this.maxEntries = 100});

  final int maxEntries;
  final List<ConnectionLogEntry> _entries = [];

  List<ConnectionLogEntry> get entries => List.unmodifiable(_entries);

  /// Full log as plain text, oldest entry first (for clipboard / paste elsewhere).
  String get clipboardText {
    if (_entries.isEmpty) return '';
    return _entries.reversed.map((e) => e.clipboardLine).join('\n');
  }

  void add(String message, {String? peerId, String? peerName, int? revision}) {
    _entries.insert(
      0,
      ConnectionLogEntry(
        timestamp: DateTime.now(),
        message: message,
        peerId: peerId,
        peerName: peerName,
        revision: revision,
      ),
    );
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
