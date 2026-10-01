import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/slot_badges.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_special_label.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "1 Atributos": attack, element/status and affinity in a grid that wraps
/// down to one column, then the slots.
class WeaponAttributesSection extends StatelessWidget {
  const WeaponAttributesSection({
    required this.weapon,
    this.number = 1,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final Weapon weapon;
  final int number;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final affinity = weapon.affinity;
    final traits = weapon.traits;
    // Type traits are words, not numbers (006 US4).
    Text word(String text) => Text(text, style: notebookTitle(size: 22));
    final cells = <(String, Widget)>[
      (
        l10n.attack,
        Text('${weapon.attack}', style: notebookNumber(size: 26, bold: true)),
      ),
      for (final special in weapon.special)
        (
          l10n.specialName(special.kind),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (special.kind.element case final element?) ...[
                ElementIcon(element: element, size: 20),
                const SizedBox(width: 6),
              ],
              Text(
                '${special.value}',
                style: notebookNumber(
                  size: 26,
                  color: special.kind.element == null
                      ? statusColor(special.kind)
                      : HunterPalette.text,
                ),
              ),
            ],
          ),
        ),
      (
        l10n.affinity,
        Text(
          l10n.signedPercent(affinity),
          style: notebookNumber(
            size: 26,
            color: affinity < 0 ? HunterPalette.negative : HunterPalette.text,
          ),
        ),
      ),
      if (traits.phial case final phial?)
        (l10n.traitPhial, word(phial.resolve(language))),
      if (traits.shelling case final shelling?)
        (l10n.traitShelling, word(shelling.resolve(language))),
      if (traits.kinsectLevel case final level?)
        (l10n.traitKinsect, word(l10n.kinsectLevel(level))),
    ];

    return NotebookSection(
      number: number,
      title: l10n.weaponSectionAttributes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Three columns while they fit; one column at large text.
              final scale = MediaQuery.textScalerOf(context).scale(1);
              final columns = (constraints.maxWidth / (96 * scale))
                  .floor()
                  .clamp(1, 3);
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 8,
                children: [
                  for (final (label, value) in cells)
                    SizedBox(
                      width: width,
                      child: MergeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: HunterPalette.textMuted),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: value,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          SlotBadges(slots: weapon.slots, rampageSlot: weapon.rampageSlot),
          if (traits.songs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.traitSongs,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: HunterPalette.textMuted),
            ),
            const SizedBox(height: 4),
            for (final (i, song) in traits.songs.indexed)
              RuledRow(
                ruled: i < traits.songs.length - 1,
                label: Text(song.resolve(language)),
              ),
          ],
        ],
      ),
    );
  }
}
