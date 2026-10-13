import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/load_weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';

import '../../../../fakes/fake_weapon_repository.dart';
import '../../../../helpers/pump_app.dart';

/// 011 T009: the World weapon list and detail.
void main() {
  late WeaponCatalog catalog;

  setUpAll(() {
    final json = jsonDecode(
      File('assets/data/world_iceborne/weapons.json').readAsStringSync(),
    ) as Map<String, Object?>;
    catalog = WeaponDatasetMapper.toCatalog(
      WeaponDatasetDto.fromJson(json, expectedGame: Game.worldIceborne),
    );
  });

  testWidgets('Dharma Inabalável: hidden element, Elderseal, defense, '
      'augments, no Rampage', (tester) async {
    final handle = tester.ensureSemantics();
    final weapon = catalog.weapons.firstWhere(
      (w) => w.name.en == 'Immovable Dharma',
    );
    setWindowSize(tester, const Size(420, 3000));
    await pumpApp(
      tester,
      Scaffold(
        body: WeaponDetailView(
          weapon: weapon,
          catalog: catalog,
          onSelectWeapon: (_) {},
        ),
      ),
    );
    expect(find.text('Dharma Inabalável'), findsWidgets);
    expect(find.text('1344'), findsOneWidget);
    expect(find.text('(540)'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Dragão 540, oculto')), findsWidgets);
    expect(find.textContaining('Liberar Elemento'), findsOneWidget);
    expect(find.text('Selo do Ancião'), findsOneWidget);
    expect(find.text('Alto'), findsOneWidget);
    expect(find.text('+30'), findsOneWidget);
    expect(find.text('Aumentos (Iceborne)'), findsOneWidget);
    expect(find.text('1 espaço · Raridade 12'), findsOneWidget);
    expect(find.textContaining('Rampage'), findsNothing);
    expect(find.textContaining('estimado'), findsNothing);
    expect(find.text('Espada Selo Dragão I'), findsWidgets); // tree
    handle.dispose();
  });

  testWidgets('a special opens with "Como obter" instead of materials', (
    tester,
  ) async {
    final weapon = catalog.specialsOf('great-sword').last;
    setWindowSize(tester, const Size(420, 2400));
    await pumpApp(
      tester,
      Scaffold(
        body: WeaponDetailView(
          weapon: weapon,
          catalog: catalog,
          onSelectWeapon: (_) {},
        ),
      ),
    );
    expect(find.text('Como obter'), findsOneWidget);
    expect(find.byKey(const Key('world-special-how-to')), findsOneWidget);
    expect(find.text('Materiais'), findsNothing);
  });

  testWidgets('World list: Mestre rank, hidden element row, Especiais card', (
    tester,
  ) async {
    final controller = WeaponListController(
      loadCatalog: LoadWeaponCatalog(FakeWeaponRepository(catalog: catalog)),
      game: Game.worldIceborne,
    );
    addTearDown(controller.dispose);
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(tester, WeaponsPage(controller: controller));
    await tester.pumpAndSettle();
    controller.setRank(Rank.master);
    controller.setSearchText('dharma');
    await tester.pumpAndSettle();
    expect(find.text('Dharma Inabalável'), findsOneWidget);
    expect(find.text('(540)'), findsOneWidget);

    controller.setSearchText('');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('world-specials')),
      800,
      scrollable: find
          .descendant(
            of: find.byKey(const PageStorageKey('weapon-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Especiais'), findsOneWidget);
    expect(find.textContaining('Kulve Taroth · sorteada'), findsWidgets);
  });
}
