import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section.dart';

/// Screen state of the monster list (the "Model" in MVC).
sealed class MonsterListState {
  const MonsterListState();
}

final class MonsterListLoading extends MonsterListState {
  const MonsterListLoading();
}

final class MonsterListLoaded extends MonsterListState {
  const MonsterListLoaded({
    required this.sections,
    required this.query,
    required this.failedGames,
    this.selectedId,
  });

  final List<MonsterSection> sections;
  final MonsterQuery query;

  /// Games whose data could not be loaded (FR-017); the others still work.
  final Map<Game, Failure> failedGames;
  final MonsterId? selectedId;

  bool get isEmpty => sections.isEmpty;

  bool get hasActiveFilters => query.hasActiveFilters;
}

/// Only when no game could be loaded at all.
final class MonsterListLoadFailed extends MonsterListState {
  const MonsterListLoadFailed(this.failure);

  final Failure failure;
}
