import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:netpad/features/editor/netpad_line_number_controller.dart';
import 'package:netpad/features/editor/wrap_line_metrics.dart';

/// [CodeField] fork that keeps line numbers aligned when [wrap] is enabled.
class NetpadCodeField extends StatefulWidget {
  final SmartQuotesType? smartQuotesType;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final bool wrap;
  final CodeController controller;
  final LineNumberStyle lineNumberStyle;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  final bool? enabled;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool isDense;
  final TextSelectionControls? selectionControls;
  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final bool lineNumbers;
  final bool horizontalScroll;

  /// Optional input formatters (e.g. free-tier character limit).
  final List<TextInputFormatter>? inputFormatters;

  const NetpadCodeField({
    super.key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.lineNumberStyle = const LineNumberStyle(),
    this.enabled,
    this.onTap,
    this.readOnly = false,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
    this.isDense = false,
    this.smartQuotesType,
    this.keyboardType,
    this.lineNumbers = true,
    this.horizontalScroll = true,
    this.selectionControls,
    this.inputFormatters,
  });

  @override
  State<NetpadCodeField> createState() => _NetpadCodeFieldState();
}

class _NetpadCodeFieldState extends State<NetpadCodeField> {
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  NetpadLineNumberController? _numberController;

  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  FocusNode? _focusNode;
  String longestLine = '';
  double? _wrapContentWidth;

  static bool get _mobileTextInput =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = NetpadLineNumberController(widget.lineNumberBuilder);
    widget.controller.addListener(_onTextChanged);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.onKeyEvent = _onKeyEvent;

    _updateLineNumbers();
  }

  @override
  void didUpdateWidget(covariant NetpadCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wrap != widget.wrap ||
        oldWidget.textStyle != widget.textStyle) {
      _updateLineNumbers();
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.readOnly) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      final sel = widget.controller.selection;
      final updated = widget.controller.text.replaceRange(
        sel.start,
        sel.end,
        '\t',
      );
      widget.controller.text = updated;
      widget.onChanged?.call(updated);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _numberController?.dispose();
    _keyboardVisibilitySubscription?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _updateLineNumbers();
  }

  TextStyle _layoutTextStyle(BuildContext context) {
    const rootKey = 'root';
    final scheme = Theme.of(context).colorScheme;
    final styles = CodeTheme.of(context)?.styles;

    var textStyle = widget.textStyle ?? const TextStyle();
    return textStyle.copyWith(
      color: textStyle.color ?? styles?[rootKey]?.color ?? scheme.onSurface,
      fontSize: textStyle.fontSize ?? 16.0,
    );
  }

  void _updateLineNumbers([TextStyle? layoutTextStyle]) {
    final logicalLines = widget.controller.text.split('\n');
    final textStyle = layoutTextStyle ?? widget.textStyle ?? const TextStyle();

    final rows = widget.wrap && _wrapContentWidth != null
        ? wrapAwareLineNumbers(
            logicalLines: logicalLines,
            textStyle: textStyle,
            contentWidth: _wrapContentWidth!,
          )
        : [for (var i = 0; i < logicalLines.length; i++) '${i + 1}'];

    _numberController?.text = rows.join('\n');

    longestLine = '';
    for (final line in logicalLines) {
      if (line.length > longestLine.length) longestLine = line;
    }

    if (mounted) setState(() {});
  }

  void _scheduleWrapWidthUpdate(double width, TextStyle textStyle) {
    if (_wrapContentWidth == width) return;
    _wrapContentWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateLineNumbers(textStyle);
    });
  }

  Widget _wrapInScrollView(
    Widget codeField,
    TextStyle textStyle,
    double minWidth,
  ) {
    final leftPad = widget.lineNumberStyle.margin / 2;
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0,
              minWidth: max(minWidth - leftPad, 0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(longestLine, style: textStyle),
            ),
          ),
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: leftPad,
        right: widget.padding.right,
      ),
      scrollDirection: Axis.horizontal,
      physics: widget.horizontalScroll
          ? null
          : const NeverScrollableScrollPhysics(),
      child: intrinsic,
    );
  }

  static const _editorInputDecoration = InputDecoration(
    filled: false,
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
  );

  @override
  Widget build(BuildContext context) {
    const rootKey = 'root';
    final scheme = Theme.of(context).colorScheme;
    final styles = CodeTheme.of(context)?.styles;
    Color? backgroundCol = widget.background ??
        styles?[rootKey]?.backgroundColor ??
        scheme.surface;

    if (widget.decoration != null) {
      backgroundCol = null;
    }

    final textStyle = _layoutTextStyle(context);

    var numberTextStyle =
        widget.lineNumberStyle.textStyle ?? const TextStyle();
    final numberColor =
        (styles?[rootKey]?.color ?? scheme.onSurface).withValues(alpha: 0.55);

    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
      height: textStyle.height,
    );

    final cursorColor =
        widget.cursorColor ?? styles?[rootKey]?.color ?? scheme.primary;

    TextField? lineNumberCol;
    Container? numberCol;

    if (widget.lineNumbers) {
      lineNumberCol = TextField(
        smartQuotesType: widget.smartQuotesType,
        scrollPadding: widget.padding,
        style: numberTextStyle,
        controller: _numberController,
        enabled: false,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        selectionControls: widget.selectionControls,
        expands: widget.expands,
        scrollController: _numberScroll,
        decoration: _editorInputDecoration.copyWith(
          isDense: widget.isDense,
        ),
        textAlign: widget.lineNumberStyle.textAlign,
      );

      numberCol = Container(
        width: widget.lineNumberStyle.width,
        padding: EdgeInsets.only(
          left: widget.padding.left,
          right: widget.lineNumberStyle.margin / 2,
        ),
        color: widget.lineNumberStyle.background,
        child: lineNumberCol,
      );
    }

    final codeField = TextField(
      keyboardType: _mobileTextInput
          ? TextInputType.multiline
          : widget.keyboardType,
      smartQuotesType: _mobileTextInput
          ? SmartQuotesType.enabled
          : widget.smartQuotesType,
      textCapitalization: _mobileTextInput
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      textInputAction:
          _mobileTextInput ? TextInputAction.newline : TextInputAction.newline,
      focusNode: _focusNode,
      onTap: widget.onTap,
      scrollPadding: widget.padding,
      style: textStyle,
      controller: widget.controller,
      minLines: widget.minLines,
      selectionControls: widget.selectionControls,
      maxLines: widget.wrap ? null : widget.maxLines,
      expands: widget.expands,
      scrollController: _codeScroll,
      inputFormatters: widget.inputFormatters,
      decoration: _editorInputDecoration.copyWith(
        isDense: widget.isDense,
      ),
      cursorColor: cursorColor,
      autocorrect: _mobileTextInput,
      enableSuggestions: _mobileTextInput,
      spellCheckConfiguration: _mobileTextInput
          ? const SpellCheckConfiguration(
              misspelledTextStyle: TextStyle(decoration: TextDecoration.underline),
            )
          : null,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
    );

    final editorTheme = Theme.of(context).copyWith(
      textSelectionTheme: widget.textSelectionTheme,
      // Keep editor TextFields free of form-field contentPadding from the skin.
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
      ),
    );

    final codeCol = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (widget.wrap) {
          final inset = editorFieldContentPaddingHorizontal(context);
          _scheduleWrapWidthUpdate(
            max(constraints.maxWidth - inset, 0),
            textStyle,
          );
          return codeField;
        }
        return _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
      },
    );

    return Theme(
      data: editorTheme,
      child: Container(
        decoration: widget.decoration,
        color: backgroundCol,
        padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lineNumbers && numberCol != null) numberCol,
            Expanded(child: codeCol),
          ],
        ),
      ),
    );
  }
}
