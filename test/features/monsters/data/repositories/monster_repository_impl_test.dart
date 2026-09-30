import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/repositories/monster_repository_impl.dart';

import '../../../../fakes/dataset_json_fixtures.dart';
import '../../../../fakes/fake_monster_datasource.dart';

void main() {
  Map<Game, Object> allGames() => {
    for (final game in Game.values)
      game: validDatasetJson(game: game.datasetKey),
  };

  test('loads monsters from every game', () async {
    final repository = MonsterRepositoryImpl(FakeMonsterDatasource(allGames()));

    final catalog = await repository.loadCatalog();

    expect(catalog.monsters, hasLength(3));
    expect(catalog.monsters.map((m) => m.id.game).toSet(), Game.values.toSet());
    expect(catalog.failedGames, isEmpty);
  });

  test('an unavailable game does not remove the others (FR-017)', () async {
    final responses = allGames()
      ..[Game.wilds] = DatasetUnavailableException('missing');
    final repository = MonsterRepositoryImpl(FakeMonsterDatasource(responses));

    final catalog = await repository.loadCatalog();

    expect(catalog.monsters, hasLength(2));
    expect(catalog.monsters.any((m) => m.id.game == Game.wilds), isFalse);
    expect(catalog.failedGames.keys, [Game.wilds]);
    expect(catalog.failedGames[Game.wilds], isA<DatasetUnavailable>());
  });

  test('a malformed dataset is reported as format failure', () async {
    final responses = allGames()
      ..[Game.riseSunbreak] = (validDatasetJson(game: 'rise_sunbreak')
        ..remove('monsters'));
    final repository = MonsterRepositoryImpl(FakeMonsterDatasource(responses));

    final catalog = await repository.loadCatalog();

    expect(catalog.failedGames[Game.riseSunbreak], isA<DatasetFormatInvalid>());
    expect(catalog.monsters, hasLength(2));
  });

  test('an unsupported schema version is reported as such', () async {
    final responses = allGames()
      ..[Game.worldIceborne] = (validDatasetJson()..['schemaVersion'] = 9);
    final repository = MonsterRepositoryImpl(FakeMonsterDatasource(responses));

    final catalog = await repository.loadCatalog();

    expect(
      catalog.failedGames[Game.worldIceborne],
      isA<UnsupportedSchemaVersion>().having((f) => f.found, 'found', 9),
    );
  });

  test('never throws even when every game fails', () async {
    final repository = MonsterRepositoryImpl(FakeMonsterDatasource({}));

    final catalog = await repository.loadCatalog();

    expect(catalog.monsters, isEmpty);
    expect(catalog.failedGames.keys.toSet(), Game.values.toSet());
  });
}
