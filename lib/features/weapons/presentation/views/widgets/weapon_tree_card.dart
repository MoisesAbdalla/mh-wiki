import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_tree.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_row.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// One upgrade tree as a card: its name and weapon count, then the weapons
/// in upgrade order, indented by depth (006 ui-contract).
class WeaponTreeCard extends StatelessWidget {
  const WeaponTreeCard({
    required this.tree,
    required this.onSelect,
    this.selectedId,
    super.key,
  });

  final WeaponTree tree;
  final WeaponId? selectedId;
  final ValueChanged<Weapon> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final title = tree.name.ptBr ?? tree.name.en;
    final count = tree.entries.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter - 10, 5, gutter - 10, 5),
      child: Material(
        color: HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.borderSubtle),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              label: l10n.weaponTreeSemantics(title, l10n.weaponCount(count)),
              excludeSemantics: true,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: HunterPalette.borderSubtle),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10,
                    children: [
                      Text(title, style: notebookTitle(size: 18)),
                      Text(
                        l10n.weaponCount(count),
                        style: notebookNumber(
                          size: 13,
                          color: HunterPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (final (i, entry) in tree.entries.indexed)
              WeaponRow(
                key: ValueKey(entry.weapon.id),
                weapon: entry.weapon,
                depth: entry.depth,
                selected: entry.weapon.id == selectedId,
                ruled: i < tree.entries.length - 1,
                onTap: () => onSelect(entry.weapon),
              ),
          ],
        ),
      ),
    );
  }
}
