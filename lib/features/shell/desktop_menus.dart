import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
List<PlatformMenuItem> buildMacosMenus(DesktopMenuActions actions) {
  return [
    PlatformMenu(
      label: 'SB Simple Netpad',
      menus: [
        const PlatformProvidedMenuItem(
          type: PlatformProvidedMenuItemType.about,
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'Settings…',
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
      label: 'File',
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'Save to File…',
              shortcut: _menuShortcut(LogicalKeyboardKey.keyS),
              onSelected: actions.onSave,
            ),
            PlatformMenuItem(
              label: 'Open File as New Note…',
              shortcut: _menuShortcut(LogicalKeyboardKey.keyO),
              onSelected: actions.onOpen,
            ),
            PlatformMenuItem(
              label: 'Share Note',
              onSelected: actions.onShare,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'Version History…',
              onSelected: actions.onHistory,
            ),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: 'Edit',
      menus: [
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: 'Find…',
              shortcut: _menuShortcut(LogicalKeyboardKey.keyF),
              onSelected: actions.onFind,
            ),
            PlatformMenuItem(
              label: 'Find and Replace…',
              shortcut: _menuShortcut(LogicalKeyboardKey.keyH),
              onSelected: actions.onFindReplace,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            PlatformMenuItem(
              label: actions.wordWrap ? 'Word Wrap ✓' : 'Word Wrap',
              onSelected: actions.onToggleWordWrap,
            ),
          ],
        ),
      ],
    ),
    PlatformMenu(
      label: 'View',
      menus: [
        PlatformMenuItem(
          label: actions.notesPanelVisible ? 'Notes Panel ✓' : 'Notes Panel',
          shortcut: _menuShortcut(LogicalKeyboardKey.keyN),
          onSelected: actions.onToggleNotes,
        ),
        PlatformMenuItem(
          label: actions.peersPanelVisible ? 'Peers Panel ✓' : 'Peers Panel',
          shortcut: _menuShortcut(LogicalKeyboardKey.keyP),
          onSelected: actions.onTogglePeers,
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
                child: const Text('Save to File…'),
              ),
              MenuItemButton(
                onPressed: actions.onOpen,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyO),
                child: const Text('Open File as New Note…'),
              ),
              MenuItemButton(
                onPressed: actions.onShare,
                child: const Text('Share Note'),
              ),
              MenuItemButton(
                onPressed: actions.onHistory,
                child: const Text('Version History…'),
              ),
              MenuItemButton(
                onPressed: actions.onSettings,
                child: const Text('Settings…'),
              ),
              MenuItemButton(
                onPressed: actions.onExit,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyQ),
                child: const Text('Exit'),
              ),
            ],
            child: const Text('File'),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: actions.onFind,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyF),
                child: const Text('Find…'),
              ),
              MenuItemButton(
                onPressed: actions.onFindReplace,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyH),
                child: const Text('Find and Replace…'),
              ),
              MenuItemButton(
                onPressed: actions.onToggleWordWrap,
                child: _CheckMenuLabel(
                  label: 'Word Wrap',
                  checked: actions.wordWrap,
                ),
              ),
            ],
            child: const Text('Edit'),
          ),
          SubmenuButton(
            menuChildren: [
              MenuItemButton(
                onPressed: actions.onToggleNotes,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyN),
                child: _CheckMenuLabel(
                  label: 'Notes Panel',
                  checked: actions.notesPanelVisible,
                ),
              ),
              MenuItemButton(
                onPressed: actions.onTogglePeers,
                shortcut: _menuShortcut(LogicalKeyboardKey.keyP),
                child: _CheckMenuLabel(
                  label: 'Peers Panel',
                  checked: actions.peersPanelVisible,
                ),
              ),
            ],
            child: const Text('View'),
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
      menus: buildMacosMenus(actions),
      child: child,
    );
  }
}
