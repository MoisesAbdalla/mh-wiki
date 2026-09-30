import 'package:mh_wiki/core/domain/game.dart';

/// What makes a version differ from its base monster (004 research R2).
/// Declared in the order the detail's version selector lists them.
enum VersionKind {
  tempered,
  archTempered,
  afflicted,
  frenzied,
  apex,
  risen,
  guardian;

  /// Kinds that exist in each game (data-model.md).
  static const allowedByGame = <Game, Set<VersionKind>>{
    Game.worldIceborne: {tempered, archTempered},
    Game.riseSunbreak: {afflicted, apex, risen},
    Game.wilds: {tempered, archTempered, guardian, frenzied},
  };

  bool isAllowedIn(Game game) => allowedByGame[game]!.contains(this);
}
