import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/habitat_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/materials_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/parts_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/weakness_section.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Header + the four detail sections (FR-007). Used both as a full page
/// (compact layout) and as the right pane (expanded layout).
class MonsterDetailView extends StatelessWidget {
  const MonsterDetailView({
    required this.monster,
    required this.language,
    super.key,
  });

  final Monster monster;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      key: PageStorageKey('detail-${monster.id}'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              MonsterImage(asset: monster.imageAsset, size: 88),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monster.name.resolve(language),
                      style: textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.gameName(monster.id.game),
                      style: textTheme.labelLarge,
                    ),
                    Text(
                      monster.classification.resolve(language),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WeaknessSection(profile: monster.weaknesses, language: language),
        HabitatSection(habitats: monster.habitats, language: language),
        PartsSection(parts: monster.parts, language: language),
        MaterialsSection(monster: monster, language: language),
      ],
    );
  }
}
