import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_item.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';

const supportedSchemaVersion = 1;

final _slugPattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

/// One game's dataset file (contracts/monster-dataset.schema.json), validated
/// against every rule in data-model.md "Validation rules" while parsing.
final class MonsterDatasetDto {
  const MonsterDatasetDto({
    required this.game,
    required this.sources,
    required this.habitats,
    required this.materials,
    required this.monsters,
    this.huntingItems = const [],
    this.partyFactors,
  });

  /// Throws [UnsupportedSchemaVersionException] for rule 1 and
  /// [DatasetFormatException] for every other violation.
  factory MonsterDatasetDto.fromJson(
    Map<String, Object?> json, {
    required Game expectedGame,
  }) {
    final root = JsonReader(json, expectedGame.datasetKey);

    final version = root.number('schemaVersion');
    if (version != supportedSchemaVersion) {
      throw UnsupportedSchemaVersionException(version.toInt());
    }

    final gameKey = root.string('game');
    if (gameKey != expectedGame.datasetKey) {
      root.fail('game "$gameKey" does not match ${expectedGame.datasetKey}');
    }
    root.string('generatedAt');

    final habitats = _uniqueById(
      root.objects('habitats').map(NamedDto.fromJson),
      root,
      'habitat',
    );
    final materials = _uniqueById(
      root.objects('materials').map(MaterialDto.fromJson),
      root,
      'material',
    );

    final huntingItems = _huntingItems(root);
    final partyFactors = root.has('partyHpFactors')
        ? _partyFactors(root.object('partyHpFactors'))
        : null;

    final monsters = <MonsterDto>[];
    final slugs = <String>{};
    for (final reader in root.objects('monsters')) {
      final monster = MonsterDto.fromJson(
        reader,
        game: expectedGame,
        habitatIds: habitats.keys.toSet(),
        materialIds: materials.keys.toSet(),
        itemIds: {for (final i in huntingItems) i.id},
      );
      if (!slugs.add(monster.slug)) {
        reader.fail('duplicate monster slug "${monster.slug}"');
      }
      monsters.add(monster);
    }

    return MonsterDatasetDto(
      game: expectedGame,
      sources: _sources(root),
      habitats: habitats,
      materials: materials,
      monsters: monsters,
      huntingItems: huntingItems,
      partyFactors: partyFactors,
    );
  }

  final Game game;
  final List<SourceRef> sources;
  final Map<String, NamedDto> habitats;
  final Map<String, MaterialDto> materials;
  final List<MonsterDto> monsters;

  /// Optional (feature 003): the game's hunting items.
  final List<HuntingItem> huntingItems;

  /// Optional (feature 003): party HP factors; `null` when undocumented.
  final PartyHpFactors? partyFactors;
}

final class NamedDto {
  const NamedDto({required this.id, required this.name});

  factory NamedDto.fromJson(JsonReader reader) => NamedDto(
    id: _slug(reader, 'id'),
    name: _localized(reader.object('name')),
  );

  final String id;
  final LocalizedText name;
}

final class MaterialDto extends NamedDto {
  const MaterialDto({required super.id, required super.name, this.rarity});

  factory MaterialDto.fromJson(JsonReader reader) {
    final rarity = reader.optionalNumber('rarity');
    if (rarity != null && (rarity is! int || rarity < 1 || rarity > 12)) {
      reader.fail('"rarity" must be an integer between 1 and 12');
    }
    return MaterialDto(
      id: _slug(reader, 'id'),
      name: _localized(reader.object('name')),
      rarity: rarity?.toInt(),
    );
  }

  final int? rarity;
}

final class PartDto extends NamedDto {
  const PartDto({
    required super.id,
    required super.name,
    required this.severable,
  });

  factory PartDto.fromJson(JsonReader reader) => PartDto(
    id: _slug(reader, 'id'),
    name: _localized(reader.object('name')),
    severable: reader.boolean('severable'),
  );

  final bool severable;
}

final class WeaknessStateDto extends NamedDto {
  const WeaknessStateDto({
    required super.id,
    required super.name,
    required this.values,
  });

  factory WeaknessStateDto.fromJson(JsonReader reader) => WeaknessStateDto(
    id: _slug(reader, 'id'),
    name: _localized(reader.object('name')),
    values: _elementMap(reader.object('values')),
  );

  final Map<ElementType, Effectiveness> values;
}

final class DropDto {
  const DropDto({
    required this.materialId,
    required this.rank,
    required this.method,
    this.methodLabel,
    this.partId,
    this.ratePercent,
  });

  factory DropDto.fromJson(
    JsonReader reader, {
    required Game game,
    required Set<String> materialIds,
    required Set<String> partIds,
  }) {
    final materialId = _slug(reader, 'materialId');
    if (!materialIds.contains(materialId)) {
      reader.fail('unknown materialId "$materialId"');
    }

    final rank = reader.enumValue('rank', Rank.values);
    if (!game.allowedRanks.contains(rank)) {
      reader.fail('rank "${rank.name}" does not exist in ${game.datasetKey}');
    }

    final method = reader.enumValue('method', DropMethod.values);
    final partId = reader.has('partId') ? _slug(reader, 'partId') : null;
    if (method == DropMethod.breakPart) {
      if (partId == null) reader.fail('breakPart requires "partId"');
      if (!partIds.contains(partId)) reader.fail('unknown partId "$partId"');
    } else if (partId != null) {
      reader.fail('"partId" is only allowed for breakPart');
    }

    final label = reader.optionalObject('methodLabel');
    if (method == DropMethod.other && label == null) {
      reader.fail('method "other" requires "methodLabel"');
    }

    final rate = reader.optionalNumber('ratePercent');
    if (rate != null && (rate <= 0 || rate > 100)) {
      reader.fail('"ratePercent" must be in (0, 100]');
    }

    return DropDto(
      materialId: materialId,
      rank: rank,
      method: method,
      methodLabel: label == null ? null : _localized(label),
      partId: partId,
      ratePercent: rate?.toDouble(),
    );
  }

  final String materialId;
  final Rank rank;
  final DropMethod method;
  final LocalizedText? methodLabel;
  final String? partId;
  final double? ratePercent;
}

final class MonsterDto {
  const MonsterDto({
    required this.slug,
    required this.name,
    required this.classification,
    required this.image,
    required this.general,
    required this.states,
    required this.habitatIds,
    required this.parts,
    required this.drops,
    required this.sources,
    this.hp = const [],
    this.reactions = const [],
  });

  factory MonsterDto.fromJson(
    JsonReader reader, {
    required Game game,
    required Set<String> habitatIds,
    required Set<String> materialIds,
    Set<String> itemIds = const {},
  }) {
    final slug = _slug(reader, 'slug');
    final monster = JsonReader(reader.json, '${reader.path}($slug)');

    final weaknesses = monster.object('weaknesses');
    final states = _uniqueById(
      weaknesses.optionalObjects('states').map(WeaknessStateDto.fromJson),
      monster,
      'weakness state',
    );

    final monsterHabitats = monster.strings('habitatIds');
    for (final id in monsterHabitats) {
      if (!habitatIds.contains(id)) monster.fail('unknown habitatId "$id"');
    }
    if (monsterHabitats.toSet().length != monsterHabitats.length) {
      monster.fail('duplicate habitatIds');
    }

    final parts = _uniqueById(
      monster.objects('parts').map(PartDto.fromJson),
      monster,
      'part',
    );

    return MonsterDto(
      slug: slug,
      name: _localized(monster.object('name')),
      classification: _localized(monster.object('classification')),
      image: monster.optionalString('image'),
      general: _elementMap(weaknesses.object('general')),
      states: states.values.toList(),
      habitatIds: monsterHabitats,
      parts: parts.values.toList(),
      drops: [
        for (final drop in monster.objects('drops'))
          DropDto.fromJson(
            drop,
            game: game,
            materialIds: materialIds,
            partIds: parts.keys.toSet(),
          ),
      ],
      sources: _sources(monster),
      hp: _rankHp(monster, game),
      reactions: _reactions(monster, itemIds),
    );
  }

  final String slug;
  final LocalizedText name;
  final LocalizedText classification;
  final String? image;
  final Map<ElementType, Effectiveness> general;
  final List<WeaknessStateDto> states;
  final List<String> habitatIds;
  final List<PartDto> parts;
  final List<DropDto> drops;
  final List<SourceRef> sources;
  final List<RankHp> hp;
  final List<ItemReaction> reactions;
}

List<HuntingItem> _huntingItems(JsonReader root) {
  final items = <HuntingItem>[];
  final ids = <String>{};
  for (final reader in root.optionalObjects('huntingItems')) {
    final id = reader.string('id');
    if (!HuntingItem.knownIds.contains(id)) {
      reader.fail('unknown hunting item "$id"');
    }
    if (!ids.add(id)) reader.fail('duplicate hunting item "$id"');
    items.add(HuntingItem(id: id, name: _localized(reader.object('name'))));
  }
  return items;
}

PartyHpFactors _partyFactors(JsonReader reader) {
  final factors = <int, FactorRange>{};
  for (final key in reader.json.keys) {
    if (key == 'source') continue;
    final players = int.tryParse(key);
    if (players == null || players < 2 || players > 4) {
      reader.fail('party factor key "$key" must be 2, 3 or 4');
    }
    final range = reader.object(key);
    final min = range.number('min').toDouble();
    final max = range.number('max').toDouble();
    if (min <= 0 || min > max) range.fail('factor must satisfy 0 < min <= max');
    factors[players] = FactorRange(min, max);
  }
  final source = reader.object('source');
  return PartyHpFactors(
    factors: factors,
    source: SourceRef(
      name: source.string('name'),
      url: _url(source),
      notes: source.optionalString('notes'),
    ),
  );
}

List<RankHp> _rankHp(JsonReader monster, Game game) {
  final result = <RankHp>[];
  final ranks = <Rank>{};
  for (final reader in monster.optionalObjects('hp')) {
    final rank = reader.enumValue('rank', Rank.values);
    if (!game.allowedRanks.contains(rank)) {
      reader.fail('rank "${rank.name}" does not exist in ${game.datasetKey}');
    }
    if (!ranks.add(rank)) reader.fail('duplicate hp rank "${rank.name}"');
    final solo = reader.number('solo');
    if (solo is! int || solo <= 0) {
      reader.fail('"solo" must be a positive integer');
    }
    result.add(
      RankHp(
        rank: rank,
        solo: solo,
        basis: reader.enumValue('basis', HpBasis.values),
      ),
    );
  }
  result.sort((a, b) => a.rank.index.compareTo(b.rank.index));
  return result;
}

List<ItemReaction> _reactions(JsonReader monster, Set<String> itemIds) {
  final result = <ItemReaction>[];
  for (final reader in monster.optionalObjects('itemReactions')) {
    final item = reader.string('item');
    if (!itemIds.contains(item)) {
      reader.fail('reaction item "$item" is not a dataset hunting item');
    }
    final effect = reader.enumValue('effect', ReactionEffect.values);
    final detail = reader.optionalObject('detail');
    if (effect == ReactionEffect.conditional && detail == null) {
      reader.fail('a conditional reaction requires "detail"');
    }
    result.add(
      ItemReaction(
        item: item,
        effect: effect,
        detail: detail == null ? null : _localized(detail),
      ),
    );
  }
  return result;
}

String _slug(JsonReader reader, String key) {
  final value = reader.string(key);
  if (!_slugPattern.hasMatch(value)) reader.fail('"$key" is not a valid slug');
  return value;
}

LocalizedText _localized(JsonReader reader) =>
    LocalizedText(en: reader.string('en'), ptBr: reader.optionalString('ptBr'));

Map<ElementType, Effectiveness> _elementMap(JsonReader reader) => {
  for (final element in ElementType.values)
    element: reader.enumValue(element.name, Effectiveness.values),
};

List<SourceRef> _sources(JsonReader reader) {
  final sources = [
    for (final source in reader.objects('sources'))
      SourceRef(
        name: source.string('name'),
        url: _url(source),
        notes: source.optionalString('notes'),
      ),
  ];
  if (sources.isEmpty) reader.fail('"sources" must not be empty');
  return sources;
}

String _url(JsonReader reader) {
  final url = reader.string('url');
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.isAbsolute || !uri.scheme.startsWith('http')) {
    reader.fail('"url" must be an absolute http(s) URL');
  }
  return url;
}

Map<String, T> _uniqueById<T extends NamedDto>(
  Iterable<T> items,
  JsonReader owner,
  String kind,
) {
  final byId = <String, T>{};
  for (final item in items) {
    if (byId.containsKey(item.id)) {
      owner.fail('duplicate $kind id "${item.id}"');
    }
    byId[item.id] = item;
  }
  return byId;
}
