import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/app_home.dart';
import 'package:mh_wiki/app/monster_weapons_card.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapon_detail_page.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_row.dart';

import '../fakes/controllers.dart';
import '../fakes/fake_monster_repository.dart';
import '../fakes/monster_fixtures.dart';
import '../fakes/weapon_fixtures.dart';
import '../helpers/pump_app.dart';

/// 006 US3: "Armas feitas com ele" on Rise monsters.
void main() {
  final anjanathDrops = [
    drop(
      material('anjanath-scale', 'Anjanath Scale'),
      Rank.low,
      DropMethod.carve,
    ),
    drop(
      material('anjanath-hardfang', 'Anjanath Hardfang'),
      Rank.master,
      DropMethod.carve,
    ),
  ];
  final anjanath = buildMonster(
    game: Game.riseSunbreak,
    slug: 'anjanath',
    en: 'Anjanath',
    drops: anjanathDrops,
  );
  final worldAnjanath = buildMonster(
    slug: 'anjanath',
    en: 'Anjanath',
    drops: anjanathDrops,
  );
  final kulu = buildMonster(
    game: Game.riseSunbreak,
    slug: 'kulu-ya-ku',
    en: 'Kulu-Ya-Ku',
  );

  late MonsterListController monsters;
  late WeaponListController weapons;

  Future<void> openMonster(WidgetTester tester, Monster monster) async {
    monsters = buildController(
      FakeMonsterRepository(monsters: [anjanath, worldAnjanath, kulu]),
    );
    await monsters.load();
    weapons = buildWeaponController();
    setWindowSize(tester, const Size(1200, 6000));
    await pumpApp(tester, AppHome(monsters: monsters, weapons: weapons));
    monsters.select(monster.id);
    await tester.pumpAndSettle();
  }

  testWidgets('a Rise monster lists the weapons made from it', (tester) async {
    await openMonster(tester, anjanath);

    expect(find.text('Armas feitas com ele'), findsOneWidget);
    expect(find.text('(2)'), findsOneWidget);
    expect(find.text('Presardente Rangedora+'), findsOneWidget);
    expect(find.text('Espadão · Rank Mestre'), findsOneWidget);
    expect(find.text('Ver todas (2)'), findsOneWidget);
  });

  testWidgets('World monsters and monsters without weapons have no card', (
    tester,
  ) async {
    await openMonster(tester, worldAnjanath);
    expect(find.byType(MonsterWeaponsCard), findsNothing);

    monsters.select(kulu.id);
    await tester.pumpAndSettle();
    expect(find.text('Armas feitas com ele'), findsNothing);
  });

  testWidgets('tapping a weapon opens it in Armas', (tester) async {
    await openMonster(tester, anjanath);
    await tester.tap(find.text('Presardente Rangedora+'));
    await tester.pumpAndSettle();

    expect(weapons.selectedWeapon?.id, wid('gnashing-flammenzahn-plus'));
    expect(find.byType(WeaponRow), findsWidgets); // the Armas list is shown
  });

  testWidgets('"Ver todas" filters Armas with a removable chip', (
    tester,
  ) async {
    await openMonster(tester, anjanath);
    await tester.tap(find.text('Ver todas (2)'));
    await tester.pumpAndSettle();

    final state = weapons.state as WeaponListLoaded;
    expect(state.query.onlyIds, hasLength(2));
    expect(find.text('Armas de Anjanath'), findsOneWidget);
    expect(find.byType(WeaponRow), findsNWidgets(2));

    await tester.tap(find.byTooltip('Limpar filtros'));
    await tester.pumpAndSettle();
    expect((weapons.state as WeaponListLoaded).query.onlyIds, isNull);
  });

  testWidgets('on a phone, a weapon opens its detail page', (tester) async {
    monsters = buildController(FakeMonsterRepository(monsters: [anjanath]));
    await monsters.load();
    weapons = buildWeaponController();
    setWindowSize(tester, const Size(400, 900));
    await pumpApp(tester, AppHome(monsters: monsters, weapons: weapons));
    monsters.select(anjanath.id);
    await tester.pumpAndSettle();

    final row = find.text('Presardente Rangedora+');
    await tester.scrollUntilVisible(
      row,
      400,
      scrollable: find
          .descendant(
            of: find.byType(MonsterDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(WeaponDetailPage), findsOneWidget);
  });
}
