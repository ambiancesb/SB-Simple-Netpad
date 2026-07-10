import 'package:flutter/material.dart';
import 'package:netpad/core/app_info.dart';
import 'package:netpad/features/help/help_screen.dart';

/// Opens the About screen.
Future<void> showAboutScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
  );
}

/// Application name, version, and summary.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 72,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppInfo.name,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppInfo.versionLabel}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppInfo.tagline,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(AppInfo.description, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            AppInfo.platforms,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(AppInfo.status, style: textTheme.bodySmall),
          const Divider(height: 32),
          Text(
            'License',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'All rights reserved before version 1.0. No use, copying, or '
            'redistribution without prior written permission from the copyright '
            'holder.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
              );
            },
            icon: const Icon(Icons.help_outline),
            label: const Text('How to use SB Simple Netpad'),
          ),
          const SizedBox(height: 24),
          Text(
            AppInfo.copyright,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
