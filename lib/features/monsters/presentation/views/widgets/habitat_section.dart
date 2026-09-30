import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class HabitatSection extends StatelessWidget {
  const HabitatSection({
    required this.habitats,
    required this.language,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.inherited = false,
    super.key,
  });

  final List<Habitat> habitats;
  final NameLanguage language;
  final EdgeInsetsGeometry margin;
  final bool inherited;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.sectionHabitat,
      margin: margin,
      inherited: inherited,
      child: habitats.isEmpty
          ? EmptySectionText(l10n.noHabitat)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final habitat in habitats)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 6),
                          child: Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: HunterPalette.gold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            habitat.name.resolve(language),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
