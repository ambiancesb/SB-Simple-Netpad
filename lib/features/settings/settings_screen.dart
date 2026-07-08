import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/local_address_service.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();
    final discovery = context.watch<DiscoveryRepository>();
    final port = discovery.serverPort;
    final address = _lanIp != null && port != null ? '$_lanIp:$port' : '…';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _dirty ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Device', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
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
                  onSelected: () => prefs.setSkin(skin),
                ),
            ],
          ),
          const Divider(height: 32),
          Text('Editor', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Word wrap'),
            subtitle: const Text('Wrap long lines instead of horizontal scroll'),
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
          const SizedBox(height: 24),
          Text(
            '© 2026 Spencer Beaumier',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SkinChoiceChip extends StatelessWidget {
  const _SkinChoiceChip({
    required this.skin,
    required this.selected,
    required this.onSelected,
  });

  final AppSkin skin;
  final bool selected;
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
          color: selected ? skin.seedColor : skin.seedColor.withValues(alpha: 0.35),
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
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                skin.label,
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
