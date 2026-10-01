import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/app_home.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';

import '../fakes/controllers.dart';
import '../fakes/fake_monster_repository.dart';
import '../fakes/monster_fixtures.dart';
import '../helpers/pump_app.dart';

/// 006 US2: "Dropado por" opens the monster in Monstros, keeping Armas.
void main() {
  testWidgets('"Dropado por" opens the monster and keeps the Armas filters', (
    tester,
  ) async {
    final anjanath = buildMonster(
      game: Game.riseSunbreak,
      slug: 'anjanath',
      en: 'Anjanath',
      drops: [
        drop(
          material('anjanath-hardfang', 'Anjanath Hardfang'),
          Rank.master,
          DropMethod.carve,
        ),
      ],
    );
    final monsters = buildController(
      FakeMonsterRepository(monsters: [anjanath]),
    );
    await monsters.load();
    final weapons = buildWeaponController();

    setWindowSize(tester, const Size(400, 900));
    await pumpApp(tester, AppHome(monsters: monsters, weapons: weapons));

    await tester.tap(find.text('Armas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mestre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Presardente Rangedora+'));
    await tester.pumpAndSettle();

    // Hardfang and the Anjanath points both link to it.
    final link = find.text('Anjanath ›').first;
    await tester.scrollUntilVisible(
      link,
      300,
      scrollable: find
          .descendant(
            of: find.byType(WeaponDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailPage), findsOneWidget);
    expect(monsters.selectedMonster?.id, anjanath.id);
    // Armas keeps its rank filter.
    expect((weapons.state as WeaponListLoaded).query.rank, Rank.master);
  });
}
