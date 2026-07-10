/// Application metadata shown in About and help screens.
abstract final class AppInfo {
  static const name = 'SB Simple Netpad';
  static const version = '1.2.0';
  static const buildNumber = '3';

  static String get versionLabel => '$version ($buildNumber)';

  static const tagline =
      'LAN notepad with peer discovery and shared editing.';

  static const description =
      'Write plain-text notes on your phone or computer and keep them in sync '
      'with other devices on the same Wi‑Fi. Peers discover each other on the '
      'local network, pair once with mutual approval, then share multiple named '
      'notes with encrypted peer sessions.';

  static const platforms = 'Android · iOS · Windows · macOS · Linux';

  static const status = 'Beta — suitable for daily LAN use.';

  static const copyright = '© 2026 Spencer Beaumier';
}
