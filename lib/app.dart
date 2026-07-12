import 'dart:async';
import 'dart:ui' show AppExitType;

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
import 'package:netpad/features/editor/mobile_voice_input_button.dart';
import 'package:netpad/features/entitlements/pro_gate.dart';
import 'package:netpad/features/notes/notes_drawer.dart';
import 'package:netpad/features/notes/version_history_sheet.dart';
import 'package:netpad/features/pairing/pairing_listener.dart';
import 'package:netpad/features/peers/peers_drawer.dart';
import 'package:netpad/features/shell/desktop_side_panel.dart';
import 'package:netpad/features/help/about_screen.dart';
import 'package:netpad/features/help/help_screen.dart';
import 'package:netpad/features/settings/settings_screen.dart';
import 'package:netpad/features/shell/desktop_menus.dart';
import 'package:netpad/features/shell/mobile_overflow_menu.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/pro_features.dart';
import 'package:netpad/services/file_service.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/share_service.dart';
import 'package:netpad/services/speech_input_service.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:provider/provider.dart';

class NetpadApp extends StatelessWidget {
  const NetpadApp({
    super.key,
    required this.config,
    required this.preferences,
    required this.entitlements,
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
  final EntitlementService entitlements;
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
        ChangeNotifierProvider.value(value: preferences),
        ChangeNotifierProvider.value(value: entitlements),
        Provider.value(value: tlsIdentity),
        ChangeNotifierProvider.value(value: trustStore),
        ChangeNotifierProvider.value(value: connectionLog),
        ChangeNotifierProvider.value(value: discovery),
        ChangeNotifierProvider.value(value: workspace),
        ChangeNotifierProvider.value(value: sync),
        ChangeNotifierProvider.value(value: pairing),
      ],
      child: Consumer2<AppPreferences, EntitlementService>(
        builder: (context, prefs, ents, _) {
          final skin = ProFeatures.effectiveSkin(prefs.skin, ents);
          return MaterialApp(
            title: 'SB Simple Netpad',
            debugShowCheckedModeBanner: false,
            theme: skin.themeData(Brightness.light),
            darkTheme: skin.themeData(Brightness.dark),
            themeMode: prefs.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
  final SpeechInputService _speechInput = SpeechInputService();
  late final SyncRepository _sync;
  late final WorkspaceRepository _workspace;
  bool _findVisible = false;
  bool _replaceMode = false;
  bool _notesPanelVisible = true;
  bool _peersPanelVisible = false;

  @override
  void initState() {
    super.initState();
    if (!isDesktopMenuPlatform()) {
      _notesPanelVisible = false;
    }
    WidgetsBinding.instance.addObserver(this);
    _sync = context.read<SyncRepository>();
    _workspace = context.read<WorkspaceRepository>();
    _sync.onLiveConflict = _resolveLiveConflict;
    _sync.onSnapshotDivergence = _resolveDivergence;
    _speechInput.getDictationAnchor = () {
      final doc = _workspace.active;
      return doc?.dictationAnchorOffset() ?? 0;
    };
    _speechInput.onDictationUpdate = _onDictationUpdate;
  }

  String _onDictationUpdate(DictationUpdate update) {
    final doc = context.read<WorkspaceRepository>().active;
    return doc?.applyDictation(
      anchorOffset: update.anchorOffset,
      previousSpan: update.previousSpan,
      recognizedWords: update.recognizedWords,
      isFinal: update.isFinal,
    ) ?? '';
  }

  Future<void> _toggleVoiceInput() async {
    if (!_speechInput.isListening) {
      final allowed = await ProGate.voiceInputAllowed(context);
      if (!allowed || !mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
    }
    final started = await _speechInput.toggleListening();
  if (!mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  if (_speechInput.lastError != null) {
    messenger.showSnackBar(
      SnackBar(content: Text(_speechInput.lastError!)),
    );
    return;
  }
  if (started) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.shellListeningSnack),
        duration: const Duration(seconds: 2),
      ),
    );
  }
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
    final l10n = context.l10n;
    final choice = await showDialog<DivergenceChoice>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.conflictLiveTitle(docTitle)),
        content: SingleChildScrollView(
          child: Text(
            l10n.conflictLiveBody(
              peerName,
              '$revision',
              _previewText(localText),
              _previewText(remoteText),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, DivergenceChoice.takeTheirs),
            child: Text(l10n.conflictUsePeers(peerName)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, DivergenceChoice.keepMine),
            child: Text(l10n.conflictKeepMine),
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
    final l10n = context.l10n;
    final choice = await showDialog<DivergenceChoice>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.conflictDivergedTitle(docTitle)),
        content: Text(
          l10n.conflictDivergedBody(
            peerName,
            docTitle,
            localText.length,
            remoteText.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, DivergenceChoice.takeTheirs),
            child: Text(l10n.conflictUsePeers(peerName)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, DivergenceChoice.keepMine),
            child: Text(l10n.conflictKeepMine),
          ),
        ],
      ),
    );
    return choice ?? DivergenceChoice.keepMine;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speechInput.dispose();
    unawaited(_workspace.flushSaveAll());
    _sync.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_workspace.flushSaveAll());
      unawaited(_speechInput.stopListening());
    }
  }

  void _toggleNotes() => setState(() => _notesPanelVisible = !_notesPanelVisible);
  void _togglePeers() => setState(() => _peersPanelVisible = !_peersPanelVisible);

  void _openPeers() {
    if (isDesktopMenuPlatform()) {
      setState(() => _peersPanelVisible = true);
    } else {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void _exitApp() {
    unawaited(_workspace.flushSaveAll());
    _sync.dispose();
    ServicesBinding.instance.exitApplication(AppExitType.required);
  }

  DesktopMenuActions _menuActions(AppPreferences prefs) {
    return DesktopMenuActions(
      wordWrap: prefs.wordWrap,
      notesPanelVisible: _notesPanelVisible,
      peersPanelVisible: _peersPanelVisible,
      onSave: () => _saveNote(context),
      onOpen: () => _openNote(context),
      onShare: () => _shareNote(context),
      onHistory: () async {
        final allowed = await ProGate.versionHistoryAllowed(context);
        if (!allowed || !mounted) return;
        final doc = context.read<WorkspaceRepository>().active;
        if (doc != null) await showVersionHistory(context, doc);
      },
      onSettings: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
      ),
      onHelp: () => showHelpScreen(context),
      onAbout: () => showAboutScreen(context),
      onCut: () => Actions.invoke(
        context,
        const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),
      ),
      onCopy: () => Actions.invoke(context, CopySelectionTextIntent.copy),
      onPaste: () => Actions.invoke(
        context,
        const PasteTextIntent(SelectionChangedCause.keyboard),
      ),
      onFind: () => _toggleFind(),
      onFindReplace: () => _toggleFind(replace: true),
      onToggleWordWrap: () => prefs.setWordWrap(!prefs.wordWrap),
      onToggleNotes: _toggleNotes,
      onTogglePeers: _togglePeers,
      onExit: _exitApp,
    );
  }

  Map<ShortcutActivator, Intent> _shortcutMap() {
    final isMac = Theme.of(context).platform == TargetPlatform.macOS;
    final mod = isMac
        ? const SingleActivator(LogicalKeyboardKey.keyS, meta: true)
        : const SingleActivator(LogicalKeyboardKey.keyS, control: true);
    final modO = isMac
        ? const SingleActivator(LogicalKeyboardKey.keyO, meta: true)
        : const SingleActivator(LogicalKeyboardKey.keyO, control: true);
    final modN = isMac
        ? const SingleActivator(LogicalKeyboardKey.keyN, meta: true)
        : const SingleActivator(LogicalKeyboardKey.keyN, control: true);
    final modP = isMac
        ? const SingleActivator(LogicalKeyboardKey.keyP, meta: true)
        : const SingleActivator(LogicalKeyboardKey.keyP, control: true);
    return {
      const SingleActivator(LogicalKeyboardKey.keyF, control: true):
          const _FindIntent(),
      const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
          const _FindIntent(),
      const SingleActivator(LogicalKeyboardKey.keyH, control: true):
          const _ReplaceIntent(),
      const SingleActivator(LogicalKeyboardKey.keyH, meta: true):
          const _ReplaceIntent(),
      if (isDesktopMenuPlatform()) ...{
        mod: const _SaveIntent(),
        modO: const _OpenIntent(),
        modN: const _ToggleNotesIntent(),
        modP: const _TogglePeersIntent(),
      },
    };
  }

  Widget _buildScaffold({
    required String activeTitle,
    required int connected,
    required bool desktopMenus,
    required bool wordWrap,
    required Widget body,
  }) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      drawer: desktopMenus ? null : const NotesDrawer(),
      endDrawer: desktopMenus ? null : const PeersDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: !desktopMenus,
        title: Text(activeTitle, overflow: TextOverflow.ellipsis),
        actions: [
          if (desktopMenus) ...[
            IconButton(
              icon: Icon(
                Icons.notes,
                color: _notesPanelVisible ? colorScheme.primary : null,
              ),
              tooltip: _notesPanelVisible
                  ? l10n.shellHideNotesPanel
                  : l10n.shellShowNotesPanel,
              onPressed: _toggleNotes,
            ),
            IconButton(
              icon: Badge(
                isLabelVisible: connected > 0,
                label: Text('$connected'),
                backgroundColor: Colors.green.shade700,
                child: Icon(
                  connected > 0 ? Icons.devices : Icons.devices_outlined,
                  color: _peersPanelVisible
                      ? colorScheme.primary
                      : connected > 0
                      ? Colors.green.shade700
                      : null,
                ),
              ),
              tooltip: connected > 0
                  ? l10n.shellPeersTooltipConnected(
                      connected,
                      _peersPanelVisible
                          ? l10n.shellPeersTooltipActionHide
                          : l10n.shellPeersTooltipActionShow,
                    )
                  : _peersPanelVisible
                  ? l10n.shellHidePeersPanel
                  : l10n.shellShowPeersPanel,
              onPressed: _togglePeers,
            ),
          ],
          if (!desktopMenus)
            IconButton(
              icon: Icon(_findVisible ? Icons.search_off : Icons.search),
              tooltip: l10n.shellFindInNote,
              onPressed: () => _toggleFind(),
            ),
          if (!desktopMenus && SpeechInputService.isSupported)
            MobileVoiceInputButton(
              service: _speechInput,
              onToggle: _toggleVoiceInput,
            ),
          Padding(
            padding: EdgeInsets.only(right: desktopMenus ? 8 : 4),
            child: Tooltip(
              message: connected > 0
                  ? l10n.shellSecurityChipConnected(connected)
                  : l10n.shellSecurityChipNone,
              child: ActionChip(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: desktopMenus
                    ? null
                    : const EdgeInsets.symmetric(horizontal: 4),
                avatar: Icon(
                  connected > 0 ? Icons.lock : Icons.lock_outline,
                  size: 16,
                  color: connected > 0 ? Colors.green : Colors.grey,
                ),
                label: Text('$connected'),
                onPressed: _openPeers,
              ),
            ),
          ),
          if (!desktopMenus)
            MobileOverflowMenuButton(
              wordWrap: wordWrap,
              onSelected: (action) => _onAppMenuAction(context, action),
            ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildDesktopBody({
    required Widget editor,
    required bool showMaterialMenuBar,
    required DesktopMenuActions menuActions,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_notesPanelVisible)
          DesktopSidePanel(
            title: context.l10n.notesTitle,
            width: 300,
            onClose: _toggleNotes,
            child: const NotesPanel(showTitle: false),
          ),
        Expanded(
          child: showMaterialMenuBar
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DesktopMaterialMenuBar(actions: menuActions),
                    Expanded(child: editor),
                  ],
                )
              : editor,
        ),
        if (_peersPanelVisible)
          PeersDesktopPanel(onClose: _togglePeers),
      ],
    );
  }

  Future<void> _onAppMenuAction(
    BuildContext context,
    MobileAppMenuAction action,
  ) async {
    final prefs = context.read<AppPreferences>();
    switch (action) {
      case MobileAppMenuAction.wordWrap:
        await prefs.setWordWrap(!prefs.wordWrap);
      case MobileAppMenuAction.save:
        await _saveNote(context);
      case MobileAppMenuAction.open:
        await _openNote(context);
      case MobileAppMenuAction.share:
        await _shareNote(context);
      case MobileAppMenuAction.history:
        final allowed = await ProGate.versionHistoryAllowed(context);
        if (!allowed || !context.mounted) return;
        final doc = context.read<WorkspaceRepository>().active;
        if (doc != null) await showVersionHistory(context, doc);
      case MobileAppMenuAction.settings:
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
        );
      case MobileAppMenuAction.help:
        if (!context.mounted) return;
        await showHelpScreen(context);
      case MobileAppMenuAction.about:
        if (!context.mounted) return;
        await showAboutScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryRepository>();
    final workspace = context.watch<WorkspaceRepository>();
    final prefs = context.watch<AppPreferences>();
    final connected = discovery.connectedPeers.length;
    final activeTitle = workspace.active?.title ?? 'SB Simple Netpad';
    final desktopMenus = isDesktopMenuPlatform();
    final menuActions = _menuActions(prefs);

    final editor = EditorScreen(
      findVisible: _findVisible,
      replaceMode: _replaceMode,
      onReplaceModeChanged: (replace) =>
          setState(() => _replaceMode = replace),
      onCloseFind: () => setState(() {
        _findVisible = false;
        _replaceMode = false;
      }),
      speechInput: SpeechInputService.isSupported ? _speechInput : null,
    );

    final shellBody = desktopMenus
        ? _buildDesktopBody(
            editor: editor,
            showMaterialMenuBar: useMaterialWindowMenuBar(),
            menuActions: menuActions,
          )
        : editor;

    return Shortcuts(
      shortcuts: _shortcutMap(),
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
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              _saveNote(context);
              return null;
            },
          ),
          _OpenIntent: CallbackAction<_OpenIntent>(
            onInvoke: (_) {
              _openNote(context);
              return null;
            },
          ),
          _ToggleNotesIntent: CallbackAction<_ToggleNotesIntent>(
            onInvoke: (_) {
              _toggleNotes();
              return null;
            },
          ),
          _TogglePeersIntent: CallbackAction<_TogglePeersIntent>(
            onInvoke: (_) {
              _togglePeers();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: DesktopMenuHost(
            actions: menuActions,
            child: _buildScaffold(
              activeTitle: activeTitle,
              connected: connected,
              desktopMenus: desktopMenus,
              wordWrap: prefs.wordWrap,
              body: shellBody,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote(BuildContext context) async {
    final doc = context.read<WorkspaceRepository>().active;
    if (doc == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final path = await _fileService.saveText(
        doc.text,
        suggestedName: '${_safeName(doc.title)}.txt',
      );
      if (path == null) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.fileSavedTo(path))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.fileCouldNotSave('$e'))));
    }
  }

  Future<void> _openNote(BuildContext context) async {
    final workspace = context.read<WorkspaceRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final loaded = await _fileService.openText();
      if (loaded == null || !context.mounted) return;

      final allowed = await ProGate.createNoteAllowed(
        context,
        currentNoteCount: workspace.documents.length,
      );
      if (!allowed || !context.mounted) return;

      final doc = workspace.createNote(title: _titleFromFile(loaded.name));
      doc.replaceLocal(loaded.text, snapshotLabel: 'Imported file');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fileOpenedAsNewNote(loaded.name))),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.fileCouldNotOpen('$e'))));
    }
  }

  Future<void> _shareNote(BuildContext context) async {
    final doc = context.read<WorkspaceRepository>().active;
    if (doc == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final text = doc.text;
    if (text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fileNothingToShare)),
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
        SnackBar(content: Text(l10n.fileShareFallbackClipboard)),
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

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _OpenIntent extends Intent {
  const _OpenIntent();
}

class _ToggleNotesIntent extends Intent {
  const _ToggleNotesIntent();
}

class _TogglePeersIntent extends Intent {
  const _TogglePeersIntent();
}
