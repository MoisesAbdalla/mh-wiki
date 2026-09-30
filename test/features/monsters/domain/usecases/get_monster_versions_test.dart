import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_versions.dart';

import '../../../../fakes/monster_fixtures.dart';

void main() {
  const getVersions = GetMonsterVersions();
  final rathalos = buildMonster(game: Game.wilds);
  final guardian = buildVersion(
    rathalos,
    VersionKind.guardian,
    slug: 'guardian-rathalos',
    en: 'Guardian Rathalos',
  );
  final tempered = buildVersion(
    rathalos,
    VersionKind.tempered,
    slug: 'tempered-rathalos',
    en: 'Tempered Rathalos',
  );
  final all = [
    guardian,
    buildMonster(game: Game.wilds, slug: 'arkveld'),
    rathalos,
    tempered,
  ];

  List<Monster> versionsOf(MonsterId id) =>
      (getVersions(all, id) as Success<List<Monster>>).value;

  test('base first, then versions in kind order, from the base id', () {
    expect(versionsOf(rathalos.id), [rathalos, tempered, guardian]);
  });

  test('the same family from a version id', () {
    expect(versionsOf(guardian.id), [rathalos, tempered, guardian]);
  });

  test('a monster without versions gives just itself', () {
    expect(versionsOf(const MonsterId(Game.wilds, 'arkveld')), hasLength(1));
  });

  test('unknown id is MonsterNotFound', () {
    final result = getVersions(all, const MonsterId(Game.wilds, 'kirin'));
    expect((result as Err).failure, isA<MonsterNotFound>());
  });
}
