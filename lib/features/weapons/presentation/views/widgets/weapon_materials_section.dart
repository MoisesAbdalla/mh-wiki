import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/material_cost_row.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "3 Materiais": "Melhorar" (from the previous weapon) and/or "Criar".
/// Each material shows short seals of where it comes from in the weapon's
/// rank (large monster link, small monster, gathering, quest), and a tap
/// opens the full list with rates (006 US5, mockup option B).
class WeaponMaterialsSection extends StatelessWidget {
  const WeaponMaterialsSection({
    required this.weapon,
    required this.sources,
    this.onOpenMonster,
    this.number = 3,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final NameLanguage language;

  final Weapon weapon;

  /// Large monsters of the app that drop each material (link targets).
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final int number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NotebookSection(
      number: number,
      title: l10n.weaponSectionMaterials,
      child: weapon.upgrade.isEmpty && weapon.forge.isEmpty
          ? EmptySectionText(l10n.noMaterials)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (weapon.upgrade.isNotEmpty)
                  ..._group(l10n.upgradeMaterials, weapon.upgrade),
                if (weapon.forge.isNotEmpty)
                  ..._group(l10n.forgeMaterials, weapon.forge),
              ],
            ),
    );
  }

  List<Widget> _group(String caption, List<MaterialCost> costs) => [
    RuledCaption(caption),
    for (final (i, cost) in costs.indexed)
      MaterialCostRow(
        key: ValueKey((caption, cost.material.id)),
        cost: cost,
        droppers: sources.droppersOf(cost.material.id),
        ranked: cost.sources.forRank(weapon.rank),
        onOpenMonster: onOpenMonster,
        ruled: i < costs.length - 1,
        language: language,
      ),
  ];
}
