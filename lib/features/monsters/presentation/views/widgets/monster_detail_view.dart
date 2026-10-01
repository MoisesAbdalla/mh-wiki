import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section_kind.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/habitat_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hp_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hunting_items_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/materials_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/parts_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/version_selector.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/weakness_section.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Builds extra cards after the monster's own, numbered from [nextNumber]
/// (006: "Armas feitas com ele"). The monsters feature knows nothing of
/// what they show.
typedef MonsterExtraSections = List<Widget> Function(
  BuildContext context,
  Monster monster,
  int nextNumber,
);

/// Header + the numbered notebook sections (001 FR-007, 005 FR-004). Used
/// both as a full page (compact layout) and as the right pane (expanded).
class MonsterDetailView extends StatelessWidget {
  const MonsterDetailView({
    required this.monster,
    required this.language,
    this.versions = const [],
    this.onSelectVersion,
    this.showGame = false,
    this.extraSections,
    super.key,
  });

  final MonsterExtraSections? extraSections;

  final Monster monster;
  final NameLanguage language;

  /// The monster's base and versions (004); the selector shows only when
  /// there is more than one.
  final List<Monster> versions;
  final ValueChanged<MonsterId>? onSelectVersion;

  /// Shows the game under the name; only when no tab already names it
  /// (005 FR-009).
  final bool showGame;

  bool _inherits(MonsterSectionKind kind) =>
      monster.inheritedSections.contains(kind);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final gutter = Space.gutter(width);
    final subtitle = [
      monster.classification.resolve(language),
      if (showGame) l10n.gameName(monster.id.game),
    ].join(' · ');

    return ListView(
      key: PageStorageKey('detail-${monster.id}'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        monster.name.resolve(language),
                        style: notebookTitle(
                          size: width < 360 ? 32 : 40,
                          height: 1,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: HunterPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              MonsterImage(
                asset: monster.imageAsset,
                size: 92,
                emphasized: true,
              ),
            ],
          ),
        ),
        if (versions.length > 1 && onSelectVersion != null)
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
            child: VersionSelector(
              versions: versions,
              selected: monster.id,
              onSelect: onSelectVersion!,
            ),
          ),
        const SizedBox(height: 26),
        WeaknessSection(
          number: 1,
          profile: monster.weaknesses,
          language: language,
          inherited: _inherits(MonsterSectionKind.weaknesses),
        ),
        HpSection(number: 2, info: monster.huntingInfo),
        HuntingItemsSection(
          number: 3,
          info: monster.huntingInfo,
          language: language,
          inherited: _inherits(MonsterSectionKind.itemReactions),
        ),
        MaterialsSection(number: 4, monster: monster, language: language),
        LayoutBuilder(
          builder: (context, constraints) {
            final habitat = HabitatSection(
              number: 5,
              habitats: monster.habitats,
              language: language,
              inherited: _inherits(MonsterSectionKind.habitats),
            );
            final parts = PartsSection(
              number: 6,
              parts: monster.parts,
              language: language,
              inherited: _inherits(MonsterSectionKind.parts),
            );
            // Side by side from 360 dp of content (002 FR-008).
            if (constraints.maxWidth - 2 * gutter < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [habitat, parts],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: habitat),
                Expanded(child: parts),
              ],
            );
          },
        ),
        ...?extraSections?.call(context, monster, 7),
      ],
    );
  }
}
