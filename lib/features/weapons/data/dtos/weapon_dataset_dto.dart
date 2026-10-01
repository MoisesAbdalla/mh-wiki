import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';

const supportedWeaponSchemaVersion = 1;

/// `assets/data/<game>/weapons.json`, validated against every rule in
/// 006 data-model.md while parsing.
final class WeaponDatasetDto {
  const WeaponDatasetDto({
    required this.game,
    required this.types,
    required this.materials,
    required this.weapons,
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
      if (types.containsKey(type.id))
        reader.fail('duplicate type "${type.id}"');
      types[type.id] = type;
    }

    final materials = <String, LocalizedText>{};
    for (final reader in root.objects('materials')) {
      final id = reader.string('id');
      if (materials.containsKey(id)) reader.fail('duplicate material "$id"');
      materials[id] = _localized(reader.object('name'));
    }

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
      weapons: weapons,
    );
  }

  final Game game;
  final List<WeaponTypeDto> types;
  final Map<String, LocalizedText> materials;
  final List<WeaponDto> weapons;
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
    required this.sources,
  });

  factory WeaponDto.fromJson(
    JsonReader r, {
    required Map<String, WeaponTypeDto> types,
    required Set<String> materialIds,
    required Set<String> slugs,
  }) {
    final typeId = r.string('type');
    final type = types[typeId] ?? r.fail('unknown type "$typeId"');
    final rarity = r.number('rarity').toInt();
    if (rarity < 1 || rarity > 10) r.fail('rarity must be 1-10');
    final attack = r.number('attack').toInt();
    if (attack <= 0) r.fail('attack must be > 0');

    final special = [
      for (final s in r.objects('special'))
        (s.enumValue('kind', SpecialKind.values), _positive(s, 'value')),
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
    if (type.ranged && sharp != null)
      r.fail('ranged weapons have no sharpness');
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
      if (slug != null && !slugs.contains(slug))
        r.fail('unknown weapon "$slug"');
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
      sources: [
        for (final s in r.objects('sources'))
          (s.string('name'), s.string('url')),
      ],
    );
  }

  final String slug;
  final String type;
  final LocalizedText name;
  final LocalizedText description;
  final int rarity;
  final String tree;
  final LocalizedText treeName;
  final int attack;
  final int affinity;
  final List<(SpecialKind, int)> special;
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
  final List<(String, String)> sources;
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
