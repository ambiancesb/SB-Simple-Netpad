import 'package:code_text_field/code_text_field.dart';
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
  late final FocusNode _editorFocusNode;

  @override
  void initState() {
    super.initState();
    _editorFocusNode = FocusNode(debugLabel: 'editorFocusNode');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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

    return CodeField(
      controller: document.controller,
      focusNode: _editorFocusNode,
      lineNumbers: true,
      lineNumberStyle: _lineNumberStyle,
      textStyle: _editorTextStyle,
      expands: true,
      onTap: () => _editorFocusNode.requestFocus(),
      onChanged: (_) => document.onLocalEdit(),
    );
  }
}
