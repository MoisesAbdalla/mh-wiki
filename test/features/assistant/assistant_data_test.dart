import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/data/assistant_repositories.dart';
import 'package:mh_wiki/features/assistant/data/build_json.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fakes/build_fixtures.dart';

/// 008 research R3, R5 and data-model rules.
void main() {
  group('Progress', () {
    test('orders the whole scale', () {
      final order = [
        for (final r in ProgressRank.values)
          for (final s in Progress.stepsOf(r)) Progress(r, s),
      ];
      for (var i = 1; i < order.length; i++) {
        expect(order[i - 1].compareTo(order[i]), lessThan(0));
      }
      expect(
        const Progress(ProgressRank.master, 'M6') <=
            const Progress(ProgressRank.post, '10'),
        isTrue,
      );
    });

    test('rejects a step that does not fit the rank', () {
      expect(() => Progress.parse('high', 'M2'), throwsFormatException);
      expect(Progress.parse('post', '100').step, '100');
    });
  });

  test('splitBuilds: now up to the progress, next after it', () {
    final split = splitBuilds(
      buildFixtures(),
      const Progress(ProgressRank.master, 'M2'),
      'great-sword',
    );
    expect(split.now.map((b) => b.id), ['kamura-warrior', 'starter']);
    expect(split.next.map((b) => b.id), [
      'royal-order',
      'fine-kamura',
      'blood-awakening',
    ]);
  });

  group('builds JSON', () {
    Map<String, Object?> dataset(List<Map<String, Object?>> builds) => {
      'schemaVersion': 1,
      'game': 'rise_sunbreak',
      'builds': builds,
    };

    test('a build survives write → read', () {
      final b = buildFixture('x');
      final back = readBuildsDataset(
        dataset([
          jsonDecode(jsonEncode(writeBuild(b))) as Map<String, Object?>,
        ]),
        expectedGame: Game.riseSunbreak,
      ).builds.single;
      expect(back.name, b.name);
      expect(back.stage, b.stage);
      expect(back.pieces[1].alternatives.single.known, isFalse);
      expect(back.talisman!.level, 3);
      expect(back.pieces.first.item.ref.rarity, 8);
      expect(back.decorations.first.count, 3);
    });

    test('rejects a duplicate id, a bad type, stage or parts', () {
      Map<String, Object?> json(void Function(Map<String, Object?> b) edit) {
        final b = jsonDecode(
          jsonEncode(writeBuild(buildFixture('x'))),
        ) as Map<String, Object?>;
        edit(b);
        return b;
      }

      void rejects(List<Map<String, Object?>> builds) => expect(
        () =>
            readBuildsDataset(dataset(builds), expectedGame: Game.riseSunbreak),
        throwsA(isA<DatasetFormatException>()),
      );
      rejects([json((_) {}), json((_) {})]);
      rejects([json((b) => b['weaponType'] = 'spear')]);
      rejects([
        json((b) => (b['stage']! as Map<String, Object?>)['step'] = 'M9'),
      ]);
      rejects([
        json((b) {
          final pieces = b['pieces']! as List<Object?>;
          (pieces[1]! as Map<String, Object?>)['part'] = 'head';
        }),
      ]);
    });
  });

  group('device storage', () {
    test(
      'saved builds: save, rename, delete; corrupt value is empty',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PrefsSavedBuildsRepository(prefs);
        final saved = SavedBuild(
          id: 's1',
          name: 'Meu Espadão',
          savedAt: DateTime(2026, 10, 1),
          build: buildFixture('fine-kamura'),
        );
        expect(await repo.store([saved]), isTrue);
        final again = await PrefsSavedBuildsRepository(prefs).load();
        expect(again.single.name, 'Meu Espadão');
        expect(again.single.build.pieces, hasLength(2));

        await repo.store([again.single.renamed('Outro')]);
        expect((await repo.load()).single.name, 'Outro');
        await repo.store(const []);
        expect(await repo.load(), isEmpty);

        await prefs.setString(PrefsSavedBuildsRepository.key, '{not json');
        expect(await repo.load(), isEmpty);
      },
    );

    test('progress and weapon type', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsAssistantPrefsRepository(prefs);
      expect((await repo.load()).progress, Progress.first);
      await repo.store((
        progress: const Progress(ProgressRank.master, 'M2'),
        weaponType: 'great-sword',
      ));
      final back = await PrefsAssistantPrefsRepository(prefs).load();
      expect(back.progress, const Progress(ProgressRank.master, 'M2'));
      expect(back.weaponType, 'great-sword');
      await prefs.setString(PrefsAssistantPrefsRepository.progressKey, 'x:y');
      expect((await repo.load()).progress, Progress.first);
    });
  });

  group('shipped builds.json', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    late List<CuratedBuild> builds;

    setUpAll(() async {
      final result = await AssetBuildRepository(rootBundle)
          .loadCatalog(Game.riseSunbreak);
      builds = switch (result) {
        Success(:final value) => value.builds,
        Err(:final failure) => fail(
          'dataset failed: ${(failure as dynamic).detail}',
        ),
      };
    });

    test('Master Rank builds for all 14 types', () {
      final types = {
        for (final b in builds)
          if (b.stage.rank == ProgressRank.master ||
              b.stage.rank == ProgressRank.post)
            b.weaponType,
      };
      expect(types, weaponTypeIds);
    });

    test('Kamura Warrior Cleaver at M1, Fine Kamura Cleaver at M6', () {
      final kamura = builds.firstWhere(
        (b) => b.name.startsWith('Kamura Warrior Cleaver'),
      );
      expect(kamura.stage, const Progress(ProgressRank.master, 'M1'));
      expect(kamura.pieces.first.item.ref.name.en, "Hunter's Helm X");
      final fine = builds.firstWhere(
        (b) => b.name.startsWith('Fine Kamura Cleaver'),
      );
      expect(fine.stage, const Progress(ProgressRank.master, 'M6'));
      final waist = fine.pieces.firstWhere((p) => p.part == BuildPart.waist);
      expect(waist.alternatives.single.name.en, 'Nephilim Tassets');
      expect(
        fine.skills.firstWhere((s) => s.skill.id == 'attack-boost').level,
        7,
      );
    });

    test('at least 95 % of the items are in the catalog (SC-002)', () {
      final refs = [
        for (final b in builds) ...[
          b.weapon.ref,
          for (final p in b.pieces) p.item.ref,
          for (final s in b.skills) s.skill,
        ],
      ];
      expect(refs.where((r) => r.known).length / refs.length, greaterThan(.95));
    });
  });
}
