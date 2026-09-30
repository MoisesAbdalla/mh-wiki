import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';

/// Serves in-memory datasets per game; games mapped to an [Exception] throw it.
class FakeMonsterDatasource implements MonsterDatasource {
  FakeMonsterDatasource(this.responses);

  final Map<Game, Object> responses;

  @override
  Future<Map<String, Object?>> fetchDataset(Game game) async {
    final response = responses[game];
    if (response == null) {
      throw DatasetUnavailableException('no dataset for ${game.datasetKey}');
    }
    if (response is Exception) throw response;
    return response as Map<String, Object?>;
  }
}
