import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/features/notes/version_history_sheet.dart';
import 'package:provider/provider.dart';

/// Mobile slide-out drawer wrapping [NotesPanel].
class NotesDrawer extends StatelessWidget {
  const NotesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      width: 340,
      child: SafeArea(child: NotesPanel(dismissOnSelect: true)),
    );
  }
}

/// Note list with search — shared by the drawer (mobile) and docked panel.
class NotesPanel extends StatefulWidget {
  const NotesPanel({
    super.key,
    this.dismissOnSelect = false,
    this.showTitle = true,
  });

  /// When true, closes the enclosing [Drawer] after selecting a note.
  final bool dismissOnSelect;
  final bool showTitle;

  @override
  State<NotesPanel> createState() => _NotesPanelState();
}

class _NotesPanelState extends State<NotesPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _maybeDismiss() {
    if (widget.dismissOnSelect) Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceRepository>();
    final hits = workspace.search(_query);
    final searching = _query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showTitle)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  tooltip: 'New note',
                  onPressed: () {
                    workspace.createNote();
                    _maybeDismiss();
                  },
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.add, size: 20),
                tooltip: 'New note',
                visualDensity: VisualDensity.compact,
                onPressed: () => workspace.createNote(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: 'Search all notes',
              border: const OutlineInputBorder(),
              suffixIcon: searching
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: searching
              ? _buildSearchResults(context, workspace, hits)
              : _buildOrderedList(context, workspace),
        ),
      ],
    );
  }

  Future<void> _rename(
    BuildContext context,
    WorkspaceRepository workspace,
    DocumentRepository doc,
  ) async {
    final controller = TextEditingController(text: doc.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) workspace.renameNote(doc.id, result);
  }

  Future<void> _delete(
    BuildContext context,
    WorkspaceRepository workspace,
    DocumentRepository doc,
  ) async {
    final synced = workspace.isSyncEnabled(doc.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${doc.title}"?'),
        content: Text(
          synced
              ? 'This removes the note for you and every connected peer.'
              : 'This removes the note from this device only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) workspace.deleteNote(doc.id);
  }

  Widget _buildSearchResults(
    BuildContext context,
    WorkspaceRepository workspace,
    List<NoteSearchHit> hits,
  ) {
    if (hits.isEmpty) {
      return Center(
        child: Text(
          'No matches',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: hits.length,
      itemBuilder: (context, index) {
        final hit = hits[index];
        return _NoteTile(
          hit: hit,
          searching: true,
          active: hit.doc.id == workspace.activeId,
          syncEnabled: workspace.isSyncEnabled(hit.doc.id),
          onSyncChanged: (enabled) =>
              workspace.setSyncEnabled(hit.doc.id, enabled),
          onTap: () {
            workspace.selectNote(hit.doc.id);
            _maybeDismiss();
          },
          onRename: () => _rename(context, workspace, hit.doc),
          onDelete: () => _delete(context, workspace, hit.doc),
          onHistory: () => showVersionHistory(context, hit.doc),
        );
      },
    );
  }

  Widget _buildOrderedList(
    BuildContext context,
    WorkspaceRepository workspace,
  ) {
    final docs = workspace.documents;
    if (docs.isEmpty) {
      return Center(
        child: Text(
          'No notes',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      buildDefaultDragHandles: false,
      itemCount: docs.length,
      onReorder: workspace.reorderNote,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final hit = NoteSearchHit(doc: doc, matchCount: 0, snippet: '');
        return _NoteTile(
          key: ValueKey(doc.id),
          listIndex: index,
          hit: hit,
          searching: false,
          active: doc.id == workspace.activeId,
          syncEnabled: workspace.isSyncEnabled(doc.id),
          onSyncChanged: (enabled) =>
              workspace.setSyncEnabled(doc.id, enabled),
          onTap: () {
            workspace.selectNote(doc.id);
            _maybeDismiss();
          },
          onRename: () => _rename(context, workspace, doc),
          onDelete: () => _delete(context, workspace, doc),
          onHistory: () => showVersionHistory(context, doc),
        );
      },
    );
  }
}

enum _NoteMenu { rename, history, delete }

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    super.key,
    this.listIndex,
    required this.hit,
    required this.searching,
    required this.active,
    required this.syncEnabled,
    required this.onSyncChanged,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onHistory,
  });

  final int? listIndex;
  final NoteSearchHit hit;
  final bool searching;
  final bool active;
  final bool syncEnabled;
  final ValueChanged<bool> onSyncChanged;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final doc = hit.doc;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.outline;
    final subtitle = _subtitle(doc.text);

    return ListTile(
      selected: active,
      selectedTileColor: theme.colorScheme.primary.withValues(
        alpha: 0.08,
      ),
      leading: Icon(
        _leadingIcon(active, syncEnabled),
        color: active && syncEnabled
            ? theme.colorScheme.primary
            : (!syncEnabled ? muted : null),
      ),
      title: Text(
        doc.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: !syncEnabled ? theme.colorScheme.onSurface.withValues(alpha: 0.75) : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: !syncEnabled
            ? TextStyle(color: muted, fontSize: theme.textTheme.bodySmall?.fontSize)
            : null,
      ),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: syncEnabled ? 'Sync with peers' : 'Local only',
            child: Switch.adaptive(
              value: syncEnabled,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: onSyncChanged,
            ),
          ),
          if (!searching && listIndex != null)
            ReorderableDragStartListener(
              index: listIndex!,
              child: Icon(
                Icons.drag_handle,
                size: 20,
                color: muted,
              ),
            ),
          PopupMenuButton<_NoteMenu>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              switch (value) {
                case _NoteMenu.rename:
                  onRename();
                case _NoteMenu.history:
                  onHistory();
                case _NoteMenu.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: _NoteMenu.rename, child: Text('Rename')),
              PopupMenuItem(
                value: _NoteMenu.history,
                child: Text('Version history'),
              ),
              PopupMenuItem(value: _NoteMenu.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  IconData _leadingIcon(bool active, bool syncEnabled) {
    if (!syncEnabled) return Icons.cloud_off_outlined;
    return active ? Icons.edit_note : Icons.description_outlined;
  }

  String _subtitle(String text) {
    if (!syncEnabled) {
      if (searching) {
        final matchLine = hit.snippet.isEmpty
            ? '${hit.matchCount} match(es)'
            : '${hit.snippet}  ·  ${hit.matchCount} match(es)';
        return 'Local only · $matchLine';
      }
      return 'Local only';
    }
    if (searching) {
      return hit.snippet.isEmpty
          ? '${hit.matchCount} match(es)'
          : '${hit.snippet}  ·  ${hit.matchCount} match(es)';
    }
    return _firstLine(text);
  }

  String _firstLine(String text) {
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return 'Empty note';
  }
}
