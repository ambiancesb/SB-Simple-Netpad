import 'package:flutter/material.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/file_service.dart';

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
    this.showFileImportExport = true,
  });

  final bool wordWrap;
  final ValueChanged<MobileAppMenuAction> onSelected;

  /// When false (iOS), Save / Open are omitted; Share remains.
  final bool showFileImportExport;

  static const _menuWidth = 280.0;

  /// Default for the running platform; override in tests.
  static bool get defaultShowFileImportExport =>
      FileService.supportsImportExport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // AppBar sets a light-on-primary IconTheme; keep the trigger matching that
    // chrome, but color menu icons explicitly so they stay visible on the
    // light popup surface (otherwise they inherit white → white-on-white).
    final triggerColor =
        Theme.of(context).appBarTheme.foregroundColor ??
        IconTheme.of(context).color;

    return PopupMenuButton<MobileAppMenuAction>(
      icon: const Icon(Icons.more_vert),
      iconColor: triggerColor,
      tooltip: l10n.commonMore,
      constraints: const BoxConstraints(minWidth: _menuWidth),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: MobileAppMenuAction.wordWrap,
          child: _MobileMenuLabel(
            icon: Icons.wrap_text,
            label: l10n.shellMobileWordWrap,
            checked: wordWrap,
          ),
        ),
        const PopupMenuDivider(),
        if (showFileImportExport) ...[
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
        ],
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
  const _MobileMenuLabel({
    required this.icon,
    required this.label,
    this.checked = false,
  });

  final IconData icon;
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Explicit colors — AppBar IconTheme is white in light mode and would
    // otherwise paint these invisible on the popup surface.
    final iconColor = colors.onSurfaceVariant;

    return Row(
      children: [
        SizedBox(
          width: 24,
          child: checked
              ? Icon(Icons.check, size: 20, color: iconColor)
              : null,
        ),
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
