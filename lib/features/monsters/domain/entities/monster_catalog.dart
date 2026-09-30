import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';

/// Monsters from every game that loaded, plus the games that failed (FR-017).
final class MonsterCatalog {
  const MonsterCatalog({required this.monsters, required this.failedGames});

  final List<Monster> monsters;
  final Map<Game, Failure> failedGames;
}
