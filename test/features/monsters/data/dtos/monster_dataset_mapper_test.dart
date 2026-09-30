import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';

import '../../../../fakes/dataset_json_fixtures.dart';

/// Inheritance of version data (004 research R3, spec FR-006c).
void main() {
  List<Monster> map(Map<String, Object?> json) =>
      MonsterDatasetMapper.toMonsters(
        MonsterDatasetDto.fromJson(json, expectedGame: Game.worldIceborne),
      );

  test('a version inherits the omitted sections from its base', () {
    final monsters = map(withHuntingInfo(withVersion(validDatasetJson())));
    final base = monsters.first;
    final version = monsters.last;

    expect(version.isVersion, isTrue);
    expect(version.versionOf, const MonsterId(Game.worldIceborne, 'rathalos'));
    expect(version.versionKind, VersionKind.tempered);
    expect(version.name.ptBr, 'Rathalos Temperado');

    expect(version.weaknesses.general, base.weaknesses.general);
    expect(version.weaknesses.states, hasLength(1));
    expect(version.parts.map((p) => p.id), ['head', 'tail']);
    expect(version.habitats.single.id, 'ancient-forest');
    expect(version.classification, base.classification);
    expect(
      version.huntingInfo.reactions.map((r) => r.item),
      base.huntingInfo.reactions.map((r) => r.item),
    );
    expect(version.inheritedSections, {
      MonsterSectionKind.weaknesses,
      MonsterSectionKind.parts,
      MonsterSectionKind.habitats,
      MonsterSectionKind.itemReactions,
      MonsterSectionKind.classification,
    });
  });

  test('hp and drops are never inherited', () {
    final monsters = map(withHuntingInfo(withVersion(validDatasetJson())));
    final version = monsters.last;

    expect(version.huntingInfo.hp.single.solo, 9000);
    expect(version.huntingInfo.hp.single.rank, Rank.high);
    expect(version.drops, hasLength(1));
    expect(version.drops.single.partId, 'head');
  });

  test('own sections of a version are kept and not marked inherited', () {
    final json = withVersion(validDatasetJson());
    lastMonster(json)['habitatIds'] = <Object?>[];
    final version = map(json).last;

    expect(version.habitats, isEmpty);
    expect(
      version.inheritedSections,
      isNot(contains(MonsterSectionKind.habitats)),
    );
  });

  test('base monsters have no version data', () {
    final base = map(withVersion(validDatasetJson())).first;
    expect(base.isVersion, isFalse);
    expect(base.versionOf, isNull);
    expect(base.versionKind, isNull);
    expect(base.inheritedSections, isEmpty);
  });
}
