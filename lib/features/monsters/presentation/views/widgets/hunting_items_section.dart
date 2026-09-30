import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Vision and reaction to each hunting item of the game (003 FR-003/004).
class HuntingItemsSection extends StatelessWidget {
  const HuntingItemsSection({
    required this.info,
    required this.language,
    super.key,
  });

  final HuntingInfo info;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final sees = info.vision == Vision.sees;

    return SectionCard(
      title: l10n.sectionHuntingItems,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemRow(
            name: l10n.visionLabel,
            effect: sees ? ReactionEffect.affects : ReactionEffect.unknown,
            status: sees ? l10n.visionSees : l10n.unknown,
          ),
          if (info.items.isNotEmpty) const Divider(height: 20),
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

/// "name [status]" with the detail under the name; read as one sentence.
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
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: HunterPalette.text),
                  ),
                  if (detail != null) Text(detail!, style: detailStyle),
                ],
              ),
              _StatusBadge(effect: effect, text: status),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gold for "affects", gold outline for "conditional", muted otherwise.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.effect, required this.text});

  final ReactionEffect effect;
  final String text;

  @override
  Widget build(BuildContext context) {
    final (background, border, color) = switch (effect) {
      ReactionEffect.affects => (
        HunterPalette.gold,
        HunterPalette.gold,
        HunterPalette.textOnGold,
      ),
      ReactionEffect.conditional => (
        null,
        HunterPalette.gold,
        HunterPalette.gold,
      ),
      _ => (null, HunterPalette.borderSubtle, HunterPalette.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          fontStyle: effect == ReactionEffect.unknown ? FontStyle.italic : null,
        ),
      ),
    );
  }
}
