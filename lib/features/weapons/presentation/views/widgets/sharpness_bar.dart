import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/weapons/domain/entities/sharpness.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The game's sharpness colours, red to purple.
const sharpnessColors = [
  Color(0xFFD9534A),
  Color(0xFFE8913A),
  Color(0xFFE8D33A),
  Color(0xFF6FBF4A),
  Color(0xFF4A8FE8),
  Color(0xFFF2F2EE),
  Color(0xFFB05AE8),
];

/// One sharpness bar: each segment is as wide as its units over
/// [Sharpness.maxUnits]; the rest stays empty.
class SharpnessBar extends StatelessWidget {
  const SharpnessBar({required this.label, required this.units, super.key});

  final String label;
  final List<int> units;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = [
      l10n.sharpnessRed,
      l10n.sharpnessOrange,
      l10n.sharpnessYellow,
      l10n.sharpnessGreen,
      l10n.sharpnessBlue,
      l10n.sharpnessWhite,
      l10n.sharpnessPurple,
    ];
    final spoken = [
      for (final (i, u) in units.indexed)
        if (u > 0) '${names[i]} $u',
    ].join(', ');

    return Semantics(
      label: l10n.sharpnessSemantics(label, spoken),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: HunterPalette.textMuted),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  height: 12,
                  color: HunterPalette.background,
                  child: Row(
                    children: [
                      for (final (i, u) in units.indexed)
                        if (u > 0)
                          SizedBox(
                            key: ValueKey('sharpness-$i'),
                            width: width * u / Sharpness.maxUnits,
                            // An explicit height: a childless box in a Row
                            // would collapse to zero.
                            height: 12,
                            child: ColoredBox(color: sharpnessColors[i]),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
