import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late FakeMonsterRepository repository;
  late MonsterListController controller;

  setUp(() {
    repository = FakeMonsterRepository(
      monsters: [
        richMonster(),
        for (var i = 0; i < 30; i++)
          buildMonster(
            slug: 'monster-$i',
            en: 'Monster ${i.toString().padLeft(2, '0')}',
          ),
      ],
    );
    controller = buildController(repository);
  });

  tearDown(() => controller.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, MonstersPage(controller: controller));
  }

  testWidgets('shows a progress indicator while loading', (tester) async {
    repository.completer = Completer<void>();
    setWindowSize(tester, const Size(400, 800));
    unawaited(controller.load());
    await pumpApp(tester, MonstersPage(controller: controller), settle: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.completer!.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('list tiles show name, game and placeholder image', (
    tester,
  ) async {
    await controller.load();
    await pumpPage(tester);

    expect(find.text('Monster 00'), findsOneWidget);
    expect(find.text('Flying Wyvern'), findsWidgets);
    expect(find.byIcon(Icons.pets), findsWidgets);
  });

  testWidgets('tapping a monster opens its detail; back keeps scroll', (
    tester,
  ) async {
    final listScrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    await controller.load();
    await pumpPage(tester);

    await tester.drag(listScrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
    final offsetBefore = tester
        .state<ScrollableState>(listScrollable)
        .position
        .pixels;
    expect(offsetBefore, greaterThan(0));

    await tester.tap(find.text('Monster 12'));
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailPage), findsOneWidget);
    for (final title in [
      'Fraquezas elementais',
      'Habitat',
      'Partes quebráveis',
      'Materiais',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget);
    }

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailPage), findsNothing);
    expect(controller.selectedMonster, isNull);
    final offsetAfter = tester
        .state<ScrollableState>(listScrollable)
        .position
        .pixels;
    expect(offsetAfter, offsetBefore);
  });

  testWidgets('all games failing shows retry, which reloads', (tester) async {
    repository
      ..monsters = []
      ..failedGames = {for (final g in Game.values) g: DatasetUnavailable(g)};
    await controller.load();
    await pumpPage(tester);

    expect(find.text('Tentar novamente'), findsOneWidget);

    repository
      ..monsters = [buildMonster()]
      ..failedGames = {};
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Rathalos'), findsOneWidget);
  });

  testWidgets('a failed game shows a non-blocking banner', (tester) async {
    repository.failedGames = {Game.wilds: const DatasetUnavailable(Game.wilds)};
    await controller.load();
    await pumpPage(tester);

    expect(
      find.text('Não foi possível carregar os dados de: Monster Hunter Wilds'),
      findsOneWidget,
    );
    expect(find.text('Monster 00'), findsOneWidget);
  });
}
