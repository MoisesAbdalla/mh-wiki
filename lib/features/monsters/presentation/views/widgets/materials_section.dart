import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/method_drop_group.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Materials of the chosen rank, grouped by how they are obtained; each row is
/// a material with its rate or "Taxa desconhecida" (001 FR-011, 005 FR-014).
class MaterialsSection extends StatefulWidget {
  const MaterialsSection({
    required this.monster,
    required this.language,
    this.number,
    super.key,
  });

  final Monster monster;
  final NameLanguage language;

  /// Position in the detail (005 FR-004).
  final int? number;

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
    final monster = widget.monster;
    final ranks = monster.dropsByRank.keys.toList();

    if (ranks.isEmpty) {
      return NotebookSection(
        number: widget.number,
        title: l10n.sectionMaterials,
        child: EmptySectionText(l10n.noMaterials),
      );
    }

    final selected = ranks.contains(_selected) ? _selected! : ranks.first;

    return NotebookSection(
      number: widget.number,
      title: l10n.sectionMaterials,
      note: ranks.length > 1 ? null : l10n.rankName(selected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ranks.length > 1)
            UnderlineTabs<Rank>(
              options: [
                for (final rank in ranks)
                  TabOption(value: rank, text: l10n.rankName(rank)),
              ],
              selected: selected,
              textSize: 16,
              onChanged: (rank) => setState(() => _selected = rank),
            ),
          for (final group in monster.dropsByMethod(selected)) ...[
            RuledCaption(_methodLabel(l10n, group)),
            for (final drop in group.drops)
              _MaterialRow(drop: drop, language: widget.language),
          ],
        ],
      ),
    );
  }

  String _methodLabel(AppLocalizations l10n, MethodDropGroup group) =>
      switch (group.method) {
        DropMethod.carve => l10n.methodCarve,
        DropMethod.tailCarve => l10n.methodTailCarve,
        DropMethod.capture => l10n.methodCapture,
        DropMethod.breakPart => l10n.methodBreakPart(
          widget.monster
                  .partById(group.partId!)
                  ?.name
                  .resolve(widget.language) ??
              group.partId!,
        ),
        DropMethod.questReward => l10n.methodQuestReward,
        DropMethod.droppedMaterial => l10n.methodDroppedMaterial,
        DropMethod.other => group.methodLabel?.resolve(widget.language) ?? '',
      };
}

/// One ruled line: material (and rarity) at the left, rate at the right.
class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.drop, required this.language});

  final MaterialDrop drop;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final rarity = drop.material.rarity;
    final rate = drop.ratePercent;
    return RuledRow(
      label: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            drop.material.name.resolve(language),
            style: textTheme.bodyLarge,
          ),
          if (rarity != null)
            Text(l10n.rarity(rarity), style: textTheme.bodySmall),
        ],
      ),
      trailing: rate == null
          ? Text(
              l10n.rateUnknown,
              textAlign: TextAlign.end,
              style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            )
          : Text(l10n.percent(rate), style: notebookNumber(bold: true)),
    );
  }
}
