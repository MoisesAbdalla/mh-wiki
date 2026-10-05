import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/filter_weapons.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';

/// 010 T008 / T014: the shipped Wilds weapons and Artian.
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

  test('every weapon of the 14 types, with pt-BR names (SC-001)', () {
    expect(catalog.weapons, hasLength(1146)); // without the 42 Artian
    expect(catalog.types, hasLength(14));
    final pt = catalog.weapons.where((w) => w.name.ptBr != null).length;
    expect(pt / catalog.weapons.length, greaterThanOrEqualTo(0.99));
  });

  test('Sieglinde: 1008, 15%, Poison 300, slots 3-2-1, its skills', () {
    final w = catalog.weapons.firstWhere((w) => w.name.en == 'Sieglinde');
    expect(w.attack, 1008);
    expect(w.affinity, 15);
    expect(w.special.single.kind, SpecialKind.poison);
    expect(w.special.single.value, 300);
    expect(w.slots, [3, 2, 1]);
    expect(w.rampageSlot, 0);
    expect(w.rank, Rank.high);
    expect(
      {for (final s in w.skills) s.name.en: s.level},
      {'Poison Duration Up': 1, 'Critical Status': 3},
    );
    expect(w.upgrade.map((c) => c.material.name.en), contains('Rathian Ruby'));
    expect(
      w.upgrade
          .firstWhere((c) => c.material.name.en == 'Rathian Ruby')
          .sources
          .monsters,
      isNotEmpty,
    );
  });

  test(
    'images resolve for at least 95% (SC-003, the rest use the type icon)',
    () {
      final withImage = catalog.weapons.where((w) {
        final path = w.imageAsset;
        return path != null && File(path).existsSync();
      }).length;
      expect(withImage / catalog.weapons.length, greaterThanOrEqualTo(0.95));
    },
  );

  group('Artian (research R2)', () {
    late ArtianType gs;
    setUp(() => gs = catalog.artianOf('great-sword')!);

    test('14 types, three rarities each', () {
      expect(catalog.artian, hasLength(14));
      for (final a in catalog.artian) {
        expect(a.bases.map((b) => b.rarity), [6, 7, 8], reason: a.type);
      }
      expect(gs.bases.map((b) => b.attack), [816, 864, 912]);
      expect(gs.base(8)!.name.ptBr, 'Varianza');
    });

    test('SC-004: five builds match the source', () {
      // Varianza, Ice from 3 parts (+30 infusion), 3 Attack parts,
      // rolls Attack ×4 and Affinity ×1.
      var r = simulateArtian(
        gs,
        const ArtianBuild(
          type: 'great-sword',
          rarity: 8,
          element: 'ice',
          elementParts: 3,
          boosts: {ArtianBoost.attack: 4, ArtianBoost.affinity: 1},
        ),
      );
      expect(r.attack, 912 + 3 * 24 + 4 * 24);
      expect(r.affinity, 5 + 5);
      expect(r.elementValue, 450 + 30);
      expect(r.infusion, isTrue);

      // Two parts of Fire: element without infusion; 2 Affinity parts.
      r = simulateArtian(
        gs,
        const ArtianBuild(
          type: 'great-sword',
          rarity: 8,
          element: 'fire',
          elementParts: 2,
          attackParts: 1,
          boosts: {ArtianBoost.element: 4},
        ),
      );
      expect(r.attack, 912 + 24);
      expect(r.affinity, 5 + 10);
      expect(r.elementValue, 450 + 4 * 80);
      expect(r.infusion, isFalse);

      // One part only: no element.
      r = simulateArtian(
        gs,
        const ArtianBuild(
          type: 'great-sword',
          rarity: 8,
          element: 'fire',
          elementParts: 1,
        ),
      );
      expect(r.elementValue, isNull);

      // Long Sword rarity 8 Sleep: 70, +30 with 3 parts.
      final ls = catalog.artianOf('long-sword')!;
      r = simulateArtian(
        ls,
        const ArtianBuild(
          type: 'long-sword',
          rarity: 8,
          element: 'sleep',
          elementParts: 3,
        ),
      );
      expect(r.attack, 627 + 3 * ls.attackPart);
      expect(r.elementValue, 70 + 30);

      // Dual Blades rarity 6 Water, Sharpness ×2.
      final db = catalog.artianOf('dual-blades')!;
      r = simulateArtian(
        db,
        const ArtianBuild(
          type: 'dual-blades',
          rarity: 6,
          element: 'water',
          elementParts: 2,
          boosts: {ArtianBoost.sharpness: 2},
        ),
      );
      final top = db.base(6)!.sharpness!.base;
      expect(
        r.sharpness!.base.fold<int>(0, (a, b) => a + b),
        top.fold<int>(0, (a, b) => a + b) + 60,
      );
    });

    test('rules: limits, bowguns and status bows', () {
      expect(
        validArtian(
          gs,
          const ArtianBuild(
            type: 'great-sword',
            rarity: 8,
            boosts: {ArtianBoost.attack: 6},
          ),
        ),
        isFalse,
      );
      expect(
        validArtian(
          gs,
          const ArtianBuild(
            type: 'great-sword',
            rarity: 8,
            boosts: {ArtianBoost.attack: 3, ArtianBoost.affinity: 3},
          ),
        ),
        isFalse,
        reason: '6 rolls',
      );
      final lbg = catalog.artianOf('light-bowgun')!;
      expect(lbg.boost(ArtianBoost.element), isNull);
      expect(lbg.boost(ArtianBoost.ammo)?.max, 2);
      final bow = catalog.artianOf('bow')!;
      expect(bow.elementsByRarity[8]!.containsKey('poison'), isFalse);
      expect(bow.elementsByRarity[8]!['blast'], 60);
    });

    test('status values by rarity, parts in range, no element', () {
      expect(gs.elementsByRarity[6]!['poison'], 150);
      expect(gs.elementsByRarity[8]!['poison'], 300);
      expect(gs.elementsByRarity[8]!['sleep'], 250);
      expect(
        validArtian(
          gs,
          const ArtianBuild(type: 'great-sword', rarity: 8, elementParts: 4),
        ),
        isFalse,
      );
      expect(
        validArtian(
          gs,
          const ArtianBuild(type: 'great-sword', rarity: 8, attackParts: -1),
        ),
        isFalse,
      );
      final none = simulateArtian(
        gs,
        const ArtianBuild(type: 'great-sword', rarity: 8, elementParts: 3),
      );
      expect(none.element, isNull);
      expect(none.elementValue, isNull);
      expect(none.infusion, isFalse);
    });
  });

  test('Gogma Artian: 14 types × 3 foci, out of the trees', () {
    final gogma = catalog.weapons.where((w) => w.gogma != null).toList();
    expect(gogma, hasLength(42));
    for (final a in catalog.artian) {
      expect(
        catalog.gogmaOf(a.type).map((w) => w.gogma),
        ArtianFocus.values,
        reason: a.type,
      );
    }
    final cb = catalog.gogmaOf('charge-blade');
    expect(cb.map((w) => w.name.ptBr).toSet(), {'Abismo Prometido'});
    expect(cb.map((w) => w.attack), [720, 648, 684]);
    expect(cb.map((w) => w.affinity), [-10, 15, 0]);
    expect(cb.first.traits.phial?.en, 'Impact');
    final trees = FilterWeapons(catalog)(
      const WeaponQuery(typeId: 'charge-blade'),
    );
    expect(
      trees.expand((t) => t.entries).where((e) => e.weapon.gogma != null),
      isEmpty,
    );
  });
}
