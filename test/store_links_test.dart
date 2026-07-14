import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/store_links.dart';

void main() {
  test('Play Store URL uses package id', () {
    expect(
      StoreLinks.playStore.toString(),
      'https://play.google.com/store/apps/details?id=com.spencerbeaumier.sbnetpad',
    );
  });

  test('App Store falls back to search when id is unset', () {
    expect(
      StoreLinks.appStore.toString(),
      contains('apps.apple.com/search'),
    );
    expect(StoreLinks.appStore.toString(), contains('SB'));
  });

  test('Microsoft Store uses search query', () {
    expect(
      StoreLinks.microsoftStore.toString(),
      contains('apps.microsoft.com/search'),
    );
  });
}
