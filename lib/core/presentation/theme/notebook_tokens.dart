import 'package:flutter/widgets.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';

/// Font families of the "Caderninho" look (005 research R1), bundled in
/// pubspec.yaml under the SIL Open Font License.
abstract final class NotebookFonts {
  /// Titles: brand, text tabs, monster names, section titles, stamp.
  static const title = 'IMFellEnglishSC';

  /// Numbers: HP, ruler values, rates, section numbers, counts.
  static const number = 'AveriaSerifLibre';

  /// Body text.
  static const body = 'AtkinsonHyperlegible';
}

/// Spacing rhythm: generous between sections, tight inside them (005 FR-003).
abstract final class Space {
  static const section = 32.0;

  /// Gap between cards (detail sections, list rows).
  static const card = 12.0;
  static const title = 12.0;
  static const row = 8.0;

  /// Horizontal page padding; narrower on small screens.
  static double gutter(double width) => width < 360 ? 16 : 22;
}

/// The single content transition of the app (005 FR-015, research R9).
abstract final class Motion {
  static const switchDuration = Duration(milliseconds: 220);
  static const curve = Curves.easeOutCubic;

  /// [switchDuration], or zero when the platform asks for reduced motion.
  static Duration duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : switchDuration;
}

/// Title style in IM Fell English SC. The family has a single weight, so
/// hierarchy comes from size and colour only.
TextStyle notebookTitle({
  double size = 20,
  Color color = HunterPalette.text,
  double height = 1.15,
}) => TextStyle(
  fontFamily: NotebookFonts.title,
  fontSize: size,
  fontWeight: FontWeight.w400,
  color: color,
  height: height,
);

/// Number style in Averia Serif Libre with tabular figures, so columns of
/// values line up.
TextStyle notebookNumber({
  double size = 14,
  Color color = HunterPalette.text,
  bool bold = false,
}) => TextStyle(
  fontFamily: NotebookFonts.number,
  fontSize: size,
  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
  color: color,
  fontFeatures: const [FontFeature.tabularFigures()],
  height: 1.1,
);
