import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/asset_monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';

/// Guards the shipped data: every bundled dataset must parse and validate,
/// and every monster must have a bundled thumbnail (002 SC-001).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final datasource = AssetMonsterDatasource(rootBundle);

  Future<List<Monster>> load(Game game) async {
    final json = await datasource.fetchDataset(game);
    final dataset = MonsterDatasetDto.fromJson(json, expectedGame: game);
    return MonsterDatasetMapper.toMonsters(dataset);
  }

  for (final game in Game.values) {
    test('${game.datasetKey} dataset is valid', () async {
      final monsters = await load(game);

      expect(monsters, isNotEmpty);
      expect(
        monsters.map((m) => m.id.slug).toSet(),
        hasLength(monsters.length),
      );
    });

    test('${game.datasetKey} monsters all have a bundled thumbnail', () async {
      for (final monster in await load(game)) {
        final asset = monster.imageAsset;
        expect(asset, isNotNull, reason: '${monster.id} has no image');
        final bytes = await rootBundle.load(asset!);
        expect(bytes.lengthInBytes, greaterThan(0), reason: asset);
      }
    });
  }

  test('the same monster uses a different thumbnail in each game', () async {
    final images = <List<int>>[];
    for (final game in Game.values) {
      final rathalos = (await load(game))
          .singleWhere((m) => m.id.slug == 'rathalos');
      final data = await rootBundle.load(rathalos.imageAsset!);
      images.add(data.buffer.asUint8List());
    }
    expect(images[0], isNot(equals(images[1])));
    expect(images[1], isNot(equals(images[2])));
    expect(images[0], isNot(equals(images[2])));
  });
}
