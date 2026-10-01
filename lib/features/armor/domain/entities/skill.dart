import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';

/// An armor skill and what each of its levels does.
final class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.levels,
  });

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
  });

  final String id;
  final LocalizedText name;
  final int slotLevel;
  final List<SkillLevel> skills;
  final List<MaterialCost> forge;

  @override
  bool operator ==(Object other) => other is ArmorDecoration && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
