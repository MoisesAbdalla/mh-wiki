import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_row.dart';

import '../../../../helpers/pump_app.dart';

/// 010 T010: a Wilds weapon's detail.
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

  testWidgets('Sieglinde: weapon skills card, no Rampage, skill link', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final opened = <String>[];
    final weapon = catalog.weapons.firstWhere((w) => w.name.en == 'Sieglinde');
    setWindowSize(tester, const Size(420, 2400));
    await pumpApp(
      tester,
      Scaffold(
        body: WeaponDetailView(
          weapon: weapon,
          catalog: catalog,
          onSelectWeapon: (_) {},
          onOpenSkill: opened.add,
        ),
      ),
    );
    expect(find.text('Sieglinde'), findsWidgets);
    expect(find.text('1008'), findsOneWidget);
    expect(find.text('Habilidades da arma'), findsOneWidget);
    expect(find.text('Status Crítico'), findsOneWidget);
    expect(find.textContaining('Rampage'), findsNothing);
    expect(find.textContaining('estimado'), findsNothing);
    expect(
      find.bySemanticsLabel('Status Crítico, nível 3 de 3'),
      findsOneWidget,
    );
    await tester.tap(find.text('Status Crítico'));
    expect(opened.single, 'critical-status');
    handle.dispose();
  });

  test('a Wilds weapon without a render uses its rarity type icon', () {
    final noImage = catalog.weapons.firstWhere((w) => w.imageAsset == null);
    expect(
      weaponImage(noImage),
      'assets/images/wilds/icons/${noImage.type.id}-${noImage.rarity}.webp',
    );
  });
}
