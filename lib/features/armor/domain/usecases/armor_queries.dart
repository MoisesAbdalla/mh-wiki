import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';

/// What the set list shows: a rank, a text and a chosen skill (007 FR-005).
final class SetQuery {
  const SetQuery({this.rank, this.text = '', this.skillId});

  final Rank? rank;
  final String text;
  final String? skillId;

  bool get hasFilters =>
      rank != null || text.trim().isNotEmpty || skillId != null;

  SetQuery copyWith({
    Rank? Function()? rank,
    String? text,
    String? Function()? skillId,
  }) => SetQuery(
    rank: rank != null ? rank() : this.rank,
    text: text ?? this.text,
    skillId: skillId != null ? skillId() : this.skillId,
  );
}

/// A skill and its level summed over a set's pieces.
final class SkillTotal {
  const SkillTotal(this.skill, this.level);

  final Skill skill;
  final int level;

  /// Levels above the skill's max (real data: the game caps them).
  int get overflow => level > skill.maxLevel ? level - skill.maxLevel : 0;
}

/// The skills of [set], summed, highest level first, then by name.
List<SkillTotal> sumSetSkills(ArmorCatalog catalog, ArmorSet set) {
  final levels = <String, int>{};
  for (final piece in set.pieces) {
    for (final s in piece.skills) {
      levels[s.skillId] = (levels[s.skillId] ?? 0) + s.level;
    }
  }
  final totals = [
    for (final MapEntry(:key, :value) in levels.entries)
      if (catalog.skill(key) case final skill?) SkillTotal(skill, value),
  ];
  return totals..sort((a, b) {
    final byLevel = b.level.compareTo(a.level);
    return byLevel != 0 ? byLevel : a.skill.name.en.compareTo(b.skill.name.en);
  });
}

/// The set list for a query. Names are normalized once per catalog.
class FilterSets {
  FilterSets(this.catalog)
    : _names = {
        for (final s in catalog.sets)
          s.id: [
            s.name.en,
            s.name.ptBr ?? '',
            for (final p in s.pieces) ...[p.name.en, p.name.ptBr ?? ''],
          ].map(normalizeForSearch).join('\n'),
      },
      _skillsOf = {
        for (final s in catalog.sets)
          s.id: {
            for (final p in s.pieces)
              for (final k in p.skills) k.skillId,
          },
      };

  final ArmorCatalog catalog;
  final Map<String, String> _names;
  final Map<String, Set<String>> _skillsOf;

  List<ArmorSet> call(SetQuery query) {
    final needle = normalizeForSearch(query.text);
    final result = [
      for (final s in catalog.sets)
        if ((query.rank == null || s.rank == query.rank) &&
            (query.skillId == null ||
                _skillsOf[s.id]!.contains(query.skillId)) &&
            (needle.isEmpty || _names[s.id]!.contains(needle)))
          s,
    ];
    return result..sort((a, b) {
      final byRarity = a.rarity.compareTo(b.rarity);
      return byRarity != 0 ? byRarity : a.name.en.compareTo(b.name.en);
    });
  }

  /// Skills whose name matches [text] (en or pt-BR), for the search
  /// suggestions.
  List<Skill> matchingSkills(String text, {int limit = 5}) {
    final needle = normalizeForSearch(text);
    if (needle.length < 2) return const [];
    return [
      for (final s in catalog.skills)
        if (normalizeForSearch(s.name.en).contains(needle) ||
            normalizeForSearch(s.name.ptBr ?? '').contains(needle))
          s,
    ].take(limit).toList();
  }
}

/// A piece or decoration that gives a skill, with the level it gives.
typedef PieceWithLevel = ({ArmorPiece piece, int level});
typedef DecorationWithLevel = ({ArmorDecoration decoration, int level});

/// Where a skill comes from (007 FR-008): decorations by slot level, and
/// pieces by rank (master first), each by level then name.
final class SkillSources {
  const SkillSources({required this.decorations, required this.pieces});

  final List<DecorationWithLevel> decorations;
  final Map<Rank, List<PieceWithLevel>> pieces;

  int get pieceCount => pieces.values.fold(0, (n, l) => n + l.length);
}

SkillSources skillSources(ArmorCatalog catalog, String skillId) {
  final decorations = [
    for (final d in catalog.decorations)
      for (final s in d.skills)
        if (s.skillId == skillId) (decoration: d, level: s.level),
  ]..sort((a, b) => a.decoration.slotLevel.compareTo(b.decoration.slotLevel));
  final pieces = <Rank, List<PieceWithLevel>>{};
  for (final p in catalog.pieces) {
    for (final s in p.skills) {
      if (s.skillId == skillId) {
        pieces.putIfAbsent(p.rank, () => []).add((piece: p, level: s.level));
      }
    }
  }
  for (final list in pieces.values) {
    list.sort((a, b) {
      final byLevel = b.level.compareTo(a.level);
      return byLevel != 0
          ? byLevel
          : a.piece.name.en.compareTo(b.piece.name.en);
    });
  }
  return SkillSources(
    decorations: decorations,
    pieces: {for (final rank in Rank.values.reversed) rank: ?pieces[rank]},
  );
}
