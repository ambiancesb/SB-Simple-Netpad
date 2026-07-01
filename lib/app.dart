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
import 'package:netpad/features/settings/settings_screen.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/file_service.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/share_service.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';

enum _AppMenuAction { wordWrap, save, open, share, history, settings }

class NetpadApp extends StatelessWidget {
  const NetpadApp({
    super.key,
    required this.config,
    required this.preferences,
    required this.tlsIdentity,
    required this.trustStore,
    required this.connectionLog,
    required this.discovery,
    required this.workspace,
    required this.sync,
    required this.pairing,
  });

  final InstanceConfig config;
  final AppPreferences preferences;
  final TlsIdentity tlsIdentity;
  final TrustStore trustStore;
  final ConnectionLogRepository connectionLog;
  final DiscoveryRepository discovery;
  final WorkspaceRepository workspace;
  final SyncRepository sync;
  final PairingRepository pairing;

  static const _seedColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: config),
        ChangeNotifierProvider.value(value: preferences),
        Provider.value(value: tlsIdentity),
        ChangeNotifierProvider.value(value: trustStore),
        ChangeNotifierProvider.value(value: connectionLog),
        ChangeNotifierProvider.value(value: discovery),
        ChangeNotifierProvider.value(value: workspace),
        ChangeNotifierProvider.value(value: sync),
        ChangeNotifierProvider.value(value: pairing),
      ],
      child: Consumer<AppPreferences>(
        builder: (context, prefs, _) {
          return MaterialApp(
            title: 'SB Simple Netpad',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _seedColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: prefs.themeMode,
            home: const PairingListener(child: _HomeShell()),
          );
        },
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
  final ShareService _shareService = const ShareService();
  bool _findVisible = false;
  bool _replaceMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final sync = context.read<SyncRepository>();
    sync.onLiveConflict = _resolveLiveConflict;
    sync.onSnapshotDivergence = _resolveDivergence;
  }

  String _previewText(String text, {int maxLen = 200}) {
    final singleLine = text.replaceAll('\n', ' ').trim();
    if (singleLine.length <= maxLen) return singleLine;
    return '${singleLine.substring(0, maxLen)}…';
  }

  void _toggleFind({bool replace = false}) {
    setState(() {
      if (_findVisible && _replaceMode == replace) {
        _findVisible = false;
        _replaceMode = false;
      } else {
        _findVisible = true;
        _replaceMode = replace;
      }
    });
  }

  Future<DivergenceChoice> _resolveLiveConflict(
    String peerName,
    String docTitle,
    int revision,
    String localText,
    String remoteText,
  ) async {
    if (!mounted) return DivergenceChoice.keepMine;
    final choice = await showDialog<DivergenceChoice>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Edit conflict in "$docTitle"'),
        content: SingleChildScrollView(
          child: Text(
            '$peerName edited the same note at the same time (revision '
            '$revision).\n\n'
            'Yours:\n${_previewText(localText)}\n\n'
            '$peerName:\n${_previewText(remoteText)}\n\n'
            'Which version should both devices keep?',
          ),
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
    final discovery = context.watch<DiscoveryRepository>();
    final workspace = context.watch<WorkspaceRepository>();
    final prefs = context.watch<AppPreferences>();
    final connected = discovery.connectedPeers.length;
    final activeTitle = workspace.active?.title ?? 'SB Simple Netpad';

    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            const _FindIntent(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            const _FindIntent(),
        const SingleActivator(LogicalKeyboardKey.keyH, control: true):
            const _ReplaceIntent(),
        const SingleActivator(LogicalKeyboardKey.keyH, meta: true):
            const _ReplaceIntent(),
      },
      child: Actions(
        actions: {
          _FindIntent: CallbackAction<_FindIntent>(
            onInvoke: (_) {
              _toggleFind();
              return null;
            },
          ),
          _ReplaceIntent: CallbackAction<_ReplaceIntent>(
            onInvoke: (_) {
              _toggleFind(replace: true);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: const NotesDrawer(),
            appBar: AppBar(
              title: Text(activeTitle, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  icon: Icon(
                    _findVisible ? Icons.search_off : Icons.search,
                  ),
                  tooltip: 'Find in note (Ctrl+F)',
                  onPressed: () => _toggleFind(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Tooltip(
                    message: connected > 0
                        ? '$connected peer session${connected == 1 ? '' : 's'} '
                              'encrypted with WSS/TLS · tap for peers'
                        : 'No active peer sessions · tap for peers',
                    child: ActionChip(
                      avatar: Icon(
                        connected > 0 ? Icons.lock : Icons.lock_outline,
                        size: 16,
                        color: connected > 0 ? Colors.green : Colors.grey,
                      ),
                      label: Text('$connected'),
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ),
                ),
                PopupMenuButton<_AppMenuAction>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More',
                  onSelected: (action) => _onAppMenuAction(context, action),
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: _AppMenuAction.wordWrap,
                      checked: prefs.wordWrap,
                      child: const ListTile(
                        leading: Icon(Icons.wrap_text),
                        title: Text('Word wrap'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: _AppMenuAction.save,
                      child: ListTile(
                        leading: Icon(Icons.save_alt),
                        title: Text('Save to file…'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const PopupMenuItem(
                      value: _AppMenuAction.open,
                      child: ListTile(
                        leading: Icon(Icons.folder_open),
                        title: Text('Open file as new note…'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const PopupMenuItem(
                      value: _AppMenuAction.share,
                      child: ListTile(
                        leading: Icon(Icons.ios_share),
                        title: Text('Share note'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const PopupMenuItem(
                      value: _AppMenuAction.history,
                      child: ListTile(
                        leading: Icon(Icons.history),
                        title: Text('Version history…'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: _AppMenuAction.settings,
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
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
              replaceMode: _replaceMode,
              onReplaceModeChanged: (replace) =>
                  setState(() => _replaceMode = replace),
              onCloseFind: () => setState(() {
                _findVisible = false;
                _replaceMode = false;
              }),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAppMenuAction(
    BuildContext context,
    _AppMenuAction action,
  ) async {
    final prefs = context.read<AppPreferences>();
    switch (action) {
      case _AppMenuAction.wordWrap:
        await prefs.setWordWrap(!prefs.wordWrap);
      case _AppMenuAction.save:
        await _saveNote(context);
      case _AppMenuAction.open:
        await _openNote(context);
      case _AppMenuAction.share:
        await _shareNote(context);
      case _AppMenuAction.history:
        final doc = context.read<WorkspaceRepository>().active;
        if (doc != null) await showVersionHistory(context, doc);
      case _AppMenuAction.settings:
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
        );
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
      await _shareService.shareNote(
        text: text,
        title: doc.title,
        context: context,
      );
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

class _FindIntent extends Intent {
  const _FindIntent();
}

class _ReplaceIntent extends Intent {
  const _ReplaceIntent();
}
