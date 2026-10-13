import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/filter_weapons.dart';

/// 011 T007: the shipped World: Iceborne weapons.
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

  Weapon named(String en) => catalog.weapons.firstWhere((w) => w.name.en == en);

  test('every World and Iceborne weapon, with pt-BR names (SC-001)', () {
    expect(catalog.weapons, hasLength(3123));
    expect(catalog.types, hasLength(14));
    final pt = catalog.weapons.where((w) => w.name.ptBr != null).length;
    expect(pt / catalog.weapons.length, greaterThanOrEqualTo(0.99));
    expect(catalog.weapons.map((w) => w.rarity).toSet(), {
      for (var r = 1; r <= 12; r++) r,
    });
    expect(catalog.weapons.map((w) => w.rank).toSet(), Rank.values.toSet());
  });

  test('Dharma Inabalável (the US1 independent test)', () {
    final w = named('Immovable Dharma');
    expect(w.name.ptBr, 'Dharma Inabalável');
    expect(w.attack, 1344);
    expect(w.affinity, 0);
    expect(w.special.single.kind, SpecialKind.dragon);
    expect(w.special.single.value, 540);
    expect(w.special.single.hidden, isTrue);
    expect(w.elderseal, Elderseal.high);
    expect(w.defenseBonus, 30);
    expect(w.slots, [1, 1]);
    expect(w.augmentSlots, 1);
    expect(w.rank, Rank.master);
    expect(catalog.byId(w.previous!)!.name.en, 'Dragonseal Sword I');
    expect(w.upgrade.map((c) => c.material.id), contains('shara-ishvalda-gem'));
    expect(w.sharpness!.handicraft.last, 30);
  });

  test('augments by rarity, and type traits', () {
    expect(named('Dragonseal Sword I').augmentSlots, 3); // rarity 10
    expect(named('Dragonseal Sword II').augmentSlots, 2); // rarity 11
    expect(named('Dragonbone Cleaver III').augmentSlots, 0);
    final cb = catalog.weapons.firstWhere((w) => w.type.id == 'charge-blade');
    expect(cb.traits.phial, isNotNull);
    final ig = catalog.weapons.firstWhere((w) => w.type.id == 'insect-glaive');
    expect(ig.traits.kinsectBonus?.ptBr, isNotNull);
    final hh = catalog.weapons.firstWhere((w) => w.type.id == 'hunting-horn');
    expect(hh.traits.notes, hasLength(3));
    final lbg = catalog.weapons.firstWhere(
      (w) => w.type.id == 'light-bowgun' && w.traits.ammo.isNotEmpty,
    );
    expect(lbg.traits.specialAmmo?.en, 'Wyvernblast');
    expect(lbg.sharpness, isNull);
  });

  test('Especiais: out of the trees, in their own list', () {
    final specials = catalog.specialsOf('great-sword');
    expect(specials, isNotEmpty);
    expect(
      specials.map((w) => w.worldSpecial).toSet(),
      WorldSpecial.values.toSet(),
    );
    final trees = FilterWeapons(catalog)(
      const WeaponQuery(typeId: 'great-sword'),
    );
    expect(
      trees
          .expand((t) => t.entries)
          .where((e) => e.weapon.worldSpecial != null),
      isEmpty,
    );
  });

  test('materials name the World monsters that drop them', () {
    final sources = catalog.weapons
        .expand((w) => [...w.forge, ...w.upgrade])
        .where((c) => c.sources.monsters.isNotEmpty)
        .length;
    expect(sources, greaterThan(1000));
  });
}
