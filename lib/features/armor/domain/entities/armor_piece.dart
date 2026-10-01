import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';

/// Where an armor piece is worn, in display order.
enum BodyPart { head, chest, arms, waist, legs }

/// Elemental resistances of a piece or a whole set.
final class Resistances {
  const Resistances({
    this.fire = 0,
    this.water = 0,
    this.thunder = 0,
    this.ice = 0,
    this.dragon = 0,
  });

  static const zero = Resistances();

  final int fire;
  final int water;
  final int thunder;
  final int ice;
  final int dragon;

  Resistances operator +(Resistances other) => Resistances(
    fire: fire + other.fire,
    water: water + other.water,
    thunder: thunder + other.thunder,
    ice: ice + other.ice,
    dragon: dragon + other.dragon,
  );
}

/// One wearable piece (007 data-model).
final class ArmorPiece {
  const ArmorPiece({
    required this.id,
    required this.setId,
    required this.part,
    required this.name,
    required this.rarity,
    required this.defense,
    this.description = const LocalizedText(en: ''),
    this.maxDefense,
    this.resistances = Resistances.zero,
    this.slots = const [],
    this.skills = const [],
    this.forge = const [],
    this.imageAsset,
    this.sources = const [],
  });

  final String id;
  final String setId;
  final BodyPart part;
  final LocalizedText name;
  final LocalizedText description;
  final int rarity;
  final int defense;

  /// With every upgrade; `null` when the source does not say.
  final int? maxDefense;
  final Resistances resistances;

  /// Decoration slot levels (1–4), highest first.
  final List<int> slots;
  final List<SkillLevel> skills;
  final List<MaterialCost> forge;
  final String? imageAsset;
  final List<SourceRef> sources;

  /// Sunbreak ranks by rarity: 1–3 Low, 4–7 High, 8–10 Master.
  Rank get rank => rarity <= 3
      ? Rank.low
      : rarity <= 7
      ? Rank.high
      : Rank.master;

  @override
  bool operator ==(Object other) => other is ArmorPiece && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
