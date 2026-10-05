import 'package:mh_wiki/core/data/material_sources_json.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';

const supportedArmorSchemaVersion = 1;

/// Reads `assets/data/<game>/armor.json` into an [ArmorCatalog], checking
/// every rule of 007 data-model.md › Validation rules on the way.
ArmorCatalog readArmorDataset(
  Map<String, Object?> json, {
  required Game expectedGame,
}) {
  final root = JsonReader(json, '${expectedGame.datasetKey}/armor');
  final version = root.number('schemaVersion');
  if (version != supportedArmorSchemaVersion) {
    throw UnsupportedSchemaVersionException(version.toInt());
  }
  final gameKey = root.string('game');
  if (gameKey != expectedGame.datasetKey) {
    root.fail('game "$gameKey" does not match ${expectedGame.datasetKey}');
  }

  T unique<T>(Map<String, T> map, String id, T value, JsonReader at) {
    if (map.containsKey(id)) at.fail('duplicate id "$id"');
    return map[id] = value;
  }

  // Skills.
  final skills = <String, Skill>{};
  for (final r in root.objects('skills')) {
    final levels = [
      for (final l in r.objects('levels')) readLocalized(l.object('effect')),
    ];
    if (levels.isEmpty) r.fail('a skill needs levels');
    unique(
      skills,
      r.string('id'),
      Skill(
        id: r.string('id'),
        name: readLocalized(r.object('name')),
        description: _text(r.object('description')),
        levels: levels,
        kind: r.has('kind')
            ? r.enumValue('kind', SkillKind.values)
            : SkillKind.armor,
      ),
      r,
    );
  }

  // Some decorations give more than a skill's max (Hard Sniper Jewel 4:
  // Steadiness 3 of 2), as the game data says; pieces never do.
  List<SkillLevel> skillLevels(JsonReader r, {bool capped = true}) => [
    for (final s in r.objects('skills'))
      () {
        final id = s.string('skill');
        final skill = skills[id] ?? s.fail('unknown skill "$id"');
        final level = s.number('level').toInt();
        if (level < 1 || (capped && level > skill.maxLevel)) {
          s.fail('level $level outside 1-${skill.maxLevel} for "$id"');
        }
        return SkillLevel(id, level);
      }(),
  ];

  // Materials.
  final materials = <String, (MonsterMaterial, MaterialSources)>{};
  for (final r in root.objects('materials')) {
    final id = r.string('id');
    unique(materials, id, (
      MonsterMaterial(id: id, name: readLocalized(r.object('name'))),
      switch (r.optionalObject('sources')) {
        final s? => readMaterialSources(s),
        null => MaterialSources.none,
      },
    ), r);
  }

  List<MaterialCost> forge(JsonReader r) => [
    for (final c in r.objects('forge'))
      () {
        final id = c.string('material');
        final (material, sources) =
            materials[id] ?? c.fail('unknown material "$id"');
        final quantity = c.number('quantity').toInt();
        if (quantity < 1) c.fail('quantity must be >= 1');
        return MaterialCost(
          material: material,
          quantity: quantity,
          sources: sources,
        );
      }(),
  ];

  List<int> slots(JsonReader r) {
    final raw = r.json['slots'];
    if (raw is! List<Object?>) r.fail('"slots" must be a list');
    final out = [
      for (final v in raw) v is num ? v.toInt() : r.fail('bad slot'),
    ];
    if (out.length > 3 || out.any((v) => v < 1 || v > 4)) {
      r.fail('slots must be at most 3 levels of 1-4');
    }
    return out;
  }

  // Decorations.
  final decorations = <String, ArmorDecoration>{};
  for (final r in root.objects('decorations')) {
    final level = r.number('slotLevel').toInt();
    if (level < 1 || level > 4) r.fail('slotLevel must be 1-4');
    unique(
      decorations,
      r.string('id'),
      ArmorDecoration(
        id: r.string('id'),
        name: readLocalized(r.object('name')),
        slotLevel: level,
        skills: skillLevels(r, capped: false),
        forge: forge(r),
        kind: r.has('kind')
            ? r.enumValue('kind', DecorationKind.values)
            : DecorationKind.armor,
        iconAsset: r.optionalString('icon'),
      ),
      r,
    );
  }

  // Pieces.
  final pieces = <String, ArmorPiece>{};
  for (final r in root.objects('pieces')) {
    final defense = r.number('defense').toInt();
    final maxDefense = r.optionalNumber('maxDefense')?.toInt();
    if (maxDefense != null && maxDefense < defense) {
      r.fail('maxDefense below defense');
    }
    final res = r.object('resistances');
    final rarity = r.number('rarity').toInt();
    if (rarity < 1 || rarity > 10) r.fail('rarity must be 1-10');
    unique(
      pieces,
      r.string('id'),
      ArmorPiece(
        id: r.string('id'),
        setId: r.string('set'),
        part: r.enumValue('part', BodyPart.values),
        name: readLocalized(r.object('name')),
        description: r.has('description')
            ? _text(r.object('description'))
            : const LocalizedText(en: ''),
        rarity: rarity,
        defense: defense,
        maxDefense: maxDefense,
        resistances: Resistances(
          fire: res.number('fire').toInt(),
          water: res.number('water').toInt(),
          thunder: res.number('thunder').toInt(),
          ice: res.number('ice').toInt(),
          dragon: res.number('dragon').toInt(),
        ),
        slots: slots(r),
        skills: skillLevels(r),
        forge: forge(r),
        imageAsset: r.optionalString('image'),
        sources: [
          for (final s in r.optionalObjects('sources'))
            SourceRef(name: s.string('name'), url: s.string('url')),
        ],
      ),
      r,
    );
  }

  SetBonus? bonus(JsonReader? b) {
    if (b == null) return null;
    final skill = b.string('skill');
    if (!skills.containsKey(skill)) b.fail('unknown skill "$skill"');
    return SetBonus(
      skillId: skill,
      steps: [
        for (final s in b.objects('steps'))
          SetBonusStep(
            pieces: () {
              final n = s.number('pieces').toInt();
              if (n < 1 || n > 5) s.fail('pieces must be 1-5');
              return n;
            }(),
            name: _text(s.object('name')),
            description: _text(s.object('description')),
          ),
      ],
    );
  }

  // Sets: every piece in exactly one set, in body-part order.
  final sets = <ArmorSet>[];
  final placed = <String>{};
  for (final r in root.objects('sets')) {
    final id = r.string('id');
    final members = [
      for (final pid in r.strings('pieces'))
        () {
          final piece = pieces[pid] ?? r.fail('unknown piece "$pid"');
          if (piece.setId != id) r.fail('"$pid" belongs to "${piece.setId}"');
          if (!placed.add(pid)) r.fail('"$pid" is in two sets');
          return piece;
        }(),
    ];
    for (var i = 1; i < members.length; i++) {
      if (members[i].part.index < members[i - 1].part.index) {
        r.fail('pieces of "$id" are not in body-part order');
      }
    }
    sets.add(
      ArmorSet(
        id: id,
        name: readLocalized(r.object('name')),
        rarity: r.number('rarity').toInt(),
        pieces: members,
        declaredRank: r.has('rank') ? r.enumValue('rank', Rank.values) : null,
        bonus: bonus(r.optionalObject('bonus')),
        groupBonus: bonus(r.optionalObject('groupBonus')),
      ),
    );
  }
  final orphan = pieces.keys.where((p) => !placed.contains(p));
  if (orphan.isNotEmpty) root.fail('pieces without a set: ${orphan.first}');

  return ArmorCatalog(
    game: expectedGame,
    sets: sets,
    skills: skills.values.toList(),
    decorations: decorations.values.toList(),
    talismans: [
      for (final t in root.optionalObjects('talismans'))
        Talisman(
          id: t.string('id'),
          ranks: [
            for (final r in t.objects('ranks'))
              TalismanRank(
                level: r.number('level').toInt(),
                name: readLocalized(r.object('name')),
                rarity: r.number('rarity').toInt(),
                skills: skillLevels(r),
                forge: forge(r),
              ),
          ],
        ),
    ],
  );
}

/// Like [readLocalized], but an empty English text is allowed.
LocalizedText _text(JsonReader r) => LocalizedText(
  en: r.json['en'] is String ? r.json['en']! as String : '',
  ptBr: r.optionalString('ptBr'),
);
