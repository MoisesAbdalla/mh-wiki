import 'dart:async';

import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_catalog.dart';
import 'package:mh_wiki/features/monsters/domain/repositories/monster_repository.dart';

/// Returns a configurable catalog; [completer] lets tests hold the load open.
class FakeMonsterRepository implements MonsterRepository {
  FakeMonsterRepository({
    this.monsters = const [],
    this.failedGames = const {},
  });

  List<Monster> monsters;
  Map<Game, Failure> failedGames;
  Completer<void>? completer;
  int loadCount = 0;

  @override
  Future<MonsterCatalog> loadCatalog() async {
    loadCount++;
    await completer?.future;
    return MonsterCatalog(monsters: monsters, failedGames: failedGames);
  }
}
