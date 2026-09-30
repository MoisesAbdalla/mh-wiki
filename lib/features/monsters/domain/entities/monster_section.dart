import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';

/// Monsters of one game, already sorted for display.
final class MonsterSection {
  const MonsterSection({required this.game, required this.monsters});

  final Game game;
  final List<Monster> monsters;
}
