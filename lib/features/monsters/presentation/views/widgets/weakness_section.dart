import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/widgets/star_rating.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/ranked_weakness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Weaknesses as ruled rows from best to worst, each with the element symbol
/// and stars; the best one in gold with a "Melhor" stamp (005 FR-010/FR-011).
/// Per-state weaknesses follow under their state names (001 FR-008a).
class WeaknessSection extends StatelessWidget {
  const WeaknessSection({
    required this.profile,
    required this.language,
    this.number,
    this.inherited = false,
    super.key,
  });

  final WeaknessProfile profile;
  final NameLanguage language;
  final bool inherited;

  /// Position in the detail (005 FR-004).
  final int? number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NotebookSection(
      number: number,
      title: l10n.sectionWeaknesses,
      note: inherited ? l10n.inheritedFromBase : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final weakness in profile.ranked) WeaknessRow(weakness),
          if (profile.states.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.weaknessByState,
              style: notebookTitle(size: 17, color: HunterPalette.textMuted),
            ),
            for (final state in profile.states) ...[
              RuledCaption(state.name.resolve(language)),
              for (final weakness in state.ranked)
                WeaknessRow(weakness, inState: true),
            ],
          ],
        ],
      ),
    );
  }
}

/// One element: symbol, name (and stamp when best), stars; read as one
/// sentence such as "Dragão: 3 de 3, melhor fraqueza".
class WeaknessRow extends StatelessWidget {
  const WeaknessRow(this.weakness, {this.inState = false, super.key});

  final RankedWeakness weakness;

  /// A row of a named state (no highlight).
  final bool inState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = l10n.elementName(weakness.element);
    final stars = weakness.effectiveness.stars;
    final label = weakness.effectiveness == Effectiveness.immune
        ? l10n.immuneSemantics(name)
        : weakness.best
        ? l10n.bestWeaknessSemantics(name, stars)
        : l10n.starsSemantics(name, stars);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: RuledRow(
        leading: ElementIcon(element: weakness.element, size: 20),
        label: Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: weakness.best ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (weakness.best) BestStamp(l10n.bestWeakness),
          ],
        ),
        trailing: StarRating(
          elementName: name,
          effectiveness: weakness.effectiveness,
          highlighted: weakness.best,
        ),
      ),
    );
  }
}

/// Gold "Melhor" stamp, slightly tilted like a seal on a page.
class BestStamp extends StatelessWidget {
  const BestStamp(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -3 * math.pi / 180,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: HunterPalette.gold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          text,
          style: notebookTitle(size: 13, color: HunterPalette.gold),
        ),
      ),
    ),
  );
}
