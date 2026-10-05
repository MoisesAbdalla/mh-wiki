import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/assistant/data/build_searcher.dart';
import 'package:mh_wiki/features/assistant/data/optimizer_json.dart';
import 'package:mh_wiki/features/assistant/data/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fakes/optimizer_fixtures.dart';

/// 009 T005: the optimizer dataset reader, the device storage and the
/// searcher.
void main() {
  group('optimizer.json', () {
    Map<String, Object?> dataset({
      Object? version = 1,
      List<Map<String, Object?>>? pieces,
      List<Map<String, Object?>>? weapons,
      List<Map<String, Object?>>? decorations,
    }) => {
      'schemaVersion': version,
      'game': 'rise_sunbreak',
      'skills': [
        {
          'id': 'attack-boost',
          'name': {'en': 'Attack Boost', 'ptBr': 'Reforço de Ataque'},
          'max': 7,
        },
      ],
      'decorations':
          decorations ??
          [
            {
              'id': 'attack-jewel-2',
              'name': {'en': 'Attack Jewel 2'},
              'slot': 2,
              'skill': 'attack-boost',
              'points': 1,
            },
          ],
      'pieces':
          pieces ??
          [
            {
              'id': 'helm',
              'name': {'en': 'Helm'},
              'part': 'head',
              'rarity': 8,
              'slots': [2, 4],
              'defense': 100,
              'skills': [
                {'skill': 'attack-boost', 'level': 2},
              ],
            },
          ],
      'weapons':
          weapons ??
          [
            {
              'id': 'sword',
              'name': {'en': 'Sword'},
              'type': 'great-sword',
              'rarity': 8,
              'slots': [1],
              'attack': 200,
            },
          ],
    };

    void rejects(Map<String, Object?> json) => expect(
      () => readOptimizerDataset(json, expectedGame: Game.riseSunbreak),
      throwsA(isA<DatasetFormatException>()),
    );

    test('reads a valid dataset; slots come highest first', () {
      final c = readOptimizerDataset(
        dataset(),
        expectedGame: Game.riseSunbreak,
      );
      expect(c.piecesByPart.values.single.single.slots, [4, 2]);
      expect(c.decorationsBySkill['attack-boost']!.single.points, 1);
      expect(c.weaponsByType['great-sword']!.single.attack, 200);
    });

    test('rejects a bad version, references, slots, parts and types', () {
      expect(
        () => readOptimizerDataset(
          dataset(version: 2),
          expectedGame: Game.riseSunbreak,
        ),
        throwsA(isA<UnsupportedSchemaVersionException>()),
      );
      rejects(
        dataset(
          decorations: [
            {
              'id': 'x',
              'name': {'en': 'x'},
              'slot': 2,
              'skill': 'nope',
              'points': 1,
            },
          ],
        ),
      );
      rejects(
        dataset(
          pieces: [
            {
              'id': 'h',
              'name': {'en': 'h'},
              'part': 'head',
              'rarity': 1,
              'slots': [5],
              'defense': 1,
            },
          ],
        ),
      );
      rejects(
        dataset(
          pieces: [
            {
              'id': 'h',
              'name': {'en': 'h'},
              'part': 'tail',
              'rarity': 1,
              'slots': [],
              'defense': 1,
            },
          ],
        ),
      );
      rejects(
        dataset(
          weapons: [
            {
              'id': 'w',
              'name': {'en': 'w'},
              'type': 'spear',
              'rarity': 1,
              'slots': [],
              'attack': 1,
            },
          ],
        ),
      );
      rejects(
        dataset(
          weapons: [
            {
              'id': 'w',
              'name': {'en': 'w'},
              'type': 'bow',
              'rarity': 1,
              'slots': [],
              'attack': 1,
            },
            {
              'id': 'w',
              'name': {'en': 'w'},
              'type': 'bow',
              'rarity': 1,
              'slots': [],
              'attack': 1,
            },
          ],
        ),
      );
    });
  });

  group('device storage', () {
    test('talismans: save, edit, delete; corrupt value is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsTalismanRepository(prefs);
      final t = UserTalisman(
        id: 't1',
        skills: {'critical-eye': 3, 'attack-boost': 1},
        slots: [1, 2, 0],
      );
      expect(await repo.store([t]), isTrue);
      final back = (await PrefsTalismanRepository(prefs).load()).single;
      expect(back.skills, {'critical-eye': 3, 'attack-boost': 1});
      expect(back.slots, [2, 1, 0]);

      await repo.store([
        back.copyWith(skills: {'handicraft': 2}),
      ]);
      expect((await repo.load()).single.skills, {'handicraft': 2});
      await repo.store(const []);
      expect(await repo.load(), isEmpty);

      await prefs.setString(PrefsTalismanRepository.key, '[{"id":1}]');
      expect(await repo.load(), isEmpty);
    });

    test('the request keeps its skill order and options', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsRequestRepository(prefs);
      expect((await repo.load()).skills, isEmpty);
      await repo.store((
        skills: {'weakness-exploit': 3, 'attack-boost': 7},
        fixedWeaponId: 'fine-kamura-cleaver',
        useTalismans: false,
        onlyMyProgress: false,
        weaponFilters: {'charge-blade': (trait: 'impact', element: null)},
      ));
      final back = await PrefsRequestRepository(prefs).load();
      expect(back.skills.keys, ['weakness-exploit', 'attack-boost']);
      expect(back.fixedWeaponId, 'fine-kamura-cleaver');
      expect(back.useTalismans, isFalse);
      expect(back.onlyMyProgress, isFalse);
      expect(back.weaponFilters['charge-blade']?.trait, 'impact');
      await prefs.setString(PrefsRequestRepository.key, 'nope');
      expect((await repo.load()).onlyMyProgress, isTrue);
    });
  });

  group('searcher', () {
    final catalog = fixtureCatalog();
    const request = BuildRequest(
      skills: {'attack': 7, 'crit': 3},
      weaponType: 'great-sword',
      progress: Progress(ProgressRank.post, '10'),
    );

    test('gives the same results as searchBuilds', () async {
      final expected = searchBuilds(catalog, request, const []);
      final got = await createBuildSearcher().search(
        catalog,
        request,
        const [],
      );
      expect(got!.map((s) => s.signature), expected.map((s) => s.signature));
    });

    test('cancel completes with null', () async {
      final searcher = createBuildSearcher();
      final future = searcher.search(catalog, request, const []);
      searcher.cancel();
      expect(await future, isNull);
    });
  });
}
