import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MonsterListController controller;

  setUp(() async {
    controller = buildController(
      FakeMonsterRepository(
        monsters: [
          buildMonster(
            game: Game.worldIceborne,
            slug: 'anjanath',
            en: 'Anjanath',
          ),
          buildMonster(
            game: Game.riseSunbreak,
            slug: 'magnamalo',
            en: 'Magnamalo',
          ),
          buildMonster(game: Game.wilds, slug: 'arkveld', en: 'Arkveld'),
        ],
      ),
    );
    await controller.load();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, MonstersPage(controller: controller));
  }

  testWidgets('offers "Todos" plus the three games', (tester) async {
    await pumpPage(tester);

    for (final label in [
      'Todos',
      'World: Iceborne',
      'Rise: Sunbreak',
      'Wilds',
    ]) {
      expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
    }
  });

  testWidgets('"Todos" shows a header per game in order', (tester) async {
    await pumpPage(tester);

    final headers = [
      'Monster Hunter World: Iceborne',
      'Monster Hunter Rise: Sunbreak',
      'Monster Hunter Wilds',
    ];
    final positions = [
      for (final header in headers) tester.getTopLeft(find.text(header)).dy,
    ];
    expect(positions, orderedEquals([...positions]..sort()));
  });

  testWidgets('selecting Wilds shows only Wilds monsters without header', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Wilds'));
    await tester.pumpAndSettle();

    expect(find.text('Arkveld'), findsOneWidget);
    expect(find.text('Anjanath'), findsNothing);
    expect(find.text('Magnamalo'), findsNothing);
    expect(find.text('Monster Hunter Wilds'), findsNothing);
  });

  testWidgets('empty result with active filter offers to clear it', (
    tester,
  ) async {
    controller = buildController(
      FakeMonsterRepository(monsters: [buildMonster(game: Game.wilds)]),
    );
    await controller.load();
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Rise: Sunbreak'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum monstro encontrado'), findsOneWidget);
    expect(find.text('Há filtros ativos.'), findsOneWidget);

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Rathalos'), findsOneWidget);
    expect(controller.query.game, isNull);
  });
}
