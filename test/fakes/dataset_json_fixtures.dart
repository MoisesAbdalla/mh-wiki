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
