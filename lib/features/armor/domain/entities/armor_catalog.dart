import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
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
  });

  final String id;
  final LocalizedText name;
  final int rarity;
  final List<ArmorPiece> pieces;

  Rank get rank => rarity <= 3
      ? Rank.low
      : rarity <= 7
      ? Rank.high
      : Rank.master;

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
  }) : _skills = {for (final s in skills) s.id: s},
       _sets = {for (final s in sets) s.id: s};

  final Game game;
  final List<ArmorSet> sets;
  final List<Skill> skills;
  final List<ArmorDecoration> decorations;
  final Map<String, Skill> _skills;
  final Map<String, ArmorSet> _sets;

  Iterable<ArmorPiece> get pieces => sets.expand((s) => s.pieces);

  Skill? skill(String id) => _skills[id];

  ArmorSet? set(String id) => _sets[id];
}
