import 'package:flutter/material.dart';
import 'package:netpad/features/shell/desktop_menus.dart';

/// Opens the in-app help guide.
Future<void> showHelpScreen(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
  );
}

/// Scrollable guide for using SB Simple Netpad on any platform.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktopMenuPlatform();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'SB Simple Netpad',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'A LAN notepad for plain-text notes. Devices on the same Wi‑Fi '
            'discover each other, pair once, then sync notes in real time.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _section(
            context,
            title: 'Getting started',
            bullets: const [
              'Join the same Wi‑Fi network as the devices you want to sync with.',
              'Open the Peers panel (lock icon or Peers drawer) and wait for '
                  'nearby devices to appear.',
              'Copy your address from This device and share it if discovery is slow.',
              'Use Connect by IP when mDNS discovery does not find peers.',
            ],
          ),
          _section(
            context,
            title: 'Notes',
            bullets: const [
              'Tap the menu icon (☰) or Notes panel to switch between notes.',
              'Create, rename, reorder, and delete notes from the notes list.',
              'Each note syncs independently — toggle sync per note when needed.',
              'Search within a note (Find) or across all notes from the editor.',
              'Version history saves local snapshots you can restore later.',
            ],
          ),
          _section(
            context,
            title: 'Peers & pairing',
            bullets: const [
              'Nearby lists discovered devices in the same room (see Settings).',
              'Tap Connect on a peer — the other device must tap Accept.',
              'Compare the pairing verification code before accepting.',
              'After the first Accept, trusted devices can auto-reconnect.',
              'Trusted devices: toggle auto-sync or Revoke to require Accept again.',
              'Block disconnects a device and refuses future pairing until unblocked.',
              'Connected shows active sessions with address and cursor presence.',
            ],
          ),
          _section(
            context,
            title: 'File & sharing',
            bullets: [
              if (desktop)
                'File menu: Save to File, Open File as New Note, Share Note, '
                    'Version History, Settings, Exit.'
              else
                'Overflow menu (⋮): save to file, open file as new note, share, '
                    'version history, settings, and this help guide.',
              'Save to file exports the active note as .txt or .md.',
              'Open file imports text into a new note that syncs like any other.',
              'Share uses the OS share sheet; Linux falls back to clipboard.',
            ],
          ),
          _section(
            context,
            title: 'Settings',
            bullets: const [
              'Device name and room require Save — other options apply immediately.',
              'Room ID groups peers: only devices in the same room are discovered.',
              'Appearance and editor preferences (theme, skin, wrap, font) save '
                  'as you change them.',
            ],
          ),
          if (desktop)
            _section(
              context,
              title: 'Desktop shortcuts',
              bullets: const [
                'Ctrl/Cmd+S — Save to file',
                'Ctrl/Cmd+O — Open file as new note',
                'Ctrl/Cmd+F — Find in note',
                'Ctrl/Cmd+H — Find and replace',
                'Ctrl/Cmd+N — Toggle notes panel',
                'Ctrl/Cmd+P — Toggle peers panel',
                'Ctrl/Cmd+Q — Exit (Windows/Linux)',
              ],
            ),
          _section(
            context,
            title: 'Troubleshooting',
            bullets: const [
              'No peers? Confirm same Wi‑Fi subnet and room ID; try Connect by IP.',
              'Local network required banner means sync is paused until Wi‑Fi is up.',
              'Allow the app through your firewall on first launch (desktop).',
              'Linux: install dbus and avahi-daemon if discovery never starts.',
              'Android: grant nearby Wi‑Fi permission when prompted.',
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 Spencer Beaumier',
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
