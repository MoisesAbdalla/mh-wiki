import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';

final class GetMonsterById {
  const GetMonsterById();

  Result<Monster> call(List<Monster> all, MonsterId id) {
    for (final monster in all) {
      if (monster.id == id) return Success(monster);
    }
    return Err(MonsterNotFound(id.game, id.slug));
  }
}
