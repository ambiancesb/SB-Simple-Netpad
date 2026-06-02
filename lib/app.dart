import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/features/editor/editor_screen.dart';
import 'package:netpad/features/pairing/pairing_listener.dart';
import 'package:netpad/features/peers/peers_panel.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:provider/provider.dart';

class NetpadApp extends StatelessWidget {
  const NetpadApp({
    super.key,
    required this.config,
    required this.discovery,
    required this.document,
    required this.sync,
    required this.pairing,
  });

  final InstanceConfig config;
  final DiscoveryRepository discovery;
  final DocumentRepository document;
  final SyncRepository sync;
  final PairingRepository pairing;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: config),
        ChangeNotifierProvider.value(value: discovery),
        ChangeNotifierProvider.value(value: document),
        ChangeNotifierProvider.value(value: sync),
        ChangeNotifierProvider.value(value: pairing),
      ],
      child: MaterialApp(
        title: 'SB Simple Netpad',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
        ),
        home: const PairingListener(child: _HomeShell()),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SyncRepository>().onConflictMerged = () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remote edit applied (revision conflict resolved)'),
          duration: Duration(seconds: 2),
        ),
      );
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<DocumentRepository>().flushSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<InstanceConfig>();
    final discovery = context.watch<DiscoveryRepository>();
    final connected = discovery.connectedPeers.length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('SB Simple Netpad'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: Icon(
                Icons.circle,
                size: 10,
                color: connected > 0 ? Colors.green : Colors.grey,
              ),
              label: Text('$connected connected'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Device name',
            onPressed: () => _editDeviceName(context, config),
          ),
          IconButton(
            icon: const Icon(Icons.devices),
            tooltip: 'Peers',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: 320,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      discovery.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LAN notepad',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2026 Spencer Beaumier',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Expanded(child: PeersPanel()),
            ],
          ),
        ),
      ),
      body: const EditorScreen(),
    );
  }

  Future<void> _editDeviceName(
    BuildContext context,
    InstanceConfig config,
  ) async {
    final controller = TextEditingController(text: config.displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Device name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Name shown to other devices',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              '© 2026 Spencer Beaumier',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      final discovery = context.read<DiscoveryRepository>();
      final sync = context.read<SyncRepository>();
      await config.setDisplayName(result);
      final name = config.displayName;
      await discovery.updateDisplayName(name);
      sync.updateDisplayName(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device name updated to "$name"')),
        );
      }
    }
  }
}
