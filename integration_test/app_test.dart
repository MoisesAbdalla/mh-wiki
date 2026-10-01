import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';

/// End-to-end flow on the real app with the bundled datasets (SC-008):
/// list → filter Wilds → search "rath" → open Rathalos → four sections →
/// back keeps filter and search.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// A game tab by its spoken name; the tabs are logos since 005.
  Finder gameTab(String name) => find.descendant(
    of: find.byType(GameTabs),
    matching: find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == name,
    ),
  );

  testWidgets('browse, filter, search and open a monster', (tester) async {
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    linkNameLanguage(settings: settings, monsters: monsters);
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: dependencies.createWeaponListController(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(gameTab('Monster Hunter Wilds'));
    await tester.pumpAndSettle();
    // Desktop runs do not register the test keyboard by default.
    if (!tester.testTextInput.isRegistered) tester.testTextInput.register();
    await tester.enterText(find.byType(TextField), 'rath');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rathalos').first);
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailView), findsOneWidget);
    for (final title in [
      'Fraquezas elementais',
      'Habitat',
      'Partes quebráveis',
      'Materiais',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        200,
        scrollable: find
            .descendant(
              of: find.byType(MonsterDetailView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text(title), findsOneWidget);
    }

    // Compact layout: leave the detail route. Expanded: detail is a pane.
    if (find.byType(MonsterDetailPage).evaluate().isNotEmpty) {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }

    expect(monsters.query.text, 'rath');
    expect(monsters.query.game, Game.wilds);
  });

  // 006 T032: weapons, then "Dropado por" to the monster and back.
  testWidgets('find a weapon and follow its material to the monster', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    final weapons = dependencies.createWeaponListController();
    linkNameLanguage(settings: settings, monsters: monsters, weapons: weapons);
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: weapons,
      ),
    );
    await tester.pumpAndSettle();

    // 006 T035: time from tapping Armas to the list (load + first build).
    final open = Stopwatch()..start();
    await tester.tap(find.text('Armas'));
    await tester.pumpAndSettle();
    open.stop();
    // ignore: avoid_print
    print('armas list opened in ${open.elapsedMilliseconds} ms');
    expect((weapons.state as WeaponListLoaded).query.typeId, 'great-sword');
    if (!tester.testTextInput.isRegistered) tester.testTextInput.register();
    await tester.enterText(find.byType(TextField), 'flammen');
    await tester.pumpAndSettle();

    final plus = weapons.catalog!.byId(
      const WeaponId(Game.riseSunbreak, 'gnashing-flammenzahn-plus'),
    )!;
    await tester.tap(find.text(plus.name.ptBr ?? plus.name.en));
    await tester.pumpAndSettle();
    expect(find.byType(WeaponDetailView), findsOneWidget);

    final link = find.text('Dropado por: Anjanath').first;
    await tester.scrollUntilVisible(
      link,
      200,
      scrollable: find
          .descendant(
            of: find.byType(WeaponDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();

    expect(monsters.selectedMonster?.id.slug, 'anjanath');
    await tester.scrollUntilVisible(
      find.text('Armas feitas com ele'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(MonsterDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Armas feitas com ele'), findsOneWidget);
    // Armas kept its search.
    expect((weapons.state as WeaponListLoaded).query.text, 'flammen');
  });

  // 004 T038 / SC-004: time to load every dataset and show the list, and to
  // switch games, on the real bundled data. Printed for research R6.
  testWidgets('list opening and game switch times', (tester) async {
    final total = Stopwatch()..start();
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    linkNameLanguage(settings: settings, monsters: monsters);
    await settings.load();
    final load = Stopwatch()..start();
    await monsters.load();
    load.stop();
    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: dependencies.createWeaponListController(),
      ),
    );
    await tester.pumpAndSettle();
    total.stop();
    expect(find.byType(GameTabs), findsOneWidget);

    final switches = <String, int>{};
    for (final name in [
      'Monster Hunter World: Iceborne',
      'Monster Hunter Rise: Sunbreak',
      'Monster Hunter Wilds',
    ]) {
      final watch = Stopwatch()..start();
      await tester.tap(gameTab(name));
      await tester.pumpAndSettle();
      switches[name] = watch.elapsedMilliseconds;
    }

    // ignore: avoid_print
    print(
      'T038 datasets load: ${load.elapsedMilliseconds} ms; '
      'list on screen: ${total.elapsedMilliseconds} ms; switches: $switches',
    );
    expect(total.elapsedMilliseconds, lessThan(1000));
  });
}
