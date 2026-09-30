import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';

/// Font families bundled in pubspec.yaml.
abstract final class HunterFonts {
  static const display = 'Cinzel';
  static const body = 'AlegreyaSans';
}

/// Cinzel style for titles, section headings and tabs. Cinzel is a variable
/// font, so the weight is set through the `wght` axis.
TextStyle hunterDisplay({
  double size = 14,
  double weight = 700,
  Color color = HunterPalette.gold,
  double letterSpacing = 2,
}) => TextStyle(
  fontFamily: HunterFonts.display,
  fontSize: size,
  fontWeight: weight >= 600 ? FontWeight.w700 : FontWeight.w500,
  fontVariations: [FontVariation('wght', weight)],
  color: color,
  letterSpacing: letterSpacing,
);

/// The only theme of the app: dark "Caderno do Caçador" (FR-001).
ThemeData buildHunterTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: HunterPalette.gold,
    onPrimary: HunterPalette.textOnGold,
    secondary: HunterPalette.goldBright,
    onSecondary: HunterPalette.textOnGold,
    error: Color(0xFFF2A08A),
    onError: HunterPalette.textOnGold,
    surface: HunterPalette.panel,
    onSurface: HunterPalette.text,
    onSurfaceVariant: HunterPalette.textMuted,
    surfaceContainerHighest: HunterPalette.panelRaised,
    surfaceContainerHigh: HunterPalette.panelRaised,
    outline: HunterPalette.border,
    outlineVariant: HunterPalette.borderSubtle,
    secondaryContainer: HunterPalette.panelRaised,
    onSecondaryContainer: HunterPalette.gold,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: HunterFonts.body,
  );
  final text = base.textTheme.apply(
    fontFamily: HunterFonts.body,
    bodyColor: HunterPalette.text,
    displayColor: HunterPalette.text,
  );
  const square = RoundedRectangleBorder();
  const frame = BorderSide(color: HunterPalette.border);

  return base.copyWith(
    scaffoldBackgroundColor: HunterPalette.background,
    canvasColor: HunterPalette.background,
    textTheme: text.copyWith(
      headlineSmall: hunterDisplay(size: 26, letterSpacing: 1),
      titleLarge: hunterDisplay(size: 20, letterSpacing: 2),
      titleMedium: hunterDisplay(size: 15),
      titleSmall: hunterDisplay(size: 13),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: HunterPalette.background,
      foregroundColor: HunterPalette.gold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const Border(bottom: frame),
      titleTextStyle: hunterDisplay(size: 20, letterSpacing: 3),
    ),
    dividerTheme: const DividerThemeData(color: HunterPalette.border, space: 1),
    cardTheme: const CardThemeData(
      color: HunterPalette.panel,
      shape: RoundedRectangleBorder(side: frame),
      elevation: 0,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: HunterPalette.panelRaised,
      labelStyle: const TextStyle(color: HunterPalette.text),
      side: frame,
      shape: square,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: HunterPalette.text,
      iconColor: HunterPalette.gold,
      selectedColor: HunterPalette.goldBright,
      selectedTileColor: HunterPalette.panelHighlight,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: HunterPalette.panelRaised,
      hintStyle: TextStyle(color: HunterPalette.textMuted),
      prefixIconColor: HunterPalette.gold,
      suffixIconColor: HunterPalette.gold,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: frame,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: frame,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: HunterPalette.gold, width: 1.5),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? HunterPalette.gold
            : HunterPalette.textMuted,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: HunterPalette.gold,
        foregroundColor: HunterPalette.textOnGold,
        shape: square,
        minimumSize: const Size(48, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HunterPalette.gold,
        side: frame,
        shape: square,
        minimumSize: const Size(48, 48),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: HunterPalette.gold),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: HunterPalette.gold,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: HunterPalette.panelRaised,
      contentTextStyle: TextStyle(color: HunterPalette.text),
      shape: RoundedRectangleBorder(side: frame),
    ),
    bannerTheme: const MaterialBannerThemeData(
      backgroundColor: HunterPalette.panelRaised,
      contentTextStyle: TextStyle(color: HunterPalette.text),
    ),
  );
}
