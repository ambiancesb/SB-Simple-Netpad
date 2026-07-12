import 'package:flutter/material.dart';
import 'package:netpad/core/app_info.dart';
import 'package:netpad/features/help/about_screen.dart';
import 'package:netpad/features/shell/desktop_menus.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the in-app help guide.
Future<void> showHelpScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
  );
}

Future<void> _openDocsPage(
  BuildContext context,
  String url,
  String label,
) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.commonCouldNotOpenLabel(label))),
    );
  }
}

/// Scrollable guide for using SB Simple Netpad on any platform.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final desktop = isDesktopMenuPlatform();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppInfo.name,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpIntro,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.helpAboutTile),
            subtitle: Text(l10n.commonVersionLabel(AppInfo.versionLabel)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showAboutScreen(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.gavel_outlined),
            title: Text(l10n.commonEndUserLicenseAgreement),
            subtitle: Text(l10n.helpEulaSubtitle),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openDocsPage(context, AppInfo.eulaUrl, l10n.commonEulaLabel),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.commonPrivacyPolicy),
            subtitle: Text(l10n.helpPrivacySubtitle),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openDocsPage(
              context,
              AppInfo.privacyPolicyUrl,
              l10n.commonPrivacyPolicyLabel,
            ),
          ),
          const Divider(height: 24),
          _section(
            context,
            title: l10n.helpGettingStartedTitle,
            bullets: [
              l10n.helpGettingStarted1,
              l10n.helpGettingStarted2,
              l10n.helpGettingStarted3,
              l10n.helpGettingStarted4,
            ],
          ),
          _section(
            context,
            title: l10n.helpNotesTitle,
            bullets: [
              l10n.helpNotes1,
              l10n.helpNotes2,
              l10n.helpNotes3,
              l10n.helpNotes4,
              l10n.helpNotes5,
            ],
          ),
          _section(
            context,
            title: l10n.helpPeersTitle,
            bullets: [
              l10n.helpPeers1,
              l10n.helpPeers2,
              l10n.helpPeers3,
              l10n.helpPeers4,
              l10n.helpPeers5,
              l10n.helpPeers6,
              l10n.helpPeers7,
            ],
          ),
          _section(
            context,
            title: l10n.helpFileSharingTitle,
            bullets: [
              if (desktop) l10n.helpFileSharing1Desktop else l10n.helpFileSharing1Mobile,
              l10n.helpFileSharing2,
              l10n.helpFileSharing3,
              l10n.helpFileSharing4,
            ],
          ),
          _section(
            context,
            title: l10n.helpSettingsTitle,
            bullets: [
              l10n.helpSettings1,
              l10n.helpSettings2,
              l10n.helpSettings3,
            ],
          ),
          if (desktop)
            _section(
              context,
              title: l10n.helpDesktopShortcutsTitle,
              bullets: [
                l10n.helpDesktopShortcuts1,
                l10n.helpDesktopShortcuts2,
                l10n.helpDesktopShortcuts3,
                l10n.helpDesktopShortcuts4,
                l10n.helpDesktopShortcuts5,
                l10n.helpDesktopShortcuts6,
                l10n.helpDesktopShortcuts7,
              ],
            ),
          _section(
            context,
            title: l10n.helpTroubleshootingTitle,
            bullets: [
              l10n.helpTroubleshooting1,
              l10n.helpTroubleshooting2,
              l10n.helpTroubleshooting3,
              l10n.helpTroubleshooting4,
              l10n.helpTroubleshooting5,
            ],
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

  Widget _section(
    BuildContext context, {
    required String title,
    required List<String> bullets,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final line in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: textTheme.bodyMedium),
                  Expanded(child: Text(line, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
