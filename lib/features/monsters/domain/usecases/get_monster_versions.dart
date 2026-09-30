import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';

/// The base monster of [id]'s family followed by its versions in kind order,
/// for the detail's version selector (004 FR-006a). Works from the base or
/// from any of its versions.
final class GetMonsterVersions {
  const GetMonsterVersions();

  Result<List<Monster>> call(List<Monster> all, MonsterId id) {
    Monster? find(MonsterId target) {
      for (final monster in all) {
        if (monster.id == target) return monster;
      }
      return null;
    }

    final monster = find(id);
    if (monster == null) return Err(MonsterNotFound(id.game, id.slug));
    final base = monster.versionOf == null ? monster : find(monster.versionOf!);
    if (base == null) return Err(MonsterNotFound(id.game, id.slug));

    final versions = [
      for (final m in all)
        if (m.versionOf == base.id) m,
    ]..sort((a, b) => a.versionKind!.index - b.versionKind!.index);
    return Success([base, ...versions]);
  }
}
