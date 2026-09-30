import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
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

  group('US2 game filter', () {
    test('setGame re-filters, keeps selection and notifies', () async {
      await controller.load();
      controller.select(const MonsterId(Game.wilds, 'arkveld'));
      final before = notifications;

      controller.setGame(Game.worldIceborne);

      final state = controller.state as MonsterListLoaded;
      expect(state.sections.map((s) => s.game), [Game.worldIceborne]);
      expect(state.selectedId, const MonsterId(Game.wilds, 'arkveld'));
      expect(state.hasActiveFilters, isTrue);
      expect(notifications, before + 1);
    });

    test('setGame(null) shows every game again', () async {
      await controller.load();
      controller
        ..setGame(Game.wilds)
        ..setGame(null);

      final state = controller.state as MonsterListLoaded;
      expect(state.sections, hasLength(2));
      expect(state.hasActiveFilters, isFalse);
    });

    test('clearFilters resets the game filter', () async {
      await controller.load();
      controller
        ..setGame(Game.riseSunbreak)
        ..clearFilters();

      final state = controller.state as MonsterListLoaded;
      expect(state.query.game, isNull);
      expect(state.sections, hasLength(2));
    });
  });

  group('US3 search', () {
    test(
      'setSearchText re-filters and keeps game filter and selection',
      () async {
        await controller.load();
        controller
          ..setGame(Game.worldIceborne)
          ..select(const MonsterId(Game.wilds, 'arkveld'))
          ..setSearchText('rath');

        final state = controller.state as MonsterListLoaded;
        expect(state.query.text, 'rath');
        expect(state.query.game, Game.worldIceborne);
        expect(state.selectedId, const MonsterId(Game.wilds, 'arkveld'));
        expect(state.sections.single.monsters.single.name.en, 'Rathalos');
      },
    );

    test(
      'non-matching text gives an empty state with active filters',
      () async {
        await controller.load();
        controller.setSearchText('zzz');

        final state = controller.state as MonsterListLoaded;
        expect(state.isEmpty, isTrue);
        expect(state.hasActiveFilters, isTrue);
      },
    );

    test('clearFilters also clears the text', () async {
      await controller.load();
      controller
        ..setSearchText('zzz')
        ..clearFilters();

      final state = controller.state as MonsterListLoaded;
      expect(state.query.text, isEmpty);
      expect(state.sections, hasLength(2));
    });
  });

  group('name language (FR-025)', () {
    test(
      'onLanguageChanged re-sorts by the new language and keeps state',
      () async {
        repository.monsters = [
          buildMonster(slug: 'a', en: 'Zinogre', ptBr: 'Alfa'),
          buildMonster(slug: 'b', en: 'Anjanath', ptBr: 'Beta'),
        ];
        await controller.load();
        controller
          ..setSearchText('a')
          ..select(const MonsterId(Game.worldIceborne, 'a'));

        controller.onLanguageChanged(NameLanguage.en);

        final state = controller.state as MonsterListLoaded;
        expect(state.sections.single.monsters.map((m) => m.id.slug), [
          'b',
          'a',
        ]);
        expect(state.query.text, 'a');
        expect(state.selectedId, const MonsterId(Game.worldIceborne, 'a'));
        expect(controller.language, NameLanguage.en);
      },
    );
  });

  group('versions (004)', () {
    final rathalos = buildMonster(game: Game.wilds, en: 'Rathalos');
    final guardian = buildVersion(
      rathalos,
      VersionKind.guardian,
      slug: 'guardian-rathalos',
      en: 'Guardian Rathalos',
      ptBr: 'Rathalos Guardião',
    );

    setUp(() => repository.monsters = [guardian, rathalos]);

    test('selecting a version exposes it and its family', () async {
      await controller.load();
      controller.select(guardian.id);

      expect(controller.selectedMonster, guardian);
      expect(controller.selectedVersions, [rathalos, guardian]);
      expect((controller.state as MonsterListLoaded).selectedId, guardian.id);
    });

    test('a monster without versions has a single-member family', () async {
      repository.monsters = [rathalos];
      await controller.load();
      controller.select(rathalos.id);
      expect(controller.selectedVersions, [rathalos]);
    });

    test('nothing selected gives no family', () async {
      await controller.load();
      expect(controller.selectedVersions, isEmpty);
    });

    test('a language change keeps the selected version', () async {
      await controller.load();
      controller
        ..select(guardian.id)
        ..onLanguageChanged(NameLanguage.en);
      expect(controller.selectedMonster, guardian);
    });
  });
}
