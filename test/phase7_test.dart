import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/find_replace.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FindReplace', () {
    test('matchOffsets finds non-overlapping case-insensitive matches', () {
      expect(FindReplace.matchOffsets('Hello hello HELLO', 'll'), [2, 8, 14]);
      expect(FindReplace.matchOffsets('abc', ''), isEmpty);
      expect(FindReplace.matchOffsets('abc', 'z'), isEmpty);
    });

    test('replaceAll replaces every match preserving case in source', () {
      expect(
        FindReplace.replaceAll('foo Foo FOO', 'foo', 'bar'),
        'bar bar bar',
      );
      expect(FindReplace.replaceAll('abc', 'z', 'x'), 'abc');
    });

    test('replaceOne updates text and shifts later match offsets', () {
      final result = FindReplace.replaceOne(
        text: 'cat cat cat',
        needle: 'cat',
        replacement: 'dog',
        matches: const [0, 4, 8],
        matchIndex: 1,
      );
      expect(result.text, 'cat dog cat');
      expect(
        FindReplace.matchOffsets(result.text, 'cat'),
        [0, 8],
      );
    });
  });

  group('AppPreferences', () {
    test('load restores persisted theme, skin, wrap, and font size', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': ThemeMode.dark.index,
        'app_skin': AppSkin.ocean.name,
        'editor_word_wrap': true,
        'editor_font_size': 18.0,
      });
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      await prefs.load();
      expect(prefs.themeMode, ThemeMode.dark);
      expect(prefs.skin, AppSkin.ocean);
      expect(prefs.wordWrap, isTrue);
      expect(prefs.fontSize, 18.0);
    });

    test('setters persist values', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferences.getInstance();
      final prefs = AppPreferences(store);
      await prefs.load();

      await prefs.setThemeMode(ThemeMode.light);
      await prefs.setSkin(AppSkin.forest);
      await prefs.setWordWrap(true);
      await prefs.setFontSize(20);

      expect(store.getInt('theme_mode'), ThemeMode.light.index);
      expect(store.getString('app_skin'), AppSkin.forest.name);
      expect(store.getBool('editor_word_wrap'), isTrue);
      expect(store.getDouble('editor_font_size'), 20.0);
    });

    test('font size is clamped to allowed range', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = AppPreferences(await SharedPreferences.getInstance());
      await prefs.load();

      await prefs.setFontSize(4);
      expect(prefs.fontSize, AppPreferences.minFontSize);

      await prefs.setFontSize(40);
      expect(prefs.fontSize, AppPreferences.maxFontSize);
    });
  });

  group('AppSkin', () {
    test('each skin has a distinctly tinted editor background', () {
      final lightBgs = {
        for (final skin in AppSkin.values)
          skin: skin.editorColors(Brightness.light).background,
      };
      final darkBgs = {
        for (final skin in AppSkin.values)
          skin: skin.editorColors(Brightness.dark).background,
      };

      expect(lightBgs.values.toSet().length, AppSkin.values.length);
      expect(darkBgs.values.toSet().length, AppSkin.values.length);

      for (final skin in AppSkin.values) {
        final light = skin.editorColors(Brightness.light);
        final dark = skin.editorColors(Brightness.dark);
        expect(
          light.background.computeLuminance() >
              dark.background.computeLuminance(),
          isTrue,
          reason: '${skin.name} light editor should be brighter than dark',
        );
      }

      // Ocean/Forest/Sunset should not look like plain Default grey-blue.
      expect(
        AppSkin.ocean.editorColors(Brightness.light).background,
        isNot(AppSkin.defaultBlue.editorColors(Brightness.light).background),
      );
      expect(
        AppSkin.sunset.themeData(Brightness.light).scaffoldBackgroundColor,
        isNot(
          AppSkin.defaultBlue.themeData(Brightness.light).scaffoldBackgroundColor,
        ),
      );
    });
  });
}
