import 'package:mh_wiki/core/domain/game.dart';

/// Each game's own icons (010 FR-009): Rise keeps its slot gems and type
/// icons; the Wilds use the game's rarity icons and slot icons.
abstract final class GameIcons {
  static String slot(int level, Game game) => game == Game.wilds
      ? 'assets/images/wilds/slots/slot${level.clamp(1, 4)}.webp'
      : 'assets/images/weapons/slots/deco$level.webp';

  /// A weapon type's icon; the Wilds one in the colour of [rarity].
  static String weaponType(String typeId, Game game, {int rarity = 8}) =>
      game == Game.wilds
      ? 'assets/images/wilds/icons/$typeId-${rarity.clamp(1, 8)}.webp'
      : 'assets/images/weapons/types/$typeId.webp';

  /// An armor part's (or `talisman`'s) Wilds icon in the colour of [rarity];
  /// null for other games.
  static String? armorPart(String part, int rarity, Game game) =>
      game == Game.wilds
      ? 'assets/images/wilds/icons/$part-${rarity.clamp(1, 8)}.webp'
      : null;
}
