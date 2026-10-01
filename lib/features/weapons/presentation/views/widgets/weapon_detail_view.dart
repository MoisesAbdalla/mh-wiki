import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Everything about one weapon (006 ui-contract "Armas: detail").
class WeaponDetailView extends StatelessWidget {
  const WeaponDetailView({
    required this.weapon,
    required this.catalog,
    required this.onSelectWeapon,
    super.key,
  });

  final Weapon weapon;
  final WeaponCatalog catalog;
  final ValueChanged<Weapon> onSelectWeapon;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return ListView(
      key: PageStorageKey(('weapon-detail', weapon.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, 18, gutter, Space.card),
          child: WeaponHeader(weapon: weapon),
        ),
      ],
    );
  }
}

/// Name, "type · Raridade n · rank · n★ (estimado)", the tilted icon plate
/// and the description.
class WeaponHeader extends StatelessWidget {
  const WeaponHeader({required this.weapon, super.key});

  final Weapon weapon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final type = weapon.type.name.ptBr ?? weapon.type.name.en;
    final description = weapon.description.ptBr ?? weapon.description.en;
    final subtitle = [
      type,
      l10n.rarity(weapon.rarity),
      l10n.rankLabel(l10n.rankName(weapon.rank)),
      if (weapon.stars.estimated)
        l10n.starsEstimated(weapon.stars.value)
      else
        '${weapon.stars.value}★',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      weapon.name.ptBr ?? weapon.name.en,
                      style: notebookTitle(size: 32, height: 1.05),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: HunterPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            MonsterImage(asset: weapon.imageAsset, size: 84, emphasized: true),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: HunterPalette.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
