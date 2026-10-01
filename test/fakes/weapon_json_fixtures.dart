/// Small weapon datasets in the `weapons.json` shape (006 data-model.md).
Map<String, Object?> weaponJson({
  String slug = 'flammenzahn-i',
  String type = 'great-sword',
  int rarity = 3,
  int attack = 140,
  List<int> slots = const [1],
  int rampageSlot = 1,
  Object? sharpness = _melee,
  String? previous,
  List<String> next = const [],
  String material = 'anjanath-scale',
}) => {
  'slug': slug,
  'kiranicoId': '123',
  'type': type,
  'name': {'en': slug, 'ptBr': '$slug pt'},
  'description': {'en': 'A weapon.'},
  'rarity': rarity,
  'tree': 'anjanath-tree',
  'treeName': {'en': 'Anjanath Tree'},
  'attack': attack,
  'affinity': -20,
  'special': [
    {'kind': 'fire', 'value': 20},
  ],
  'slots': slots,
  'rampageSlot': rampageSlot,
  'sharpness': ?sharpness,
  'previous': previous,
  'next': next,
  'forge': [
    {'material': material, 'quantity': 2},
  ],
  'upgrade': [
    {'material': 'anjanath-material', 'points': 10},
  ],
  'stars': {'value': 4, 'estimated': true},
  'sources': [
    {'name': 'Kiranico', 'url': 'https://mhrise.kiranico.com'},
  ],
};

const _melee = {
  'base': [130, 100, 40, 50, 20, 10, 0],
  'handicraft': [130, 100, 40, 50, 20, 60, 0],
};

Map<String, Object?> weaponDatasetJson({
  int schemaVersion = 1,
  String game = 'rise_sunbreak',
  List<Map<String, Object?>>? weapons,
}) => {
  'schemaVersion': schemaVersion,
  'game': game,
  'generatedAt': '2026-10-01',
  'weaponTypes': [
    {
      'id': 'great-sword',
      'name': {'en': 'Great Sword', 'ptBr': 'Espadão'},
      'ranged': false,
    },
    {
      'id': 'bow',
      'name': {'en': 'Bow', 'ptBr': 'Arco'},
      'ranged': true,
    },
  ],
  'materials': [
    {
      'id': 'anjanath-scale',
      'name': {'en': 'Anjanath Scale', 'ptBr': 'Escama de Anjanath'},
    },
    {
      'id': 'anjanath-material',
      'name': {'en': 'Anjanath Material(s)'},
    },
  ],
  'weapons':
      weapons ??
      [
        weaponJson(next: ['flammenzahn-ii']),
        weaponJson(
          slug: 'flammenzahn-ii',
          rarity: 8,
          attack: 280,
          previous: 'flammenzahn-i',
        ),
        weaponJson(slug: 'hunters-bow', type: 'bow', sharpness: null),
      ],
};
