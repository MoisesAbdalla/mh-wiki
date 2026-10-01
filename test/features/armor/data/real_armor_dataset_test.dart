import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/armor/data/armor_repository_impl.dart';
import 'package:mh_wiki/features/armor/data/asset_armor_datasource.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/usecases/armor_queries.dart';

/// Pieces per rarity in the shipped dataset (007 T003 report).
const piecesPerRarity = {
  1: 40,
  2: 164,
  3: 105,
  4: 131,
  5: 110,
  6: 84,
  7: 64,
  8: 338,
  9: 208,
  10: 127,
};

/// Guards the shipped Rise armor (007 SC-001, SC-002, SC-007).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ArmorCatalog catalog;

  setUpAll(() async {
    final result = await ArmorRepositoryImpl(AssetArmorDatasource(rootBundle))
        .loadCatalog(Game.riseSunbreak);
    catalog = switch (result) {
      Success(:final value) => value,
      Err(:final failure) => fail('dataset failed: $failure'),
    };
  });

  test('pieces per rarity, every piece in one set', () {
    final pieces = catalog.pieces.toList();
    for (final MapEntry(key: rarity, value: count) in piecesPerRarity.entries) {
      expect(pieces.where((p) => p.rarity == rarity), hasLength(count));
    }
    expect(pieces.map((p) => p.id).toSet(), hasLength(pieces.length));
    expect(catalog.skills, hasLength(147));
    expect(catalog.decorations, hasLength(243));
  });

  test('Rathalos X matches the game', () {
    final set = catalog.set('rathalos-x')!;
    expect(set.defense, 570);
    expect(set.maxDefense, 870);
    final r = set.resistances;
    expect([r.fire, r.water, r.thunder, r.ice, r.dragon], [15, 5, -10, 5, -15]);
    expect(
      [for (final t in sumSetSkills(catalog, set)) (t.skill.id, t.level)],
      [
        ('attack-boost', 7),
        ('earplugs', 5),
        ('partbreaker', 3),
        ('windproof', 3),
        ('critical-boost', 2),
      ],
    );
    final helm = set.pieces.first;
    expect(
      helm.forge.map((c) => c.material.id),
      contains('heavy-rathalos-scrap'),
    );
  });

  test('Attack Boost: 7 levels and its decorations', () {
    expect(catalog.skill('attack-boost')!.maxLevel, 7);
    final sources = skillSources(catalog, 'attack-boost');
    expect(
      sources.decorations.map((d) => (d.decoration.id, d.decoration.slotLevel)),
      [('attack-jewel-2', 2), ('attack-jewel-plus-4', 4)],
    );
  });

  test('every skill has its level effects', () {
    expect(catalog.skills.where((s) => s.levels.isEmpty), isEmpty);
  });

  test('at least 90 % of the pieces have a bundled icon (SC-007)', () {
    final pieces = catalog.pieces.toList();
    final withIcon = pieces.where(
      (p) => p.imageAsset != null && File(p.imageAsset!).existsSync(),
    );
    expect(withIcon.length / pieces.length, greaterThanOrEqualTo(.9));
  });
}
