import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/weapons_of_monster.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';

import '../fakes/monster_fixtures.dart';
import '../fakes/weapon_fixtures.dart';

/// 006 research R7: monsters and weapons joined through materials.
void main() {
  final anjanath = buildMonster(
    game: Game.riseSunbreak,
    slug: 'anjanath',
    en: 'Anjanath',
    drops: [
      drop(
        material('anjanath-scale', 'Anjanath Scale'),
        Rank.low,
        DropMethod.carve,
      ),
      drop(
        material('anjanath-hardfang', 'Anjanath Hardfang'),
        Rank.master,
        DropMethod.carve,
      ),
    ],
  );
  final fulgur = buildVersion(
    anjanath,
    VersionKind.risen,
    slug: 'risen-anjanath',
    en: 'Risen Anjanath',
  );
  final worldAnjanath = buildMonster(
    slug: 'anjanath',
    en: 'Anjanath',
    drops: [
      drop(
        material('anjanath-scale', 'Anjanath Scale'),
        Rank.low,
        DropMethod.carve,
      ),
    ],
  );
  final index = MonsterMaterialIndex([anjanath, fulgur, worldAnjanath]);

  test('a material maps to the Rise base monsters that drop it', () {
    expect(index.droppersOf('anjanath-scale'), [anjanath]);
    expect(index.droppersOf('mystery-ore'), isEmpty);
  });

  test('points materials map to their monster by name', () {
    expect(index.droppersOf('anjanath-material-s'), [anjanath]);
    expect(index.droppersOf('mr-anjanath-material-s'), [anjanath]);
    expect(index.droppersOf('anjanath-plus-material-s'), [anjanath]);
  });

  test('the lookup names monsters in the chosen language', () {
    final lookup = index.lookup(() => NameLanguage.en);
    final dropper = lookup.droppersOf('anjanath-scale').single;
    expect(dropper.name, 'Anjanath');
    expect(
      monsterIdOf(dropper),
      const MonsterId(Game.riseSunbreak, 'anjanath'),
    );
  });

  test('weapons made from a monster, master rank first', () {
    final weapons = index.weaponsUsingMaterialsOf(anjanath, anjanathWeapons());
    expect(weapons.map((w) => w.id.slug), [
      'gnashing-flammenzahn-plus',
      'flammenzahn-i',
    ]);
    // A version counts as its base; other games have none.
    expect(
      index.weaponsUsingMaterialsOf(fulgur, anjanathWeapons()),
      hasLength(2),
    );
    expect(
      index.weaponsUsingMaterialsOf(worldAnjanath, anjanathWeapons()),
      isEmpty,
    );
  });
}
