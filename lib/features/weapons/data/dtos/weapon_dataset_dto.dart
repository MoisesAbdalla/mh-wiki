import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';
import 'package:mh_wiki/core/data/material_sources_json.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/domain/entities/rampage.dart';
import 'package:mh_wiki/features/weapons/domain/entities/sharpness.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';

const supportedWeaponSchemaVersion = 1;

/// `assets/data/<game>/weapons.json`, validated against every rule in
/// 006 data-model.md while parsing.
final class WeaponDatasetDto {
  const WeaponDatasetDto({
    required this.game,
    required this.types,
    required this.materials,
    this.rampageDecorations = const [],
    this.sources = const {},
    required this.weapons,
    this.skills = const {},
    this.artian = const [],
  });

  factory WeaponDatasetDto.fromJson(
    Map<String, Object?> json, {
    required Game expectedGame,
  }) {
    final root = JsonReader(json, '${expectedGame.datasetKey}/weapons');
    final version = root.number('schemaVersion');
    if (version != supportedWeaponSchemaVersion) {
      throw UnsupportedSchemaVersionException(version.toInt());
    }
    final gameKey = root.string('game');
    if (gameKey != expectedGame.datasetKey) {
      root.fail('game "$gameKey" does not match ${expectedGame.datasetKey}');
    }

    final types = <String, WeaponTypeDto>{};
    for (final reader in root.objects('weaponTypes')) {
      final type = WeaponTypeDto(
        id: reader.string('id'),
        name: _localized(reader.object('name')),
        ranged: reader.boolean('ranged'),
      );
      if (types.containsKey(type.id)) {
        reader.fail('duplicate type "${type.id}"');
      }
      types[type.id] = type;
    }

    final materials = <String, LocalizedText>{};
    final sources = <String, MaterialSources>{};
    for (final reader in root.objects('materials')) {
      final id = reader.string('id');
      if (materials.containsKey(id)) reader.fail('duplicate material "$id"');
      materials[id] = _localized(reader.object('name'));
      if (reader.optionalObject('sources') case final s?) {
        sources[id] = readMaterialSources(s);
      }
    }

    // Rampage tables (007 research R6).
    final rampageSkills = <String, RampageSkill>{};
    for (final r in root.optionalObjects('rampageSkills')) {
      final id = r.string('id');
      if (rampageSkills.containsKey(id)) {
        r.fail('duplicate rampage skill "$id"');
      }
      rampageSkills[id] = RampageSkill(
        id: id,
        name: readLocalized(r.object('name')),
        effect: readLocalized(r.object('effect')),
      );
    }
    final rampageDecorations = [
      for (final r in root.optionalObjects('rampageDecorations'))
        RampageDecoration(
          id: r.string('id'),
          name: readLocalized(r.object('name')),
          slotLevel: r.number('slotLevel').toInt(),
          skill:
              rampageSkills[r.string('skill')] ??
              r.fail('unknown rampage skill "${r.string('skill')}"'),
          weaponTypes: r.has('types') ? r.strings('types') : const [],
        ),
    ];

    // Skills the weapons carry (Wilds): id → (name, max level).
    final skills = <String, (LocalizedText, int)>{
      for (final s in root.optionalObjects('skills'))
        s.string('id'): (_localized(s.object('name')), _positive(s, 'max')),
    };

    final readers = root.objects('weapons');
    final slugs = <String>{};
    for (final reader in readers) {
      if (!slugs.add(reader.string('slug'))) {
        reader.fail('duplicate weapon slug "${reader.string('slug')}"');
      }
    }
    final weapons = [
      for (final reader in readers)
        WeaponDto.fromJson(
          reader,
          types: types,
          materialIds: materials.keys.toSet(),
          slugs: slugs,
          rampageSkills: rampageSkills,
          skills: skills,
        ),
    ];

    // previous/next must agree both ways.
    final bySlug = {for (final w in weapons) w.slug: w};
    for (final w in weapons) {
      final previous = w.previous;
      if (previous != null && !bySlug[previous]!.next.contains(w.slug)) {
        root.fail(
          '"${w.slug}" has previous "$previous" that does not list it as next',
        );
      }
      for (final next in w.next) {
        if (bySlug[next]!.previous != w.slug) {
          root.fail('"${w.slug}" lists next "$next" whose previous differs');
        }
      }
    }

    return WeaponDatasetDto(
      game: expectedGame,
      types: types.values.toList(),
      materials: materials,
      sources: sources,
      weapons: weapons,
      rampageDecorations: rampageDecorations,
      skills: skills,
      artian: [
        for (final a in root.optionalObjects('artian')) _artian(a, types),
      ],
    );
  }

  final Game game;
  final List<WeaponTypeDto> types;
  final Map<String, LocalizedText> materials;

  /// Material id → where it comes from.
  final Map<String, MaterialSources> sources;
  final List<WeaponDto> weapons;
  final List<RampageDecoration> rampageDecorations;
  final Map<String, (LocalizedText, int)> skills;
  final List<ArtianType> artian;
}

final class WeaponTypeDto {
  const WeaponTypeDto({
    required this.id,
    required this.name,
    required this.ranged,
  });

  final String id;
  final LocalizedText name;
  final bool ranged;
}

final class CostDto {
  const CostDto({required this.material, this.quantity, this.points});

  final String material;
  final int? quantity;
  final int? points;
}

final class WeaponDto {
  const WeaponDto({
    required this.slug,
    required this.type,
    required this.name,
    required this.description,
    required this.rarity,
    required this.tree,
    required this.treeName,
    required this.attack,
    required this.affinity,
    required this.special,
    required this.slots,
    required this.rampageSlot,
    required this.sharpness,
    required this.previous,
    required this.next,
    required this.forge,
    required this.upgrade,
    required this.stars,
    required this.starsEstimated,
    required this.image,
    required this.traits,
    this.rampageSkills = const [],
    required this.sources,
    this.skills = const [],
    this.gogma,
    this.elderseal,
    this.defenseBonus = 0,
    this.worldSpecial,
  });

  factory WeaponDto.fromJson(
    JsonReader r, {
    required Map<String, WeaponTypeDto> types,
    required Set<String> materialIds,
    required Set<String> slugs,
    Map<String, RampageSkill> rampageSkills = const {},
    Map<String, (LocalizedText, int)> skills = const {},
  }) {
    final typeId = r.string('type');
    final type = types[typeId] ?? r.fail('unknown type "$typeId"');
    final rarity = r.number('rarity').toInt();
    // World goes up to rarity 12 (011).
    if (rarity < 1 || rarity > 12) r.fail('rarity must be 1-12');
    final attack = r.number('attack').toInt();
    if (attack <= 0) r.fail('attack must be > 0');

    final special = [
      for (final s in r.objects('special'))
        (
          s.enumValue('kind', SpecialKind.values),
          _positive(s, 'value'),
          s.has('hidden') && s.boolean('hidden'),
        ),
    ];
    if (special.length > 2) r.fail('at most 2 special values');

    final slots = [for (final v in _ints(r, 'slots')) v];
    if (slots.length > 3 || slots.any((v) => v < 1 || v > 4)) {
      r.fail('slots must be at most 3 levels of 1-4');
    }
    final rampage = r.number('rampageSlot').toInt();
    if (rampage < 0 || rampage > 3) r.fail('rampageSlot must be 0-3');

    (List<int>, List<int>)? sharpness;
    final sharp = r.optionalObject('sharpness');
    if (type.ranged && sharp != null) {
      r.fail('ranged weapons have no sharpness');
    }
    if (!type.ranged && sharp == null) r.fail('melee weapons need sharpness');
    if (sharp != null) {
      final base = _ints(sharp, 'base');
      final handicraft = _ints(sharp, 'handicraft');
      if (base.length != 7 || handicraft.length != 7) {
        sharp.fail('sharpness bars need 7 segments');
      }
      for (var i = 0; i < 7; i++) {
        if (base[i] < 0 || handicraft[i] < base[i]) {
          sharp.fail('handicraft must not be below base');
        }
      }
      sharpness = (base, handicraft);
    }

    String? link(String? slug) {
      if (slug != null && !slugs.contains(slug)) {
        r.fail('unknown weapon "$slug"');
      }
      return slug;
    }

    List<CostDto> costs(String key) => [
      for (final c in r.objects(key))
        () {
          final id = c.string('material');
          if (!materialIds.contains(id)) c.fail('unknown material "$id"');
          final quantity = c.optionalNumber('quantity')?.toInt();
          final points = c.optionalNumber('points')?.toInt();
          if ((quantity == null) == (points == null) ||
              (quantity ?? points!) < 1) {
            c.fail('needs a quantity or points >= 1');
          }
          return CostDto(material: id, quantity: quantity, points: points);
        }(),
    ];

    final stars = r.object('stars');
    final starValue = stars.number('value').toInt();
    if (starValue < 1 || starValue > 7) r.fail('stars must be 1-7');

    return WeaponDto(
      gogma: r.has('gogma') ? r.enumValue('gogma', ArtianFocus.values) : null,
      elderseal: r.has('elderseal')
          ? r.enumValue('elderseal', Elderseal.values)
          : null,
      defenseBonus: r.has('defenseBonus') ? _positive(r, 'defenseBonus') : 0,
      worldSpecial: r.has('worldSpecial')
          ? r.enumValue('worldSpecial', WorldSpecial.values)
          : null,
      slug: r.string('slug'),
      type: typeId,
      name: _localized(r.object('name')),
      description: _localized(r.object('description'), allowEmpty: true),
      rarity: rarity,
      tree: r.string('tree'),
      treeName: _localized(r.object('treeName')),
      attack: attack,
      affinity: r.number('affinity').toInt(),
      special: special,
      slots: slots,
      rampageSlot: rampage,
      sharpness: sharpness,
      previous: link(r.optionalString('previous')),
      next: [for (final s in r.strings('next')) link(s)!],
      forge: costs('forge'),
      upgrade: costs('upgrade'),
      stars: starValue,
      starsEstimated: stars.boolean('estimated'),
      image: r.optionalString('image'),
      traits: _traits(r, typeId),
      rampageSkills: [
        if (r.has('rampageSkills'))
          for (final id in r.strings('rampageSkills'))
            rampageSkills[id] ?? r.fail('unknown rampage skill "$id"'),
      ],
      sources: [
        for (final s in r.objects('sources'))
          (s.string('name'), s.string('url')),
      ],
      skills: [
        for (final s in r.optionalObjects('skills'))
          () {
            final id = s.string('skill');
            final (name, max) = skills[id] ?? s.fail('unknown skill "$id"');
            return WeaponSkill(
              id: id,
              name: name,
              level: _positive(s, 'level'),
              max: max,
            );
          }(),
      ],
    );
  }

  final ArtianFocus? gogma;
  final Elderseal? elderseal;
  final int defenseBonus;
  final WorldSpecial? worldSpecial;
  final String slug;
  final String type;
  final LocalizedText name;
  final LocalizedText description;
  final int rarity;
  final String tree;
  final LocalizedText treeName;
  final int attack;
  final int affinity;
  final List<(SpecialKind, int, bool)> special;
  final List<int> slots;
  final int rampageSlot;
  final (List<int>, List<int>)? sharpness;
  final String? previous;
  final List<String> next;
  final List<CostDto> forge;
  final List<CostDto> upgrade;
  final int stars;
  final bool starsEstimated;
  final String? image;
  final WeaponTraits traits;
  final List<RampageSkill> rampageSkills;
  final List<(String, String)> sources;
  final List<WeaponSkill> skills;
}

LocalizedText _localized(JsonReader r, {bool allowEmpty = false}) {
  final en = allowEmpty && r.json['en'] == '' ? '' : r.string('en');
  return LocalizedText(en: en, ptBr: r.optionalString('ptBr'));
}

int _positive(JsonReader r, String key) {
  final value = r.number(key).toInt();
  if (value <= 0) r.fail('"$key" must be > 0');
  return value;
}

List<int> _ints(JsonReader r, String key) {
  final raw = r.json[key];
  if (raw is! List<Object?>) r.fail('"$key" must be a list');
  return [
    for (final v in raw)
      if (v is num) v.toInt() else r.fail('"$key" must contain numbers'),
  ];
}

/// The fields each weapon type may carry in `traits` (006 data-model).
const _traitsByType = {
  'charge-blade': {'phial'},
  'switch-axe': {'phial'},
  'gunlance': {'shelling'},
  'insect-glaive': {'kinsectLevel', 'kinsectBonus'},
  'hunting-horn': {'songs', 'notes'},
  'bow': {'arcShot', 'chargeShots', 'coatings'},
  'light-bowgun': {'deviation', 'recoil', 'reload', 'ammo', 'specialAmmo'},
  'heavy-bowgun': {'deviation', 'recoil', 'reload', 'ammo', 'specialAmmo'},
};

WeaponTraits _traits(JsonReader weapon, String typeId) {
  final r = weapon.optionalObject('traits');
  if (r == null) return WeaponTraits.none;
  final allowed = _traitsByType[typeId] ?? const <String>{};
  for (final key in r.json.keys) {
    if (!allowed.contains(key)) r.fail('"$key" is not a trait of $typeId');
  }
  LocalizedText? text(String key) =>
      r.has(key) ? _localized(r.object(key)) : null;
  List<BowShot> shots(String key) => [
    for (final s in r.optionalObjects(key))
      BowShot(
        name: _localized(s.object('name')),
        locked: s.has('locked') && s.boolean('locked'),
      ),
  ];
  return WeaponTraits(
    phial: text('phial'),
    shelling: text('shelling'),
    kinsectLevel: r.optionalNumber('kinsectLevel')?.toInt(),
    songs: [for (final s in r.optionalObjects('songs')) _localized(s)],
    arcShot: text('arcShot'),
    chargeShots: shots('chargeShots'),
    coatings: shots('coatings'),
    deviation: text('deviation'),
    recoil: text('recoil'),
    reload: text('reload'),
    ammo: [
      for (final a in r.optionalObjects('ammo'))
        AmmoCapacity(
          kind: a.enumValue('ammo', AmmoKind.values),
          capacity: _ints(a, 'capacity'),
        ),
    ],
    kinsectBonus: text('kinsectBonus'),
    notes: [for (final n in r.optionalObjects('notes')) _localized(n)],
    specialAmmo: text('specialAmmo'),
  );
}

/// One `artian` entry (010 data-model).
ArtianType _artian(JsonReader r, Map<String, WeaponTypeDto> types) {
  final type = r.string('type');
  if (!types.containsKey(type)) r.fail('unknown type "$type"');
  final production = r.object('production');
  final bases = [
    for (final w in r.objects('weapons'))
      ArtianBase(
        type: type,
        rarity: w.number('rarity').toInt(),
        name: _localized(w.object('name')),
        attack: _positive(w, 'attack'),
        affinity: w.number('affinity').toInt(),
        slots: _ints(w, 'slots'),
        sharpness: switch (w.optionalObject('sharpness')) {
          final s? => Sharpness(
            base: _ints(s, 'base'),
            handicraft: _ints(s, 'handicraft'),
          ),
          null => null,
        },
        imageAsset: w.optionalString('image'),
      ),
  ];
  final elements = r.object('elementsByRarity');
  return ArtianType(
    type: type,
    bases: bases,
    elementsByRarity: {
      for (final e in elements.json.entries)
        int.parse(e.key): {
          for (final k in (e.value! as Map<String, Object?>).entries)
            k.key: (k.value! as num).toInt(),
        },
    },
    infusion: r.number('infusion').toInt(),
    attackPart: production.number('attackDisplay').toInt(),
    affinityPart: production.number('affinity').toInt(),
    boosts: [
      for (final b in r.objects('reinforcement'))
        (
          kind: b.enumValue('kind', ArtianBoost.values),
          // Attack rolls are stored raw; the displayed value is what adds up.
          value: (b.optionalNumber('display') ?? b.number('value')).toInt(),
          max: _positive(b, 'max'),
        ),
    ],
    rolls: _positive(r, 'rolls'),
  );
}
