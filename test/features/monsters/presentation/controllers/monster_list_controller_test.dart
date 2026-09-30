import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/models/monster_list_state.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';

void main() {
  late FakeMonsterRepository repository;
  late MonsterListController controller;
  late int notifications;

  setUp(() {
    repository = FakeMonsterRepository(
      monsters: [
        buildMonster(
          game: Game.worldIceborne,
          slug: 'rathalos',
          en: 'Rathalos',
        ),
        buildMonster(game: Game.wilds, slug: 'arkveld', en: 'Arkveld'),
      ],
    );
    controller = buildController(repository);
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  group('US1 loading and selection', () {
    test('starts in Loading', () {
      expect(controller.state, isA<MonsterListLoading>());
    });

    test('load() emits Loaded with sections', () async {
      await controller.load();

      final state = controller.state as MonsterListLoaded;
      expect(state.sections.map((s) => s.game), [
        Game.worldIceborne,
        Game.wilds,
      ]);
      expect(state.failedGames, isEmpty);
      expect(state.isEmpty, isFalse);
      expect(notifications, greaterThanOrEqualTo(1));
    });

    test('all games failing emits LoadFailed and retry recovers', () async {
      repository
        ..monsters = []
        ..failedGames = {for (final g in Game.values) g: DatasetUnavailable(g)};
      await controller.load();
      expect(controller.state, isA<MonsterListLoadFailed>());

      repository
        ..monsters = [buildMonster()]
        ..failedGames = {}
        ..completer = Completer<void>();
      final retry = controller.load();
      expect(controller.state, isA<MonsterListLoading>());
      repository.completer!.complete();
      await retry;
      expect(controller.state, isA<MonsterListLoaded>());
    });

    test(
      'partial failure keeps loaded games and reports failed ones',
      () async {
        repository.failedGames = {
          Game.riseSunbreak: const DatasetUnavailable(Game.riseSunbreak),
        };
        await controller.load();

        final state = controller.state as MonsterListLoaded;
        expect(state.failedGames.keys, [Game.riseSunbreak]);
        expect(state.sections, hasLength(2));
      },
    );

    test('select sets the selected monster and notifies', () async {
      await controller.load();
      final before = notifications;

      controller.select(const MonsterId(Game.wilds, 'arkveld'));

      expect(
        (controller.state as MonsterListLoaded).selectedId,
        const MonsterId(Game.wilds, 'arkveld'),
      );
      expect(controller.selectedMonster?.name.en, 'Arkveld');
      expect(notifications, before + 1);
    });

    test('clearSelection removes the selection', () async {
      await controller.load();
      controller.select(const MonsterId(Game.wilds, 'arkveld'));

      controller.clearSelection();

      expect((controller.state as MonsterListLoaded).selectedId, isNull);
      expect(controller.selectedMonster, isNull);
    });
  });
}
