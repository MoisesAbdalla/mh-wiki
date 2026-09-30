import 'package:flutter/painting.dart';

/// Color tokens of the "Caderno do Caçador" identity (prototype A).
/// Contrast ratios are documented in specs/002-visual-identity/research.md (R8).
abstract final class HunterPalette {
  static const background = Color(0xFF16120E);
  static const panel = Color(0xFF1F1812);
  static const panelRaised = Color(0xFF221B14);
  static const panelHighlight = Color(0xFF2C2215);

  static const border = Color(0xFF5A4526);
  static const borderSubtle = Color(0xFF3B2E1D);

  static const gold = Color(0xFFE0BD6A);
  static const goldBright = Color(0xFFF3D68E);

  static const text = Color(0xFFEFE4C8);
  static const textMuted = Color(0xFFB9A67F);
  static const textOnGold = Color(0xFF1C150D);
  static const textDisabled = Color(0xFF8A7652);

  static const fire = Color(0xFFF07A4A);
  static const water = Color(0xFF6FB2F0);
  static const thunder = Color(0xFFF0CF4A);
  static const ice = Color(0xFFA9E2F2);
  static const dragon = Color(0xFFC592F0);
}
