import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_entry.dart';

/// List rows of one game, already sorted for display.
final class MonsterSection {
  const MonsterSection({required this.game, required this.entries});

  final Game game;
  final List<MonsterEntry> entries;

  /// The base monster of each row.
  List<Monster> get monsters => [for (final e in entries) e.base];
}
