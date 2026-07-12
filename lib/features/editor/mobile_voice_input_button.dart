import 'package:flutter/material.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/speech_input_service.dart';

/// Microphone toggle for dictating into the active note (Android/iOS only).
class MobileVoiceInputButton extends StatelessWidget {
  const MobileVoiceInputButton({
    super.key,
    required this.service,
    required this.onToggle,
  });

  final SpeechInputService service;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final listening = service.isListening;
        final colorScheme = Theme.of(context).colorScheme;
        return IconButton(
          icon: Icon(
            listening ? Icons.mic : Icons.mic_none,
            color: listening ? colorScheme.error : null,
          ),
          tooltip: listening
              ? context.l10n.editorStopDictation
              : context.l10n.editorDictate,
          onPressed: onToggle,
        );
      },
    );
  }
}
