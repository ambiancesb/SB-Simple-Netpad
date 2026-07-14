import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/features/shell/mobile_overflow_menu.dart';
import 'package:netpad/l10n/app_localizations.dart';

void main() {
  Future<void> pumpMenu(
    WidgetTester tester, {
    required bool showFileImportExport,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          appBar: AppBar(
            actions: [
              MobileOverflowMenuButton(
                wordWrap: false,
                showFileImportExport: showFileImportExport,
                onSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  testWidgets('mobile overflow menu opens and shows Settings', (tester) async {
    MobileAppMenuAction? selected;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          appBar: AppBar(
            actions: [
              MobileOverflowMenuButton(
                wordWrap: false,
                onSelected: (action) => selected = action,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('About SB Simple Netpad'), findsOneWidget);
    expect(find.text('Word wrap'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(selected, MobileAppMenuAction.settings);
  });

  testWidgets('Android-style menu shows Save and Open', (tester) async {
    await pumpMenu(tester, showFileImportExport: true);

    expect(find.text('Save to file…'), findsOneWidget);
    expect(find.text('Open file as new note…'), findsOneWidget);
    expect(find.text('Share note'), findsOneWidget);
  });

  testWidgets('iOS-style menu hides Save and Open, keeps Share', (tester) async {
    await pumpMenu(tester, showFileImportExport: false);

    expect(find.text('Save to file…'), findsNothing);
    expect(find.text('Open file as new note…'), findsNothing);
    expect(find.text('Share note'), findsOneWidget);
  });
}
