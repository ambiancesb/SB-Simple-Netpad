import 'package:flutter/material.dart';

/// Shared corner radii — prefer these over one-off [BorderRadius.circular] values.
abstract final class AppRadii {
  /// Compact chips, dense banners, small controls.
  static const double sm = 10;

  /// Search fields, list cards, filled inputs.
  static const double md = 14;

  /// Sheets, dialogs, featured panels, skin chips.
  static const double lg = 20;

  /// App icon / hero marks.
  static const double xl = 28;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);

  static const BorderRadius sheetTop =
      BorderRadius.vertical(top: Radius.circular(lg));
}

/// Shared spacing scale for padding and gaps.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}
