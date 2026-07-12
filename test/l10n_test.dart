import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/l10n/app_localizations.dart';

void main() {
  test('supported locales include major languages', () {
    final codes = AppLocalizations.supportedLocales
        .map((l) => l.toLanguageTag())
        .toSet();
    expect(codes.contains('en'), isTrue);
    expect(codes.contains('es'), isTrue);
    expect(codes.contains('fr'), isTrue);
    expect(codes.contains('de'), isTrue);
    expect(codes.contains('pt'), isTrue);
    expect(codes.contains('pt-BR'), isTrue);
    expect(codes.contains('ja'), isTrue);
    expect(codes.contains('zh'), isTrue);
    expect(codes.contains('ko'), isTrue);
    expect(codes.contains('it'), isTrue);
    expect(codes.contains('nl'), isTrue);
  });

  test('lookup returns translated Settings label', () async {
    final es = await AppLocalizations.delegate.load(const Locale('es'));
    expect(es.settingsTitle, isNot(equals('Settings')));
    expect(es.commonAppName, 'SB Simple Netpad');

    final ja = await AppLocalizations.delegate.load(const Locale('ja'));
    expect(ja.commonConnect, isNot(equals('Connect')));
    expect(ja.commonProName, 'Netpad Pro');
  });
}
