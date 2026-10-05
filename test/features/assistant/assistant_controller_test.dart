import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';

import '../../fakes/build_fixtures.dart';

/// 008 T012 / T019: AssistantController.
void main() {
  late FakeBuildRepository builds;
  late FakeSavedBuildsRepository saved;
  late FakeAssistantPrefsRepository prefs;

  AssistantController controller() => AssistantController(
    loadCatalog: LoadBuildCatalog(builds),
    saved: saved,
    prefs: prefs,
    clock: () => DateTime(2026, 10, 1, 12),
  );

  setUp(() {
    builds = FakeBuildRepository();
    saved = FakeSavedBuildsRepository();
    prefs = FakeAssistantPrefsRepository();
  });

  List<String> ids(Iterable<CuratedBuild> builds) => [
    for (final b in builds) b.id,
  ];

  test('loads once; a failure can be retried', () async {
    builds.failure = const DatasetUnavailable(Game.riseSunbreak);
    final c = controller();
    expect(c.state, isA<AssistantLoading>());
    await c.ensureLoaded();
    await c.ensureLoaded();
    expect(builds.loadCount, 1);
    expect(c.state, isA<AssistantFailed>());

    builds.failure = null;
    await c.load();
    expect(c.state, isA<AssistantLoaded>());
  });

  test('restores the progress and type, and recomputes the lists', () async {
    prefs.prefs = (
      progress: const Progress(ProgressRank.master, 'M2'),
      weaponType: 'great-sword',
    );
    final c = controller();
    await c.load();
    var state = c.state as AssistantLoaded;
    expect(ids(state.now), ['kamura-warrior', 'starter']);
    expect(ids(state.next), ['royal-order', 'fine-kamura', 'blood-awakening']);

    c.setProgress(const Progress(ProgressRank.post, '180'));
    state = c.state as AssistantLoaded;
    expect(state.next, isEmpty);
    expect(prefs.prefs.progress, const Progress(ProgressRank.post, '180'));

    c.setWeaponType('bow');
    expect(ids((c.state as AssistantLoaded).now), ['bow-build']);
    expect(prefs.prefs.weaponType, 'bow');
  });

  test('defaults to the Great Sword and the first step', () async {
    final c = controller();
    await c.load();
    expect(c.weaponType, 'great-sword');
    expect(c.progress, Progress.first);
  });

  test('Montar build cannot be opened', () async {
    final c = controller();
    await c.load();
    c.selectTab(AssistantTab.build);
    expect(c.tab, AssistantTab.recommended);
    c.selectTab(AssistantTab.saved);
    expect(c.tab, AssistantTab.saved);
  });

  test('save, rename and delete a build', () async {
    final c = controller();
    await c.load();
    final build = (c.state as AssistantLoaded).now.first;
    expect(await c.save(build), isTrue);
    expect(saved.saved.single.name, build.name);
    expect(c.savedBuilds.single.savedAt, DateTime(2026, 10, 1, 12));

    c.selectSaved(c.savedBuilds.single);
    expect(await c.rename(c.savedBuilds.single, '  Meu Espadão '), isTrue);
    expect(saved.saved.single.name, 'Meu Espadão');
    expect(c.selection?.saved?.name, 'Meu Espadão');
    expect(await c.rename(c.savedBuilds.single, '   '), isFalse);

    expect(await c.delete(c.savedBuilds.single), isTrue);
    expect(saved.saved, isEmpty);
    expect(c.selection, isNull);
  });

  test('a refused write keeps the list as it was', () async {
    final c = controller();
    await c.load();
    saved.refuse = true;
    expect(await c.save((c.state as AssistantLoaded).now.first), isFalse);
    expect(c.savedBuilds, isEmpty);
  });
}
