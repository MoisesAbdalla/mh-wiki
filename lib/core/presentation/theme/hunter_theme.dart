import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';

/// The only theme of the app: dark "Caderninho" (002 FR-001, 005).
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
    fontFamily: NotebookFonts.body,
  );
  final text = base.textTheme.apply(
    fontFamily: NotebookFonts.body,
    bodyColor: HunterPalette.text,
    displayColor: HunterPalette.text,
  );
  const square = RoundedRectangleBorder();
  const frame = BorderSide(color: HunterPalette.border);

  return base.copyWith(
    scaffoldBackgroundColor: HunterPalette.background,
    canvasColor: HunterPalette.background,
    textTheme: text.copyWith(
      headlineSmall: notebookTitle(size: 28),
      titleLarge: notebookTitle(size: 22),
      titleMedium: notebookTitle(size: 18),
      titleSmall: notebookTitle(size: 16),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 16),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14),
      bodySmall: text.bodySmall?.copyWith(
        fontSize: 12.5,
        color: HunterPalette.textMuted,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: HunterPalette.background,
      foregroundColor: HunterPalette.gold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: notebookTitle(size: 26),
    ),
    dividerTheme: const DividerThemeData(
      color: HunterPalette.borderSubtle,
      space: 1,
      thickness: 1,
    ),
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
    // A search line, not a box (005 FR-003).
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      hintStyle: TextStyle(color: HunterPalette.textMuted),
      prefixIconColor: HunterPalette.gold,
      suffixIconColor: HunterPalette.gold,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: HunterPalette.border),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: HunterPalette.border),
      ),
      focusedBorder: UnderlineInputBorder(
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
