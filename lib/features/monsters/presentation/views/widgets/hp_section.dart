import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hp_ruler.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Reference HP of the chosen rank: the solo value large and, when the game
/// documents party scaling, a ruler with the 2 and 3–4 hunter estimates
/// (003 FR-001/FR-002, 005 FR-013).
class HpSection extends StatefulWidget {
  const HpSection({required this.info, this.number, super.key});

  final HuntingInfo info;

  /// Position in the detail (005 FR-004).
  final int? number;

  @override
  State<HpSection> createState() => _HpSectionState();
}

class _HpSectionState extends State<HpSection> {
  Rank? _selected;

  @override
  void didUpdateWidget(HpSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.info, widget.info)) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = widget.info;
    final ranks = [for (final hp in info.hp) hp.rank];

    if (ranks.isEmpty) {
      return NotebookSection(
        number: widget.number,
        title: l10n.sectionHp,
        child: EmptySectionText(l10n.hpUnknown),
      );
    }

    final selected = ranks.contains(_selected) ? _selected! : ranks.first;
    final hp = info.hp.firstWhere((h) => h.rank == selected);

    return NotebookSection(
      number: widget.number,
      title: l10n.sectionHp,
      note: ranks.length > 1 ? null : l10n.rankName(selected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ranks.length > 1) ...[
            UnderlineTabs<Rank>(
              options: [
                for (final rank in ranks)
                  TabOption(value: rank, text: l10n.rankName(rank)),
              ],
              selected: selected,
              textSize: 16,
              onChanged: (rank) => setState(() => _selected = rank),
            ),
            const SizedBox(height: Space.title),
          ],
          _HpValue(hp: hp, info: info),
          if (info.partyFactors case final factors?) ...[
            const SizedBox(height: 10),
            Text(
              l10n.sourceLabel(factors.source.name),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// The solo value and its ruler, read as one sentence when there is one.
class _HpValue extends StatelessWidget {
  const _HpValue({required this.hp, required this.info});

  final RankHp hp;
  final HuntingInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(l10n.localeName);
    String format(int v) => number.format(v);
    String range(HpRange r) =>
        r.isExact ? format(r.min) : '${format(r.min)}–${format(r.max)}';

    final value = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 10,
      runSpacing: 2,
      children: [
        Text(format(hp.solo), style: notebookNumber(size: 40, bold: true)),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            [
              l10n.hpSolo.toLowerCase(),
              if (hp.basis == HpBasis.minQuest) l10n.hpFromLabel,
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: HunterPalette.textMuted),
          ),
        ),
      ],
    );

    final factors = info.partyFactors;
    final two = hp.partyEstimate(factors, 2);
    final three = hp.partyEstimate(factors, 3);
    final four = hp.partyEstimate(factors, 4);
    if (two == null || three == null || four == null) return value;

    final more = HpRange(three.min, four.max);
    return Semantics(
      container: true,
      label: l10n.hpRulerSemantics(format(hp.solo), range(two), range(more)),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          value,
          const SizedBox(height: 8),
          HpRuler(solo: hp.solo, two: two, more: more, format: format),
        ],
      ),
    );
  }
}
