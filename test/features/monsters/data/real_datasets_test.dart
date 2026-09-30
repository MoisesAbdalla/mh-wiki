import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/datasources/asset_monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';

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

    test('${game.datasetKey} monsters all have a reference HP (003)', () async {
      for (final monster in await load(game)) {
        expect(monster.huntingInfo.hp, isNotEmpty, reason: '${monster.id}');
      }
    });

    test('${game.datasetKey} documents party HP factors (003)', () async {
      final factors = (await load(game)).first.huntingInfo.partyFactors;
      expect(factors, isNotNull);
      expect(factors!.factors.keys, containsAll([2, 3, 4]));
    });
  }

  test('World Rathalos HP matches Kiranico expeditions (003)', () async {
    final rathalos = (await load(Game.worldIceborne))
        .singleWhere((m) => m.id.slug == 'rathalos');
    expect(
      [for (final hp in rathalos.huntingInfo.hp) (hp.rank, hp.solo, hp.basis)],
      [
        (Rank.low, 4908, HpBasis.expedition),
        (Rank.high, 6565, HpBasis.expedition),
        (Rank.master, 20800, HpBasis.expedition),
      ],
    );
  });

  test('Wilds Rathalos HP matches the Kiranico quest list (003)', () async {
    final rathalos = (await load(Game.wilds))
        .singleWhere((m) => m.id.slug == 'rathalos');
    final hp = rathalos.huntingInfo.hp.single;
    expect((hp.rank, hp.solo), (Rank.high, 13500));
    expect(
      hp.partyEstimate(rathalos.huntingInfo.partyFactors, 4),
      const HpRange(32400, 32400), // Kiranico: 4 players = 32,400
    );
  });

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
