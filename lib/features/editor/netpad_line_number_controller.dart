import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/widgets.dart';

/// Line gutter controller that supports blank rows for soft-wrapped continuations.
class NetpadLineNumberController extends LineNumberController {
  NetpadLineNumberController(super.lineNumberBuilder);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final children = <InlineSpan>[];
    final list = text.split('\n');

    for (var k = 0; k < list.length; k++) {
      final el = list[k];
      if (el.isEmpty) {
        children.add(TextSpan(text: '', style: style));
      } else {
        final number = int.parse(el);
        var textSpan = TextSpan(text: el, style: style);
        if (lineNumberBuilder != null) {
          textSpan = lineNumberBuilder!(number, style);
        }
        children.add(textSpan);
      }
      if (k < list.length - 1) {
        children.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: children, style: style);
  }
}
