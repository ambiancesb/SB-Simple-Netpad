import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Narrow read/write API used by [TlsSecretStore] (Keychain or test doubles).
abstract class SecureStringBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class _FlutterSecureBackend implements SecureStringBackend {
  _FlutterSecureBackend(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// In-memory secure backend for unit tests.
class MemorySecureBackend implements SecureStringBackend {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

/// Persists opaque TLS secrets. On Apple platforms uses the Keychain
/// ([FlutterSecureStorage]); elsewhere uses [SharedPreferences].
///
/// If Keychain access fails (common with ad-hoc macOS signing / missing
/// entitlements), falls back to prefs so the app can still launch.
class TlsSecretStore {
  TlsSecretStore._({
    required SharedPreferences prefs,
    SecureStringBackend? secure,
  }) : _prefs = prefs,
       _secure = secure;

  /// Production store for the current platform.
  factory TlsSecretStore.platform(SharedPreferences prefs) {
    final apple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    if (apple) {
      return TlsSecretStore._(
        prefs: prefs,
        secure: _FlutterSecureBackend(
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
            // Data-protection keychain needs a team entitlements prefix; ad-hoc
            // macOS debug signing often returns errSecMissingEntitlement (-34018).
            mOptions: MacOsOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
              usesDataProtectionKeychain: false,
            ),
          ),
        ),
      );
    }
    return TlsSecretStore._(prefs: prefs);
  }

  /// Prefs-only store for unit tests on non-Keychain paths.
  factory TlsSecretStore.prefsOnly(SharedPreferences prefs) {
    return TlsSecretStore._(prefs: prefs);
  }

  /// Prefs + secure backend (Keychain migration tests).
  factory TlsSecretStore.withSecure({
    required SharedPreferences prefs,
    required SecureStringBackend secure,
  }) {
    return TlsSecretStore._(prefs: prefs, secure: secure);
  }

  final SharedPreferences _prefs;
  SecureStringBackend? _secure;

  bool get usesKeychain => _secure != null;

  Future<String?> read(String key) async {
    final secure = _secure;
    if (secure != null) {
      try {
        final value = await secure.read(key);
        if (value != null && value.isNotEmpty) return value;
      } on PlatformException catch (e) {
        _disableSecure('read', e);
      } catch (e) {
        _disableSecure('read', e);
      }
    }
    return _prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    final secure = _secure;
    if (secure != null) {
      try {
        await secure.write(key, value);
        await _prefs.remove(key);
        return;
      } on PlatformException catch (e) {
        _disableSecure('write', e);
      } catch (e) {
        _disableSecure('write', e);
      }
    }
    await _prefs.setString(key, value);
  }

  /// Copies prefs → secure store once, then removes prefs values.
  Future<void> migrateFromPrefsIfNeeded(List<String> keys) async {
    final secure = _secure;
    if (secure == null) return;
    for (final key in keys) {
      try {
        final existing = await secure.read(key);
        if (existing != null && existing.isNotEmpty) {
          await _prefs.remove(key);
          continue;
        }
        final legacy = _prefs.getString(key);
        if (legacy == null || legacy.isEmpty) continue;
        await secure.write(key, legacy);
        await _prefs.remove(key);
      } on PlatformException catch (e) {
        _disableSecure('migrate', e);
        return;
      } catch (e) {
        _disableSecure('migrate', e);
        return;
      }
    }
  }

  void _disableSecure(String op, Object error) {
    if (kDebugMode) {
      debugPrint(
        'TlsSecretStore: Keychain $op failed ($error); using SharedPreferences',
      );
    }
    _secure = null;
  }
}
