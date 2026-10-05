import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/game_icons.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/material_cost_row.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/armor/domain/usecases/armor_queries.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_widgets.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Shared header of the armor details: name, subtitle and an optional plate.
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, this.image});

  final String title;
  final String subtitle;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, Space.card),
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
                    title,
                    style: notebookTitle(size: 30, height: 1.05),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: HunterPalette.textMuted),
                ),
              ],
            ),
          ),
          if (image != null) ...[
            const SizedBox(width: 12),
            MonsterImage(asset: image, size: 76, emphasized: true),
          ],
        ],
      ),
    );
  }
}

/// A set: 1 Defesa, 2 Habilidades, 3 Peças (007 US2).
class ArmorSetDetailView extends StatelessWidget {
  const ArmorSetDetailView({
    required this.set,
    required this.catalog,
    required this.onOpenSkill,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final ArmorSet set;
  final ArmorCatalog catalog;
  final ValueChanged<Skill> onOpenSkill;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final max = set.maxDefense;
    final chest = set.pieces.where((p) => p.part == BodyPart.chest).firstOrNull;
    final totals = sumSetSkills(catalog, set);
    return ListView(
      key: PageStorageKey(('armor-set', set.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        _Header(
          title: set.name.resolve(language),
          subtitle: [
            l10n.rankLabel(l10n.rankName(set.rank)),
            l10n.rarity(set.rarity),
            l10n.piecesCount(set.pieces.length),
          ].join(' · '),
          image:
              (chest ?? set.pieces.first).imageAsset ??
              GameIcons.armorPart(
                (chest ?? set.pieces.first).part.name,
                set.rarity,
                catalog.game,
              ),
        ),
        NotebookSection(
          number: 1,
          title: l10n.armorSectionDefense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.defenseBase,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: HunterPalette.textMuted),
              ),
              Text(
                max == null
                    ? '${set.defense}'
                    : l10n.defenseRange(set.defense, max),
                style: notebookNumber(size: 26, bold: true),
              ),
              const SizedBox(height: 10),
              ResistanceRow(resistances: set.resistances),
            ],
          ),
        ),
        if (totals.isNotEmpty)
          NotebookSection(
            number: 2,
            title: l10n.armorSectionSkills,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, t) in totals.indexed)
                  Semantics(
                    button: true,
                    label: _counted(t.skill)
                        ? '${t.skill.name.resolve(language)}, '
                              '${l10n.piecesN(t.level)}'
                        : l10n.skillLevelOf(
                            t.skill.name.resolve(language),
                            t.level,
                            t.skill.maxLevel,
                          ),
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => onOpenSkill(t.skill),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: RuledRow(
                          ruled: i < totals.length - 1,
                          label: Text(t.skill.name.resolve(language)),
                          trailing: _counted(t.skill)
                              ? Text(
                                  l10n.piecesN(t.level),
                                  style: notebookNumber(
                                    size: 13,
                                    color: HunterPalette.textMuted,
                                  ),
                                )
                              : SkillPips(
                                  level: t.level,
                                  max: t.skill.maxLevel,
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (set.bonus != null || set.groupBonus != null)
          NotebookSection(
            number: 3,
            title: l10n.setBonus,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (bonus, group) in [
                  if (set.bonus case final b?) (b, false),
                  if (set.groupBonus case final g?) (g, true),
                ])
                  _BonusBlock(
                    bonus: bonus,
                    group: group,
                    catalog: catalog,
                    language: language,
                    onOpenSkill: onOpenSkill,
                  ),
              ],
            ),
          ),
        NotebookSection(
          number: set.bonus != null || set.groupBonus != null ? 4 : 3,
          title: l10n.armorSectionPieces,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final piece in set.pieces)
                _PieceMaterials(
                  key: ValueKey(piece.id),
                  piece: piece,
                  sources: sources,
                  onOpenMonster: onOpenMonster,
                  language: language,
                  game: catalog.game,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Set and group skills count pieces, not levels.
  static bool _counted(Skill s) =>
      s.kind == SkillKind.set || s.kind == SkillKind.group;
}

/// One set or group bonus: the skill and each piece-count step.
class _BonusBlock extends StatelessWidget {
  const _BonusBlock({
    required this.bonus,
    required this.group,
    required this.catalog,
    required this.language,
    required this.onOpenSkill,
  });

  final SetBonus bonus;
  final bool group;
  final ArmorCatalog catalog;
  final NameLanguage language;
  final ValueChanged<Skill> onOpenSkill;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final skill = catalog.skill(bonus.skillId);
    final name = skill?.name.resolve(language) ?? bonus.skillId;
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HunterPalette.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.row),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: skill == null ? null : () => onOpenSkill(skill),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: name),
                        if (group)
                          TextSpan(
                            text: '  (${l10n.groupBonusLabel})',
                            style: muted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            for (final step in bonus.steps)
              Semantics(
                label: l10n.setStepSemantics(
                  name,
                  l10n.piecesN(step.pieces),
                  step.name.resolve(language),
                ),
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: HunterPalette.border),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            l10n.piecesN(step.pieces),
                            style: notebookNumber(
                              size: 12,
                              color: HunterPalette.gold,
                              bold: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [
                            step.name.resolve(language),
                            step.description.resolve(language),
                          ].where((t) => t.isNotEmpty).join(' — '),
                          style: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A piece row; a tap shows its forge materials with their sources.
class _PieceMaterials extends StatefulWidget {
  const _PieceMaterials({
    required this.piece,
    required this.sources,
    required this.onOpenMonster,
    required this.language,
    this.game = Game.riseSunbreak,
    super.key,
  });

  final ArmorPiece piece;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final NameLanguage language;
  final Game game;

  @override
  State<_PieceMaterials> createState() => _PieceMaterialsState();
}

class _PieceMaterialsState extends State<_PieceMaterials> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final piece = widget.piece;
    final name = piece.name.resolve(widget.language);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          label: '$name, ${l10n.partName(piece.part)}',
          hint: _open ? l10n.hideSources : l10n.showSources,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: RuledRow(
                leading: switch (GameIcons.armorPart(
                  piece.part.name,
                  piece.rarity,
                  widget.game,
                )) {
                  final icon? => Image.asset(
                    icon,
                    width: 26,
                    height: 26,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => const SizedBox(width: 26),
                  ),
                  null => null,
                },
                label: Text(name, style: notebookTitle(size: 16)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SlotGems(slots: piece.slots, size: 18, game: widget.game),
                    Icon(
                      _open ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: HunterPalette.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (piece.forge.isEmpty)
                  EmptySectionText(l10n.noMaterials)
                else ...[
                  RuledCaption(l10n.forgeMaterials),
                  for (final (i, cost) in piece.forge.indexed)
                    MaterialCostRow(
                      key: ValueKey((piece.id, cost.material.id)),
                      cost: cost,
                      droppers: widget.sources.droppersOf(cost.material.id),
                      ranked: cost.sources.forRank(piece.rank),
                      onOpenMonster: widget.onOpenMonster,
                      ruled: i < piece.forge.length - 1,
                      language: widget.language,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// A skill: 1 Níveis, 2 Joias, 3 Armaduras (007 US3).
class SkillDetailView extends StatefulWidget {
  const SkillDetailView({
    required this.skill,
    required this.catalog,
    required this.onOpenDecoration,
    required this.onOpenSet,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final Skill skill;
  final ArmorCatalog catalog;
  final ValueChanged<ArmorDecoration> onOpenDecoration;
  final ValueChanged<String> onOpenSet;
  final NameLanguage language;

  @override
  State<SkillDetailView> createState() => _SkillDetailViewState();
}

class _SkillDetailViewState extends State<SkillDetailView> {
  static const _preview = 8;
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final skill = widget.skill;
    final language = widget.language;
    final sources = skillSources(widget.catalog, skill.id);
    final pieces = [
      for (final MapEntry(key: rank, value: list) in sources.pieces.entries)
        for (final p in list) (rank: rank, piece: p.piece, level: p.level),
    ];
    final shown = _all ? pieces : pieces.take(_preview).toList();
    var number = 1;
    return ListView(
      key: PageStorageKey(('skill', skill.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        _Header(
          title: skill.name.resolve(language),
          subtitle: [
            skill.description.resolve(language),
            if (widget.catalog.game == Game.wilds)
              switch (skill.kind) {
                SkillKind.weapon => l10n.skillKindWeapon,
                SkillKind.armor => l10n.skillKindArmor,
                SkillKind.set => l10n.skillKindSet,
                SkillKind.group => l10n.skillKindGroup,
              },
            l10n.skillMaxLevel(skill.maxLevel),
          ].where((t) => t.isNotEmpty).join(' · '),
        ),
        NotebookSection(
          number: number++,
          title: l10n.skillSectionLevels,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, effect) in skill.levels.indexed)
                RuledRow(
                  ruled: i < skill.levels.length - 1,
                  leading: SizedBox(
                    width: 44,
                    child: Text(
                      l10n.skillLevelShort(i + 1),
                      style: notebookNumber(
                        size: 14,
                        color: HunterPalette.gold,
                      ),
                    ),
                  ),
                  label: Text(effect.resolve(language)),
                ),
            ],
          ),
        ),
        if (sources.decorations.isNotEmpty)
          NotebookSection(
            number: number++,
            title: l10n.skillSectionDecorations,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, d) in sources.decorations.indexed)
                  InkWell(
                    onTap: () => widget.onOpenDecoration(d.decoration),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: RuledRow(
                        ruled: i < sources.decorations.length - 1,
                        label: Text(
                          '${d.decoration.name.resolve(language)} · '
                          '${l10n.skillLevelShort(d.level)}',
                        ),
                        trailing: DecorationIcon(
                          decoration: d.decoration,
                          game: widget.catalog.game,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (pieces.isNotEmpty)
          NotebookSection(
            number: number++,
            title: l10n.skillSectionArmor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, p) in shown.indexed) ...[
                  if (i == 0 || shown[i - 1].rank != p.rank)
                    RuledCaption(l10n.rankLabel(l10n.rankName(p.rank))),
                  InkWell(
                    onTap: () => widget.onOpenSet(p.piece.setId),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: RuledRow(
                        label: Text(p.piece.name.resolve(language)),
                        trailing: Text(
                          l10n.skillLevelShort(p.level),
                          style: notebookNumber(
                            size: 13,
                            color: HunterPalette.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (!_all && pieces.length > _preview)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _all = true),
                      child: Text(l10n.seeAllPieces(pieces.length)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A decoration: 1 Habilidade, 2 Materiais (007 US3).
class DecorationDetailView extends StatelessWidget {
  const DecorationDetailView({
    required this.decoration,
    required this.catalog,
    required this.onOpenSkill,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final ArmorDecoration decoration;
  final ArmorCatalog catalog;
  final ValueChanged<Skill> onOpenSkill;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      key: PageStorageKey(('decoration', decoration.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        _Header(
          title: decoration.name.resolve(language),
          subtitle: [
            l10n.slotLevelTitle(decoration.slotLevel),
            if (catalog.game == Game.wilds)
              decoration.kind == DecorationKind.weapon
                  ? l10n.decoKindWeapon
                  : l10n.decoKindArmor,
          ].join(' · '),
        ),
        NotebookSection(
          number: 1,
          title: l10n.decorationSectionSkill,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, s) in decoration.skills.indexed)
                if (catalog.skill(s.skillId) case final skill?)
                  InkWell(
                    onTap: () => onOpenSkill(skill),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: RuledRow(
                        ruled: i < decoration.skills.length - 1,
                        label: Text(skill.name.resolve(language)),
                        trailing: SkillPips(
                          level: s.level,
                          max: skill.maxLevel,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        NotebookSection(
          number: 2,
          title: l10n.weaponSectionMaterials,
          child: decoration.forge.isEmpty
              ? EmptySectionText(l10n.noMaterials)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, cost) in decoration.forge.indexed)
                      MaterialCostRow(
                        key: ValueKey(cost.material.id),
                        cost: cost,
                        droppers: sources.droppersOf(cost.material.id),
                        ranked: cost.sources.forRank(Rank.master),
                        onOpenMonster: onOpenMonster,
                        ruled: i < decoration.forge.length - 1,
                        language: language,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A talisman: each rank with its skill, rarity and materials (Wilds,
/// 010 FR-008).
class TalismanDetailView extends StatelessWidget {
  const TalismanDetailView({
    required this.talisman,
    required this.catalog,
    required this.onOpenSkill,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final Talisman talisman;
  final ArmorCatalog catalog;
  final ValueChanged<Skill> onOpenSkill;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final first = talisman.ranks.first;
    final last = talisman.ranks.last;
    return ListView(
      key: PageStorageKey(('talisman', talisman.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        _Header(
          title: first.name
              .resolve(language)
              .replaceFirst(RegExp(r'\s+[IVX]+$'), ''),
          subtitle: first.rarity == last.rarity
              ? l10n.rarity(first.rarity)
              : '${l10n.rarity(first.rarity)}–${last.rarity}',
          image: GameIcons.armorPart('talisman', last.rarity, catalog.game),
        ),
        for (final (i, rank) in talisman.ranks.indexed)
          NotebookSection(
            number: i + 1,
            title: rank.name.resolve(language),
            note: l10n.rarity(rank.rarity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final s in rank.skills)
                  if (catalog.skill(s.skillId) case final skill?)
                    InkWell(
                      onTap: () => onOpenSkill(skill),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: RuledRow(
                          label: Text(skill.name.resolve(language)),
                          trailing: SkillPips(
                            level: s.level,
                            max: skill.maxLevel,
                          ),
                        ),
                      ),
                    ),
                if (rank.forge.isNotEmpty) ...[
                  RuledCaption(l10n.forgeMaterials),
                  for (final (j, cost) in rank.forge.indexed)
                    MaterialCostRow(
                      key: ValueKey((rank.level, cost.material.id)),
                      cost: cost,
                      droppers: sources.droppersOf(cost.material.id),
                      ranked: cost.sources.forRank(Rank.high),
                      onOpenMonster: onOpenMonster,
                      ruled: j < rank.forge.length - 1,
                      language: language,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
