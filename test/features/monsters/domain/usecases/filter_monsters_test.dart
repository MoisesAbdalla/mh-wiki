import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/filter_monsters.dart';

import '../../../../fakes/monster_fixtures.dart';

void main() {
  const filter = FilterMonsters();

  final monsters = [
    buildMonster(game: Game.wilds, slug: 'rey-dau', en: 'Rey Dau'),
    buildMonster(game: Game.worldIceborne, slug: 'rathalos', en: 'Rathalos'),
    buildMonster(game: Game.worldIceborne, slug: 'anjanath', en: 'Anjanath'),
    buildMonster(game: Game.wilds, slug: 'arkveld', en: 'Arkveld'),
  ];

  group('baseline (no filters)', () {
    test('one section per game with results, in game order', () {
      final sections = filter(monsters, const MonsterQuery());
      expect(sections.map((s) => s.game), [Game.worldIceborne, Game.wilds]);
    });

    test('monsters sorted alphabetically by resolved name', () {
      final sections = filter(monsters, const MonsterQuery());
      expect(sections.first.monsters.map((m) => m.name.en), [
        'Anjanath',
        'Rathalos',
      ]);
      expect(sections.last.monsters.map((m) => m.name.en), [
        'Arkveld',
        'Rey Dau',
      ]);
    });

    test('sorting follows the selected name language', () {
      final localized = [
        buildMonster(slug: 'a', en: 'Zinogre', ptBr: 'Alfa'),
        buildMonster(slug: 'b', en: 'Anjanath', ptBr: 'Beta'),
      ];
      final ptBr = filter(localized, const MonsterQuery());
      final en = filter(
        localized,
        const MonsterQuery(language: NameLanguage.en),
      );
      expect(ptBr.single.monsters.map((m) => m.id.slug), ['a', 'b']);
      expect(en.single.monsters.map((m) => m.id.slug), ['b', 'a']);
    });

    test('no monsters yields no sections', () {
      expect(filter(const [], const MonsterQuery()), isEmpty);
    });
  });
}
