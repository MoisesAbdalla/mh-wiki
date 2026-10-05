import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/armor/data/armor_dataset_dto.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/usecases/load_armor_catalog.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/armor_page.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/data/repositories/prefs_my_artian_repository.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/load_weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_armor_repository.dart';
import '../fakes/fake_weapon_repository.dart';
import '../helpers/pump_app.dart';

/// 010 T018: the Wilds screens at 320 dp with 200 % text, and the guidelines.
void main() {
  late WeaponCatalog weaponCatalog;
  late ArmorCatalog armorCatalog;

  setUpAll(() {
    Map<String, Object?> read(String path) =>
        jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
    weaponCatalog = WeaponDatasetMapper.toCatalog(
      WeaponDatasetDto.fromJson(
        read('assets/data/wilds/weapons.json'),
        expectedGame: Game.wilds,
      ),
    );
    armorCatalog = readArmorDataset(
      read('assets/data/wilds/armor.json'),
      expectedGame: Game.wilds,
    );
  });

  Future<void> pumpScaled(WidgetTester tester, Widget child) async {
    setWindowSize(tester, const Size(320, 640));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHunterTheme(),
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: child,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<(WeaponListController, ArtianController)> weapons() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return (
      WeaponListController(
        loadCatalog: LoadWeaponCatalog(
          FakeWeaponRepository(catalog: weaponCatalog),
        ),
        game: Game.wilds,
      ),
      ArtianController(repository: PrefsMyArtianRepository(prefs)),
    );
  }

  ArmorController armor() => ArmorController(
    loadCatalog: LoadArmorCatalog(FakeArmorRepository(catalog: armorCatalog)),
    game: Game.wilds,
  );

  Future<void> scrollThrough(WidgetTester tester) async {
    final page = find.byType(Scrollable).last;
    for (var i = 0; i < 6; i++) {
      await tester.drag(page, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  }

  testWidgets('weapons: list, Sieglinde and the Artian simulator', (
    tester,
  ) async {
    final (list, artians) = await weapons();
    await pumpScaled(tester, WeaponsPage(controller: list, artians: artians));
    expect(tester.takeException(), isNull);

    final sieglinde = weaponCatalog.weapons.firstWhere(
      (w) => w.name.en == 'Sieglinde',
    );
    await list.select(sieglinde.id);
    await tester.pumpAndSettle();
    await scrollThrough(tester);
    Navigator.of(tester.element(find.byType(Scrollable).last)).pop();
    await tester.pumpAndSettle();

    artians.open('great-sword', 8);
    await tester.pumpAndSettle();
    await scrollThrough(tester);
  });

  testWidgets('armor: set, Joias and Talismãs', (tester) async {
    final controller = armor();
    await pumpScaled(tester, ArmorPage(controller: controller));
    expect(tester.takeException(), isNull);

    final arkveld = armorCatalog.sets.firstWhere(
      (s) => s.name.en == 'Arkveld α',
    );
    for (final (tab, id) in [
      (ArmorTab.sets, arkveld.id),
      (ArmorTab.decorations, armorCatalog.decorations.first.id),
      (ArmorTab.talismans, armorCatalog.talismans.first.id),
    ]) {
      await controller.select(tab, id);
      await tester.pumpAndSettle();
      await scrollThrough(tester);
      controller.clearSelection();
      await tester.pumpAndSettle();
    }
    controller.setTab(ArmorTab.talismans);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    controller.setTab(ArmorTab.decorations);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('simulator: contrast, labels and tap targets', (tester) async {
    final (list, artians) = await weapons();
    setWindowSize(tester, const Size(1200, 2600));
    await pumpApp(tester, WeaponsPage(controller: list, artians: artians));
    await tester.pumpAndSettle();
    artians.open('great-sword', 8);
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('Arkveld α: contrast, labels and tap targets', (tester) async {
    final controller = armor();
    setWindowSize(tester, const Size(1200, 2600));
    await pumpApp(tester, ArmorPage(controller: controller));
    await tester.pumpAndSettle();
    await controller.select(
      ArmorTab.sets,
      armorCatalog.sets.firstWhere((s) => s.name.en == 'Arkveld α').id,
    );
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
