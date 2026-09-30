import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/star_rating.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// General weaknesses as a grid of five element cells, the most effective
/// framed (FR-008, 002 FR-006), plus per-state blocks (FR-008a).
class WeaknessSection extends StatelessWidget {
  const WeaknessSection({
    required this.profile,
    required this.language,
    super.key,
  });

  final WeaknessProfile profile;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.sectionWeaknesses,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ElementGrid(
            values: profile.general,
            highlighted: profile.mostEffective,
          ),
          if (profile.states.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              l10n.weaknessByState,
              style: hunterDisplay(size: 13, color: HunterPalette.textMuted),
            ),
            for (final state in profile.states) ...[
              const SizedBox(height: 12),
              Text(
                state.name.resolve(language),
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: HunterPalette.text),
              ),
              const SizedBox(height: 6),
              _ElementGrid(values: state.values, highlighted: const {}),
            ],
          ],
        ],
      ),
    );
  }
}

/// Five cells in one row; three per row when the space is narrow or the text
/// is enlarged, so nothing overflows (U1 of the 002 analysis).
class _ElementGrid extends StatelessWidget {
  const _ElementGrid({required this.values, required this.highlighted});

  final Map<ElementType, Effectiveness> values;
  final Set<ElementType> highlighted;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth < 300 || textScale > 1.3 ? 3 : 5;
        // Clamped: during route transitions the width can be ~0.
        final width = math.max(
          0.0,
          (constraints.maxWidth - _gap * (perRow - 1)) / perRow - 0.01,
        );
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final element in ElementType.values)
              SizedBox(
                width: width,
                child: WeaknessCell(
                  element: element,
                  effectiveness: values[element] ?? Effectiveness.none,
                  highlighted: highlighted.contains(element),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One element of the weakness grid: icon, name and rating.
class WeaknessCell extends StatelessWidget {
  const WeaknessCell({
    required this.element,
    required this.effectiveness,
    required this.highlighted,
    super.key,
  });

  final ElementType element;
  final Effectiveness effectiveness;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final name = AppLocalizations.of(context).elementName(element);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: highlighted ? HunterPalette.panelHighlight : null,
        border: Border.all(
          color: highlighted ? HunterPalette.gold : HunterPalette.borderSubtle,
        ),
      ),
      child: Column(
        children: [
          ElementIcon(element: element),
          const SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              color: highlighted ? HunterPalette.text : HunterPalette.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          StarRating(
            elementName: name,
            effectiveness: effectiveness,
            highlighted: highlighted,
          ),
        ],
      ),
    );
  }
}
