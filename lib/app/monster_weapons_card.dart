import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "Armas feitas com ele" on a Rise monster (006 ui-contract): up to five
/// weapons, then "Ver todas (n)". Shows nothing when [weapons] is empty.
class MonsterWeaponsCard extends StatelessWidget {
  const MonsterWeaponsCard({
    required this.number,
    required this.weapons,
    required this.onOpenWeapon,
    required this.onSeeAll,
    super.key,
  });

  /// How many rows show before "Ver todas".
  static const preview = 5;

  final int number;

  /// Already sorted, master rank first.
  final List<Weapon> weapons;
  final ValueChanged<Weapon> onOpenWeapon;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (weapons.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final shown = weapons.take(preview).toList();

    return NotebookSection(
      number: number,
      title: l10n.weaponsMadeFrom,
      trailing: Text(
        '(${weapons.length})',
        style: notebookNumber(size: 15, color: HunterPalette.textMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, weapon) in shown.indexed)
            _WeaponLink(
              weapon: weapon,
              ruled: i < shown.length - 1,
              caption: [
                weapon.type.name.ptBr ?? weapon.type.name.en,
                l10n.rankLabel(l10n.rankName(weapon.rank)),
              ].join(' · '),
              captionStyle: muted,
              onTap: () => onOpenWeapon(weapon),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onSeeAll,
              child: Text(l10n.seeAllWeapons(weapons.length)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeaponLink extends StatelessWidget {
  const _WeaponLink({
    required this.weapon,
    required this.ruled,
    required this.caption,
    required this.captionStyle,
    required this.onTap,
  });

  final Weapon weapon;
  final bool ruled;
  final String caption;
  final TextStyle? captionStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = weapon.name.ptBr ?? weapon.name.en;
    return Semantics(
      button: true,
      label: '$name, $caption',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: RuledRow(
            ruled: ruled,
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: notebookTitle(size: 17)),
                Text(caption, style: captionStyle),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: HunterPalette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
