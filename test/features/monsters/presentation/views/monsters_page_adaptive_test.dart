import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';

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
          buildMonster(slug: 'anjanath', en: 'Anjanath'),
          buildMonster(game: Game.wilds, slug: 'arkveld', en: 'Arkveld'),
        ],
      ),
    );
    await controller.load();
  });

  tearDown(() => controller.dispose());

  testWidgets('wide window shows list and detail side by side', (tester) async {
    setWindowSize(tester, const Size(1200, 800));
    await pumpApp(tester, MonstersPage(controller: controller));

    expect(find.text('Selecione um monstro'), findsOneWidget);

    await tester.tap(find.text('Arkveld'));
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailPage), findsNothing);
    expect(find.byType(MonsterDetailView), findsOneWidget);
    expect(find.text('Anjanath'), findsOneWidget); // list still visible
    expect(find.text('Arkveld'), findsNWidgets(2)); // tile + detail header

    await tester.tap(find.text('Anjanath'));
    await tester.pumpAndSettle();
    expect(controller.selectedMonster?.id.slug, 'anjanath');
  });

  testWidgets('shrinking with a selection opens the detail route', (
    tester,
  ) async {
    setWindowSize(tester, const Size(1200, 800));
    await pumpApp(tester, MonstersPage(controller: controller));
    controller.select(const MonsterId(Game.wilds, 'arkveld'));
    await tester.pumpAndSettle();

    setWindowSize(tester, const Size(400, 800));
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailPage), findsOneWidget);
    expect(controller.selectedMonster?.id.slug, 'arkveld');
  });

  testWidgets(
    'growing with the detail route open pops it and keeps selection',
    (tester) async {
      setWindowSize(tester, const Size(400, 800));
      await pumpApp(tester, MonstersPage(controller: controller));
      await tester.tap(find.text('Arkveld'));
      await tester.pumpAndSettle();
      expect(find.byType(MonsterDetailPage), findsOneWidget);

      setWindowSize(tester, const Size(1200, 800));
      await tester.pumpAndSettle();

      expect(find.byType(MonsterDetailPage), findsNothing);
      expect(find.byType(MonsterDetailView), findsOneWidget);
      expect(controller.selectedMonster?.id.slug, 'arkveld');
    },
  );
}
