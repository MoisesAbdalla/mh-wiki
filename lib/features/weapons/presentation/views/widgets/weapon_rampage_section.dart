import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/widgets/slot_icon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The weapon's Rampage card (007 US4): the Rampage skills to choose from
/// (Low/High Rank), or the Rampage slot and the Rampage decorations that fit
/// it (Master Rank). Hidden when the weapon has neither.
class WeaponRampageSection extends StatelessWidget {
  const WeaponRampageSection({
    required this.weapon,
    required this.catalog,
    required this.number,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final Weapon weapon;
  final WeaponCatalog catalog;
  final int number;
  final NameLanguage language;

  /// Whether the card has anything to show.
  static bool shows(Weapon weapon) =>
      weapon.rampageSkills.isNotEmpty ||
      (weapon.rank == Rank.master && weapon.rampageSlot > 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);

    if (weapon.rampageSkills.isNotEmpty) {
      final skills = weapon.rampageSkills;
      return NotebookSection(
        number: number,
        title: l10n.weaponSectionRampage,
        note: l10n.rampageChooseOne,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, s) in skills.indexed)
              RuledRow(
                ruled: i < skills.length - 1,
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name.resolve(language)),
                    Text(s.effect.resolve(language), style: muted),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    final slot = weapon.rampageSlot;
    final fitting = [
      for (final d in catalog.rampageDecorations)
        if (d.fits(weapon.type.id, slot)) d,
    ];
    return NotebookSection(
      number: number,
      title: l10n.rampageTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RuledRow(
            label: Text(l10n.rampageSlotRow),
            trailing: SlotIcon(level: slot, rampage: true),
          ),
          if (fitting.isNotEmpty) ...[
            RuledCaption(l10n.rampageDecorationsFit),
            for (final (i, d) in fitting.indexed)
              RuledRow(
                ruled: i < fitting.length - 1,
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name.resolve(language)),
                    Text(
                      '${d.skill.name.resolve(language)} · '
                      '${d.skill.effect.resolve(language)}',
                      style: muted,
                    ),
                  ],
                ),
                trailing: SlotIcon(level: d.slotLevel, rampage: true, size: 20),
              ),
          ],
        ],
      ),
    );
  }
}
