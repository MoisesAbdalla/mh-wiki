import 'package:mh_wiki/core/data/material_sources_json.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/assistant/data/build_json.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';

const supportedOptimizerSchemaVersion = 1;

/// Reads `assets/data/<game>/optimizer.json`, checking 009 data-model.md ›
/// Validation.
OptimizerCatalog readOptimizerDataset(
  Map<String, Object?> json, {
  required Game expectedGame,
}) {
  final root = JsonReader(json, '${expectedGame.datasetKey}/optimizer');
  final version = root.number('schemaVersion');
  if (version != supportedOptimizerSchemaVersion) {
    throw UnsupportedSchemaVersionException(version.toInt());
  }
  if (root.string('game') != expectedGame.datasetKey) {
    root.fail('game does not match ${expectedGame.datasetKey}');
  }

  final skills = [
    for (final s in root.objects('skills'))
      OptimizerSkill(
        id: s.string('id'),
        name: readLocalized(s.object('name')),
        max: _positive(s, 'max'),
      ),
  ];
  final skillIds = _unique(root, 'skills', [for (final s in skills) s.id]);

  String skillRef(JsonReader r, String key) {
    final id = r.string(key);
    if (!skillIds.contains(id)) r.fail('unknown skill "$id"');
    return id;
  }

  final decorations = [
    for (final d in root.objects('decorations'))
      OptimizerDecoration(
        id: d.string('id'),
        name: readLocalized(d.object('name')),
        slot: _slot(d, d.number('slot').toInt()),
        skill: skillRef(d, 'skill'),
        points: _positive(d, 'points'),
      ),
  ];
  _unique(root, 'decorations', [for (final d in decorations) d.id]);

  final pieces = [
    for (final p in root.objects('pieces'))
      OptimizerPiece(
        id: p.string('id'),
        name: readLocalized(p.object('name')),
        part: p.enumValue('part', BuildPart.values),
        rarity: _positive(p, 'rarity'),
        slots: _slots(p),
        defense: p.number('defense').toInt(),
        skills: {
          for (final s in p.optionalObjects('skills'))
            skillRef(s, 'skill'): _positive(s, 'level'),
        },
      ),
  ];
  _unique(root, 'pieces', [for (final p in pieces) p.id]);

  final weapons = [
    for (final w in root.objects('weapons'))
      OptimizerWeapon(
        id: w.string('id'),
        name: readLocalized(w.object('name')),
        type: _type(w),
        rarity: _positive(w, 'rarity'),
        slots: _slots(w),
        attack: w.number('attack').toInt(),
        image: w.optionalString('image'),
      ),
  ];
  _unique(root, 'weapons', [for (final w in weapons) w.id]);

  return OptimizerCatalog(
    game: expectedGame,
    skills: skills,
    decorations: decorations,
    pieces: pieces,
    weapons: weapons,
  );
}

Set<String> _unique(JsonReader root, String list, List<String> ids) {
  final seen = <String>{};
  for (final id in ids) {
    if (!seen.add(id)) root.fail('duplicate id "$id" in $list');
  }
  return seen;
}

int _positive(JsonReader r, String key) {
  final v = r.number(key).toInt();
  if (v < 1) r.fail('$key must be at least 1');
  return v;
}

int _slot(JsonReader r, int level) {
  if (level < 1 || level > 4) r.fail('slot level $level is not 1–4');
  return level;
}

List<int> _slots(JsonReader r) {
  final raw = r.json['slots'];
  if (raw is! List) r.fail('slots must be a list');
  if (raw.length > 3) r.fail('at most 3 slots');
  return [
    for (final s in raw)
      if (s is num) _slot(r, s.toInt()) else r.fail('slot must be a number'),
  ]..sort((a, b) => b - a);
}

String _type(JsonReader r) {
  final type = r.string('type');
  if (!weaponTypeIds.contains(type)) r.fail('unknown weapon type "$type"');
  return type;
}
