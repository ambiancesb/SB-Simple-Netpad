import 'package:flutter/material.dart';

enum MobileAppMenuAction { wordWrap, save, open, share, history, settings }

/// Compact overflow menu for mobile app bars (File, editor, and settings).
class MobileOverflowMenuButton extends StatelessWidget {
  const MobileOverflowMenuButton({
    super.key,
    required this.wordWrap,
    required this.onSelected,
  });

  final bool wordWrap;
  final ValueChanged<MobileAppMenuAction> onSelected;

  static const _menuWidth = 280.0;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MobileAppMenuAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More',
      constraints: const BoxConstraints(minWidth: _menuWidth),
      onSelected: onSelected,
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: MobileAppMenuAction.wordWrap,
          checked: wordWrap,
          child: const _MobileMenuLabel(
            icon: Icons.wrap_text,
            label: 'Word wrap',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: MobileAppMenuAction.save,
          child: _MobileMenuLabel(
            icon: Icons.save_alt,
            label: 'Save to file…',
          ),
        ),
        const PopupMenuItem(
          value: MobileAppMenuAction.open,
          child: _MobileMenuLabel(
            icon: Icons.folder_open,
            label: 'Open file as new note…',
          ),
        ),
        const PopupMenuItem(
          value: MobileAppMenuAction.share,
          child: _MobileMenuLabel(
            icon: Icons.ios_share,
            label: 'Share note',
          ),
        ),
        const PopupMenuItem(
          value: MobileAppMenuAction.history,
          child: _MobileMenuLabel(
            icon: Icons.history,
            label: 'Version history…',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: MobileAppMenuAction.settings,
          child: _MobileMenuLabel(
            icon: Icons.settings,
            label: 'Settings',
          ),
        ),
      ],
    );
  }
}

class _MobileMenuLabel extends StatelessWidget {
  const _MobileMenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
