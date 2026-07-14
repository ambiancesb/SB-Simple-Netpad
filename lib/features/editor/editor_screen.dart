import 'dart:async';

import 'package:code_text_field/code_text_field.dart' show CodeController, LineNumberStyle;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/find_replace.dart';
import 'package:netpad/core/ime_voice_gate.dart';
import 'package:netpad/core/shortcut_labels.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/features/editor/netpad_code_field.dart';
import 'package:netpad/features/entitlements/standard_gate.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/standard_features.dart';
import 'package:netpad/services/speech_input_service.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:netpad/theme/editor_colors.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.findVisible,
    required this.replaceMode,
    required this.onReplaceModeChanged,
    required this.onCloseFind,
    this.speechInput,
  });

  final bool findVisible;
  final bool replaceMode;
  final ValueChanged<bool> onReplaceModeChanged;
  final VoidCallback onCloseFind;
  final SpeechInputService? speechInput;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<AppPreferences>();

    return Selector<WorkspaceRepository, DocumentRepository?>(
      selector: (_, workspace) => workspace.active,
      builder: (context, document, _) {
        if (document == null) {
          return Center(child: Text(context.l10n.notesNoNoteSelected));
        }

        return _EditorBody(
          document: document,
          prefs: prefs,
          findVisible: widget.findVisible,
          replaceMode: widget.replaceMode,
          onReplaceModeChanged: widget.onReplaceModeChanged,
          onCloseFind: widget.onCloseFind,
          speechInput: widget.speechInput,
        );
      },
    );
  }
}

class _EditorBody extends StatefulWidget {
  const _EditorBody({
    required this.document,
    required this.prefs,
    required this.findVisible,
    required this.replaceMode,
    required this.onReplaceModeChanged,
    required this.onCloseFind,
    this.speechInput,
  });

  final DocumentRepository document;
  final AppPreferences prefs;
  final bool findVisible;
  final bool replaceMode;
  final ValueChanged<bool> onReplaceModeChanged;
  final VoidCallback onCloseFind;
  final SpeechInputService? speechInput;

  @override
  State<_EditorBody> createState() => _EditorBodyState();
}

class _EditorBodyState extends State<_EditorBody> {
  late final FocusNode _editorFocusNode;
  late String _textBeforeChange;
  bool _checkingImeVoice = false;

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(debugLabel: 'editorFocusNode');
    _textBeforeChange = widget.document.text;
    widget.document.controller.addListener(_onEditorTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editorFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant _EditorBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      oldWidget.document.controller.removeListener(_onEditorTextChanged);
      _textBeforeChange = widget.document.text;
      widget.document.controller.addListener(_onEditorTextChanged);
    }
  }

  @override
  void dispose() {
    widget.document.controller.removeListener(_onEditorTextChanged);
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onEditorTextChanged() {
    final document = widget.document;
    final after = document.controller.text;
    final before = _textBeforeChange;
    if (after == before) return;

    if (document.isApplyingProgrammatic) {
      _textBeforeChange = after;
      return;
    }

    final speech = widget.speechInput;
    if (speech != null && speech.isListening) {
      _textBeforeChange = after;
      return;
    }

    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.canUseVoiceInput(entitlements)) {
      _textBeforeChange = after;
      return;
    }

    final inserted = ImeVoiceGate.insertedSpan(before, after);
    if (inserted == null || !ImeVoiceGate.looksLikeVoiceDictation(inserted)) {
      _textBeforeChange = after;
      return;
    }

    if (_checkingImeVoice) return;
    _checkingImeVoice = true;
    unawaited(_blockUnauthorizedImeVoice(
      document: document,
      before: before,
      after: after,
      inserted: inserted,
    ));
  }

  Future<void> _blockUnauthorizedImeVoice({
    required DocumentRepository document,
    required String before,
    required String after,
    required String inserted,
  }) async {
    try {
      if (await ImeVoiceGate.looksLikePaste(inserted)) {
        if (document.controller.text == after) {
          _textBeforeChange = after;
        }
        return;
      }
      if (!mounted) return;
      if (document.controller.text != after) {
        _textBeforeChange = document.controller.text;
        return;
      }

      final caret = document.controller.selection.baseOffset
          .clamp(0, before.length);
      document.revertUnauthorizedEdit(before, caret: caret);
      _textBeforeChange = before;

      if (!mounted) return;
      await StandardGate.voiceInputAllowed(context);
    } finally {
      _checkingImeVoice = false;
    }
  }

  LineNumberStyle _lineNumberStyle(
    BuildContext context,
    double fontSize,
    EditorColors colors,
  ) {
    return LineNumberStyle(
      width: 48,
      textAlign: TextAlign.right,
      margin: 12,
      textStyle: TextStyle(
        fontFamily: kEditorFontFamily,
        fontSize: fontSize - 1,
        height: 1.4,
        color: colors.lineNumber,
      ),
    );
  }

  TextStyle _editorTextStyle(double fontSize, EditorColors colors) {
    return TextStyle(
      fontFamily: kEditorFontFamily,
      fontSize: fontSize,
      height: 1.4,
      color: colors.foreground,
    );
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    final prefs = widget.prefs;
    final brightness = Theme.of(context).brightness;
    final colors = prefs.skin.editorColors(brightness);

    return Column(
      children: [
        if (widget.speechInput != null)
          _DictationBar(service: widget.speechInput!),
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
          child: Builder(
            builder: (context) {
              final entitlements = context.watch<EntitlementService>();
              final limit = StandardFeatures.noteCharacterLimit(entitlements);
              return NetpadCodeField(
                key: ValueKey('editor-${document.id}'),
                controller: document.controller,
                focusNode: _editorFocusNode,
                lineNumbers: true,
                lineNumberStyle: _lineNumberStyle(
                  context,
                  prefs.fontSize,
                  colors,
                ),
                textStyle: _editorTextStyle(prefs.fontSize, colors),
                background: colors.background,
                cursorColor: colors.cursor,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: colors.cursor,
                  selectionColor: colors.selection,
                  selectionHandleColor: colors.cursor,
                ),
                wrap: prefs.wordWrap,
                horizontalScroll: !prefs.wordWrap,
                expands: true,
                inputFormatters: limit == null
                    ? null
                    : [LengthLimitingTextInputFormatter(limit)],
                onTap: () => _editorFocusNode.requestFocus(),
                onChanged: (_) => document.onLocalEdit(),
              );
            },
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
    final l10n = context.l10n;
    final label = _findQuery.text.isEmpty
        ? ''
        : _matches.isEmpty
        ? l10n.editorMatchNone
        : l10n.editorMatchCounter(_current + 1, _matches.length);

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
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: l10n.editorFindHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: _recompute,
                    onSubmitted: (_) => _step(1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  tooltip: l10n.editorPrevious,
                  onPressed: _matches.isEmpty ? null : () => _step(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  tooltip: l10n.editorNext,
                  onPressed: _matches.isEmpty ? null : () => _step(1),
                ),
                IconButton(
                  icon: Icon(
                    widget.replaceMode
                        ? Icons.find_replace
                        : Icons.find_replace_outlined,
                  ),
                  tooltip: widget.replaceMode
                      ? l10n.editorHideReplace(ShortcutLabels.findReplace)
                      : l10n.editorShowReplace(ShortcutLabels.findReplace),
                  onPressed: () =>
                      widget.onReplaceModeChanged(!widget.replaceMode),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.editorClose,
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
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.find_replace, size: 18),
                        hintText: l10n.editorReplaceHint,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _applyReplace(all: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed:
                        _matches.isEmpty ? null : () => _applyReplace(all: false),
                    child: Text(l10n.editorReplace),
                  ),
                  TextButton(
                    onPressed:
                        _matches.isEmpty ? null : () => _applyReplace(all: true),
                    child: Text(l10n.editorReplaceAll),
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

class _DictationBar extends StatelessWidget {
  const _DictationBar({required this.service});

  final SpeechInputService service;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        if (!service.isListening) return const SizedBox.shrink();
        final colorScheme = Theme.of(context).colorScheme;
        final preview = service.liveText.trim();
        return Material(
          color: colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.mic, size: 18, color: colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    preview.isEmpty ? context.l10n.editorListening : preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
