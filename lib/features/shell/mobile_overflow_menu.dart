import 'package:flutter/material.dart';
import 'package:netpad/l10n/l10n_ext.dart';

enum MobileAppMenuAction {
  wordWrap,
  save,
  open,
  share,
  history,
  settings,
  help,
  about,
}

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
    final l10n = context.l10n;
    return PopupMenuButton<MobileAppMenuAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: l10n.commonMore,
      constraints: const BoxConstraints(minWidth: _menuWidth),
      onSelected: onSelected,
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: MobileAppMenuAction.wordWrap,
          checked: wordWrap,
          child: _MobileMenuLabel(
            icon: Icons.wrap_text,
            label: l10n.shellMobileWordWrap,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: MobileAppMenuAction.save,
          child: _MobileMenuLabel(
            icon: Icons.save_alt,
            label: l10n.shellMobileSaveToFile,
          ),
        ),
        PopupMenuItem(
          value: MobileAppMenuAction.open,
          child: _MobileMenuLabel(
            icon: Icons.folder_open,
            label: l10n.shellMobileOpenFileAsNewNote,
          ),
        ),
        PopupMenuItem(
          value: MobileAppMenuAction.share,
          child: _MobileMenuLabel(
            icon: Icons.ios_share,
            label: l10n.shellMobileShareNote,
          ),
        ),
        PopupMenuItem(
          value: MobileAppMenuAction.history,
          child: _MobileMenuLabel(
            icon: Icons.history,
            label: l10n.shellMobileVersionHistory,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: MobileAppMenuAction.settings,
          child: _MobileMenuLabel(
            icon: Icons.settings,
            label: l10n.shellMobileSettings,
          ),
        ),
        PopupMenuItem(
          value: MobileAppMenuAction.help,
          child: _MobileMenuLabel(
            icon: Icons.help_outline,
            label: l10n.shellMobileHelp,
          ),
        ),
        PopupMenuItem(
          value: MobileAppMenuAction.about,
          child: _MobileMenuLabel(
            icon: Icons.info_outline,
            label: l10n.shellMobileAbout,
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
