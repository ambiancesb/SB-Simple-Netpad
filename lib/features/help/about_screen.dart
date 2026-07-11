import 'package:flutter/material.dart';
import 'package:netpad/core/app_info.dart';
import 'package:netpad/features/help/help_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the About screen.
Future<void> showAboutScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
  );
}

Future<void> _openPrivacyPolicy(BuildContext context) async {
  final uri = Uri.parse(AppInfo.privacyPolicyUrl);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open privacy policy')),
    );
  }
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
            'All rights reserved. Core editing and LAN sync are free. Netpad Pro '
            'is a one-time unlock via the App Store, Google Play, or Microsoft '
            'Store.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _openPrivacyPolicy(context),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Privacy Policy'),
          ),
          const SizedBox(height: 12),
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
