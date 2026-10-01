import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// One forge or upgrade material: its name and amount, seals of where it
/// comes from in a rank (large monster link, small monster, gathering,
/// quest, or unknown origin), and a tap that lists every source with its
/// rate (006 US5; shared by weapons, armor and decorations, 007 R5).
class MaterialCostRow extends StatefulWidget {
  const MaterialCostRow({
    required this.cost,
    required this.droppers,
    required this.ranked,
    required this.onOpenMonster,
    required this.ruled,
    required this.language,
    super.key,
  });

  final NameLanguage language;
  final MaterialCost cost;
  final List<MaterialDropper> droppers;
  final RankedSources ranked;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final bool ruled;

  @override
  State<MaterialCostRow> createState() => _MaterialCostRowState();
}

class _MaterialCostRowState extends State<MaterialCostRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = widget.language;
    final cost = widget.cost;
    final ranked = widget.ranked;
    final name = cost.material.name.resolve(language);
    final points = cost.points;
    final amount = points != null
        ? l10n.materialPoints(points)
        : '×${cost.quantity}';
    final open = widget.onOpenMonster;
    final small = [
      for (final m in ranked.monsters)
        if (m.small) m,
    ];
    final canOpen = ranked.hasDetails;
    final kind = gatherLabel(l10n, ranked.kind);
    final unknown =
        widget.droppers.isEmpty && ranked.isEmpty && ranked.kind == null;

    final chips = <Widget>[
      for (final dropper in widget.droppers.take(3))
        _Chip(
          text: '${dropper.name} ›',
          semanticsLabel: l10n.droppedBy(dropper.name),
          gold: true,
          onTap: open == null ? null : () => open(dropper),
        ),
      for (final m in small.take(2))
        _Chip(text: l10n.smallMonster(m.name.resolve(language))),
      if (ranked.gathering.length == 1)
        _Chip(
          text: l10n.gatheringAt(
            kind,
            ranked.gathering.single.map.resolve(language),
          ),
        )
      else if (ranked.gathering.isNotEmpty)
        _Chip(text: l10n.gatheringMaps(kind, ranked.gathering.length))
      else if (ranked.kind != null)
        _Chip(text: l10n.gatherNoMap(kind)),
      if (ranked.quests.length == 1)
        _Chip(text: l10n.questChip(ranked.quests.single.stars))
      else if (ranked.quests.isNotEmpty)
        _Chip(text: l10n.questsChip(ranked.quests.length)),
      if (unknown) _Chip(text: l10n.unknownOrigin, dashed: true),
    ];

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(name)),
        const SizedBox(width: 12),
        Text(amount, style: notebookNumber(size: 15)),
        if (canOpen)
          ExcludeSemantics(
            child: Icon(
              _open ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: HunterPalette.textMuted,
            ),
          ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: widget.ruled
            ? const Border(
                bottom: BorderSide(color: HunterPalette.borderSubtle),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.row),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canOpen)
              Semantics(
                button: true,
                expanded: _open,
                label: '$name, $amount',
                hint: _open ? l10n.hideSources : l10n.showSources,
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => setState(() => _open = !_open),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: header,
                    ),
                  ),
                ),
              )
            else
              header,
            if (chips.isNotEmpty) Wrap(spacing: 6, children: chips),
            if (_open) _SourcesTable(ranked: ranked, language: language),
          ],
        ),
      ),
    );
  }
}

/// A short seal: a large monster link (gold) or plain text.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    this.semanticsLabel,
    this.gold = false,
    this.dashed = false,
    this.onTap,
  });

  final String text;
  final String? semanticsLabel;
  final bool gold;
  final bool dashed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = gold ? HunterPalette.gold : HunterPalette.textMuted;
    final seal = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: gold ? HunterPalette.gold : HunterPalette.border,
          style: dashed ? BorderStyle.none : BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: color, height: 1.3),
      ),
    );
    final tap = onTap;
    if (tap == null) {
      return Padding(padding: const EdgeInsets.only(top: 6), child: seal);
    }
    return Semantics(
      container: true,
      link: true,
      label: semanticsLabel ?? text,
      excludeSemantics: true,
      child: InkWell(
        onTap: tap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(widthFactor: 1, child: seal),
        ),
      ),
    );
  }
}

/// The full list of sources of one rank, with rates.
class _SourcesTable extends StatelessWidget {
  const _SourcesTable({required this.ranked, required this.language});

  final RankedSources ranked;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rank = l10n.rankName(ranked.rank);
    final caption = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: HunterPalette.textMuted,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    String rate(int? r) => r == null ? '' : '$r%';

    Widget row(String label, String value, {required bool ruled}) => RuledRow(
      ruled: ruled,
      label: Text(label, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(value, style: notebookNumber(size: 13)),
    );

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: HunterPalette.panelHighlight,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ranked.description case final description?) ...[
            Text(
              description.resolve(language),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HunterPalette.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (ranked.gathering.isNotEmpty) ...[
            Text(
              l10n.sourcesGathering(gatherLabel(l10n, ranked.kind), rank),
              style: caption,
            ),
            for (final (i, g) in ranked.gathering.indexed)
              row(
                g.map.resolve(language),
                rate(g.rate),
                ruled: i < ranked.gathering.length - 1,
              ),
          ],
          if (ranked.monsters.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(l10n.sourcesMonsters(rank), style: caption),
            for (final (i, m) in ranked.monsters.indexed)
              row(
                '${m.name.resolve(language)} · ${m.method.resolve(language)}',
                rate(m.rate),
                ruled: i < ranked.monsters.length - 1,
              ),
          ],
          if (ranked.quests.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(l10n.sourcesQuests, style: caption),
            for (final (i, q) in ranked.quests.indexed)
              row(
                '${q.category.resolve(language)} ${q.stars}★ · '
                '${q.name.resolve(language)}',
                rate(q.rate),
                ruled: i < ranked.quests.length - 1,
              ),
          ],
        ],
      ),
    );
  }
}

/// "Mineração", "Pilha de ossos"… or "Coleta" when the kind is unknown.
String gatherLabel(AppLocalizations l10n, GatherKind? kind) => switch (kind) {
  GatherKind.ore => l10n.gatherOre,
  GatherKind.bone => l10n.gatherBone,
  GatherKind.bug => l10n.gatherBug,
  GatherKind.plant => l10n.gatherPlant,
  GatherKind.fish => l10n.gatherFish,
  null => l10n.gatherAny,
};
