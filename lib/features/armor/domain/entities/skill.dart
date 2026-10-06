import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';

/// What gives a skill in the Wilds (010 FR-006); Rise skills are armor.
enum SkillKind { weapon, armor, set, group, secret }

/// Which slots a decoration fits in the Wilds (010 FR-007).
enum DecorationKind { weapon, armor }

/// An armor skill and what each of its levels does.
final class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.levels,
    this.kind = SkillKind.armor,
  });

  final SkillKind kind;

  final String id;
  final LocalizedText name;
  final LocalizedText description;

  /// The effect of level 1, 2… in order.
  final List<LocalizedText> levels;

  int get maxLevel => levels.length;

  @override
  bool operator ==(Object other) => other is Skill && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A skill at a level, as a piece or decoration gives it.
final class SkillLevel {
  const SkillLevel(this.skillId, this.level);

  final String skillId;
  final int level;
}

/// A decoration: fits a slot of [slotLevel] or higher and gives [skills].
final class ArmorDecoration {
  const ArmorDecoration({
    required this.id,
    required this.name,
    required this.slotLevel,
    required this.skills,
    this.forge = const [],
    this.kind = DecorationKind.armor,
    this.iconAsset,
  });

  final String id;
  final LocalizedText name;
  final int slotLevel;
  final List<SkillLevel> skills;
  final List<MaterialCost> forge;
  final DecorationKind kind;

  /// The game's own decoration icon (Wilds); null for Rise.
  final String? iconAsset;

  @override
  bool operator ==(Object other) => other is ArmorDecoration && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
