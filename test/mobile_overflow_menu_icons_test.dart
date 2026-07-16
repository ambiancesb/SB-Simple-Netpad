import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/features/shell/mobile_overflow_menu.dart';
import 'package:netpad/l10n/app_localizations.dart';
import 'package:netpad/theme/app_skin.dart';

void main() {
  testWidgets('overflow menu item icons stay onSurface in light AppBar theme',
      (tester) async {
    final theme = AppSkin.slate.themeData(Brightness.light);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test'),
            actions: [
              MobileOverflowMenuButton(
                wordWrap: true,
                onSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final settingsIcon = find.descendant(
      of: find.byType(PopupMenuItem<MobileAppMenuAction>),
      matching: find.byIcon(Icons.settings),
    );
    expect(settingsIcon, findsOneWidget);

    final icon = tester.widget<Icon>(settingsIcon);
    expect(icon.color, theme.colorScheme.onSurfaceVariant);
    expect(icon.color, isNot(Colors.white));

    final checkIcon = find.descendant(
      of: find.byType(PopupMenuItem<MobileAppMenuAction>),
      matching: find.byIcon(Icons.check),
    );
    expect(checkIcon, findsOneWidget);
    expect(
      tester.widget<Icon>(checkIcon).color,
      theme.colorScheme.onSurfaceVariant,
    );
  });
}
