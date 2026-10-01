import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';

/// Where a material comes from, as Kiranico lists it (006 US5, FR-015).
final class MaterialSources {
  const MaterialSources({
    this.gathering = const [],
    this.monsters = const [],
    this.quests = const [],
  });

  static const none = MaterialSources();

  /// Best rate per map and rank, highest first.
  final List<GatheringSource> gathering;

  /// Best row per monster and rank, highest rate first.
  final List<MonsterSource> monsters;

  /// Quests whose rewards include it, by stars.
  final List<QuestSource> quests;

  bool get isEmpty => gathering.isEmpty && monsters.isEmpty && quests.isEmpty;

  /// The sources to show for a weapon of [rank]: gathering and monsters of
  /// that rank; when there are none, those of the nearest rank (lower ranks
  /// first). Quests have no reliable rank and are always kept.
  RankedSources forRank(Rank rank) {
    final order = [
      rank,
      for (var i = rank.index - 1; i >= 0; i--) Rank.values[i],
      for (var i = rank.index + 1; i < Rank.values.length; i++) Rank.values[i],
    ];
    for (final r in order) {
      final g = [
        for (final s in gathering)
          if (s.rank == r) s,
      ];
      final m = [
        for (final s in monsters)
          if (s.rank == r) s,
      ];
      if (g.isNotEmpty || m.isNotEmpty) {
        return RankedSources(
          rank: r,
          gathering: g,
          monsters: m,
          quests: quests,
        );
      }
    }
    return RankedSources(rank: rank, quests: quests);
  }
}

/// The sources of one rank, picked by [MaterialSources.forRank].
final class RankedSources {
  const RankedSources({
    required this.rank,
    this.gathering = const [],
    this.monsters = const [],
    this.quests = const [],
  });

  final Rank rank;
  final List<GatheringSource> gathering;
  final List<MonsterSource> monsters;
  final List<QuestSource> quests;

  bool get isEmpty => gathering.isEmpty && monsters.isEmpty && quests.isEmpty;
}

final class GatheringSource {
  const GatheringSource({required this.map, required this.rank, this.rate});

  final LocalizedText map;
  final Rank rank;

  /// Percent; `null` when the source has none.
  final int? rate;
}

final class MonsterSource {
  const MonsterSource({
    required this.name,
    required this.rank,
    required this.method,
    this.rate,
    this.slug,
  });

  final LocalizedText name;
  final Rank rank;

  /// "Talha", "Prêmios do Alvo"…
  final LocalizedText method;
  final int? rate;

  /// The app's large monster slug; `null` for small monsters.
  final String? slug;

  bool get small => slug == null;
}

final class QuestSource {
  const QuestSource({
    required this.name,
    required this.category,
    required this.stars,
    this.rate,
  });

  final LocalizedText name;

  /// "Missões de Eventos", "Vila"…
  final LocalizedText category;

  /// "8" or "M6", as the game writes it.
  final String stars;
  final int? rate;
}
