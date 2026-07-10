import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/features/shell/mobile_overflow_menu.dart';

void main() {
  testWidgets('mobile overflow menu opens and shows Settings', (tester) async {
    MobileAppMenuAction? selected;

    await tester.pumpWidget(
      MaterialApp(
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
    expect(find.text('Word wrap'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(selected, MobileAppMenuAction.settings);
  });
}
