import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section.dart';

/// Builds the list sections for a query: one section per game with results,
/// in game order, monsters sorted by their name in the selected language.
/// Game filter and text search combine with AND (FR-005).
final class FilterMonsters {
  const FilterMonsters();

  List<MonsterSection> call(List<Monster> all, MonsterQuery query) {
    String sortKey(Monster m) =>
        normalizeForSearch(m.name.resolve(query.language));

    final sections = <MonsterSection>[];
    for (final game in Game.values) {
      if (query.game != null && query.game != game) continue;
      final monsters =
          all
              .where((m) => m.id.game == game && m.name.matches(query.text))
              .toList()
            ..sort((a, b) => sortKey(a).compareTo(sortKey(b)));
      if (monsters.isNotEmpty) {
        sections.add(MonsterSection(game: game, monsters: monsters));
      }
    }
    return sections;
  }
}
