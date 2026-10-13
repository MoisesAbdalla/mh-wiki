import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "2 Munição" for bows and bowguns, which have no sharpness (006 US4): the
/// arc shot, charge shots and coatings of a bow; the deviation, recoil,
/// reload and the ammo each bowgun loads.
class WeaponAmmoSection extends StatelessWidget {
  const WeaponAmmoSection({
    required this.traits,
    this.number = 2,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final WeaponTraits traits;
  final int number;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final usable = [
      for (final c in traits.coatings)
        if (!c.locked) c,
    ];

    return NotebookSection(
      number: number,
      title: l10n.weaponSectionAmmo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (traits.arcShot case final arc?)
            RuledRow(
              label: Text(l10n.arcShot, style: muted),
              trailing: Text(arc.resolve(language)),
            ),
          if (traits.chargeShots.isNotEmpty) ...[
            RuledCaption(l10n.chargeShots),
            for (final (i, shot) in traits.chargeShots.indexed)
              RuledRow(
                ruled: i < traits.chargeShots.length - 1,
                label: Text(
                  l10n.chargeLevel(i + 1),
                  style: notebookNumber(
                    size: 14,
                    color: HunterPalette.textMuted,
                  ),
                ),
                trailing: Text(
                  shot.locked
                      ? '${shot.name.resolve(language)} (${l10n.needsSkill})'
                      : shot.name.resolve(language),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: shot.locked
                        ? HunterPalette.textMuted
                        : HunterPalette.text,
                  ),
                ),
              ),
          ],
          if (usable.isNotEmpty) ...[
            RuledCaption(l10n.coatings),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in usable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: HunterPalette.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        c.name.resolve(language),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
          for (final stat in [traits.deviation, traits.recoil, traits.reload])
            if (stat != null) RuledRow(label: Text(stat.resolve(language))),
          if (traits.specialAmmo case final special?)
            RuledRow(
              label: Text(l10n.traitSpecialAmmo, style: muted),
              trailing: Text(special.resolve(language)),
            ),
          if (traits.ammo.isNotEmpty) ...[
            RuledCaption(l10n.weaponSectionAmmo),
            for (final (i, ammo) in traits.ammo.indexed)
              _AmmoRow(ammo: ammo, ruled: i < traits.ammo.length - 1),
            const SizedBox(height: 6),
            Text(
              '${l10n.ammoLevels} · ${l10n.ammoElementalLevels}',
              style: muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _AmmoRow extends StatelessWidget {
  const _AmmoRow({required this.ammo, required this.ruled});

  final AmmoCapacity ammo;
  final bool ruled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = l10n.ammoName(ammo.kind);
    final values = [for (final n in ammo.capacity) n == 0 ? '–' : '$n'];
    return Semantics(
      label: l10n.ammoCapacitySemantics(name, values.join(', ')),
      excludeSemantics: true,
      child: RuledRow(
        ruled: ruled,
        label: Text(name),
        trailing: Text(values.join(' · '), style: notebookNumber(size: 15)),
      ),
    );
  }
}
