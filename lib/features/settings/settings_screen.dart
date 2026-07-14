import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/app_info.dart';
import 'package:netpad/core/shortcut_labels.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/features/entitlements/paywall_sheet.dart';
import 'package:netpad/features/entitlements/standard_gate.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/local_address_service.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:netpad/theme/app_spacing.dart';
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
      SnackBar(
        content: Text(context.l10n.settingsSavedSnack(name, room)),
      ),
    );
  }

  Future<void> _copyAddress(int? port) async {
    if (_lanIp == null || port == null) return;
    await Clipboard.setData(ClipboardData(text: '$_lanIp:$port'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsAddressCopied)),
    );
  }

  Future<void> _openDocsPage(String url, String label) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.commonCouldNotOpenLabel(label)),
        ),
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
              child: Text(context.l10n.commonClose),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              title: Text(l10n.settingsTitle),
              actions: [
                if (_dirty)
                  FilledButton(
                    onPressed: _save,
                    child: Text(l10n.commonSave),
                  )
                else
                  TextButton(
                    onPressed: null,
                    child: Text(l10n.commonSave),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.settingsDeviceSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.settingsDeviceHint(ShortcutLabels.mod),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.settingsDeviceName,
                    hintText: l10n.settingsDeviceNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roomController,
                  decoration: InputDecoration(
                    labelText: l10n.settingsSessionRoom,
                    hintText: l10n.settingsSessionRoomHint,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsListeningPort),
                  subtitle: Text(
                    port == null
                        ? l10n.settingsStartingServer
                        : l10n.settingsAddressShare(address),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: l10n.settingsCopyAddress,
                    onPressed: port == null ? null : () => _copyAddress(port),
                  ),
                ),
                const Divider(height: 32),
                Text(
                  l10n.settingsAppearanceSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.settingsMode, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.settingsThemeSystem),
                      icon: const Icon(Icons.brightness_auto, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.settingsThemeLight),
                      icon: const Icon(Icons.light_mode, size: 18),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.settingsThemeDark),
                      icon: const Icon(Icons.dark_mode, size: 18),
                    ),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (selection) {
                    prefs.setThemeMode(selection.first);
                  },
                ),
                const SizedBox(height: 16),
                Text(l10n.settingsSkin, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final skin in AppSkin.values)
                      _SkinChoiceChip(
                        skin: skin,
                        selected: prefs.skin == skin,
                        locked: !entitlements.isStandard &&
                            skin != AppSkin.defaultBlue,
                        onSelected: () async {
                          final allowed =
                              await StandardGate.skinAllowed(context, skin);
                          if (!allowed || !context.mounted) return;
                          await prefs.setSkin(skin);
                        },
                      ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  l10n.settingsStandardSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    entitlements.isStandard ? l10n.settingsStandardUnlocked : l10n.settingsFree,
                  ),
                  subtitle: Text(
                    entitlements.isStandard
                        ? l10n.settingsStandardUnlockedSubtitle
                        : entitlements.purchasesSupported
                        ? l10n.settingsStandardBuySubtitle
                        : l10n.settingsStandardStoreSubtitle,
                  ),
                  trailing: entitlements.isStandard
                      ? Icon(
                          Icons.verified,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: entitlements.isStandard
                      ? null
                      : () => showPaywallSheet(context),
                ),
                if (!entitlements.isStandard && entitlements.purchasesSupported)
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
                                  ? context.l10n.settingsStandardRestored
                                  : context.l10n.settingsNoPreviousStandard,
                            ),
                          ),
                        );
                      },
                      child: Text(l10n.settingsRestorePurchases),
                    ),
                  ),
                if (kDebugMode) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Unlock Standard (debug)'),
                    subtitle: const Text(
                      'Forces Netpad Standard for local testing. Not available in release builds.',
                    ),
                    value: entitlements.debugForceStandard,
                    onChanged: (value) => entitlements.setDebugForceStandard(value),
                  ),
                ],
                const Divider(height: 32),
                Text(
                  l10n.settingsEditorSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsWordWrap),
                  subtitle: Text(l10n.settingsWordWrapSubtitle),
                  value: prefs.wordWrap,
                  onChanged: prefs.setWordWrap,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.settingsFontSize(prefs.fontSize.round()),
                  ),
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
                Text(
                  l10n.settingsLegalSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.commonEndUserLicenseAgreement),
                  subtitle: Text(
                    entitlements.isStandard
                        ? l10n.settingsEulaSubtitleStandard
                        : l10n.settingsEulaSubtitleFree,
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openDocsPage(AppInfo.eulaUrl, l10n.commonEulaLabel),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.commonPrivacyPolicy),
                  subtitle: Text(l10n.settingsPrivacySubtitle),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openDocsPage(
                    AppInfo.privacyPolicyUrl,
                    l10n.commonPrivacyPolicyLabel,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsDisclaimerTitle),
                  subtitle: Text(l10n.settingsDisclaimerSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalDialog(
                    title: l10n.settingsDisclaimerTitle,
                    paragraphs: [
                      l10n.settingsDisclaimerP1,
                      l10n.settingsDisclaimerP2,
                      l10n.settingsDisclaimerP3,
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsNoLegalAdviceTitle),
                  subtitle: Text(l10n.settingsNoLegalAdviceSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalDialog(
                    title: l10n.settingsNoLegalAdviceTitle,
                    paragraphs: [
                      l10n.settingsNoLegalAdviceP1,
                      l10n.settingsNoLegalAdviceP2,
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
    final l10n = context.l10n;
    final skinName = switch (skin) {
      AppSkin.defaultBlue => l10n.settingsSkinDefault,
      AppSkin.ocean => l10n.settingsSkinOcean,
      AppSkin.forest => l10n.settingsSkinForest,
      AppSkin.sunset => l10n.settingsSkinSunset,
      AppSkin.slate => l10n.settingsSkinSlate,
    };
    final colors = skin.editorColors(Theme.of(context).brightness);
    return Material(
      color: colors.background,
      elevation: selected ? 3 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.lgAll,
        side: BorderSide(
          color: selected
              ? skin.seedColor
              : skin.seedColor.withValues(alpha: 0.35),
          width: selected ? 2.5 : 1.25,
        ),
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: AppRadii.lgAll,
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
                locked ? l10n.settingsSkinStandardLabel(skinName) : skinName,
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
