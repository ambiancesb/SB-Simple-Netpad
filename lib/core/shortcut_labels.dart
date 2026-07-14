import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Keyboard modifier / shortcut labels that match the host platform.
abstract final class ShortcutLabels {
  static bool get isApple {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isIOS;
  }

  /// Primary chord modifier shown in tooltips ("Cmd" on Apple, "Ctrl" elsewhere).
  static String get mod => isApple ? 'Cmd' : 'Ctrl';

  /// Find & Replace chord (avoids Cmd+H Hide on macOS).
  static String get findReplace =>
      isApple ? 'Option+Cmd+F' : 'Ctrl+H';
}
