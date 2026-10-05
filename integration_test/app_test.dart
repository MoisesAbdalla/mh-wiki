import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_detail_views.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/build_detail_view.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/artian_simulator_view.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end flow on the real app with the bundled datasets (SC-008):
/// list → filter Wilds → search "rath" → open Rathalos → four sections →
/// back keeps filter and search.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Every flow starts from default settings, not this machine's saved ones.
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

    final link = find.text('Anjanath ›').first;
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

  // 007 T025: Armaduras → Mestre → a skill filter → Rathalos X → skill → decoration.
  testWidgets('find a set by skill, then its skill and a decoration', (
    tester,
  ) async {
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    final weapons = dependencies.createWeaponListController();
    final armor = dependencies.createArmorController();
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: weapons,
        armorController: armor,
      ),
    );
    await tester.pumpAndSettle();

    final open = Stopwatch()..start();
    await tester.tap(find.text('Armaduras'));
    await tester.pumpAndSettle();
    open.stop();
    // ignore: avoid_print
    print('armaduras list opened in ${open.elapsedMilliseconds} ms');

    await tester.tap(find.text('Mestre'));
    await tester.pumpAndSettle();
    if (!tester.testTextInput.isRegistered) tester.testTextInput.register();
    await tester.enterText(find.byType(TextField).first, 'reforço de ata');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Reforço de Ataque'));
    await tester.pumpAndSettle();
    expect((armor.state as ArmorLoaded).setQuery.skillId, 'attack-boost');

    await armor.select(ArmorTab.sets, 'rathalos-x');
    await tester.pumpAndSettle();
    expect(find.text('570 → 870'), findsOneWidget);

    await armor.select(ArmorTab.skills, 'attack-boost');
    await tester.pumpAndSettle();
    expect(find.byType(SkillDetailView), findsOneWidget);
    final jewel = find.textContaining('Joia do Ataque 2');
    await tester.scrollUntilVisible(
      jewel,
      200,
      scrollable: find
          .descendant(
            of: find.byType(SkillDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(jewel);
    await tester.pumpAndSettle();
    expect(find.byType(DecorationDetailView), findsOneWidget);
  });

  // 010 T019: Armas → Wilds → Sieglinde → its skill in Armaduras (Wilds);
  // then an Artian built and saved.
  testWidgets('Wilds weapon to its skill, then save an Artian', (tester) async {
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    final weapons = dependencies.createWeaponListController();
    final wildsWeapons = dependencies.createWeaponListController(
      game: Game.wilds,
    );
    final wildsArmor = dependencies.createArmorController(game: Game.wilds);
    final artians = dependencies.createArtianController();
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: weapons,
        armorController: dependencies.createArmorController(),
        wildsWeaponController: wildsWeapons,
        wildsArmorController: wildsArmor,
        artianController: artians,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Armas'));
    await tester.pumpAndSettle();
    await tester.tap(gameTab('Monster Hunter Wilds').first);
    await tester.pumpAndSettle();
    expect(wildsWeapons.state, isA<WeaponListLoaded>());

    final sieglinde = wildsWeapons.catalog!.weapons.firstWhere(
      (w) => w.name.en == 'Sieglinde',
    );
    await wildsWeapons.select(sieglinde.id);
    await tester.pumpAndSettle();
    final skill = find.text('Status Crítico').last;
    await tester.ensureVisible(skill);
    await tester.pumpAndSettle();
    await tester.tap(skill);
    await tester.pumpAndSettle();
    expect(find.byType(SkillDetailView), findsOneWidget);
    expect(wildsArmor.selectedSkill?.id, 'critical-status');

    await tester.tap(find.text('Armas'));
    await tester.pumpAndSettle();
    wildsWeapons.clearSelection();
    artians.open('great-sword', 8);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Gelo').last);
    await tester.pumpAndSettle();
    final save = find.text('Salvar minha Artian');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find
          .descendant(
            of: find.byType(ArtianSimulatorView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    if (!tester.testTextInput.isRegistered) tester.testTextInput.register();
    await tester.enterText(find.byType(TextField).last, 'Gelo');
    await tester.tap(find.widgetWithText(TextButton, 'Salvar'));
    await tester.pumpAndSettle();
    expect(artians.mine.single.build.element, 'ice');
  });

  // 008 T021: Assistente → Mestre M2★ → Espadão → a build → save it → it
  // shows in Minhas builds. Preferences are mocked so the real ones stay.
  testWidgets('pick the progress, open a build and save it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    final weapons = dependencies.createWeaponListController();
    final armor = dependencies.createArmorController();
    final assistant = dependencies.createAssistantController();
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: weapons,
        armorController: armor,
        assistantController: assistant,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Assistente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mestre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('M2★'));
    await tester.pumpAndSettle();
    expect(assistant.weaponType, 'great-sword');
    expect(find.text('Para agora'), findsOneWidget);

    final build = find.text('Kamura Warrior Cleaver Raw Affinity');
    await tester.scrollUntilVisible(
      build,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(build);
    await tester.pumpAndSettle();
    expect(find.byType(BuildDetailView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BuildDetailView),
        matching: find.text('Cutelo Guerreiro Kamura'),
      ),
      findsOneWidget,
    );

    final save = find.text('Salvar em Minhas builds');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find
          .descendant(
            of: find.byType(BuildDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(assistant.savedBuilds, hasLength(1));

    assistant
      ..clearSelection()
      ..selectTab(AssistantTab.saved);
    await tester.pumpAndSettle();
    expect(build, findsOneWidget);
  });

  // 009 T019: Montar build → M6★ Espadão → 4 skills → results → open → save.
  testWidgets('build a set from skills and save it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    final weapons = dependencies.createWeaponListController();
    final armor = dependencies.createArmorController();
    final assistant = dependencies.createAssistantController();
    final optimizer = dependencies.createOptimizerController(assistant);
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(
        monsterListController: monsters,
        settingsController: settings,
        weaponListController: weapons,
        armorController: armor,
        assistantController: assistant,
        optimizerController: optimizer,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assistente'));
    await tester.pumpAndSettle();
    assistant.setProgress(const Progress(ProgressRank.master, 'M6'));
    assistant.selectTab(AssistantTab.build);
    await tester.pumpAndSettle();
    await optimizer.ensureLoaded();
    await tester.pumpAndSettle();
    expect(find.text('Habilidades que você quer'), findsOneWidget);

    optimizer
      ..addSkill('attack-boost')
      ..addSkill('critical-eye')
      ..addSkill('critical-boost')
      ..addSkill('weakness-exploit');
    await tester.pumpAndSettle();
    final watch = Stopwatch()..start();
    await optimizer.build();
    watch.stop();
    // ignore: avoid_print
    print('montar build (4 skills, M6) took ${watch.elapsedMilliseconds} ms');
    await tester.pumpAndSettle();
    expect(find.text('Opção 1'), findsOneWidget);
    expect(find.text('completa'), findsWidgets);

    optimizer.select(0);
    await tester.pumpAndSettle();
    expect(find.text('Habilidades pedidas'), findsOneWidget);

    final save = find.text('Salvar em Minhas builds');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find
          .descendant(
            of: find.byType(BuildDetailView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(assistant.savedBuilds, hasLength(1));
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
