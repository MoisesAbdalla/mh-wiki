import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/habitat_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hp_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hunting_items_section.dart';
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
              MonsterImage(
                asset: monster.imageAsset,
                size: 104,
                emphasized: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gameName(monster.id.game).toUpperCase(),
                      style: hunterDisplay(
                        size: 11,
                        color: HunterPalette.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monster.name.resolve(language),
                      style: hunterDisplay(size: 26, letterSpacing: 1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monster.classification.resolve(language),
                      style: textTheme.bodyLarge?.copyWith(
                        color: HunterPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        WeaknessSection(profile: monster.weaknesses, language: language),
        HpSection(info: monster.huntingInfo),
        HuntingItemsSection(info: monster.huntingInfo, language: language),
        LayoutBuilder(
          builder: (context, constraints) {
            final habitat = HabitatSection(
              habitats: monster.habitats,
              language: language,
              margin: EdgeInsets.zero,
            );
            final parts = PartsSection(
              parts: monster.parts,
              language: language,
              margin: EdgeInsets.zero,
            );
            // Side by side from 360 dp of content (002 FR-008).
            if (constraints.maxWidth - 32 < 360) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [habitat, const SizedBox(height: 12), parts],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: habitat),
                    const SizedBox(width: 12),
                    Expanded(child: parts),
                  ],
                ),
              ),
            );
          },
        ),
        MaterialsSection(monster: monster, language: language),
      ],
    );
  }
}
