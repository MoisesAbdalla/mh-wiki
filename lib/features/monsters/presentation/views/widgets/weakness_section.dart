import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/widgets/star_rating.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// General weaknesses (most effective highlighted) plus per-state blocks
/// when the monster has states (FR-008, FR-008a).
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
    final textTheme = Theme.of(context).textTheme;
    final highlighted = profile.mostEffective;

    return SectionCard(
      title: l10n.sectionWeaknesses,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ElementTable(values: profile.general, highlighted: highlighted),
          if (profile.states.isNotEmpty) ...[
            const Divider(height: 32),
            Text(l10n.weaknessByState, style: textTheme.titleSmall),
            for (final state in profile.states) ...[
              const SizedBox(height: 12),
              Text(state.name.resolve(language), style: textTheme.labelLarge),
              const SizedBox(height: 4),
              _ElementTable(values: state.values, highlighted: const {}),
            ],
          ],
        ],
      ),
    );
  }
}

class _ElementTable extends StatelessWidget {
  const _ElementTable({required this.values, required this.highlighted});

  final Map<ElementType, Effectiveness> values;
  final Set<ElementType> highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final element in ElementType.values)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.elementName(element),
                    style: highlighted.contains(element)
                        ? textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )
                        : textTheme.bodyLarge,
                  ),
                ),
                StarRating(
                  elementName: l10n.elementName(element),
                  effectiveness: values[element] ?? Effectiveness.none,
                  highlighted: highlighted.contains(element),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
