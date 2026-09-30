/// Returns a fresh, valid dataset map (schema v1) that tests may mutate.
Map<String, Object?> validDatasetJson({String game = 'world_iceborne'}) => {
  'schemaVersion': 1,
  'game': game,
  'generatedAt': '2026-09-29',
  'sources': [
    {'name': 'Test source', 'url': 'https://example.com/source'},
  ],
  'habitats': [
    {
      'id': 'ancient-forest',
      'name': {'en': 'Ancient Forest', 'ptBr': 'Floresta Antiga'},
    },
  ],
  'materials': [
    {
      'id': 'rathalos-scale',
      'name': {'en': 'Rathalos Scale'},
      'rarity': 4,
    },
    {
      'id': 'rathalos-ruby',
      'name': {'en': 'Rathalos Ruby'},
    },
  ],
  'monsters': [
    {
      'slug': 'rathalos',
      'name': {'en': 'Rathalos', 'ptBr': 'Rathalos'},
      'classification': {'en': 'Flying Wyvern'},
      'weaknesses': {
        'general': {
          'fire': 'immune',
          'water': 'low',
          'thunder': 'medium',
          'ice': 'low',
          'dragon': 'high',
        },
        'states': [
          {
            'id': 'enraged',
            'name': {'en': 'Enraged'},
            'values': {
              'fire': 'none',
              'water': 'low',
              'thunder': 'high',
              'ice': 'low',
              'dragon': 'high',
            },
          },
        ],
      },
      'habitatIds': ['ancient-forest'],
      'parts': [
        {
          'id': 'head',
          'name': {'en': 'Head'},
          'severable': false,
        },
        {
          'id': 'tail',
          'name': {'en': 'Tail'},
          'severable': true,
        },
      ],
      'drops': [
        {
          'materialId': 'rathalos-scale',
          'rank': 'low',
          'method': 'carve',
          'ratePercent': 32,
        },
        {
          'materialId': 'rathalos-ruby',
          'rank': 'high',
          'method': 'breakPart',
          'partId': 'head',
        },
        {
          'materialId': 'rathalos-ruby',
          'rank': 'high',
          'method': 'other',
          'methodLabel': {'en': 'Investigation'},
          'ratePercent': 1.5,
        },
      ],
      'sources': [
        {'name': 'Test source', 'url': 'https://example.com/rathalos'},
      ],
    },
  ],
};

/// Shorthand to reach the first monster map inside a dataset map.
Map<String, Object?> firstMonster(Map<String, Object?> dataset) =>
    (dataset['monsters']! as List<Object?>).first! as Map<String, Object?>;

/// Adds the optional hunting-info fields (feature 003) to a dataset map.
Map<String, Object?> withHuntingInfo(Map<String, Object?> dataset) {
  dataset['partyHpFactors'] = <String, Object?>{
    '2': {'min': 1.5, 'max': 1.5},
    '3': {'min': 2.2, 'max': 2.6},
    '4': {'min': 2.2, 'max': 2.6},
    'source': {'name': 'Fextralife', 'url': 'https://example.com/multiplayer'},
  };
  dataset['huntingItems'] = <Object?>[
    {
      'id': 'flash',
      'name': {'en': 'Flash Pod'},
    },
    {
      'id': 'sonic',
      'name': {'en': 'Screamer Pod'},
    },
    {
      'id': 'dung',
      'name': {'en': 'Dung Pod'},
    },
    {
      'id': 'pitfallTrap',
      'name': {'en': 'Pitfall Trap', 'ptBr': 'Armadilha de Fosso'},
    },
    {
      'id': 'shockTrap',
      'name': {'en': 'Shock Trap'},
    },
  ];
  final monster = firstMonster(dataset);
  monster['hp'] = <Object?>[
    {'rank': 'low', 'solo': 4908, 'basis': 'expedition'},
    {'rank': 'high', 'solo': 6565, 'basis': 'minQuest'},
  ];
  monster['itemReactions'] = <Object?>[
    {
      'item': 'flash',
      'effect': 'affects',
      'detail': {'en': 'Duration: 20 s', 'ptBr': 'Duração: 20 s'},
    },
    {'item': 'sonic', 'effect': 'noEffect'},
    {
      'item': 'dung',
      'effect': 'conditional',
      'detail': {'en': '50% chance to flee'},
    },
  ];
  return dataset;
}

/// Adds a version of the first monster (feature 004): by default a World
/// tempered Rathalos with its own HP and one drop, inheriting every other
/// section.
Map<String, Object?> withVersion(
  Map<String, Object?> dataset, {
  String slug = 'tempered-rathalos',
  String versionOf = 'rathalos',
  String kind = 'tempered',
}) {
  dataset['monsters'] = <Object?>[
    ...dataset['monsters']! as List<Object?>,
    <String, Object?>{
      'slug': slug,
      'versionOf': versionOf,
      'versionKind': kind,
      'name': {'en': 'Tempered Rathalos', 'ptBr': 'Rathalos Temperado'},
      'hp': <Object?>[
        {'rank': 'high', 'solo': 9000, 'basis': 'minQuest'},
      ],
      'drops': <Object?>[
        {
          'materialId': 'rathalos-ruby',
          'rank': 'high',
          'method': 'breakPart',
          'partId': 'head',
          'ratePercent': 5,
        },
      ],
      'sources': <Object?>[
        {'name': 'Test source', 'url': 'https://example.com/tempered'},
      ],
    },
  ];
  return dataset;
}

/// The last monster map of a dataset (the version added by [withVersion]).
Map<String, Object?> lastMonster(Map<String, Object?> dataset) =>
    (dataset['monsters']! as List<Object?>).last! as Map<String, Object?>;
