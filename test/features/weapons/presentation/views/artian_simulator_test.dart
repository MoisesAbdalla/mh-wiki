import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/gogma_artian_view.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/data/repositories/prefs_my_artian_repository.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/load_weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/artian_simulator_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fakes/fake_weapon_repository.dart';
import '../../../../helpers/pump_app.dart';

/// 010 T016: the Artian group and the simulator.
void main() {
  late WeaponCatalog catalog;

  setUpAll(() {
    final json = jsonDecode(
      File('assets/data/wilds/weapons.json').readAsStringSync(),
    ) as Map<String, Object?>;
    catalog = WeaponDatasetMapper.toCatalog(
      WeaponDatasetDto.fromJson(json, expectedGame: Game.wilds),
    );
  });

  late WeaponListController weapons;
  late ArtianController artians;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    weapons = WeaponListController(
      loadCatalog: LoadWeaponCatalog(FakeWeaponRepository(catalog: catalog)),
      game: Game.wilds,
    );
    artians = ArtianController(repository: PrefsMyArtianRepository(prefs));
  });

  tearDown(() {
    weapons.dispose();
    artians.dispose();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(tester, WeaponsPage(controller: weapons, artians: artians));
    await tester.pumpAndSettle();
    // The group follows the type's trees.
    await tester.scrollUntilVisible(
      find.byKey(const Key('artian-group')),
      600,
      scrollable: find
          .descendant(
            of: find.byKey(const PageStorageKey('weapon-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapIt(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder stepper(String key, IconData icon) => find.descendant(
    of: find.byKey(Key(key)),
    matching: find.widgetWithIcon(IconButton, icon),
  );

  String resultText(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(const Key('artian-result')),
          matching: find.byType(Text),
        ),
      )
      .map((t) => t.data)
      .join(' ');

  testWidgets('the Artian group lists the three bases of the type', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.byKey(const Key('artian-group')), findsOneWidget);
    expect(find.text('Varianza'), findsOneWidget);
    expect(find.textContaining('elemento à escolha'), findsNWidgets(3));
  });

  testWidgets('simulator: element, parts and rolls update the result live', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    await tapIt(tester, find.text('Varianza'));
    expect(find.byType(ArtianSimulatorView), findsOneWidget);
    expect(resultText(tester), contains('984')); // 912 + 3 × 24
    expect(find.text('restam 5'), findsOneWidget);

    await tapIt(tester, find.widgetWithText(ChoiceChip, 'Gelo'));
    expect(resultText(tester), contains('480')); // 450 + infusion 30
    expect(find.text('com infusão'), findsOneWidget);

    // Two parts of Gelo: no infusion.
    await tapIt(tester, stepper('artian-part-element', Icons.remove));
    expect(resultText(tester), contains('450'));
    expect(find.text('com infusão'), findsNothing);

    // One Affinity part: −24 attack, +5%.
    await tapIt(tester, stepper('artian-part-affinity', Icons.add));
    expect(resultText(tester), contains('960'));
    expect(resultText(tester), contains('+10%'));

    for (var i = 0; i < 4; i++) {
      await tapIt(tester, stepper('artian-boost-attack', Icons.add));
    }
    expect(find.text('restam 1'), findsOneWidget);
    expect(resultText(tester), contains('${960 + 4 * 24}'));
    await tapIt(tester, stepper('artian-boost-sharpness', Icons.add));
    expect(find.text('restam 0'), findsOneWidget);
    // All rolls are used: every + is off.
    final plus = tester.widget<IconButton>(
      stepper('artian-boost-affinity', Icons.add),
    );
    expect(plus.onPressed, isNull);
    expect(find.byTooltip('Aumentar Ataque'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('save, rename and delete my Artian', (tester) async {
    await pumpPage(tester);
    await tapIt(tester, find.text('Varianza'));
    await tapIt(tester, find.widgetWithText(ChoiceChip, 'Raio'));
    await tapIt(tester, find.text('Salvar minha Artian'));
    await tester.enterText(find.byType(TextField).last, 'Raio crítico');
    await tapIt(tester, find.widgetWithText(TextButton, 'Salvar'));

    expect(artians.mine.single.name, 'Raio crítico');
    expect(find.text('minha'), findsOneWidget);
    expect(find.text('Raio crítico'), findsWidgets);

    await tapIt(tester, find.widgetWithText(OutlinedButton, 'Renomear'));
    await tester.enterText(find.byType(TextField).last, 'Trovão');
    await tapIt(tester, find.widgetWithText(TextButton, 'Salvar'));
    expect(artians.mine.single.name, 'Trovão');

    await tapIt(tester, find.widgetWithText(OutlinedButton, 'Excluir'));
    await tapIt(tester, find.widgetWithText(TextButton, 'Excluir'));
    expect(artians.mine, isEmpty);
    expect(find.text('minha'), findsNothing);
    expect(find.text('Salvar minha Artian'), findsOneWidget);
  });

  testWidgets('Gogma: a subsection, the three foci and the Gogmazios link', (
    tester,
  ) async {
    final opened = <MaterialDropper>[];
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(
      tester,
      WeaponsPage(
        controller: weapons,
        artians: artians,
        onOpenMonster: opened.add,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('gogma-group')),
      600,
      scrollable: find
          .descendant(
            of: find.byKey(const PageStorageKey('weapon-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Foco Ataque'), findsOneWidget);

    await tapIt(tester, find.textContaining('Foco Afinidade'));
    expect(find.byType(GogmaArtianView), findsOneWidget);
    expect(artians.selection?.focus, ArtianFocus.affinity);
    expect(find.text('864'), findsWidgets); // Ostrak Oblivion, Afinidade

    final foci = find.byKey(const Key('gogma-foci'));
    await tapIt(
      tester,
      find.descendant(of: foci, matching: find.text('Ataque')).last,
    );
    expect(artians.selection?.focus, ArtianFocus.attack);

    final link = find.text('Abrir em Monstros');
    await tester.scrollUntilVisible(
      link,
      300,
      scrollable: find
          .descendant(
            of: find.byType(GogmaArtianView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tapIt(tester, link);
    expect(opened.single.name, 'Gogmazios');
  });
}
