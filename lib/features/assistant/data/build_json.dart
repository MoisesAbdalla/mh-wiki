import 'package:mh_wiki/core/data/material_sources_json.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';

const supportedBuildsSchemaVersion = 1;

const weaponTypeIds = {
  'great-sword',
  'long-sword',
  'sword-and-shield',
  'dual-blades',
  'hammer',
  'hunting-horn',
  'lance',
  'gunlance',
  'switch-axe',
  'charge-blade',
  'insect-glaive',
  'bow',
  'light-bowgun',
  'heavy-bowgun',
};

/// Reads `assets/data/<game>/builds.json`, checking 008 data-model.md ›
/// Validation rules.
BuildCatalog readBuildsDataset(
  Map<String, Object?> json, {
  required Game expectedGame,
}) {
  final root = JsonReader(json, '${expectedGame.datasetKey}/builds');
  final version = root.number('schemaVersion');
  if (version != supportedBuildsSchemaVersion) {
    throw UnsupportedSchemaVersionException(version.toInt());
  }
  if (root.string('game') != expectedGame.datasetKey) {
    root.fail('game does not match ${expectedGame.datasetKey}');
  }
  final ids = <String>{};
  final builds = [
    for (final r in root.objects('builds'))
      () {
        final b = readBuild(r);
        if (!ids.add(b.id)) r.fail('duplicate build "${b.id}"');
        return b;
      }(),
  ];
  return BuildCatalog(game: expectedGame, builds: builds);
}

CatalogRef _ref(JsonReader r) => CatalogRef(
  id: r.optionalString('id'),
  name: readLocalized(r.object('name')),
  kind: r.enumValue('kind', RefKind.values),
  rarity: r.has('rarity') ? r.number('rarity').toInt() : null,
  image: r.optionalString('image'),
);

List<CatalogRef> _refs(JsonReader r, String key) => [
  for (final x in r.optionalObjects(key)) _ref(x),
];

BuildItem _item(JsonReader r) =>
    BuildItem(ref: _ref(r.object('ref')), decorations: _refs(r, 'decorations'));

/// One build, as the dataset and the saved builds write it.
CuratedBuild readBuild(JsonReader r) {
  final type = r.string('weaponType');
  if (!weaponTypeIds.contains(type)) r.fail('unknown weapon type "$type"');
  final stage = r.object('stage');
  final Progress progress;
  try {
    progress = Progress.parse(stage.string('rank'), stage.string('step'));
  } on Object catch (e) {
    stage.fail('$e');
  }
  final pieces = [
    for (final p in r.objects('pieces'))
      BuildPiece(
        part: p.has('part') ? p.enumValue('part', BuildPart.values) : null,
        item: _item(p.object('item')),
        alternatives: _refs(p, 'alternatives'),
      ),
  ];
  if (pieces.length > 5) r.fail('a build has at most 5 pieces');
  final parts = [
    for (final p in pieces)
      if (p.part != null) p.part,
  ];
  if (parts.toSet().length != parts.length) r.fail('two pieces share a part');
  final talisman = r.optionalObject('talisman');
  final source = r.object('source');
  return CuratedBuild(
    id: r.string('id'),
    name: r.string('name'),
    weaponType: type,
    stage: progress,
    stageLabel: stage.string('label'),
    weapon: _item(r.object('weapon')),
    pieces: pieces,
    talisman: talisman == null
        ? null
        : BuildTalisman(
            skill: _ref(talisman.object('skill')),
            level: talisman.number('level').toInt(),
            note: talisman.optionalString('note') ?? '',
            decorations: _refs(talisman, 'decorations'),
          ),
    skills: [
      for (final s in r.optionalObjects('skills'))
        BuildSkill(
          skill: _ref(s.object('skill')),
          level: s.number('level').toInt(),
          maxLevel: s.number('maxLevel').toInt(),
        ),
    ],
    rampage: _refs(r, 'rampage'),
    decorations: [
      for (final d in r.optionalObjects('decorations'))
        DecorationCount(
          _ref(d.object('decoration')),
          d.number('count').toInt(),
        ),
    ],
    sourceName: source.string('name'),
    sourceUrl: source.string('url'),
  );
}

Map<String, Object?> _writeText(LocalizedText t) => {
  'en': t.en,
  'ptBr': ?t.ptBr,
};

Map<String, Object?> _writeRef(CatalogRef r) => {
  'id': ?r.id,
  'name': _writeText(r.name),
  'kind': r.kind.name,
  'rarity': ?r.rarity,
  'image': ?r.image,
};

Map<String, Object?> _writeItem(BuildItem i) => {
  'ref': _writeRef(i.ref),
  'decorations': [for (final d in i.decorations) _writeRef(d)],
};

/// The inverse of [readBuild], for the saved builds.
Map<String, Object?> writeBuild(CuratedBuild b) => {
  'id': b.id,
  'name': b.name,
  'weaponType': b.weaponType,
  'stage': {
    'label': b.stageLabel,
    'rank': b.stage.rank.name,
    'step': b.stage.step,
  },
  'weapon': _writeItem(b.weapon),
  'pieces': [
    for (final p in b.pieces)
      {
        if (p.part case final part?) 'part': part.name,
        'item': _writeItem(p.item),
        'alternatives': [for (final a in p.alternatives) _writeRef(a)],
      },
  ],
  if (b.talisman case final t?)
    'talisman': {
      'skill': _writeRef(t.skill),
      'level': t.level,
      'note': t.note,
      'decorations': [for (final d in t.decorations) _writeRef(d)],
    },
  'skills': [
    for (final s in b.skills)
      {'skill': _writeRef(s.skill), 'level': s.level, 'maxLevel': s.maxLevel},
  ],
  'rampage': [for (final r in b.rampage) _writeRef(r)],
  'decorations': [
    for (final d in b.decorations)
      {'decoration': _writeRef(d.decoration), 'count': d.count},
  ],
  'source': {'name': b.sourceName, 'url': b.sourceUrl},
};
