import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/app_info.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/features/entitlements/paywall_sheet.dart';
import 'package:netpad/features/entitlements/pro_gate.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/local_address_service.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen settings: device identity, networking, theme, and editor prefs.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _roomController;
  String? _lanIp;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final config = context.read<InstanceConfig>();
    _nameController = TextEditingController(text: config.displayName);
    _roomController = TextEditingController(text: config.roomId);
    _nameController.addListener(_markDirty);
    _roomController.addListener(_markDirty);
    _loadLanIp();
  }

  Future<void> _loadLanIp() async {
    final ip = await LocalAddressService.getLanIpv4();
    if (mounted) setState(() => _lanIp = ip);
  }

  void _markDirty() => setState(() => _dirty = true);

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final config = context.read<InstanceConfig>();
    final discovery = context.read<DiscoveryRepository>();
    final sync = context.read<SyncRepository>();
    final previousRoom = config.roomId;

    await config.setDisplayName(_nameController.text);
    await config.setRoomId(_roomController.text);
    final name = config.displayName;
    final room = config.roomId;

    await discovery.updateDisplayName(name);
    sync.updateDisplayName(name);
    if (room != previousRoom) {
      await discovery.updateRoom(room);
    }

    if (!mounted) return;
    _nameController.removeListener(_markDirty);
    _roomController.removeListener(_markDirty);
    _nameController.text = name;
    _roomController.text = room;
    _nameController.addListener(_markDirty);
    _roomController.addListener(_markDirty);
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved · "$name" · room "$room"')),
    );
  }

  Future<void> _copyAddress(int? port) async {
    if (_lanIp == null || port == null) return;
    await Clipboard.setData(ClipboardData(text: '$_lanIp:$port'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard')),
    );
  }

  Future<void> _openDocsPage(String url, String label) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $label')),
      );
    }
  }

  Future<void> _showLegalDialog({
    required String title,
    required List<String> paragraphs,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < paragraphs.length; i++) ...[
                  Text(paragraphs[i], style: textTheme.bodyMedium),
                  if (i < paragraphs.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();
    final entitlements = context.watch<EntitlementService>();
    final discovery = context.watch<DiscoveryRepository>();
    final port = discovery.serverPort;
    final address = _lanIp != null && port != null ? '$_lanIp:$port' : '…';

    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const _SaveSettingsIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            const _SaveSettingsIntent(),
      },
      child: Actions(
        actions: {
          _SaveSettingsIntent: CallbackAction<_SaveSettingsIntent>(
            onInvoke: (_) {
              if (_dirty) unawaited(_save());
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              actions: [
                if (_dirty)
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  )
                else
                  TextButton(
                    onPressed: null,
                    child: const Text('Save'),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Device', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Device name and room require Save (Ctrl+S). '
                  'Appearance and editor preferences save immediately.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Device name',
                    hintText: 'Name shown to other devices',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Session / room',
                    hintText: 'Only peers in the same room are discovered',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Listening port'),
                  subtitle: Text(
                    port == null
                        ? 'Starting server…'
                        : '$address (share this with manual connect)',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy address',
                    onPressed: port == null ? null : () => _copyAddress(port),
                  ),
                ),
                const Divider(height: 32),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Mode', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode, size: 18),
                    ),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (selection) {
                    prefs.setThemeMode(selection.first);
                  },
                ),
                const SizedBox(height: 16),
                Text('Skin', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final skin in AppSkin.values)
                      _SkinChoiceChip(
                        skin: skin,
                        selected: prefs.skin == skin,
                        locked: !entitlements.isPro &&
                            skin != AppSkin.defaultBlue,
                        onSelected: () async {
                          final allowed =
                              await ProGate.skinAllowed(context, skin);
                          if (!allowed || !context.mounted) return;
                          await prefs.setSkin(skin);
                        },
                      ),
                  ],
                ),
                const Divider(height: 32),
                Text('Netpad Pro', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entitlements.isPro ? 'Pro unlocked' : 'Free'),
                  subtitle: Text(
                    entitlements.isPro
                        ? 'Unlimited notes and peers, skins, history, auto-sync, and voice'
                        : entitlements.purchasesSupported
                        ? 'One-time unlock via your app store'
                        : 'Purchases unavailable on this platform',
                  ),
                  trailing: entitlements.isPro
                      ? Icon(
                          Icons.verified,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : entitlements.purchasesSupported
                      ? const Icon(Icons.chevron_right)
                      : null,
                  onTap: entitlements.isPro || !entitlements.purchasesSupported
                      ? null
                      : () => showPaywallSheet(context),
                ),
                if (!entitlements.isPro && entitlements.purchasesSupported)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () async {
                        final ok = await entitlements.restorePurchases();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Pro restored'
                                  : 'No previous Pro purchase found',
                            ),
                          ),
                        );
                      },
                      child: const Text('Restore purchases'),
                    ),
                  ),
                const Divider(height: 32),
                Text('Editor', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Word wrap'),
                  subtitle: const Text(
                    'Wrap long lines instead of horizontal scroll',
                  ),
                  value: prefs.wordWrap,
                  onChanged: prefs.setWordWrap,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Font size (${prefs.fontSize.round()} pt)'),
                  subtitle: Slider(
                    min: AppPreferences.minFontSize,
                    max: AppPreferences.maxFontSize,
                    divisions:
                        (AppPreferences.maxFontSize - AppPreferences.minFontSize)
                            .round(),
                    value: prefs.fontSize,
                    label: '${prefs.fontSize.round()}',
                    onChanged: (value) => prefs.setFontSize(value),
                  ),
                ),
                const Divider(height: 32),
                Text('Legal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End User License Agreement'),
                  subtitle: Text(
                    entitlements.isPro
                        ? 'Pro · Opens EULA on GitHub Pages'
                        : 'Free · Opens EULA on GitHub Pages',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openDocsPage(AppInfo.eulaUrl, 'EULA'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Opens privacy page on GitHub Pages'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () =>
                      _openDocsPage(AppInfo.privacyPolicyUrl, 'privacy policy'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disclaimer and liability'),
                  subtitle: const Text('Use at your own risk'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalDialog(
                    title: 'Disclaimer and liability',
                    paragraphs: const [
                      'This software is provided "as is", without warranties of any kind, express or implied, including merchantability, fitness for a particular purpose, and non-infringement.',
                      'You are solely responsible for how you use this app and for compliance with all applicable laws, regulations, policies, and agreements.',
                      'The copyright holder is not liable for any claims, damages, losses, data loss, business interruption, or other liability arising from use or misuse of this software.',
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('No legal advice'),
                  subtitle: const Text('Informational software only'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalDialog(
                    title: 'No legal advice',
                    paragraphs: const [
                      'This app and its documentation do not provide legal, regulatory, or professional advice.',
                      'If you need legal guidance for your use case, consult a qualified professional.',
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppInfo.copyright,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveSettingsIntent extends Intent {
  const _SaveSettingsIntent();
}

class _SkinChoiceChip extends StatelessWidget {
  const _SkinChoiceChip({
    required this.skin,
    required this.selected,
    required this.onSelected,
    this.locked = false,
  });

  final AppSkin skin;
  final bool selected;
  final bool locked;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = skin.editorColors(Theme.of(context).brightness);
    return Material(
      color: colors.background,
      elevation: selected ? 3 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? skin.seedColor
              : skin.seedColor.withValues(alpha: 0.35),
          width: selected ? 2.5 : 1.25,
        ),
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: skin.seedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.foreground.withValues(alpha: 0.25),
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : locked
                    ? const Icon(Icons.lock, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                locked ? '${skin.label} · Pro' : skin.label,
                style: TextStyle(
                  color: colors.foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
