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
          buildMonster(slug: 'rathalos', en: 'Rathalos'),
          buildMonster(slug: 'anjanath', en: 'Anjanath'),
          buildMonster(game: Game.wilds, slug: 'rathalos', en: 'Rathalos'),
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

  testWidgets('filters as the user types', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'rath');
    await tester.pumpAndSettle();

    expect(find.text('Anjanath'), findsNothing);
    expect(find.text('Rathalos'), findsNWidgets(2));
    expect(controller.query.text, 'rath');
  });

  testWidgets('clear button restores the full list', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'rath');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Limpar busca'));
    await tester.pumpAndSettle();

    expect(find.text('Anjanath'), findsOneWidget);
    expect(controller.query.text, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('no match shows empty state and "Limpar filtros" resets', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('Nenhum monstro encontrado'), findsOneWidget);

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Anjanath'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
  });

  testWidgets('shows a search hint', (tester) async {
    await pumpPage(tester);
    expect(find.text('Buscar monstro'), findsOneWidget);
  });
}
