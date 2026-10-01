import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "4 Árvore": the previous weapon, this one (gold) and every next one.
class WeaponTreeSection extends StatelessWidget {
  const WeaponTreeSection({
    required this.weapon,
    required this.catalog,
    required this.onOpenWeapon,
    this.number = 4,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final NameLanguage language;

  final Weapon weapon;
  final WeaponCatalog catalog;
  final ValueChanged<Weapon> onOpenWeapon;
  final int number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final previous = switch (weapon.previous) {
      final id? => catalog.byId(id),
      null => null,
    };
    final next = [for (final id in weapon.next) ?catalog.byId(id)];
    final rows = [
      if (previous != null) (previous, l10n.treePrevious),
      (weapon, l10n.treeCurrent),
      for (final w in next) (w, l10n.treeNext),
    ];
    return NotebookSection(
      number: number,
      title: l10n.weaponSectionTree,
      note: weapon.treeName.resolve(language),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (w, caption)) in rows.indexed)
            _TreeRow(
              weapon: w,
              caption: caption,
              current: w == weapon,
              language: language,
              ruled: i < rows.length - 1,
              onTap: w == weapon ? null : () => onOpenWeapon(w),
            ),
        ],
      ),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.weapon,
    required this.caption,
    required this.current,
    required this.language,
    required this.ruled,
    required this.onTap,
  });

  final NameLanguage language;
  final Weapon weapon;
  final String caption;
  final bool current;
  final bool ruled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = weapon.name.resolve(language);
    final row = RuledRow(
      ruled: ruled,
      label: Text(
        name,
        style: notebookTitle(
          size: 17,
          color: current ? HunterPalette.gold : HunterPalette.text,
        ),
      ),
      trailing: Text(
        caption,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: HunterPalette.textMuted),
      ),
    );
    return Semantics(
      button: onTap != null,
      selected: current,
      label: '$name, $caption',
      excludeSemantics: true,
      child: onTap == null
          ? row
          : InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: row,
              ),
            ),
    );
  }
}
