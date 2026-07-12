import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/l10n/l10n_ext.dart';

/// True on Windows, macOS, and Linux (not mobile).
bool isDesktopMenuPlatform() {
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

/// macOS renders menus in the system menu bar via [PlatformMenuBar].
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
}

MenuSerializableShortcut? _menuShortcut(LogicalKeyboardKey key) {
  final isMac = defaultTargetPlatform == TargetPlatform.macOS;
  return SingleActivator(
    key,
    control: !isMac,
    meta: isMac,
  );
}

/// Native macOS menu bar (File, Edit, View).
List<PlatformMenuItem> buildMacosMenus(
  DesktopMenuActions actions,
  AppLocalizations l10n,
) {
  return [
    PlatformMenu(
      label: l10n.commonAppName,
      menus: [
        const PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.about,
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellSettings,
              shortcut: _menuShortcut(LogicalKeyboardKey.comma),
              onSelected: actions.onSettings,
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
              onSelected: actions.onSave,
            ),
            PlatformMenuItem(
              label: l10n.shellOpenFileAsNewNote,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyO),
              onSelected: actions.onOpen,
            ),
            PlatformMenuItem(
              label: l10n.shellShareNote,
              onSelected: actions.onShare,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellVersionHistory,
              onSelected: actions.onHistory,
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
              onSelected: actions.onCut,
            ),
            PlatformMenuItem(
              label: l10n.shellCopy,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyC),
              onSelected: actions.onCopy,
            ),
            PlatformMenuItem(
              label: l10n.shellPaste,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyV),
              onSelected: actions.onPaste,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: l10n.shellFind,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyF),
              onSelected: actions.onFind,
            ),
            PlatformMenuItem(
              label: l10n.shellFindAndReplace,
              shortcut: _menuShortcut(LogicalKeyboardKey.keyH),
              onSelected: actions.onFindReplace,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: actions.wordWrap ? l10n.shellWordWrapChecked : l10n.shellWordWrap,
              onSelected: actions.onToggleWordWrap,
            ),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: l10n.shellMenuView,
      menus: [
        PlatformMenuItem(
          label: actions.notesPanelVisible
              ? l10n.shellNotesPanelChecked
              : l10n.shellNotesPanel,
          shortcut: _menuShortcut(LogicalKeyboardKey.keyN),
          onSelected: actions.onToggleNotes,
        ),
        PlatformMenuItem(
          label: actions.peersPanelVisible
              ? l10n.shellPeersPanelChecked
              : l10n.shellPeersPanel,
          shortcut: _menuShortcut(LogicalKeyboardKey.keyP),
          onSelected: actions.onTogglePeers,
        ),
      ],
    ),
    PlatformMenu(
      label: l10n.shellMenuHelp,
      menus: [
        PlatformMenuItem(
          label: l10n.shellHelpItem,
          onSelected: actions.onHelp,
        ),
        PlatformMenuItem(
          label: l10n.shellAboutItem,
          onSelected: actions.onAbout,
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
                shortcut: _menuShortcut(LogicalKeyboardKey.keyH),
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

/// Wraps [child] with a native macOS menu bar when applicable.
class DesktopMenuHost extends StatelessWidget {
  const DesktopMenuHost({
    super.key,
    required this.actions,
    required this.child,
  });

  final DesktopMenuActions actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!useNativeSystemMenuBar()) return child;
    return PlatformMenuBar(
      menus: buildMacosMenus(actions, context.l10n),
      child: child,
    );
  }
}
