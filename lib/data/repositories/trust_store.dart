import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:netpad/core/models/trusted_peer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-peer security state: pinned certificate fingerprints (TOFU),
/// a blocklist of peers that may not pair, and trusted-peer auto-sync tokens.
class TrustStore extends ChangeNotifier {
  TrustStore(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  static const _keyPins = 'trust_pins';
  static const _keyBlocked = 'trust_blocked';
  static const _keyTrusted = 'trust_trusted_peers';

  final Map<String, String> _pins = {};
  final Map<String, String> _blocked = {};
  final Map<String, TrustedPeer> _trusted = {};

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
    final trusted = _prefs.getString(_keyTrusted);
    if (trusted != null && trusted.isNotEmpty) {
      final decoded = jsonDecode(trusted) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _trusted[entry.key] =
            TrustedPeer.fromJson(entry.value as Map<String, dynamic>);
      }
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
    await removeTrustedPeer(peerId);
    notifyListeners();
  }

  Future<void> unblock(String peerId) async {
    if (_blocked.remove(peerId) != null) {
      await _prefs.setString(_keyBlocked, jsonEncode(_blocked));
      notifyListeners();
    }
  }

  // --- Trusted peers (auto-sync tokens) ---

  /// Trusted peers as `peerId -> record` (excludes blocked peers).
  Map<String, TrustedPeer> get trustedPeers {
    return Map.unmodifiable(
      Map.fromEntries(
        _trusted.entries.where((e) => !_blocked.containsKey(e.key)),
      ),
    );
  }

  TrustedPeer? trustedPeer(String peerId) => _trusted[peerId];

  /// Whether this peer may auto-reconnect: pinned, not blocked, token present.
  bool canAutoSync(String peerId) {
    if (isBlocked(peerId) || !hasPin(peerId)) return false;
    final peer = _trusted[peerId];
    return peer != null &&
        peer.autoSyncToken.isNotEmpty &&
        peer.autoSyncEnabled;
  }

  String? autoSyncToken(String peerId) => _trusted[peerId]?.autoSyncToken;

  Future<void> setTrustedPeer({
    required String peerId,
    required String displayName,
    required String autoSyncToken,
    DateTime? pairedAt,
    bool autoSyncEnabled = true,
  }) async {
    _trusted[peerId] = TrustedPeer(
      displayName: displayName,
      autoSyncToken: autoSyncToken,
      pairedAt: pairedAt ?? DateTime.now().toUtc(),
      autoSyncEnabled: autoSyncEnabled,
    );
    await _persistTrusted();
    notifyListeners();
  }

  /// Forgets the auto-sync token; the cert pin is kept.
  Future<void> revokeAutoSync(String peerId) async {
    if (_trusted.remove(peerId) == null) return;
    await _persistTrusted();
    notifyListeners();
  }

  Future<void> setAutoSyncEnabled(String peerId, bool enabled) async {
    final existing = _trusted[peerId];
    if (existing == null || existing.autoSyncEnabled == enabled) return;
    _trusted[peerId] = existing.copyWith(autoSyncEnabled: enabled);
    await _persistTrusted();
    notifyListeners();
  }

  Future<void> removeTrustedPeer(String peerId) async {
    if (_trusted.remove(peerId) == null) return;
    await _persistTrusted();
    notifyListeners();
  }

  Future<void> _persistTrusted() async {
    final encoded = _trusted.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_keyTrusted, jsonEncode(encoded));
  }
}
