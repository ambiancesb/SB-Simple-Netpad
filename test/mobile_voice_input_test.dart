import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/features/editor/mobile_voice_input_button.dart';
import 'package:netpad/l10n/app_localizations.dart';
import 'package:netpad/services/speech_input_service.dart';

void main() {
  testWidgets('voice input button reflects listening state', (tester) async {
    final service = SpeechInputService();
    addTearDown(service.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          appBar: AppBar(
            actions: [
              MobileVoiceInputButton(
                service: service,
                onToggle: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    expect(find.byTooltip('Dictate'), findsOneWidget);
  });
}
