import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/models/divergence_choice.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/features/editor/editor_screen.dart';
import 'package:netpad/features/notes/notes_drawer.dart';
import 'package:netpad/features/notes/version_history_sheet.dart';
import 'package:netpad/features/pairing/pairing_listener.dart';
import 'package:netpad/features/peers/peers_panel.dart';
import 'package:netpad/services/file_service.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

enum _FileAction { save, open, share, history }

class NetpadApp extends StatelessWidget {
  const NetpadApp({
    super.key,
    required this.config,
    required this.tlsIdentity,
    required this.trustStore,
    required this.connectionLog,
    required this.discovery,
    required this.workspace,
    required this.sync,
    required this.pairing,
  });

  final InstanceConfig config;
  final TlsIdentity tlsIdentity;
  final TrustStore trustStore;
  final ConnectionLogRepository connectionLog;
  final DiscoveryRepository discovery;
  final WorkspaceRepository workspace;
  final SyncRepository sync;
  final PairingRepository pairing;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: config),
        Provider.value(value: tlsIdentity),
        ChangeNotifierProvider.value(value: trustStore),
        ChangeNotifierProvider.value(value: connectionLog),
        ChangeNotifierProvider.value(value: discovery),
        ChangeNotifierProvider.value(value: workspace),
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
  final FileService _fileService = const FileService();
  bool _findVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final sync = context.read<SyncRepository>();
    sync.onConflictMerged = () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remote edit applied (revision conflict resolved)'),
          duration: Duration(seconds: 2),
        ),
      );
    };
    sync.onSnapshotDivergence = _resolveDivergence;
  }

  Future<DivergenceChoice> _resolveDivergence(
    String peerName,
    String docTitle,
    int localRevision,
    String localText,
    int remoteRevision,
    String remoteText,
  ) async {
    if (!mounted) return DivergenceChoice.keepMine;
    final choice = await showDialog<DivergenceChoice>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('"$docTitle" has diverged'),
        content: Text(
          'Your copy and $peerName\'s copy of "$docTitle" changed differently '
          'while disconnected.\n\n'
          'Yours: ${localText.length} characters\n'
          '$peerName: ${remoteText.length} characters\n\n'
          'Which version should both devices keep?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, DivergenceChoice.takeTheirs),
            child: Text('Use $peerName\'s'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, DivergenceChoice.keepMine),
            child: const Text('Keep mine'),
          ),
        ],
      ),
    );
    return choice ?? DivergenceChoice.keepMine;
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
      context.read<WorkspaceRepository>().flushSaveAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.read<InstanceConfig>();
    final discovery = context.watch<DiscoveryRepository>();
    final workspace = context.watch<WorkspaceRepository>();
    final connected = discovery.connectedPeers.length;
    final activeTitle = workspace.active?.title ?? 'SB Simple Netpad';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const NotesDrawer(),
      appBar: AppBar(
        title: Text(activeTitle, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Find in note',
            onPressed: () => setState(() => _findVisible = !_findVisible),
          ),
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
                  title: Text('Open file as new note…'),
                ),
              ),
              PopupMenuItem(
                value: _FileAction.share,
                child: ListTile(
                  leading: Icon(Icons.ios_share),
                  title: Text('Share note'),
                ),
              ),
              PopupMenuItem(
                value: _FileAction.history,
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Version history…'),
                ),
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
      body: EditorScreen(
        findVisible: _findVisible,
        onCloseFind: () => setState(() => _findVisible = false),
      ),
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
      case _FileAction.history:
        final doc = context.read<WorkspaceRepository>().active;
        if (doc != null) await showVersionHistory(context, doc);
    }
  }

  Future<void> _saveNote(BuildContext context) async {
    final doc = context.read<WorkspaceRepository>().active;
    if (doc == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await _fileService.saveText(
        doc.text,
        suggestedName: '${_safeName(doc.title)}.txt',
      );
      if (path == null) return;
      messenger.showSnackBar(SnackBar(content: Text('Saved to $path')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  Future<void> _openNote(BuildContext context) async {
    final workspace = context.read<WorkspaceRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final loaded = await _fileService.openText();
      if (loaded == null || !context.mounted) return;

      final doc = workspace.createNote(title: _titleFromFile(loaded.name));
      doc.replaceLocal(loaded.text, snapshotLabel: 'Imported file');
      messenger.showSnackBar(
        SnackBar(content: Text('Opened ${loaded.name} as a new note')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open: $e')));
    }
  }

  Future<void> _shareNote(BuildContext context) async {
    final doc = context.read<WorkspaceRepository>().active;
    if (doc == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = doc.text;
    if (text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to share — the note is empty')),
      );
      return;
    }
    try {
      await Share.share(text, subject: doc.title);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sharing not available here — copied to clipboard'),
        ),
      );
    }
  }

  String _safeName(String title) {
    final cleaned = title.replaceAll(RegExp(r'[^\w\- ]'), '').trim();
    return cleaned.isEmpty ? 'netpad-note' : cleaned;
  }

  String _titleFromFile(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }
}
