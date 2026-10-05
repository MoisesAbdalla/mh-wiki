import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/game_icons.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';

/// One slot icon of the game; falls back to the level number in a ring.
class SlotIcon extends StatelessWidget {
  const SlotIcon({
    required this.level,
    this.rampage = false,
    this.size = 26,
    this.game = Game.riseSunbreak,
    super.key,
  });

  final int level;
  final bool rampage;
  final double size;

  /// Whose slot icons to use (010 FR-009).
  final Game game;

  static String iconAsset(int level, {Game game = Game.riseSunbreak}) =>
      GameIcons.slot(level, game);

  @override
  Widget build(BuildContext context) {
    final color = rampage ? HunterPalette.gold : HunterPalette.text;
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        SlotIcon.iconAsset(level, game: game),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        // The gem is white and grey: gold tints it for the Rampage slot.
        color: rampage ? HunterPalette.gold : null,
        colorBlendMode: BlendMode.modulate,
        errorBuilder: (_, _, _) => DecoratedBox(
          decoration: BoxDecoration(
            shape: rampage ? BoxShape.rectangle : BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              '$level',
              style: notebookNumber(size: 12, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
