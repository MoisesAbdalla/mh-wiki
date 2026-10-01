import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/filter_weapons.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_tree_card.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_weapon_repository.dart';
import '../../../../fakes/weapon_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// 14 types × 300 weapons, in trees of 6 (a chain with one branch).
WeaponCatalog _catalog() {
  final types = [
    for (var t = 0; t < 14; t++)
      WeaponType(
        id: 'type-$t',
        name: LocalizedText(en: 'Type $t', ptBr: 'Tipo $t'),
        ranged: false,
      ),
  ];
  final weapons = <Weapon>[];
  for (final type in types) {
    for (var tree = 0; tree < 50; tree++) {
      String slug(int i) => '${type.id}-$tree-$i';
      for (var i = 0; i < 6; i++) {
        weapons.add(
          buildWeapon(
            slug(i),
            en: 'Weapon ${type.id} $tree $i',
            ptBr: 'Arma ${type.id} $tree $i',
            type: type,
            rarity: 1 + i + (tree % 4),
            tree: '${type.id}-tree-$tree',
            treeEn: 'Tree $tree',
            previous: i == 0 ? null : slug(i == 5 ? 3 : i - 1),
            next: switch (i) {
              3 => [slug(4), slug(5)],
              4 || 5 => const [],
              _ => [slug(i + 1)],
            },
          ),
        );
      }
    }
  }
  return WeaponCatalog(game: Game.riseSunbreak, types: types, weapons: weapons);
}

/// 006 SC-004: the list stays fluid with ~4,000 weapons.
void main() {
  final catalog = _catalog();

  test('the synthetic catalog has 4,200 weapons', () {
    expect(catalog.weapons, hasLength(4200));
  });

  test('filtering stays under 50 ms per query', () {
    final filter = FilterWeapons(catalog);
    filter(const WeaponQuery(typeId: 'type-0')); // warm-up (JIT)

    for (final query in [
      const WeaponQuery(typeId: 'type-3'),
      const WeaponQuery(typeId: 'type-3', rank: Rank.high),
      const WeaponQuery(typeId: 'type-3', text: 'arma'),
      const WeaponQuery(typeId: 'type-3', text: 'arma type-3 4'),
      const WeaponQuery(typeId: 'type-13', text: 'xyz'),
    ]) {
      final stopwatch = Stopwatch()..start();
      filter(query);
      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: '${query.typeId} "${query.text}"',
      );
    }
  });

  testWidgets('the list builds and a type switch settles', (tester) async {
    final controller = buildWeaponController(
      FakeWeaponRepository(catalog: catalog),
    );
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, WeaponsPage(controller: controller));
    expect(find.byType(WeaponTreeCard), findsWidgets);

    final stopwatch = Stopwatch()..start();
    controller.setType('type-7');
    await tester.pumpAndSettle();
    stopwatch.stop();
    expect(find.text('Tree 0'), findsOneWidget);
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    expect(tester.takeException(), isNull);
  });
}
