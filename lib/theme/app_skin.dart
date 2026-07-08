import 'package:flutter/material.dart';
import 'package:netpad/theme/editor_colors.dart';

/// Named accent palettes for app chrome and the editor text area.
enum AppSkin {
  defaultBlue,
  ocean,
  forest,
  sunset,
  slate,
}

class _SkinPalette {
  const _SkinPalette({
    required this.seed,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.lightSurface,
    required this.lightSurfaceContainer,
    required this.lightBackground,
    required this.darkSurface,
    required this.darkSurfaceContainer,
    required this.darkBackground,
    required this.editorLightBg,
    required this.editorLightFg,
    required this.editorDarkBg,
    required this.editorDarkFg,
    required this.editorLightGutter,
    required this.editorDarkGutter,
  });

  final Color seed;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color lightSurface;
  final Color lightSurfaceContainer;
  final Color lightBackground;
  final Color darkSurface;
  final Color darkSurfaceContainer;
  final Color darkBackground;
  final Color editorLightBg;
  final Color editorLightFg;
  final Color editorDarkBg;
  final Color editorDarkFg;
  final Color editorLightGutter;
  final Color editorDarkGutter;
}

const _palettes = <AppSkin, _SkinPalette>{
  AppSkin.defaultBlue: _SkinPalette(
    seed: Color(0xFF2563EB),
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF3B82F6),
    tertiary: Color(0xFF7C3AED),
    lightSurface: Color(0xFFF8FAFF),
    lightSurfaceContainer: Color(0xFFE8EEFF),
    lightBackground: Color(0xFFEFF4FF),
    darkSurface: Color(0xFF0F172A),
    darkSurfaceContainer: Color(0xFF1E293B),
    darkBackground: Color(0xFF0B1220),
    editorLightBg: Color(0xFFF7F9FF),
    editorLightFg: Color(0xFF0F172A),
    editorDarkBg: Color(0xFF0B1220),
    editorDarkFg: Color(0xFFE2E8F0),
    editorLightGutter: Color(0xFF64748B),
    editorDarkGutter: Color(0xFF64748B),
  ),
  AppSkin.ocean: _SkinPalette(
    seed: Color(0xFF0D9488),
    primary: Color(0xFF0F766E),
    secondary: Color(0xFF06B6D4),
    tertiary: Color(0xFF0284C7),
    lightSurface: Color(0xFFE6FFFA),
    lightSurfaceContainer: Color(0xFFB2F5EA),
    lightBackground: Color(0xFFCCFBF1),
    darkSurface: Color(0xFF042F2E),
    darkSurfaceContainer: Color(0xFF0F4C4A),
    darkBackground: Color(0xFF022C22),
    editorLightBg: Color(0xFFE0F7F4),
    editorLightFg: Color(0xFF134E4A),
    editorDarkBg: Color(0xFF021F1C),
    editorDarkFg: Color(0xFF99F6E4),
    editorLightGutter: Color(0xFF0F766E),
    editorDarkGutter: Color(0xFF5EEAD4),
  ),
  AppSkin.forest: _SkinPalette(
    seed: Color(0xFF16A34A),
    primary: Color(0xFF15803D),
    secondary: Color(0xFF65A30D),
    tertiary: Color(0xFFA16207),
    lightSurface: Color(0xFFF0FDF4),
    lightSurfaceContainer: Color(0xFFBBF7D0),
    lightBackground: Color(0xFFDCFCE7),
    darkSurface: Color(0xFF052E16),
    darkSurfaceContainer: Color(0xFF14532D),
    darkBackground: Color(0xFF031A0E),
    editorLightBg: Color(0xFFE8F8EC),
    editorLightFg: Color(0xFF14532D),
    editorDarkBg: Color(0xFF04140A),
    editorDarkFg: Color(0xFFBBF7D0),
    editorLightGutter: Color(0xFF3F6212),
    editorDarkGutter: Color(0xFF86EFAC),
  ),
  AppSkin.sunset: _SkinPalette(
    seed: Color(0xFFEA580C),
    primary: Color(0xFFC2410C),
    secondary: Color(0xFFE11D48),
    tertiary: Color(0xFFD97706),
    lightSurface: Color(0xFFFFF7ED),
    lightSurfaceContainer: Color(0xFFFED7AA),
    lightBackground: Color(0xFFFFEDD5),
    darkSurface: Color(0xFF431407),
    darkSurfaceContainer: Color(0xFF7C2D12),
    darkBackground: Color(0xFF2A0E05),
    editorLightBg: Color(0xFFFFF1E6),
    editorLightFg: Color(0xFF7C2D12),
    editorDarkBg: Color(0xFF1C0A04),
    editorDarkFg: Color(0xFFFED7AA),
    editorLightGutter: Color(0xFFC2410C),
    editorDarkGutter: Color(0xFFFB923C),
  ),
  AppSkin.slate: _SkinPalette(
    seed: Color(0xFF64748B),
    primary: Color(0xFF334155),
    secondary: Color(0xFF475569),
    tertiary: Color(0xFF0F172A),
    lightSurface: Color(0xFFF8FAFC),
    lightSurfaceContainer: Color(0xFFE2E8F0),
    lightBackground: Color(0xFFF1F5F9),
    darkSurface: Color(0xFF0F172A),
    darkSurfaceContainer: Color(0xFF1E293B),
    darkBackground: Color(0xFF020617),
    editorLightBg: Color(0xFFF1F5F9),
    editorLightFg: Color(0xFF0F172A),
    editorDarkBg: Color(0xFF020617),
    editorDarkFg: Color(0xFFCBD5E1),
    editorLightGutter: Color(0xFF64748B),
    editorDarkGutter: Color(0xFF94A3B8),
  ),
};

extension AppSkinX on AppSkin {
  String get label => switch (this) {
    AppSkin.defaultBlue => 'Default',
    AppSkin.ocean => 'Ocean',
    AppSkin.forest => 'Forest',
    AppSkin.sunset => 'Sunset',
    AppSkin.slate => 'Slate',
  };

  Color get seedColor => _palettes[this]!.seed;

  _SkinPalette get _p => _palettes[this]!;

  ThemeData themeData(Brightness brightness) {
    final p = _p;
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: p.seed,
      brightness: brightness,
      primary: p.primary,
      secondary: p.secondary,
      tertiary: p.tertiary,
      surface: isLight ? p.lightSurface : p.darkSurface,
      surfaceContainerHighest:
          isLight ? p.lightSurfaceContainer : p.darkSurfaceContainer,
    ).copyWith(
      surfaceContainerLow:
          isLight ? p.lightBackground : p.darkBackground,
      surfaceContainer:
          isLight ? p.lightSurfaceContainer : p.darkSurfaceContainer,
      surfaceContainerHigh:
          isLight ? p.lightSurfaceContainer : p.darkSurfaceContainer,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor:
          isLight ? p.lightBackground : p.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? p.primary : p.darkSurfaceContainer,
        foregroundColor: isLight ? Colors.white : scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      chipTheme: ChipThemeData(
        selectedColor: p.primary.withValues(alpha: isLight ? 0.22 : 0.35),
        checkmarkColor: p.primary,
        side: BorderSide(color: p.primary.withValues(alpha: 0.45)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return p.primary;
            }
            return isLight
                ? p.lightSurfaceContainer
                : p.darkSurfaceContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return isLight ? p.primary : scheme.onSurface;
          }),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return p.primary.withValues(alpha: 0.45);
          }
          return null;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.primary,
      ),
      dividerTheme: DividerThemeData(
        color: p.primary.withValues(alpha: isLight ? 0.18 : 0.3),
      ),
    );
  }

  /// Strongly tinted notepad colors for this skin + brightness.
  EditorColors editorColors(Brightness brightness) {
    final p = _p;
    final isLight = brightness == Brightness.light;
    return EditorColors(
      background: isLight ? p.editorLightBg : p.editorDarkBg,
      foreground: isLight ? p.editorLightFg : p.editorDarkFg,
      lineNumber: isLight ? p.editorLightGutter : p.editorDarkGutter,
      cursor: p.primary,
      selection: p.primary.withValues(alpha: isLight ? 0.28 : 0.4),
    );
  }
}
