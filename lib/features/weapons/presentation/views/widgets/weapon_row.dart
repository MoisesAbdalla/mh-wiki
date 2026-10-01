import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_special_label.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// One weapon in a tree card: icon, name and rank, and attack, special and
/// affinity at the right; indented by its depth in the tree.
class WeaponRow extends StatelessWidget {
  const WeaponRow({
    required this.weapon,
    required this.depth,
    required this.onTap,
    this.selected = false,
    this.ruled = true,
    super.key,
  });

  final Weapon weapon;
  final int depth;
  final bool selected;
  final bool ruled;
  final VoidCallback onTap;

  /// Left padding of a row: `14 + 16 × depth`, depth capped at 3.
  static double indent(int depth) => 14 + 16.0 * math.min(depth, 3);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.bodySmall;
    final name = weapon.name.ptBr ?? weapon.name.en;
    final rank = l10n.rankLabel(l10n.rankName(weapon.rank));
    final affinity = weapon.affinity;

    final stats = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${weapon.attack}', style: notebookNumber(size: 16, bold: true)),
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: [
            for (final special in weapon.special)
              WeaponSpecialLabel(special: special, size: 12),
            if (affinity != 0)
              Text(
                l10n.signedPercent(affinity),
                style: notebookNumber(
                  size: 13,
                  color: affinity < 0
                      ? HunterPalette.negative
                      : HunterPalette.textMuted,
                ),
              ),
          ],
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: [
        name,
        rank,
        '${l10n.attack} ${weapon.attack}',
        for (final s in weapon.special)
          '${l10n.specialName(s.kind)} ${s.value}',
        if (affinity != 0) '${l10n.affinity} ${l10n.signedPercent(affinity)}',
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: selected ? HunterPalette.panelHighlight : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: selected ? HunterPalette.gold : Colors.transparent,
                  width: 2,
                ),
                bottom: ruled
                    ? const BorderSide(color: HunterPalette.borderSubtle)
                    : BorderSide.none,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                key: const ValueKey('weapon-row-padding'),
                padding: EdgeInsets.fromLTRB(indent(depth), 8, 14, 8),
                child: Row(
                  children: [
                    MonsterImage(asset: weapon.imageAsset, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: notebookTitle(size: 16, height: 1.15),
                          ),
                          Text(rank, style: muted),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(child: stats),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
