import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-peer security state: pinned certificate fingerprints (TOFU) and
/// a blocklist of peers that may not pair.
class TrustStore extends ChangeNotifier {
  TrustStore(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _keyPins = 'trust_pins';
  static const _keyBlocked = 'trust_blocked';

  final Map<String, String> _pins = {};
  final Map<String, String> _blocked = {};

  void _load() {
    final pins = _prefs.getString(_keyPins);
    if (pins != null && pins.isNotEmpty) {
      final decoded = jsonDecode(pins) as Map<String, dynamic>;
      _pins.addAll(decoded.map((k, v) => MapEntry(k, v as String)));
    }
    final blocked = _prefs.getString(_keyBlocked);
    if (blocked != null && blocked.isNotEmpty) {
      final decoded = jsonDecode(blocked) as Map<String, dynamic>;
      _blocked.addAll(decoded.map((k, v) => MapEntry(k, v as String)));
    }
  }

  // --- Certificate pins (TOFU) ---

  String? pinnedFingerprint(String peerId) => _pins[peerId];

  bool hasPin(String peerId) => _pins.containsKey(peerId);

  Future<void> pin(String peerId, String fingerprint) async {
    if (_pins[peerId] == fingerprint) return;
    _pins[peerId] = fingerprint;
    await _prefs.setString(_keyPins, jsonEncode(_pins));
    notifyListeners();
  }

  Future<void> unpin(String peerId) async {
    if (_pins.remove(peerId) != null) {
      await _prefs.setString(_keyPins, jsonEncode(_pins));
      notifyListeners();
    }
  }

  // --- Blocklist ---

  /// Blocked peers as `peerId -> displayName`.
  Map<String, String> get blocked => Map.unmodifiable(_blocked);

  bool isBlocked(String peerId) => _blocked.containsKey(peerId);

  Future<void> block(String peerId, String displayName) async {
    _blocked[peerId] = displayName;
    await _prefs.setString(_keyBlocked, jsonEncode(_blocked));
    notifyListeners();
  }

  Future<void> unblock(String peerId) async {
    if (_blocked.remove(peerId) != null) {
      await _prefs.setString(_keyBlocked, jsonEncode(_blocked));
      notifyListeners();
    }
  }
}
