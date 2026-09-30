import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop_group.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Materials grouped by rank; each row is one acquisition method with its
/// rate or "Taxa desconhecida" (FR-011, FR-011a, FR-011b).
class MaterialsSection extends StatefulWidget {
  const MaterialsSection({
    required this.monster,
    required this.language,
    super.key,
  });

  final Monster monster;
  final NameLanguage language;

  @override
  State<MaterialsSection> createState() => _MaterialsSectionState();
}

class _MaterialsSectionState extends State<MaterialsSection> {
  Rank? _selected;

  @override
  void didUpdateWidget(MaterialsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monster.id != widget.monster.id) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final byRank = widget.monster.dropsByRank;

    if (byRank.isEmpty) {
      return SectionCard(
        title: l10n.sectionMaterials,
        child: EmptySectionText(l10n.noMaterials),
      );
    }

    final ranks = byRank.keys.toList();
    final selected = ranks.contains(_selected) ? _selected! : ranks.first;

    return SectionCard(
      title: l10n.sectionMaterials,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ranks.length > 1)
            HunterTabs<Rank>(
              options: [for (final rank in ranks) (rank, l10n.rankName(rank))],
              selected: selected,
              dense: true,
              onChanged: (rank) => setState(() => _selected = rank),
            )
          else
            Text(
              l10n.rankName(selected),
              style: hunterDisplay(size: 12, color: HunterPalette.textMuted),
            ),
          const SizedBox(height: 8),
          for (final group in byRank[selected]!)
            _MaterialTile(
              group: group,
              monster: widget.monster,
              language: widget.language,
            ),
        ],
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({
    required this.group,
    required this.monster,
    required this.language,
  });

  final MaterialDropGroup group;
  final Monster monster;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final rarity = group.material.rarity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.material.name.resolve(language),
                  style: textTheme.titleSmall,
                ),
              ),
              if (rarity != null)
                Text(l10n.rarity(rarity), style: textTheme.labelSmall),
            ],
          ),
          for (final drop in group.drops)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(_methodLabel(l10n, drop))),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Text(
                      textAlign: TextAlign.end,
                      drop.ratePercent == null
                          ? l10n.rateUnknown
                          : l10n.percent(drop.ratePercent!),
                      style: textTheme.bodyMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: HunterPalette.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _methodLabel(AppLocalizations l10n, MaterialDrop drop) =>
      switch (drop.method) {
        DropMethod.carve => l10n.methodCarve,
        DropMethod.tailCarve => l10n.methodTailCarve,
        DropMethod.capture => l10n.methodCapture,
        DropMethod.breakPart => l10n.methodBreakPart(
          monster.partById(drop.partId!)?.name.resolve(language) ??
              drop.partId!,
        ),
        DropMethod.questReward => l10n.methodQuestReward,
        DropMethod.droppedMaterial => l10n.methodDroppedMaterial,
        DropMethod.other => drop.methodLabel?.resolve(language) ?? '',
      };
}
