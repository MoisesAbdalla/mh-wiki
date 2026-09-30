import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_catalog.dart';
import 'package:mh_wiki/features/monsters/domain/repositories/monster_repository.dart';

class MonsterRepositoryImpl implements MonsterRepository {
  MonsterRepositoryImpl(this._datasource);

  final MonsterDatasource _datasource;

  @override
  Future<MonsterCatalog> loadCatalog() async {
    final results = await Future.wait(Game.values.map(_loadGame));

    final monsters = <Monster>[];
    final failedGames = <Game, Failure>{};
    for (final (game, loaded, failure) in results) {
      if (failure != null) {
        failedGames[game] = failure;
      } else {
        monsters.addAll(loaded);
      }
    }
    return MonsterCatalog(monsters: monsters, failedGames: failedGames);
  }

  Future<(Game, List<Monster>, Failure?)> _loadGame(Game game) async {
    try {
      final json = await _datasource.fetchDataset(game);
      final dataset = MonsterDatasetDto.fromJson(json, expectedGame: game);
      return (game, MonsterDatasetMapper.toMonsters(dataset), null);
    } on DatasetUnavailableException {
      return (game, const <Monster>[], DatasetUnavailable(game));
    } on UnsupportedSchemaVersionException catch (e) {
      return (game, const <Monster>[], UnsupportedSchemaVersion(game, e.found));
    } on DatasetFormatException catch (e) {
      return (game, const <Monster>[], DatasetFormatInvalid(game, e.message));
    } on Object catch (e) {
      // Any unexpected parsing error still must not break other games.
      return (game, const <Monster>[], DatasetFormatInvalid(game, '$e'));
    }
  }
}
