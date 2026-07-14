import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/shortcut_labels.dart';

void main() {
  test('ShortcutLabels exposes a find-replace chord', () {
    final label = ShortcutLabels.findReplace;
    expect(
      label == 'Option+Cmd+F' || label == 'Ctrl+H',
      isTrue,
      reason: 'unexpected find-replace label: $label',
    );
    expect(ShortcutLabels.mod == 'Cmd' || ShortcutLabels.mod == 'Ctrl', isTrue);
  });
}
