import 'package:flutter/material.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI preferences: theme, skin, editor word wrap, and font size.
class AppPreferences extends ChangeNotifier {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keyTheme = 'theme_mode';
  static const _keySkin = 'app_skin';
  static const _keyWordWrap = 'editor_word_wrap';
  static const _keyFontSize = 'editor_font_size';

  static const double minFontSize = 10;
  static const double maxFontSize = 24;
  static const double defaultFontSize = 14;

  ThemeMode _themeMode = ThemeMode.system;
  AppSkin _skin = AppSkin.defaultBlue;
  bool _wordWrap = false;
  double _fontSize = defaultFontSize;

  ThemeMode get themeMode => _themeMode;
  AppSkin get skin => _skin;
  bool get wordWrap => _wordWrap;
  double get fontSize => _fontSize;

  Future<void> load() async {
    final themeIndex = _prefs.getInt(_keyTheme);
    if (themeIndex != null && themeIndex >= 0 && themeIndex <= 2) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    final skinName = _prefs.getString(_keySkin);
    if (skinName != null) {
      for (final value in AppSkin.values) {
        if (value.name == skinName) {
          _skin = value;
          break;
        }
      }
    }
    _wordWrap = _prefs.getBool(_keyWordWrap) ?? false;
    _fontSize = _prefs.getDouble(_keyFontSize) ?? defaultFontSize;
    _fontSize = _fontSize.clamp(minFontSize, maxFontSize);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _prefs.setInt(_keyTheme, mode.index);
    notifyListeners();
  }

  Future<void> setSkin(AppSkin skin) async {
    if (_skin == skin) return;
    _skin = skin;
    await _prefs.setString(_keySkin, skin.name);
    notifyListeners();
  }

  Future<void> setWordWrap(bool value) async {
    if (_wordWrap == value) return;
    _wordWrap = value;
    await _prefs.setBool(_keyWordWrap, value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    final next = value.clamp(minFontSize, maxFontSize);
    if (_fontSize == next) return;
    _fontSize = next;
    await _prefs.setDouble(_keyFontSize, next);
    notifyListeners();
  }
}
