import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/features/editor/editor_screen.dart';
import 'package:netpad/features/pairing/pairing_listener.dart';
import 'package:netpad/features/peers/peers_panel.dart';
<<<<<<< Updated upstream
import 'package:netpad/services/file_transfer_service.dart';
=======
import 'package:netpad/services/file_service.dart';
>>>>>>> Stashed changes
import 'package:netpad/services/instance_config.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

enum _FileAction { save, open, share }

class NetpadApp extends StatelessWidget {
  const NetpadApp({
    super.key,
    required this.config,
    required this.connectionLog,
    required this.discovery,
    required this.document,
    required this.sync,
    required this.pairing,
  });

  final InstanceConfig config;
  final ConnectionLogRepository connectionLog;
  final DiscoveryRepository discovery;
  final DocumentRepository document;
  final SyncRepository sync;
  final PairingRepository pairing;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: config),
        ChangeNotifierProvider.value(value: connectionLog),
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
<<<<<<< Updated upstream
  final FileTransferService _fileService = FileTransferService();
=======
  final FileService _fileService = const FileService();
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
          PopupMenuButton<String>(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'File',
            onSelected: (value) => _onFileAction(context, value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'open',
                child: Text('Open from file…'),
              ),
              if (_fileService.canSaveToDisk)
                const PopupMenuItem(
                  value: 'save',
                  child: Text('Save to file…'),
                ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Share note…'),
=======
          PopupMenuButton<_FileAction>(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'File',
            onSelected: (action) => _onFileAction(context, action),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _FileAction.save,
                child: ListTile(
                  leading: Icon(Icons.save_alt),
                  title: Text('Save to file…'),
                ),
              ),
              PopupMenuItem(
                value: _FileAction.open,
                child: ListTile(
                  leading: Icon(Icons.folder_open),
                  title: Text('Open file…'),
                ),
              ),
              PopupMenuItem(
                value: _FileAction.share,
                child: ListTile(
                  leading: Icon(Icons.ios_share),
                  title: Text('Share note'),
                ),
>>>>>>> Stashed changes
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => _editSettings(context, config),
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
                      'LAN notepad · room "${discovery.roomId}"',
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

  Future<void> _editSettings(
    BuildContext context,
    InstanceConfig config,
  ) async {
    final nameController = TextEditingController(text: config.displayName);
    final roomController = TextEditingController(text: config.roomId);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Device name',
                hintText: 'Name shown to other devices',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Session / room',
                hintText: 'Only peers in the same room are discovered',
              ),
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
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;

    final discovery = context.read<DiscoveryRepository>();
    final sync = context.read<SyncRepository>();
    final previousRoom = config.roomId;

    await config.setDisplayName(nameController.text);
    await config.setRoomId(roomController.text);
    final name = config.displayName;
    final room = config.roomId;

    await discovery.updateDisplayName(name);
    sync.updateDisplayName(name);
    if (room != previousRoom) {
      await discovery.updateRoom(room);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings saved · "$name" · room "$room"')),
      );
    }
  }

  Future<void> _onFileAction(BuildContext context, _FileAction action) async {
    switch (action) {
      case _FileAction.save:
        await _saveNote(context);
      case _FileAction.open:
        await _openNote(context);
      case _FileAction.share:
        await _shareNote(context);
    }
  }

  Future<void> _saveNote(BuildContext context) async {
    final document = context.read<DocumentRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await _fileService.saveText(document.text);
      if (path == null) return;
      messenger.showSnackBar(SnackBar(content: Text('Saved to $path')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  Future<void> _openNote(BuildContext context) async {
    final document = context.read<DocumentRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final loaded = await _fileService.openText();
      if (loaded == null || !context.mounted) return;

      final hasContent = document.text.trim().isNotEmpty;
      if (hasContent) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Replace current note?'),
            content: Text(
              'Opening "${loaded.name}" will replace the current note for you '
              'and every connected peer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Replace'),
              ),
            ],
          ),
        );
        if (replace != true) return;
      }

      document.replaceLocal(loaded.text);
      messenger.showSnackBar(SnackBar(content: Text('Opened ${loaded.name}')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open: $e')));
    }
  }

  Future<void> _shareNote(BuildContext context) async {
    final document = context.read<DocumentRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final text = document.text;
    if (text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to share — the note is empty')),
      );
      return;
    }
    try {
      await Share.share(text, subject: 'Netpad note');
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sharing not available here — copied to clipboard'),
        ),
      );
    }
  }

  Future<void> _onFileAction(BuildContext context, String action) async {
    final document = context.read<DocumentRepository>();
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case 'open':
        await _openFile(context, document, messenger);
      case 'save':
        await _saveFile(document, messenger);
      case 'share':
        await _fileService.shareText(document.text);
    }
  }

  Future<void> _openFile(
    BuildContext context,
    DocumentRepository document,
    ScaffoldMessengerState messenger,
  ) async {
    final String? text;
    try {
      text = await _fileService.openTextFile();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open file: $e')));
      return;
    }
    if (text == null) return;

    if (document.text.isNotEmpty) {
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Replace current note?'),
          content: const Text(
            'Opening this file replaces the current note. If you are connected '
            'to peers, the change syncs to them too.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    document.loadExternalText(text);
    messenger.showSnackBar(
      const SnackBar(content: Text('File opened into the editor')),
    );
  }

  Future<void> _saveFile(
    DocumentRepository document,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      final saved = await _fileService.saveTextFile(document.text);
      if (saved) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Note saved to file')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save file: $e')));
    }
  }
}
