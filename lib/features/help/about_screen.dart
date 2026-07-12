import 'package:flutter/material.dart';
import 'package:netpad/core/app_info.dart';
import 'package:netpad/features/help/help_screen.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
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
      SnackBar(content: Text(context.l10n.aboutCouldNotOpenPrivacy)),
    );
  }
}

Future<void> _openEula(BuildContext context) async {
  final uri = Uri.parse(AppInfo.eulaUrl);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.aboutCouldNotOpenEula)),
    );
  }
}

/// Application name, version, and summary.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
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
                  l10n.commonVersionLabel(AppInfo.versionLabel),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aboutTagline,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(l10n.aboutDescription, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            l10n.aboutPlatforms,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Text(l10n.aboutStatus, style: textTheme.bodySmall),
          const Divider(height: 32),
          Text(
            l10n.aboutEulaHeading,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aboutEulaBody(
              EntitlementConstants.freeSyncedNoteLimit,
              EntitlementConstants.freePeerLimit,
            ),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _openEula(context),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l10n.aboutViewEula),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openPrivacyPolicy(context),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l10n.aboutPrivacyPolicy),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
              );
            },
            icon: const Icon(Icons.help_outline),
            label: Text(l10n.aboutHowToUse),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aboutCopyright,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
