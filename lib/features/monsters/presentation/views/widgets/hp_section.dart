import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Reference HP per rank, solo and estimated for a party (003 FR-001/002).
class HpSection extends StatelessWidget {
  const HpSection({required this.info, super.key});

  final HuntingInfo info;

  static const _partySizes = [2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = NumberFormat.decimalPattern(l10n.localeName);
    final factors = info.partyFactors;

    String value(HpRange range) => range.isExact
        ? format.format(range.min)
        : '${format.format(range.min)} – ${format.format(range.max)}';

    return SectionCard(
      title: l10n.sectionHp,
      child: info.hp.isEmpty
          ? EmptySectionText(l10n.hpUnknown)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, hp) in info.hp.indexed) ...[
                  if (index > 0) const Divider(height: 24),
                  _Row(
                    label: l10n.rankName(hp.rank),
                    value: hp.basis == HpBasis.minQuest
                        ? l10n.hpFrom(format.format(hp.solo))
                        : format.format(hp.solo),
                    emphasized: true,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.hpParty,
                    style: hunterDisplay(
                      size: 12,
                      color: HunterPalette.textMuted,
                    ),
                  ),
                  if (factors == null)
                    EmptySectionText(l10n.unknown)
                  else
                    for (final players in _partySizes)
                      if (hp.partyEstimate(factors, players) case final range?)
                        _Row(
                          label: l10n.hpHunters(players),
                          value: value(range),
                        ),
                ],
                if (factors != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.sourceLabel(factors.source.name),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: HunterPalette.textMuted),
                  ),
                ],
              ],
            ),
    );
  }
}

/// "label ········ value" line; wraps instead of overflowing at large text.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        children: [
          Text(
            label,
            style: (emphasized ? textTheme.titleSmall : textTheme.bodyMedium)
                ?.copyWith(color: HunterPalette.text),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: HunterPalette.text,
              fontWeight: emphasized ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
