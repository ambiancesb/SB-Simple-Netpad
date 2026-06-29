import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.findVisible,
    required this.onCloseFind,
  });

  final bool findVisible;
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

  static final _lineNumberStyle = LineNumberStyle(
    width: 48,
    textAlign: TextAlign.right,
    margin: 12,
    textStyle: TextStyle(
      fontFamily: kEditorFontFamily,
      fontSize: 13,
      height: 1.4,
      color: Color(0xFF6B7280),
    ),
  );

  static const _editorTextStyle = TextStyle(
    fontFamily: kEditorFontFamily,
    fontSize: 14,
    height: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceRepository>();
    final document = workspace.active;

    if (document == null) {
      return const Center(child: Text('No note selected'));
    }

    return Column(
      children: [
        if (widget.findVisible)
          _FindBar(
            key: ValueKey('find-${document.id}'),
            controller: document.controller,
            focusNode: _editorFocusNode,
            onClose: widget.onCloseFind,
          ),
        Expanded(
          child: CodeField(
            key: ValueKey('editor-${document.id}'),
            controller: document.controller,
            focusNode: _editorFocusNode,
            lineNumbers: true,
            lineNumberStyle: _lineNumberStyle,
            textStyle: _editorTextStyle,
            expands: true,
            onTap: () => _editorFocusNode.requestFocus(),
            onChanged: (_) => document.onLocalEdit(),
          ),
        ),
      ],
    );
  }
}

/// In-note find bar: counts matches and jumps the selection between them.
class _FindBar extends StatefulWidget {
  const _FindBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onClose,
  });

  final CodeController controller;
  final FocusNode focusNode;
  final VoidCallback onClose;

  @override
  State<_FindBar> createState() => _FindBarState();
}

class _FindBarState extends State<_FindBar> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();
  List<int> _matches = const [];
  int _current = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _queryFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _recompute(String raw) {
    final needle = raw.toLowerCase();
    final matches = <int>[];
    if (needle.isNotEmpty) {
      final haystack = widget.controller.text.toLowerCase();
      var index = haystack.indexOf(needle);
      while (index != -1) {
        matches.add(index);
        index = haystack.indexOf(needle, index + needle.length);
      }
    }
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
    final end = start + _query.text.length;
    widget.controller.selection = TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final label = _query.text.isEmpty
        ? ''
        : _matches.isEmpty
        ? '0/0'
        : '${_current + 1}/${_matches.length}';

    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _query,
                focusNode: _queryFocus,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'Find in note',
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
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }
}
