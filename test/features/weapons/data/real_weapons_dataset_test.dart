import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/weapons/data/datasources/asset_weapon_datasource.dart';
import 'package:mh_wiki/features/weapons/data/repositories/weapon_repository_impl.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/build_weapon_trees.dart';

/// Weapons per type in the shipped Rise dataset (006 T003 record).
const typeCounts = {
  'great-sword': 280,
  'long-sword': 298,
  'sword-and-shield': 284,
  'dual-blades': 284,
  'hammer': 292,
  'hunting-horn': 279,
  'lance': 277,
  'gunlance': 282,
  'switch-axe': 290,
  'charge-blade': 260,
  'insect-glaive': 270,
  'light-bowgun': 256,
  'heavy-bowgun': 262,
  'bow': 311,
};

/// Guards the shipped Rise weapons (006 SC-001, SC-002, SC-007).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WeaponCatalog catalog;

  setUpAll(() async {
    final result = await WeaponRepositoryImpl(AssetWeaponDatasource(rootBundle))
        .loadCatalog(Game.riseSunbreak);
    catalog = switch (result) {
      Success(:final value) => value,
      Err(:final failure) => fail('dataset failed: $failure'),
    };
  });

  test('has the 14 types with the recorded counts', () {
    expect(catalog.types.map((t) => t.id).toSet(), typeCounts.keys.toSet());
    for (final MapEntry(key: type, value: count) in typeCounts.entries) {
      expect(
        catalog.weapons.where((w) => w.type.id == type),
        hasLength(count),
        reason: type,
      );
    }
  });

  test('no cut item, every link resolves, no cycle', () {
    expect(catalog.weapons.where((w) => w.attack == 0), isEmpty);
    for (final w in catalog.weapons) {
      for (final id in [?w.previous, ...w.next]) {
        expect(catalog.byId(id), isNotNull, reason: '${w.id} → $id');
      }
    }
    expect(() => const BuildWeaponTrees()(catalog.weapons), returnsNormally);
  });

  test('the Anjanath Great Sword tree matches the game', () {
    final tree = catalog.weapons.where(
      (w) => w.treeId == 'anjanath-tree' && w.type.id == 'great-sword',
    );
    expect(tree, hasLength(6));

    final plus = tree.singleWhere(
      (w) => w.id.slug == 'gnashing-flammenzahn-plus',
    );
    expect(plus.attack, 280);
    expect(plus.special.single.kind, SpecialKind.fire);
    expect(plus.special.single.value, 28);
    expect(plus.affinity, -20);
    expect(plus.slots, [3]);
    expect(plus.rampageSlot, 2);
    expect(plus.rarity, 8);
    expect(plus.rank, Rank.master);
  });

  test('every weapon has the traits of its type (FR-014)', () {
    for (final w in catalog.weapons) {
      final t = w.traits;
      final ok = switch (w.type.id) {
        'charge-blade' || 'switch-axe' => t.phial != null,
        'gunlance' => t.shelling != null,
        'insect-glaive' => t.kinsectLevel != null,
        'hunting-horn' => t.songs.length == 3,
        'bow' => t.arcShot != null && t.chargeShots.isNotEmpty,
        'light-bowgun' ||
        'heavy-bowgun' => t.deviation != null && t.ammo.isNotEmpty,
        _ => t.isEmpty,
      };
      expect(ok, isTrue, reason: '${w.id}');
    }
  });

  test('at least 95% of the weapons have a bundled icon (SC-007)', () {
    final withIcon = catalog.weapons.where(
      (w) => w.imageAsset != null && File(w.imageAsset!).existsSync(),
    );
    expect(withIcon.length / catalog.weapons.length, greaterThanOrEqualTo(.95));
  });
}
