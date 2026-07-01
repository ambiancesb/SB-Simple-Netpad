import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/find_replace.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.findVisible,
    required this.replaceMode,
    required this.onReplaceModeChanged,
    required this.onCloseFind,
  });

  final bool findVisible;
  final bool replaceMode;
  final ValueChanged<bool> onReplaceModeChanged;
  final VoidCallback onCloseFind;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final FocusNode _editorFocusNode;

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(debugLabel: 'editorFocusNode');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editorFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    super.dispose();
  }

  LineNumberStyle _lineNumberStyle(BuildContext context, double fontSize) {
    return LineNumberStyle(
      width: 48,
      textAlign: TextAlign.right,
      margin: 12,
      textStyle: TextStyle(
        fontFamily: kEditorFontFamily,
        fontSize: fontSize - 1,
        height: 1.4,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }

  TextStyle _editorTextStyle(double fontSize) {
    return TextStyle(
      fontFamily: kEditorFontFamily,
      fontSize: fontSize,
      height: 1.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceRepository>();
    final prefs = context.watch<AppPreferences>();
    final document = workspace.active;

    if (document == null) {
      return const Center(child: Text('No note selected'));
    }

    return Column(
      children: [
        if (widget.findVisible)
          _FindReplaceBar(
            key: ValueKey('find-${document.id}'),
            document: document,
            controller: document.controller,
            focusNode: _editorFocusNode,
            replaceMode: widget.replaceMode,
            onReplaceModeChanged: widget.onReplaceModeChanged,
            onClose: widget.onCloseFind,
          ),
        Expanded(
          child: CodeField(
            key: ValueKey('editor-${document.id}'),
            controller: document.controller,
            focusNode: _editorFocusNode,
            lineNumbers: true,
            lineNumberStyle: _lineNumberStyle(context, prefs.fontSize),
            textStyle: _editorTextStyle(prefs.fontSize),
            wrap: prefs.wordWrap,
            horizontalScroll: !prefs.wordWrap,
            expands: true,
            onTap: () => _editorFocusNode.requestFocus(),
            onChanged: (_) => document.onLocalEdit(),
          ),
        ),
      ],
    );
  }
}

/// In-note find/replace bar with match navigation.
class _FindReplaceBar extends StatefulWidget {
  const _FindReplaceBar({
    super.key,
    required this.document,
    required this.controller,
    required this.focusNode,
    required this.replaceMode,
    required this.onReplaceModeChanged,
    required this.onClose,
  });

  final DocumentRepository document;
  final CodeController controller;
  final FocusNode focusNode;
  final bool replaceMode;
  final ValueChanged<bool> onReplaceModeChanged;
  final VoidCallback onClose;

  @override
  State<_FindReplaceBar> createState() => _FindReplaceBarState();
}

class _FindReplaceBarState extends State<_FindReplaceBar> {
  final TextEditingController _findQuery = TextEditingController();
  final TextEditingController _replaceQuery = TextEditingController();
  final FocusNode _findFocus = FocusNode();
  final FocusNode _replaceFocus = FocusNode();
  List<int> _matches = const [];
  int _current = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusActiveField());
  }

  @override
  void didUpdateWidget(covariant _FindReplaceBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replaceMode != widget.replaceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusActiveField());
    }
  }

  void _focusActiveField() {
    if (!mounted) return;
    if (widget.replaceMode) {
      _replaceFocus.requestFocus();
    } else {
      _findFocus.requestFocus();
    }
  }

  @override
  void dispose() {
    _findQuery.dispose();
    _replaceQuery.dispose();
    _findFocus.dispose();
    _replaceFocus.dispose();
    super.dispose();
  }

  void _recompute(String raw) {
    final matches = FindReplace.matchOffsets(widget.controller.text, raw);
    setState(() {
      _matches = matches;
      _current = matches.isEmpty ? -1 : 0;
    });
    if (matches.isNotEmpty) _select(0);
  }

  void _step(int delta) {
    if (_matches.isEmpty) return;
    final next = (_current + delta) % _matches.length;
    setState(() => _current = next < 0 ? next + _matches.length : next);
    _select(_current);
  }

  void _select(int matchIndex) {
    final start = _matches[matchIndex];
    final end = start + _findQuery.text.length;
    widget.controller.selection = TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
    widget.focusNode.requestFocus();
  }

  void _applyReplace({required bool all}) {
    final needle = _findQuery.text;
    final replacement = _replaceQuery.text;
    if (needle.isEmpty) return;

    if (all) {
      final updated = FindReplace.replaceAll(
        widget.controller.text,
        needle,
        replacement,
      );
      if (updated == widget.controller.text) return;
      widget.controller.text = updated;
      widget.document.onLocalEdit();
      _recompute(needle);
      return;
    }

    if (_matches.isEmpty || _current < 0) return;
    final result = FindReplace.replaceOne(
      text: widget.controller.text,
      needle: needle,
      replacement: replacement,
      matches: _matches,
      matchIndex: _current,
    );
    widget.controller.text = result.text;
    widget.document.onLocalEdit();
    final nextMatches = FindReplace.matchOffsets(result.text, needle);
    setState(() {
      _matches = nextMatches;
      if (nextMatches.isEmpty) {
        _current = -1;
      } else {
        _current = result.nextMatchIndex.clamp(0, nextMatches.length - 1);
        _select(_current);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = _findQuery.text.isEmpty
        ? ''
        : _matches.isEmpty
        ? '0/0'
        : '${_current + 1}/${_matches.length}';

    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _findQuery,
                    focusNode: _findFocus,
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search, size: 18),
                      hintText: 'Find',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _recompute,
                    onSubmitted: (_) => _step(1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  tooltip: 'Previous',
                  onPressed: _matches.isEmpty ? null : () => _step(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  tooltip: 'Next',
                  onPressed: _matches.isEmpty ? null : () => _step(1),
                ),
                IconButton(
                  icon: Icon(
                    widget.replaceMode
                        ? Icons.find_replace
                        : Icons.find_replace_outlined,
                  ),
                  tooltip: widget.replaceMode
                      ? 'Hide replace (Ctrl+H)'
                      : 'Show replace (Ctrl+H)',
                  onPressed: () =>
                      widget.onReplaceModeChanged(!widget.replaceMode),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: widget.onClose,
                ),
              ],
            ),
            if (widget.replaceMode) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replaceQuery,
                      focusNode: _replaceFocus,
                      decoration: const InputDecoration(
                        isDense: true,
                        prefixIcon: Icon(Icons.find_replace, size: 18),
                        hintText: 'Replace with',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _applyReplace(all: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        _matches.isEmpty ? null : () => _applyReplace(all: false),
                    child: const Text('Replace'),
                  ),
                  TextButton(
                    onPressed:
                        _matches.isEmpty ? null : () => _applyReplace(all: true),
                    child: const Text('All'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
