import 'package:code_text_field/code_text_field.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  static const _debugLogPath =
      '/home/spencer/Coding Projects/SB-Simple-Netpad/.cursor/debug-be0b4d.log';

  late final FocusNode _editorFocusNode;

  // #region agent log
  void _debugLog(
    String hypothesisId,
    String message,
    Map<String, dynamic> data, {
    String runId = 'run1',
  }) {
    final payload = {
      'sessionId': 'be0b4d',
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': 'lib/features/editor/editor_screen.dart',
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    try {
      File(_debugLogPath).writeAsStringSync(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } catch (_) {
      // No-op in case debug log path is unavailable.
    }
  }
  // #endregion

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(debugLabel: 'editorFocusNode');
    _editorFocusNode.addListener(() {
      // #region agent log
      _debugLog(
        'H1',
        'focusNode listener fired',
        {
          'hasFocus': _editorFocusNode.hasFocus,
          'contextMounted': mounted,
        },
      );
      // #endregion
    });
    // #region agent log
    _debugLog(
      'H2',
      'editor initState',
      {
        'focusNodeCreated': true,
      },
    );
    // #endregion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // #region agent log
        _debugLog(
          'H3',
          'postFrame requesting focus',
          {
            'hasFocusBefore': _editorFocusNode.hasFocus,
          },
        );
        // #endregion
        _editorFocusNode.requestFocus();
      }
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
    final document = context.watch<DocumentRepository>();

    // #region agent log
    _debugLog(
      'H4',
      'editor build',
      {
        'hasFocus': _editorFocusNode.hasFocus,
        'textLength': document.controller.text.length,
      },
    );
    // #endregion

    return CodeField(
      controller: document.controller,
      focusNode: _editorFocusNode,
      lineNumbers: true,
      lineNumberStyle: _lineNumberStyle,
      textStyle: _editorTextStyle,
      expands: true,
      onTap: () {
        // #region agent log
        _debugLog(
          'H5',
          'editor onTap requesting focus',
          {
            'hasFocusBefore': _editorFocusNode.hasFocus,
          },
        );
        // #endregion
        _editorFocusNode.requestFocus();
      },
      onChanged: (_) => document.onLocalEdit(),
    );
  }
}
