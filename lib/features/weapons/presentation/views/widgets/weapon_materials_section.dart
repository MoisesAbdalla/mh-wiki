import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/weapons/domain/entities/material_cost.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/material_sources.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "3 Materiais": "Melhorar" (from the previous weapon) and/or "Criar",
/// each material with its amount and the monsters that drop it.
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
      _MaterialRow(
        cost: cost,
        droppers: sources.droppersOf(cost.material.id),
        onOpenMonster: onOpenMonster,
        ruled: i < costs.length - 1,
        language: language,
      ),
  ];
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({
    required this.cost,
    required this.droppers,
    required this.onOpenMonster,
    required this.ruled,
    required this.language,
  });

  final NameLanguage language;
  final MaterialCost cost;
  final List<MaterialDropper> droppers;
  final ValueChanged<MaterialDropper>? onOpenMonster;
  final bool ruled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = cost.material.name.resolve(language);
    final points = cost.points;
    final amount = points != null
        ? l10n.materialPoints(points)
        : '×${cost.quantity}';
    final open = onOpenMonster;
    return RuledRow(
      ruled: ruled,
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          for (final dropper in droppers.take(3))
            if (open == null)
              Text(
                l10n.droppedBy(dropper.name),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: HunterPalette.textMuted),
              )
            else
              Semantics(
                link: true,
                child: InkWell(
                  onTap: () => open(dropper),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Text(
                        l10n.droppedBy(dropper.name),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HunterPalette.gold,
                          decoration: TextDecoration.underline,
                          decorationColor: HunterPalette.gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
      trailing: Text(amount, style: notebookNumber(size: 15)),
    );
  }
}
