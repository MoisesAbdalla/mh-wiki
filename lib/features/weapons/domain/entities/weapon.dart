import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/weapons/domain/entities/estimated_stars.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/features/weapons/domain/entities/sharpness.dart';
import 'package:mh_wiki/features/weapons/domain/entities/rampage.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_special.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';

/// A weapon of one game (006 data-model.md).
final class Weapon {
  const Weapon({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.rarity,
    required this.treeId,
    required this.treeName,
    required this.attack,
    required this.affinity,
    required this.stars,
    this.special = const [],
    this.slots = const [],
    this.rampageSlot = 0,
    this.sharpness,
    this.previous,
    this.next = const [],
    this.forge = const [],
    this.upgrade = const [],
    this.imageAsset,
    this.sources = const [],
    this.traits = WeaponTraits.none,
    this.rampageSkills = const [],
    this.skills = const [],
  });

  final WeaponId id;
  final WeaponType type;
  final LocalizedText name;
  final LocalizedText description;
  final int rarity;
  final String treeId;
  final LocalizedText treeName;
  final int attack;

  /// Percent, may be negative.
  final int affinity;
  final List<WeaponSpecial> special;

  /// Decoration slot levels (1–4), highest first.
  final List<int> slots;

  /// Rampage decoration slot level; 0 when none.
  final int rampageSlot;

  /// `null` for ranged weapons.
  final Sharpness? sharpness;
  final WeaponId? previous;
  final List<WeaponId> next;
  final List<MaterialCost> forge;
  final List<MaterialCost> upgrade;
  final EstimatedStars stars;
  final String? imageAsset;
  final List<SourceRef> sources;

  /// Phial, shelling, kinsect, songs, shots or ammo (006 US4).
  final WeaponTraits traits;

  /// The Rampage skills to choose from (Low/High Rank, 007 US4).
  final List<RampageSkill> rampageSkills;

  /// The weapon's own skills (Wilds, 010 FR-003); empty for Rise.
  final List<WeaponSkill> skills;

  /// Ranks by rarity: Sunbreak 1–3 Low, 4–7 High, 8–10 Master (006
  /// research R3); Wilds 1–4 Low, 5–8 High.
  Rank get rank => id.game == Game.wilds
      ? (rarity <= 4 ? Rank.low : Rank.high)
      : rarity <= 3
      ? Rank.low
      : rarity <= 7
      ? Rank.high
      : Rank.master;

  @override
  bool operator ==(Object other) => other is Weapon && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A skill a weapon carries, with its level and the skill's max.
final class WeaponSkill {
  const WeaponSkill({
    required this.id,
    required this.name,
    required this.level,
    required this.max,
  });

  final String id;
  final LocalizedText name;
  final int level;
  final int max;
}
