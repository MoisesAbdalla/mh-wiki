import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/armor/data/armor_dataset_dto.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';

/// 007 data-model › Validation rules.
void main() {
  Map<String, Object?> piece(
    String id,
    String part, {
    String set = 'rathalos-x',
    List<int> slots = const [4],
    int level = 1,
    int defense = 114,
    int? maxDefense = 174,
    String material = 'rathalos-shard',
  }) => {
    'id': id,
    'set': set,
    'part': part,
    'name': {'en': id, 'ptBr': '$id pt'},
    'rarity': 9,
    'defense': defense,
    'maxDefense': ?maxDefense,
    'resistances': {
      'fire': 3,
      'water': 1,
      'thunder': -2,
      'ice': 1,
      'dragon': -3,
    },
    'slots': slots,
    'skills': [
      {'skill': 'attack-boost', 'level': level},
    ],
    'forge': [
      {'material': material, 'quantity': 4},
    ],
  };

  Map<String, Object?> dataset({
    int version = 1,
    List<Map<String, Object?>>? pieces,
    List<Map<String, Object?>>? sets,
  }) => {
    'schemaVersion': version,
    'game': 'rise_sunbreak',
    'skills': [
      {
        'id': 'attack-boost',
        'name': {'en': 'Attack Boost', 'ptBr': 'Reforço de Ataque'},
        'description': {'en': 'Increases attack power.'},
        'levels': [
          for (var i = 1; i <= 7; i++)
            {
              'level': i,
              'effect': {'en': 'Attack +$i'},
            },
        ],
      },
    ],
    'decorations': [
      {
        'id': 'attack-jewel-2',
        'name': {'en': 'Attack Jewel 2'},
        'slotLevel': 2,
        'skills': [
          {'skill': 'attack-boost', 'level': 1},
        ],
        'forge': <Object?>[],
      },
    ],
    'materials': [
      {
        'id': 'rathalos-shard',
        'name': {'en': 'Rathalos Shard', 'ptBr': 'Frag. Rathalos'},
        'sources': {
          'monsters': [
            {
              'name': {'en': 'Rathalos'},
              'rank': 'master',
              'method': {'en': 'Carves'},
              'rate': 30,
              'slug': 'rathalos',
            },
          ],
        },
      },
    ],
    'sets':
        sets ??
        [
          {
            'id': 'rathalos-x',
            'name': {'en': 'Rathalos X'},
            'rarity': 9,
            'rank': 'master',
            'pieces': ['helm', 'mail'],
          },
        ],
    'pieces': pieces ?? [piece('helm', 'head'), piece('mail', 'chest')],
  };

  void rejects(Map<String, Object?> json) => expect(
    () => readArmorDataset(json, expectedGame: Game.riseSunbreak),
    throwsA(isA<DatasetFormatException>()),
  );

  test('reads a valid dataset into the catalog', () {
    final c = readArmorDataset(dataset(), expectedGame: Game.riseSunbreak);
    final set = c.set('rathalos-x')!;
    expect(set.pieces.map((p) => p.part), [BodyPart.head, BodyPart.chest]);
    expect(set.defense, 228);
    expect(set.maxDefense, 348);
    expect(set.rank, Rank.master);
    final helm = set.pieces.first;
    expect(helm.forge.single.material.name.ptBr, 'Frag. Rathalos');
    expect(helm.forge.single.sources.monsters.single.slug, 'rathalos');
    expect(c.skill('attack-boost')!.maxLevel, 7);
    expect(c.decorations.single.slotLevel, 2);
  });

  test('rejects a wrong version', () {
    expect(
      () => readArmorDataset(
        dataset(version: 2),
        expectedGame: Game.riseSunbreak,
      ),
      throwsA(isA<UnsupportedSchemaVersionException>()),
    );
  });

  test('rejects duplicate ids and unknown references', () {
    rejects(dataset(pieces: [piece('helm', 'head'), piece('helm', 'chest')]));
    rejects(
      dataset(
        pieces: [
          piece('helm', 'head', material: 'mystery'),
          piece('mail', 'chest'),
        ],
      ),
    );
    rejects(
      dataset(
        sets: [
          {
            'id': 'rathalos-x',
            'name': {'en': 'Rathalos X'},
            'rarity': 9,
            'pieces': ['helm', 'ghost'],
          },
        ],
      ),
    );
  });

  test('rejects pieces out of order, orphaned or in another set', () {
    rejects(dataset(pieces: [piece('helm', 'chest'), piece('mail', 'head')]));
    rejects(
      dataset(
        pieces: [
          piece('helm', 'head'),
          piece('mail', 'chest'),
          piece('orphan', 'legs'),
        ],
      ),
    );
    rejects(
      dataset(
        pieces: [
          piece('helm', 'head', set: 'other'),
          piece('mail', 'chest'),
        ],
      ),
    );
  });

  test('rejects levels above the max, bad slots and max below base', () {
    rejects(
      dataset(
        pieces: [piece('helm', 'head', level: 8), piece('mail', 'chest')],
      ),
    );
    rejects(
      dataset(
        pieces: [
          piece('helm', 'head', slots: [5]),
          piece('mail', 'chest'),
        ],
      ),
    );
    rejects(
      dataset(
        pieces: [
          piece('helm', 'head', slots: [1, 1, 1, 1]),
          piece('mail', 'chest'),
        ],
      ),
    );
    rejects(
      dataset(
        pieces: [piece('helm', 'head', maxDefense: 10), piece('mail', 'chest')],
      ),
    );
  });
}
