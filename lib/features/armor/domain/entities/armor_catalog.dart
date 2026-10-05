import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';

/// An armor set: its pieces in body-part order (007 research R3).
final class ArmorSet {
  const ArmorSet({
    required this.id,
    required this.name,
    required this.rarity,
    required this.pieces,
    this.declaredRank,
    this.bonus,
    this.groupBonus,
  });

  final String id;
  final LocalizedText name;
  final int rarity;
  final List<ArmorPiece> pieces;

  /// The rank the dataset gives (Wilds); otherwise it follows the rarity.
  final Rank? declaredRank;

  /// The set bonus (Wilds): a skill with steps by piece count.
  final SetBonus? bonus;

  /// The group bonus (Wilds): usually one step of 3 pieces.
  final SetBonus? groupBonus;

  Rank get rank =>
      declaredRank ??
      (rarity <= 3
          ? Rank.low
          : rarity <= 7
          ? Rank.high
          : Rank.master);

  int get defense => pieces.fold(0, (sum, p) => sum + p.defense);

  /// With every upgrade, or `null` when a piece does not say.
  int? get maxDefense => pieces.any((p) => p.maxDefense == null)
      ? null
      : pieces.fold<int>(0, (sum, p) => sum + p.maxDefense!);

  Resistances get resistances =>
      pieces.fold(Resistances.zero, (sum, p) => sum + p.resistances);

  @override
  bool operator ==(Object other) => other is ArmorSet && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Every armor set, piece, skill and decoration of one game.
final class ArmorCatalog {
  ArmorCatalog({
    required this.game,
    required this.sets,
    required this.skills,
    required this.decorations,
    this.talismans = const [],
  }) : _skills = {for (final s in skills) s.id: s},
       _sets = {for (final s in sets) s.id: s};

  final Game game;
  final List<ArmorSet> sets;
  final List<Skill> skills;
  final List<ArmorDecoration> decorations;

  /// Talismans with their ranks (Wilds, 010 FR-008).
  final List<Talisman> talismans;
  final Map<String, Skill> _skills;
  final Map<String, ArmorSet> _sets;

  Iterable<ArmorPiece> get pieces => sets.expand((s) => s.pieces);

  Skill? skill(String id) => _skills[id];

  ArmorSet? set(String id) => _sets[id];
}

/// A set or group bonus: [skill] and what each piece count gives.
final class SetBonus {
  const SetBonus({required this.skillId, required this.steps});

  final String skillId;
  final List<SetBonusStep> steps;
}

final class SetBonusStep {
  const SetBonusStep({
    required this.pieces,
    required this.name,
    required this.description,
  });

  final int pieces;
  final LocalizedText name;
  final LocalizedText description;
}

/// A talisman and its ranks (I, II, III…).
final class Talisman {
  const Talisman({required this.id, required this.ranks});

  final String id;
  final List<TalismanRank> ranks;
}

final class TalismanRank {
  const TalismanRank({
    required this.level,
    required this.name,
    required this.rarity,
    required this.skills,
    this.forge = const [],
  });

  final int level;
  final LocalizedText name;
  final int rarity;
  final List<SkillLevel> skills;
  final List<MaterialCost> forge;
}
