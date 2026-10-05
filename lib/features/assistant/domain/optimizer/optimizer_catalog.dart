import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';

/// A skill with its max level (009 research R1).
final class OptimizerSkill {
  const OptimizerSkill({
    required this.id,
    required this.name,
    required this.max,
  });

  final String id;
  final LocalizedText name;
  final int max;
}

/// A decoration: one skill, [points] of it, in a slot of level [slot] or
/// higher.
final class OptimizerDecoration {
  const OptimizerDecoration({
    required this.id,
    required this.name,
    required this.slot,
    required this.skill,
    required this.points,
  });

  final String id;
  final LocalizedText name;
  final int slot;
  final String skill;
  final int points;
}

/// Skill points given by a piece or a talisman.
typedef SkillPoints = Map<String, int>;

final class OptimizerPiece {
  const OptimizerPiece({
    required this.id,
    required this.name,
    required this.part,
    required this.rarity,
    required this.slots,
    required this.defense,
    required this.skills,
  });

  final String id;
  final LocalizedText name;
  final BuildPart part;
  final int rarity;

  /// Slot levels, highest first.
  final List<int> slots;

  /// Max defense.
  final int defense;
  final SkillPoints skills;
}

final class OptimizerWeapon {
  const OptimizerWeapon({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.slots,
    required this.attack,
    this.image,
    this.trait,
    this.elements = const [],
  });

  final String id;
  final LocalizedText name;
  final String type;
  final int rarity;

  /// Slot levels, highest first. Weapons give no skills in the catalog.
  final List<int> slots;
  final int attack;
  final String? image;

  /// The phial (Charge Blade, Switch Axe) or shelling (Gunlance) kind, e.g.
  /// `impact` / "Impacto"; null for the other types.
  final ({String key, LocalizedText name})? trait;

  /// Element and status kinds (`fire`, `poison`…); empty for raw weapons.
  final List<String> elements;
}

/// Everything the build search needs for one game.
final class OptimizerCatalog {
  OptimizerCatalog({
    required this.game,
    required List<OptimizerSkill> skills,
    required List<OptimizerDecoration> decorations,
    required List<OptimizerPiece> pieces,
    required List<OptimizerWeapon> weapons,
  }) : skills = {for (final s in skills) s.id: s},
       decorations = {for (final d in decorations) d.id: d},
       decorationsBySkill = _group(decorations, (d) => d.skill),
       piecesByPart = _group(pieces, (p) => p.part),
       weapons = {for (final w in weapons) w.id: w},
       weaponsByType = _group(weapons, (w) => w.type);

  final Game game;
  final Map<String, OptimizerSkill> skills;
  final Map<String, OptimizerDecoration> decorations;
  final Map<String, List<OptimizerDecoration>> decorationsBySkill;
  final Map<BuildPart, List<OptimizerPiece>> piecesByPart;
  final Map<String, OptimizerWeapon> weapons;
  final Map<String, List<OptimizerWeapon>> weaponsByType;

  static Map<K, List<T>> _group<K, T>(Iterable<T> items, K Function(T) key) {
    final out = <K, List<T>>{};
    for (final i in items) {
      (out[key(i)] ??= []).add(i);
    }
    return out;
  }
}
