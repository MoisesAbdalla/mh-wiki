import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class HabitatSection extends StatelessWidget {
  const HabitatSection({
    required this.habitats,
    required this.language,
    this.number,
    this.inherited = false,
    super.key,
  });

  final List<Habitat> habitats;
  final NameLanguage language;

  /// Position in the detail (005 FR-004).
  final int? number;
  final bool inherited;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NotebookSection(
      number: number,
      title: l10n.sectionHabitat,
      note: inherited ? l10n.inheritedFromBase : null,
      child: habitats.isEmpty
          ? EmptySectionText(l10n.noHabitat)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final habitat in habitats)
                  RuledRow(label: Text(habitat.name.resolve(language))),
              ],
            ),
    );
  }
}
