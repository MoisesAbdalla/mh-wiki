import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/asset_monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';

/// Guards the shipped data: every bundled dataset must parse and validate.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final datasource = AssetMonsterDatasource(rootBundle);

  for (final game in Game.values) {
    test('${game.datasetKey} dataset is valid', () async {
      final json = await datasource.fetchDataset(game);
      final dataset = MonsterDatasetDto.fromJson(json, expectedGame: game);
      final monsters = MonsterDatasetMapper.toMonsters(dataset);

      expect(monsters, isNotEmpty);
      expect(
        monsters.map((m) => m.id.slug).toSet(),
        hasLength(monsters.length),
      );
    });
  }
}
