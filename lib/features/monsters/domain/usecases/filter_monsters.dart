import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_entry.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section.dart';

/// Builds the list sections for a query: one section per game with results,
/// in game order, one row per base monster sorted by its name in the
/// selected language, with its versions collapsed under it (004 FR-006).
/// Game filter and text search combine with AND (FR-005); the text also
/// matches version names, and the row then opens that version (FR-006a).
final class FilterMonsters {
  const FilterMonsters();

  List<MonsterSection> call(List<Monster> all, MonsterQuery query) {
    String sortKey(Monster m) =>
        normalizeForSearch(m.name.resolve(query.language));

    final versionsByBase = <MonsterId, List<Monster>>{};
    for (final monster in all) {
      final base = monster.versionOf;
      if (base != null) versionsByBase.putIfAbsent(base, () => []).add(monster);
    }
    for (final versions in versionsByBase.values) {
      versions.sort((a, b) => a.versionKind!.index - b.versionKind!.index);
    }

    final sections = <MonsterSection>[];
    for (final game in Game.values) {
      if (query.game != null && query.game != game) continue;
      final entries = <MonsterEntry>[];
      for (final base in all) {
        if (base.id.game != game || base.isVersion) continue;
        final versions = versionsByBase[base.id] ?? const <Monster>[];
        if (base.name.matches(query.text)) {
          entries.add(MonsterEntry(base: base, versions: versions));
          continue;
        }
        for (final version in versions) {
          if (version.name.matches(query.text)) {
            entries.add(
              MonsterEntry(
                base: base,
                versions: versions,
                matchedVersion: version,
              ),
            );
            break;
          }
        }
      }
      entries.sort((a, b) => sortKey(a.base).compareTo(sortKey(b.base)));
      if (entries.isNotEmpty) {
        sections.add(MonsterSection(game: game, entries: entries));
      }
    }
    return sections;
  }
}
