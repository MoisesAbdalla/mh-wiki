import 'package:mh_wiki/core/domain/game.dart';

/// Each game's own icons (010 FR-009, 011 FR-010): Rise keeps its slot gems
/// and type icons; Wilds and World use their game's rarity and slot icons.
abstract final class GameIcons {
  static String slot(int level, Game game) => switch (game) {
    Game.wilds => 'assets/images/wilds/slots/slot${level.clamp(1, 4)}.webp',
    Game.worldIceborne =>
      'assets/images/world/slots/slot${level.clamp(1, 4)}.webp',
    Game.riseSunbreak => 'assets/images/weapons/slots/deco$level.webp',
  };

  /// A weapon type's icon; Wilds and World in the colour of [rarity].
  static String weaponType(String typeId, Game game, {int rarity = 8}) =>
      switch (game) {
        Game.wilds =>
          'assets/images/wilds/icons/$typeId-${rarity.clamp(1, 8)}.webp',
        Game.worldIceborne =>
          'assets/images/world/icons/$typeId-${rarity.clamp(1, 12)}.webp',
        Game.riseSunbreak => 'assets/images/weapons/types/$typeId.webp',
      };

  /// An armor part's (or `talisman`'s) icon in the colour of [rarity]; null
  /// for Rise.
  static String? armorPart(String part, int rarity, Game game) =>
      switch (game) {
        Game.wilds =>
          'assets/images/wilds/icons/$part-${rarity.clamp(1, 8)}.webp',
        Game.worldIceborne =>
          'assets/images/world/icons/$part-${rarity.clamp(1, 12)}.webp',
        Game.riseSunbreak => null,
      };
}
