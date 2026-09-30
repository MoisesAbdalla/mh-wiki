import 'package:mh_wiki/features/monsters/domain/entities/monster_catalog.dart';

abstract interface class MonsterRepository {
  /// Loads every game's dataset independently. Never throws: a game whose
  /// dataset fails is reported in [MonsterCatalog.failedGames].
  Future<MonsterCatalog> loadCatalog();
}
