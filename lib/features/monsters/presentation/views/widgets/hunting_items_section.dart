import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Vision and reaction to each hunting item of the game (003 FR-003/004).
class HuntingItemsSection extends StatelessWidget {
  const HuntingItemsSection({
    required this.info,
    required this.language,
    this.number,
    this.inherited = false,
    super.key,
  });

  final HuntingInfo info;
  final NameLanguage language;
  final bool inherited;

  /// Position in the detail (005 FR-004).
  final int? number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final sees = info.vision == Vision.sees;

    return NotebookSection(
      number: number,
      title: l10n.sectionHuntingItems,
      note: inherited ? l10n.inheritedFromBase : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemRow(
            name: l10n.visionLabel,
            effect: sees ? ReactionEffect.affects : ReactionEffect.unknown,
            status: sees ? l10n.visionSees : l10n.unknown,
          ),
          for (final item in info.items)
            Builder(
              builder: (context) {
                final reaction = info.reactionFor(item.id);
                return _ItemRow(
                  name: item.name.resolve(language),
                  effect: reaction.effect,
                  status: switch (reaction.effect) {
                    ReactionEffect.affects => l10n.effectAffects,
                    ReactionEffect.noEffect => l10n.effectNoEffect,
                    ReactionEffect.conditional => l10n.effectConditional,
                    ReactionEffect.unknown => l10n.unknown,
                  },
                  detail: reaction.detail?.resolve(language),
                  detailStyle: textTheme.bodySmall?.copyWith(
                    color: HunterPalette.textMuted,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// One ruled line: name (and detail) at the left, reaction at the right;
/// read as one sentence.
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.name,
    required this.effect,
    required this.status,
    this.detail,
    this.detailStyle,
  });

  final String name;
  final ReactionEffect effect;
  final String status;
  final String? detail;
  final TextStyle? detailStyle;

  @override
  Widget build(BuildContext context) {
    final label = detail == null ? '$name: $status' : '$name: $status. $detail';
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: RuledRow(
          label: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.bodyLarge),
              if (detail != null) Text(detail!, style: detailStyle),
            ],
          ),
          trailing: Text(
            status,
            textAlign: TextAlign.end,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: effect == ReactionEffect.unknown
                  ? FontWeight.w400
                  : FontWeight.w700,
              fontStyle: effect == ReactionEffect.unknown
                  ? FontStyle.italic
                  : null,
              color: switch (effect) {
                ReactionEffect.affects ||
                ReactionEffect.conditional => HunterPalette.text,
                _ => HunterPalette.textMuted,
              },
            ),
          ),
        ),
      ),
    );
  }
}
