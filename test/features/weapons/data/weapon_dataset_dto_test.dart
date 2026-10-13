import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';

import '../../../fakes/weapon_json_fixtures.dart';

/// 006 data-model.md validation rules and mapping.
void main() {
  WeaponDatasetDto parse(Map<String, Object?> json) =>
      WeaponDatasetDto.fromJson(json, expectedGame: Game.riseSunbreak);

  WeaponCatalog catalog([Map<String, Object?>? json]) =>
      WeaponDatasetMapper.toCatalog(parse(json ?? weaponDatasetJson()));

  void rejects(List<Map<String, Object?>> weapons) => expect(
    () => parse(weaponDatasetJson(weapons: weapons)),
    throwsA(isA<DatasetFormatException>()),
  );

  test('maps a valid dataset into the catalog', () {
    final c = catalog();
    expect(c.types.map((t) => t.id), ['great-sword', 'bow']);
    expect(c.weapons, hasLength(3));

    final plus = c.weapons[1];
    expect(plus.name.ptBr, 'flammenzahn-ii pt');
    expect(plus.attack, 280);
    expect(plus.special.single.kind, SpecialKind.fire);
    expect(plus.slots, [1]);
    expect(plus.sharpness!.handicraft[5], 60);
    expect(plus.previous!.slug, 'flammenzahn-i');
    expect(c.weapons.first.next.single.slug, 'flammenzahn-ii');
    expect(plus.forge.single.material.name.ptBr, 'Escama de Anjanath');
    expect(plus.forge.single.quantity, 2);
    expect(plus.upgrade.single.points, 10);
    expect(plus.stars.estimated, isTrue);
    expect(c.weapons.last.sharpness, isNull);
  });

  test('derives the rank from rarity', () {
    final c = catalog();
    expect(c.weapons.first.rank, Rank.low); // rarity 3
    expect(c.weapons[1].rank, Rank.master); // rarity 8
  });

  test('rejects the wrong game or version', () {
    expect(
      () => parse(weaponDatasetJson(game: 'wilds')),
      throwsA(isA<DatasetFormatException>()),
    );
    expect(
      () => parse(weaponDatasetJson(schemaVersion: 2)),
      throwsA(isA<UnsupportedSchemaVersionException>()),
    );
  });

  test('rejects a duplicate slug', () => rejects([weaponJson(), weaponJson()]));

  test('rejects an unknown type, material or previous weapon', () {
    rejects([weaponJson(type: 'hunting-horn')]);
    rejects([weaponJson(material: 'mystery')]);
    rejects([weaponJson(previous: 'ghost')]);
  });

  test('rejects previous/next that disagree', () {
    rejects([
      weaponJson(next: ['b']),
      weaponJson(slug: 'b'),
    ]);
    rejects([weaponJson(), weaponJson(slug: 'b', previous: 'flammenzahn-i')]);
  });

  test('sharpness matches melee vs ranged', () {
    rejects([weaponJson(type: 'bow')]);
    rejects([weaponJson(sharpness: null)]);
  });

  test('reads the traits of a type and rejects foreign ones', () {
    final bow = catalog(
      weaponDatasetJson(
        weapons: [
          weaponJson(
            slug: 'hunters-bow',
            type: 'bow',
            sharpness: null,
            traits: {
              'arcShot': {'en': 'Brace', 'ptBr': 'Defensivo'},
              'chargeShots': [
                {
                  'name': {'en': 'Rapid Level 2', 'ptBr': 'Rápido nível 2'},
                },
                {
                  'name': {
                    'en': 'Pierce Level 3',
                    'ptBr': 'Perfurante nível 3',
                  },
                  'locked': true,
                },
              ],
              'coatings': [
                {
                  'name': {'en': 'Power Coating'},
                },
              ],
            },
          ),
        ],
      ),
    ).weapons.single;
    expect(bow.traits.arcShot!.ptBr, 'Defensivo');
    expect(bow.traits.chargeShots.last.locked, isTrue);
    expect(bow.traits.hasAmmo, isTrue);

    rejects([
      weaponJson(
        traits: {
          'phial': {'en': 'Impact'},
        },
      ),
    ]);
  });

  test('reads material sources into each cost', () {
    final json = weaponDatasetJson();
    (json['materials']! as List<Object?>)[0] = {
      'id': 'anjanath-scale',
      'name': {'en': 'Anjanath Scale'},
      'sources': {
        'gathering': [
          {
            'map': {'en': 'Jungle', 'ptBr': 'Selva'},
            'rank': 'high',
            'rate': 20,
          },
        ],
        'monsters': [
          {
            'name': {'en': 'Anjanath'},
            'rank': 'low',
            'method': {'en': 'Carves'},
            'rate': 30,
            'slug': 'anjanath',
          },
        ],
        'quests': [
          {
            'name': {'en': 'Q'},
            'category': {'en': 'Village'},
            'stars': '3',
          },
        ],
      },
    };
    final s = catalog(json).weapons.first.forge.single.sources;
    expect(s.gathering.single.map.ptBr, 'Selva');
    expect(s.gathering.single.rank, Rank.high);
    expect(s.monsters.single.small, isFalse);
    expect(s.quests.single.stars, '3');
  });

  test('reads Rampage tables and ids; rejects an unknown one', () {
    final json =
        weaponDatasetJson(
            weapons: [
              weaponJson(rarity: 5)..['rampageSkills'] = ['attack-boost-i'],
            ],
          )
          ..['rampageSkills'] = [
            {
              'id': 'attack-boost-i',
              'name': {'en': 'Attack Boost I'},
              'effect': {'en': 'Attack +4'},
            },
          ]
          ..['rampageDecorations'] = [
            {
              'id': 'attack-jewel-1',
              'name': {'en': 'Attack Jewel 1'},
              'slotLevel': 1,
              'skill': 'attack-boost-i',
              'types': ['great-sword'],
            },
          ];
    final c = catalog(json);
    expect(c.weapons.single.rampageSkills.single.effect.en, 'Attack +4');
    expect(c.rampageDecorations.single.fits('great-sword', 1), isTrue);
    expect(c.rampageDecorations.single.fits('bow', 3), isFalse);

    rejects([
      weaponJson()..['rampageSkills'] = ['ghost'],
    ]);
  });

  test('rejects out-of-range slots, rarity and attack', () {
    rejects([
      weaponJson(slots: [5]),
    ]);
    rejects([
      weaponJson(slots: [1, 1, 1, 1]),
    ]);
    rejects([weaponJson(rampageSlot: 4)]);
    rejects([weaponJson(rarity: 13)]);
    rejects([weaponJson(attack: 0)]);
  });

  test('reads the World fields (011): hidden element, Elderseal, defense, '
      'special', () {
    final world = {
      ...weaponJson(slug: 'dharma'),
      'special': [
        {'kind': 'dragon', 'value': 540, 'hidden': true},
        {'kind': 'fire', 'value': 120},
      ],
      'elderseal': 'high',
      'defenseBonus': 30,
      'worldSpecial': 'safi',
    };
    final plain = weaponJson(slug: 'plain');
    final c = catalog(weaponDatasetJson(weapons: [world, plain]));
    final w = c.weapons.first;
    expect(w.special.first.hidden, isTrue);
    expect(w.special.last.hidden, isFalse);
    expect(w.elderseal, Elderseal.high);
    expect(w.defenseBonus, 30);
    expect(w.worldSpecial, WorldSpecial.safi);
    expect(c.weapons.last.elderseal, isNull);
    expect(c.weapons.last.defenseBonus, 0);
    expect(c.weapons.last.worldSpecial, isNull);
    // Augments are an Iceborne rule; this dataset is Rise.
    expect(w.augmentSlots, 0);

    rejects([
      {...weaponJson(), 'elderseal': 'huge'},
    ]);
  });
}
