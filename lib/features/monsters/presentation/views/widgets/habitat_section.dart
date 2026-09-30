import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class HabitatSection extends StatelessWidget {
  const HabitatSection({
    required this.habitats,
    required this.language,
    super.key,
  });

  final List<Habitat> habitats;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.sectionHabitat,
      child: habitats.isEmpty
          ? EmptySectionText(l10n.noHabitat)
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final habitat in habitats)
                  Chip(
                    avatar: const Icon(Icons.place_outlined, size: 18),
                    label: Text(habitat.name.resolve(language)),
                  ),
              ],
            ),
    );
  }
}
