import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/optimizer_controller.dart';

import '../../../fakes/build_fixtures.dart';
import '../../../fakes/optimizer_fakes.dart';

/// 009 T008 / T015 / T017: OptimizerController.
void main() {
  late AssistantController assistant;
  late FakeAssistantPrefsRepository assistantPrefs;
  late FakeOptimizerRepository repo;
  late FakeTalismanRepository talismans;
  late FakeRequestRepository requests;
  late FakeBuildSearcher searcher;

  OptimizerController controller() => OptimizerController(
    assistant: assistant,
    loadCatalog: LoadOptimizerCatalog(repo),
    talismanRepository: talismans,
    requestRepository: requests,
    searcher: searcher,
    clock: () => DateTime(2026, 10, 5),
  );

  setUp(() async {
    assistantPrefs = FakeAssistantPrefsRepository()
      ..prefs = (
        progress: const Progress(ProgressRank.post, '10'),
        weaponType: 'great-sword',
      );
    assistant = AssistantController(
      loadCatalog: LoadBuildCatalog(FakeBuildRepository()),
      saved: FakeSavedBuildsRepository(),
      prefs: assistantPrefs,
    );
    await assistant.load();
    repo = FakeOptimizerRepository();
    talismans = FakeTalismanRepository();
    requests = FakeRequestRepository();
    searcher = FakeBuildSearcher();
  });

  test('loads once; a failure can be retried', () async {
    repo.failure = const DatasetUnavailable(Game.riseSunbreak);
    final c = controller();
    await c.ensureLoaded();
    await c.ensureLoaded();
    expect(repo.loadCount, 1);
    expect(c.failure, isNotNull);
    repo.failure = null;
    await c.load();
    expect(c.catalog, isNotNull);
    expect(c.failure, isNull);
  });

  test('add, adjust and remove skills; the request is stored', () async {
    final c = controller();
    await c.load();
    c.addSkill('attack');
    expect(c.skills, {'attack': 7});
    c.setLevel('attack', 9);
    expect(c.skills['attack'], 7);
    c.setLevel('attack', 0);
    expect(c.skills['attack'], 1);
    c.addSkill('crit');
    c.setLevel('crit', 3);
    expect(requests.stored.skills, {'attack': 1, 'crit': 3});
    c.removeSkill('attack');
    expect(c.skills.keys, ['crit']);
    c
      ..setOnlyMyProgress(false)
      ..setUseTalismans(false);
    expect(requests.stored.onlyMyProgress, isFalse);
    expect(requests.stored.useTalismans, isFalse);

    final again = controller();
    await again.load();
    expect(again.skills, {'crit': 3});
    expect(again.onlyMyProgress, isFalse);
  });

  test('at most 10 skills', () async {
    final c = controller();
    await c.load();
    expect(OptimizerController.maxSkills, 10);
    c.addSkill('attack');
    expect(c.canAddSkill, isTrue);
  });

  test(
    'matching skills ignore accents and case, and skip chosen ones',
    () async {
      final c = controller();
      await c.load();
      expect(c.matchingSkills('ATT').map((s) => s.id), ['attack']);
      c.addSkill('attack');
      expect(c.matchingSkills('att'), isEmpty);
      expect(c.matchingSkills(''), isEmpty);
    },
  );

  test('search: searching, then results; cancel goes back', () async {
    final c = controller();
    await c.load();
    c
      ..addSkill('attack')
      ..setLevel('attack', 5);
    searcher.hold = true;
    final f = c.build();
    await Future<void>.delayed(Duration.zero);
    expect(c.phase, isA<OptimizerSearching>());
    expect((c.phase as OptimizerSearching).checked, 1234);
    c.cancel();
    await f;
    expect(c.phase, isA<OptimizerIdle>());

    searcher.hold = false;
    await c.build();
    final results = c.phase as OptimizerResults;
    expect(results.sets, isNotEmpty);
    expect(results.sets.first.complete, isTrue);
    expect(searcher.lastRequest!.weaponType, 'great-sword');
  });

  test('results go when the skills, progress or type change', () async {
    final c = controller();
    await c.load();
    c.addSkill('attack');
    await c.build();
    expect(c.phase, isA<OptimizerResults>());
    c.setLevel('attack', 3);
    expect(c.phase, isA<OptimizerIdle>());

    await c.build();
    assistant.setProgress(const Progress(ProgressRank.master, 'M2'));
    expect(c.phase, isA<OptimizerIdle>());

    await c.build();
    assistant.setWeaponType('bow');
    expect(c.phase, isA<OptimizerIdle>());
  });

  test('select a result and turn it into a build to save', () async {
    final c = controller();
    await c.load();
    c.addSkill('attack');
    await c.build();
    c.select(0);
    expect(c.selected, 0);
    c.select(99);
    expect(c.selected, 0);
    final build = c.curatedOf(
      0,
      name: 'Espadão · attack 7',
      stageLabel: 'MR 10+',
      sourceName: 'Caderninho · Montar build',
    )!;
    expect(build.name, 'Espadão · attack 7');
    expect(build.skills.first.skill.id, 'attack');
    expect(build.sourceUrl, isEmpty);
    expect(await assistant.save(build), isTrue);
    expect(assistant.savedBuilds.single.build.name, 'Espadão · attack 7');
  });

  test('talismans: add, edit, delete, and the search uses them', () async {
    final c = controller();
    await c.load();
    final t = UserTalisman(
      id: c.newTalismanId(),
      skills: {'crit': 3},
      slots: [2, 0, 0],
    );
    await c.saveTalisman(t);
    expect(talismans.talismans.single.skills, {'crit': 3});
    await c.saveTalisman(t.copyWith(skills: {'crit': 2}));
    expect(c.talismans.single.skills, {'crit': 2});

    c.addSkill('crit');
    c.setLevel('crit', 4);
    await c.build();
    expect(searcher.lastTalismans, hasLength(1));
    final sets = (c.phase as OptimizerResults).sets;
    expect(sets.first.talisman?.id, t.id);

    await c.deleteTalisman(t.id);
    expect(c.talismans, isEmpty);
  });

  test(
    'a fixed weapon: listed by type and rarity, kept in the request',
    () async {
      final c = controller();
      await c.load();
      expect(c.weaponsMatching('').map((w) => w.id), contains('sword-4'));
      expect(c.weaponsMatching('').map((w) => w.id), isNot(contains('bow')));
      c.setFixedWeapon('sword-weak');
      expect(requests.stored.fixedWeaponId, 'sword-weak');
      c.addSkill('attack');
      await c.build();
      final sets = (c.phase as OptimizerResults).sets;
      expect(sets.every((s) => s.weapon?.id == 'sword-weak'), isTrue);

      // Another weapon type drops a fixed weapon of the old type.
      assistant.setWeaponType('bow');
      expect(c.fixedWeaponId, isNull);
    },
  );

  test('weapon filters are per type, stored, and count matches', () async {
    final c = controller();
    await c.load();
    expect(c.traitOptions, isEmpty);
    assistant.setWeaponType('charge-blade');
    expect(c.traitOptions.map((t) => t.key), ['element', 'impact']);
    expect(c.elementOptions, ['none', 'fire', 'ice']);
    c.setWeaponTrait('impact');
    expect(c.request.weaponTrait, 'impact');
    expect(c.matchingWeaponCount, 1);
    c.setWeaponElement('fire');
    expect(c.matchingWeaponCount, 0);
    c.addSkill('attack');
    await c.build();
    expect(c.phase, isA<OptimizerIdle>(), reason: 'no weapon fits');
    expect(requests.stored.weaponFilters['charge-blade'], (
      trait: 'impact',
      element: 'fire',
    ));
    // Another type has its own (empty) filters.
    assistant.setWeaponType('great-sword');
    expect(c.weaponTrait, isNull);
    // A fixed weapon ignores the filters.
    assistant.setWeaponType('charge-blade');
    c.setFixedWeapon('cb-ice');
    expect(c.request.weaponTrait, isNull);
    expect(c.matchingWeaponCount, 1);
  });

  test('suggestions come from the curated builds of the type', () async {
    final c = controller();
    await c.load();
    // The fixtures' curated builds use skills the fixture catalog lacks.
    expect(c.suggestions, isEmpty);
  });
}
