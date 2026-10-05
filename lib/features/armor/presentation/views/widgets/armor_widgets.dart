import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/slot_icon.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Armor enums as localized UI strings (constitution Principle VII).
extension ArmorLabels on AppLocalizations {
  String partName(BodyPart part) => switch (part) {
    BodyPart.head => partHead,
    BodyPart.chest => partChest,
    BodyPart.arms => partArms,
    BodyPart.waist => partWaist,
    BodyPart.legs => partLegs,
  };
}

/// Filled squares up to [level], outlined ones up to [max], and "+n" above
/// the max (007 ui-contract, set Habilidades card).
class SkillPips extends StatelessWidget {
  const SkillPips({required this.level, required this.max, super.key});

  final int level;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExcludeSemantics(
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 1; i <= max; i++)
            Container(
              key: ValueKey(('pip', i, i <= level)),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: i <= level ? HunterPalette.gold : null,
                border: Border.all(
                  color: i <= level ? HunterPalette.gold : HunterPalette.border,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          if (level > max)
            Text(
              l10n.skillOverflow(level - max),
              style: notebookNumber(size: 12, color: HunterPalette.gold),
            ),
        ],
      ),
    );
  }
}

/// The five resistances with their element symbols; negatives in the error
/// colour.
class ResistanceRow extends StatelessWidget {
  const ResistanceRow({required this.resistances, super.key});

  final Resistances resistances;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final values = [
      (ElementType.fire, resistances.fire),
      (ElementType.water, resistances.water),
      (ElementType.thunder, resistances.thunder),
      (ElementType.ice, resistances.ice),
      (ElementType.dragon, resistances.dragon),
    ];
    String signed(int v) => v < 0 ? '−${-v}' : '$v';
    return Semantics(
      label: l10n.resistancesSemantics(
        values.map((e) => '${l10n.elementName(e.$1)} ${e.$2}').join(', '),
      ),
      excludeSemantics: true,
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          for (final (element, value) in values)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElementIcon(element: element, size: 16),
                const SizedBox(width: 4),
                Text(
                  signed(value),
                  style: notebookNumber(
                    size: 16,
                    color: value < 0
                        ? HunterPalette.negative
                        : HunterPalette.text,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A row of slot gems (highest first).
class SlotGems extends StatelessWidget {
  const SlotGems({
    required this.slots,
    this.size = 20,
    this.game = Game.riseSunbreak,
    super.key,
  });

  final List<int> slots;
  final double size;
  final Game game;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (i, level) in slots.indexed) ...[
        if (i > 0) const SizedBox(width: 2),
        _gem(level),
      ],
    ],
  );

  Widget _gem(int level) => SlotIcon(level: level, size: size, game: game);
}

/// A decoration's own icon (Wilds), or its slot gem.
class DecorationIcon extends StatelessWidget {
  const DecorationIcon({
    required this.decoration,
    this.game = Game.riseSunbreak,
    this.size = 26,
    super.key,
  });

  final ArmorDecoration decoration;
  final Game game;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = decoration.iconAsset;
    final gem = SlotGems(slots: [decoration.slotLevel], size: size, game: game);
    if (icon == null) return gem;
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        icon,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => gem,
      ),
    );
  }
}

/// The kind of a Wilds skill as a small seal ("arma", "conjunto"…).
class SkillKindSeal extends StatelessWidget {
  const SkillKindSeal({required this.kind, super.key});

  final SkillKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = switch (kind) {
      SkillKind.weapon => l10n.skillKindWeapon,
      SkillKind.armor => l10n.skillKindArmor,
      SkillKind.set => l10n.skillKindSet,
      SkillKind.group => l10n.skillKindGroup,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: HunterPalette.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: HunterPalette.textMuted, fontSize: 11),
        ),
      ),
    );
  }
}
