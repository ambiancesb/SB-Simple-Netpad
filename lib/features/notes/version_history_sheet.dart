import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/document_repository.dart';

/// Shows the local version history of [doc], letting the user restore a
/// snapshot that was clobbered by a remote edit or a file open.
Future<void> showVersionHistory(
  BuildContext context,
  DocumentRepository doc,
) async {
  final restored = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final history = doc.history;
      return DraftHistoryList(doc: doc, hasHistory: history.isNotEmpty);
    },
  );
  if (restored == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Version restored')),
    );
  }
}

class DraftHistoryList extends StatelessWidget {
  const DraftHistoryList({
    super.key,
    required this.doc,
    required this.hasHistory,
  });

  final DocumentRepository doc;
  final bool hasHistory;

  @override
  Widget build(BuildContext context) {
    final history = doc.history;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Version history · "${doc.title}"',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (!hasHistory)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No saved versions yet. Snapshots are kept automatically '
                  'before remote edits replace your text.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ListTile(
                      title: Text(entry.preview),
                      subtitle: Text(
                        '${entry.label} · '
                        '${_formatTime(entry.savedAt)} · '
                        '${entry.text.length} chars',
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          doc.restore(entry);
                          Navigator.pop(context, true);
                        },
                        child: const Text('Restore'),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}';
  }
}
