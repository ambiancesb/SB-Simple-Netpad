import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/l10n/l10n_ext.dart';

/// True on Windows, macOS, and Linux (not mobile).
bool isDesktopMenuPlatform() {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

/// macOS renders menus in the system menu bar (not an in-window bar).
bool useNativeSystemMenuBar() => Platform.isMacOS;

/// Windows and Linux use an in-window Material [MenuBar].
bool useMaterialWindowMenuBar() =>
    Platform.isWindows || Platform.isLinux;

/// Callbacks wired from the home shell into desktop menu items.
class DesktopMenuActions {
  const DesktopMenuActions({
    required this.wordWrap,
    required this.notesPanelVisible,
    required this.peersPanelVisible,
    required this.onSave,
    required this.onOpen,
    required this.onShare,
    required this.onHistory,
    required this.onSettings,
    required this.onHelp,
    required this.onAbout,
    required this.onCut,
    required this.onCopy,
    required this.onPaste,
    required this.onFind,
    required this.onFindReplace,
    required this.onToggleWordWrap,
    required this.onToggleNotes,
    required this.onTogglePeers,
    required this.onExit,
  });

  final bool wordWrap;
  final bool notesPanelVisible;
  final bool peersPanelVisible;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onHistory;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onCut;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onFind;
  final VoidCallback onFindReplace;
  final VoidCallback onToggleWordWrap;
  final VoidCallback onToggleNotes;
  final VoidCallback onTogglePeers;
  final VoidCallback onExit;

  /// Labels / checkmarks that require pushing a new native menu tree.
  String get visualSignature =>
      '$wordWrap|$notesPanelVisible|$peersPanelVisible';
}

/// Mutable slot so native menu `onSelected` closures stay fresh without
/// calling [PlatformMenuDelegate.setMenus] (which rebuilds the macOS bar).
class DesktopMenuActionsHolder {
  DesktopMenuActions? current;
}

MenuSerializableShortcut? _menuShortcut(
  LogicalKeyboardKey key, {
  bool alt = false,
}) {
  final isMac = defaultTargetPlatform == TargetPlatform.macOS;
  return SingleActivator(
    key,
    control: !isMac,
    meta: isMac,
    alt: alt,
  );
}

/// Find & Replace: Ctrl+H on Win/Linux; Option+Cmd+F on macOS (Cmd+H is Hide).
MenuSerializableShortcut? _findReplaceShortcut() {
  final isMac = defaultTargetPlatform == TargetPlatform.macOS;
  if (isMac) {
    return const SingleActivator(
      LogicalKeyboardKey.keyF,
      meta: true,
      alt: true,
    );
  }
  return const SingleActivator(LogicalKeyboardKey.keyH, control: true);
}

/// Avoid the exact label "View" — AppKit injects Tab Bar / Full Screen items
/// that fight Flutter's menu updates and make the bar feel unstable.
String _macosViewMenuLabel(AppLocalizations l10n) {
  final label = l10n.shellMenuView;
  if (label == 'View') return 'View\u00a0';
  return label;
}

/// Native macOS menu bar hierarchy.
///
/// Callbacks read [holder.current] so the shell can rotate closures without
/// rebuilding the native NSMenu (open menus dismiss when [setMenus] runs).
List<PlatformMenuItem> buildMacosMenus(
  DesktopMenuActionsHolder holder,
  AppLocalizations l10n,
) {
  DesktopMenuActions a() => holder.current!;
  return [
    PlatformMenu(
      label: l10n.commonAppName,
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellSettings,
              shortcut: _menuShortcut(LogicalKeyboardKey.comma),
              onSelected: () => a().onSettings(),
            ),
          ],
        ),
        const PlatformMenuItemGroup(
          members: [
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.hideOtherApplications,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.showAllApplications,
            ),
          ],
        ),
        const PlatformMenuItemGroup(
          members: [
            PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: l10n.shellMenuFile,
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellSaveToFile,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyS),
              onSelected: () => a().onSave(),
            ),
            PlatformMenuItem(
              label: l10n.shellOpenFileAsNewNote,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyO),
              onSelected: () => a().onOpen(),
            ),
            PlatformMenuItem(
              label: l10n.shellShareNote,
              onSelected: () => a().onShare(),
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellVersionHistory,
              onSelected: () => a().onHistory(),
            ),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: l10n.shellMenuEdit,
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellCut,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyX),
              onSelected: () => a().onCut(),
            ),
            PlatformMenuItem(
              label: l10n.shellCopy,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyC),
              onSelected: () => a().onCopy(),
            ),
            PlatformMenuItem(
              label: l10n.shellPaste,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyV),
              onSelected: () => a().onPaste(),
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellFind,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyF),
              onSelected: () => a().onFind(),
            ),
            PlatformMenuItem(
              label: l10n.shellFindAndReplace,
              shortcut: _findReplaceShortcut(),
              onSelected: () => a().onFindReplace(),
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: a().wordWrap
                  ? l10n.shellWordWrapChecked
                  : l10n.shellWordWrap,
              onSelected: () => a().onToggleWordWrap(),
            ),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: _macosViewMenuLabel(l10n),
      menus: [
        PlatformMenuItem(
          label: a().notesPanelVisible
              ? l10n.shellNotesPanelChecked
              : l10n.shellNotesPanel,
          shortcut: _menuShortcut(LogicalKeyboardKey.keyN),
          onSelected: () => a().onToggleNotes(),
        ),
        PlatformMenuItem(
          label: a().peersPanelVisible
              ? l10n.shellPeersPanelChecked
              : l10n.shellPeersPanel,
          shortcut: _menuShortcut(LogicalKeyboardKey.keyP),
          onSelected: () => a().onTogglePeers(),
        ),
      ],
    ),
    PlatformMenu(
      label: l10n.shellMenuHelp,
      menus: [
        PlatformMenuItem(
          label: l10n.shellHelpItem,
          onSelected: () => a().onHelp(),
        ),
        PlatformMenuItem(
          label: l10n.shellAboutItem,
          onSelected: () => a().onAbout(),
        ),
      ],
    ),
  ];
}

/// In-window File / Edit / View menu for Windows and Linux.
class DesktopMaterialMenuBar extends StatelessWidget {
  const DesktopMaterialMenuBar({
    super.key,
    required this.actions,
  });

  final DesktopMenuActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      child: MenuBar(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHighest,
          ),
          surfaceTintColor: WidgetStatePropertyAll(colorScheme.surfaceTint),
        ),
        children: [
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: actions.onSave,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyS),
                child: Text(l10n.shellSaveToFile),
              ),
              MenuItemButton(
                onPressed: actions.onOpen,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyO),
                child: Text(l10n.shellOpenFileAsNewNote),
              ),
              MenuItemButton(
                onPressed: actions.onShare,
                child: Text(l10n.shellShareNote),
              ),
              MenuItemButton(
                onPressed: actions.onHistory,
                child: Text(l10n.shellVersionHistory),
              ),
              MenuItemButton(
                onPressed: actions.onSettings,
                child: Text(l10n.shellSettings),
              ),
              MenuItemButton(
                onPressed: actions.onExit,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyQ),
                child: Text(l10n.shellExit),
              ),
            ],
            child: Text(l10n.shellMenuFile),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: actions.onCut,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyX),
                child: Text(l10n.shellCut),
              ),
              MenuItemButton(
                onPressed: actions.onCopy,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyC),
                child: Text(l10n.shellCopy),
              ),
              MenuItemButton(
                onPressed: actions.onPaste,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyV),
                child: Text(l10n.shellPaste),
              ),
              MenuItemButton(
                onPressed: actions.onFind,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyF),
                child: Text(l10n.shellFind),
              ),
              MenuItemButton(
                onPressed: actions.onFindReplace,
                shortcut: _findReplaceShortcut(),
                child: Text(l10n.shellFindAndReplace),
              ),
              MenuItemButton(
                onPressed: actions.onToggleWordWrap,
                child: _CheckMenuLabel(
                  label: l10n.shellWordWrap,
                  checked: actions.wordWrap,
                ),
              ),
            ],
            child: Text(l10n.shellMenuEdit),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: actions.onToggleNotes,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyN),
                child: _CheckMenuLabel(
                  label: l10n.shellNotesPanel,
                  checked: actions.notesPanelVisible,
                ),
              ),
              MenuItemButton(
                onPressed: actions.onTogglePeers,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyP),
                child: _CheckMenuLabel(
                  label: l10n.shellPeersPanel,
                  checked: actions.peersPanelVisible,
                ),
              ),
            ],
            child: Text(l10n.shellMenuView),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: actions.onHelp,
                child: Text(l10n.shellHelpItem),
              ),
              MenuItemButton(
                onPressed: actions.onAbout,
                child: Text(l10n.shellAboutItem),
              ),
            ],
            child: Text(l10n.shellMenuHelp),
          ),
        ],
      ),
    );
  }
}

class _CheckMenuLabel extends StatelessWidget {
  const _CheckMenuLabel({required this.label, required this.checked});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: checked
              ? Icon(Icons.check, size: 16, color: Theme.of(context).iconTheme.color)
              : null,
        ),
        Text(label),
      ],
    );
  }
}

/// Hosts the macOS system menu bar without using [PlatformMenuBar].
///
/// [PlatformMenuBar] calls `clearMenus`/`setMenus` on mount and whenever its
/// descendant list identity changes — that rebuilds the native menu bar
/// (including the application menu) and makes titles flash/dismiss under the
/// mouse. This host pushes menus only when checkmark/label state changes, and
/// keeps callbacks live via [DesktopMenuActionsHolder].
class DesktopMenuHost extends StatefulWidget {
  const DesktopMenuHost({
    super.key,
    required this.actions,
    required this.child,
  });

  final DesktopMenuActions actions;
  final Widget child;

  @override
  State<DesktopMenuHost> createState() => _DesktopMenuHostState();
}

class _DesktopMenuHostState extends State<DesktopMenuHost> {
  final DesktopMenuActionsHolder _holder = DesktopMenuActionsHolder();
  String? _pushedSignature;
  Locale? _pushedLocale;

  @override
  void initState() {
    super.initState();
    _holder.current = widget.actions;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncNativeMenus();
  }

  @override
  void didUpdateWidget(covariant DesktopMenuHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _holder.current = widget.actions;
    _syncNativeMenus();
  }

  @override
  void dispose() {
    if (useNativeSystemMenuBar()) {
      WidgetsBinding.instance.platformMenuDelegate.clearMenus();
    }
    super.dispose();
  }

  void _syncNativeMenus() {
    if (!useNativeSystemMenuBar()) return;
    final actions = _holder.current;
    if (actions == null) return;

    final locale = Localizations.localeOf(context);
    final signature = actions.visualSignature;
    if (_pushedSignature == signature && _pushedLocale == locale) {
      return;
    }

    _pushedSignature = signature;
    _pushedLocale = locale;
    WidgetsBinding.instance.platformMenuDelegate.setMenus(
      buildMacosMenus(_holder, context.l10n),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
