import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_by_id.dart';

import '../../../../fakes/monster_fixtures.dart';

void main() {
  const getById = GetMonsterById();
  final monsters = [
    buildMonster(game: Game.worldIceborne),
    buildMonster(game: Game.wilds),
  ];

  test('returns the monster of the requested game', () {
    final result = getById(monsters, const MonsterId(Game.wilds, 'rathalos'));
    expect(result, isA<Success<Object>>());
    expect((result as Success).value.id.game, Game.wilds);
  });

  test('unknown id returns MonsterNotFound', () {
    final result = getById(
      monsters,
      const MonsterId(Game.riseSunbreak, 'rathalos'),
    );
    expect(result, isA<Err<Object>>());
    expect((result as Err).failure, isA<MonsterNotFound>());
  });
}
