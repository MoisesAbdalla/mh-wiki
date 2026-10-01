import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/usecases/armor_queries.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_widgets.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// One armor set as a card (007 ui-contract, option A): its pieces with
/// slots and skills, and the skill sum in the footer, the chosen skill first.
class ArmorSetCard extends StatelessWidget {
  const ArmorSetCard({
    required this.set,
    required this.catalog,
    required this.onTap,
    this.selected = false,
    this.highlightSkill,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final ArmorSet set;
  final ArmorCatalog catalog;
  final VoidCallback onTap;
  final bool selected;

  /// The skill filter, shown first and in bold in the footer.
  final String? highlightSkill;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final totals = sumSetSkills(catalog, set);
    final chosen = [
      for (final t in totals)
        if (t.skill.id == highlightSkill) t,
    ];
    final ordered = [...chosen, ...totals.where((t) => !chosen.contains(t))];
    String skillText(SkillTotal t) =>
        '${t.skill.name.resolve(language)} ${t.level}';

    return Padding(
      padding: EdgeInsets.fromLTRB(gutter - 10, 5, gutter - 10, 5),
      child: Material(
        color: selected ? HunterPalette.panelHighlight : HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? HunterPalette.gold : HunterPalette.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            button: true,
            selected: selected,
            label: [
              set.name.resolve(language),
              l10n.rarity(set.rarity),
              l10n.piecesCount(set.pieces.length),
              ...ordered.map(skillText),
            ].join(', '),
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: HunterPalette.borderSubtle),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 10,
                      children: [
                        Text(
                          set.name.resolve(language),
                          style: notebookTitle(size: 18),
                        ),
                        Text(l10n.rarity(set.rarity), style: muted),
                      ],
                    ),
                  ),
                ),
                for (final piece in set.pieces)
                  _PieceRow(piece: piece, catalog: catalog, language: language),
                if (ordered.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 9),
                    child: Text.rich(
                      TextSpan(
                        style: muted,
                        children: [
                          TextSpan(text: l10n.setSkillsFooter('')),
                          for (final (i, t) in ordered.indexed) ...[
                            if (i > 0) const TextSpan(text: ' · '),
                            TextSpan(
                              text: skillText(t),
                              style: TextStyle(
                                color: HunterPalette.text,
                                fontWeight: t.skill.id == highlightSkill
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieceRow extends StatelessWidget {
  const _PieceRow({
    required this.piece,
    required this.catalog,
    required this.language,
  });

  final ArmorPiece piece;
  final ArmorCatalog catalog;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final skills = [
      for (final s in piece.skills)
        '${catalog.skill(s.skillId)?.name.resolve(language) ?? s.skillId} '
            '${s.level}',
    ].join(' · ');
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HunterPalette.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
        child: Row(
          children: [
            MonsterImage(asset: piece.imageAsset, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    piece.name.resolve(language),
                    style: notebookTitle(size: 15, height: 1.15),
                  ),
                  if (skills.isNotEmpty) Text(skills, style: muted),
                ],
              ),
            ),
            if (piece.slots.isNotEmpty) ...[
              const SizedBox(width: 8),
              SlotGems(slots: piece.slots, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
