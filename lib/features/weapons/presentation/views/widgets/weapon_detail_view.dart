import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/material_sources.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/sharpness_bar.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_ammo_section.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_attributes_section.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_materials_section.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_tree_section.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Everything about one weapon (006 ui-contract "Armas: detail"): the
/// header, then the cards 1 Atributos, 2 Afiação (melee only), 3 Materiais
/// and 4 Árvore. Card numbers stay fixed, so a ranged weapon skips 2.
class WeaponDetailView extends StatelessWidget {
  const WeaponDetailView({
    required this.weapon,
    required this.catalog,
    required this.onSelectWeapon,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final NameLanguage language;
  final Weapon weapon;
  final WeaponCatalog catalog;
  final ValueChanged<Weapon> onSelectWeapon;
  final MaterialSourceLookup sources;

  /// Follows a "Dropado por" link; `null` shows the monsters without links.
  final ValueChanged<MaterialDropper>? onOpenMonster;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return ListView(
      key: PageStorageKey(('weapon-detail', weapon.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, 18, gutter, Space.card),
          child: WeaponHeader(weapon: weapon, language: language),
        ),
        WeaponAttributesSection(weapon: weapon, language: language),
        if (weapon.traits.hasAmmo)
          WeaponAmmoSection(traits: weapon.traits, language: language),
        if (weapon.sharpness case final sharpness?)
          NotebookSection(
            number: 2,
            title: l10n.weaponSectionSharpness,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SharpnessBar(label: l10n.sharpnessBase, units: sharpness.base),
                const SizedBox(height: 10),
                SharpnessBar(
                  label: l10n.sharpnessHandicraft,
                  units: sharpness.handicraft,
                ),
              ],
            ),
          ),
        WeaponMaterialsSection(
          weapon: weapon,
          sources: sources,
          onOpenMonster: onOpenMonster,
          language: language,
        ),
        WeaponTreeSection(
          weapon: weapon,
          catalog: catalog,
          onOpenWeapon: onSelectWeapon,
          language: language,
        ),
      ],
    );
  }
}

/// Name, "type · Raridade n · rank · n★ (estimado)", the tilted icon plate
/// and the description.
class WeaponHeader extends StatelessWidget {
  const WeaponHeader({
    required this.weapon,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final Weapon weapon;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final type = weapon.type.name.resolve(language);
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
                      weapon.name.resolve(language),
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
