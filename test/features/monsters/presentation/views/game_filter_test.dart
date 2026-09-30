import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/core/presentation/widgets/ornament_header.dart';
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

  Finder tab(String label) =>
      find.descendant(of: find.byType(GameTabs), matching: find.text(label));

  Future<void> pumpPage(WidgetTester tester) async {
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, MonstersPage(controller: controller));
  }

  testWidgets('offers "Todos" plus the three games', (tester) async {
    await pumpPage(tester);

    for (final label in ['Todos', 'World', 'Rise', 'Wilds']) {
      expect(tab(label), findsOneWidget);
    }
  });

  testWidgets('"Todos" shows an ornament header per game in order', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byType(OrnamentHeader), findsNWidgets(3));
    final headers = ['World : Iceborne', 'Rise : Sunbreak', 'Wilds'];
    final positions = [
      for (final header in headers)
        tester
            .getTopLeft(
              find.descendant(
                of: find.byType(OrnamentHeader),
                matching: find.text(header),
              ),
            )
            .dy,
    ];
    expect(positions, orderedEquals([...positions]..sort()));
  });

  testWidgets('selecting Wilds shows only Wilds monsters without header', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(tab('Wilds'));
    await tester.pumpAndSettle();

    expect(find.text('Arkveld'), findsOneWidget);
    expect(find.text('Anjanath'), findsNothing);
    expect(find.text('Magnamalo'), findsNothing);
    expect(find.byType(OrnamentHeader), findsNothing);
  });

  testWidgets('empty result with active filter offers to clear it', (
    tester,
  ) async {
    controller = buildController(
      FakeMonsterRepository(monsters: [buildMonster(game: Game.wilds)]),
    );
    await controller.load();
    await pumpPage(tester);

    await tester.tap(tab('Rise'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum monstro encontrado'), findsOneWidget);
    expect(find.text('Há filtros ativos.'), findsOneWidget);

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Rathalos'), findsOneWidget);
    expect(controller.query.game, isNull);
  });
}
