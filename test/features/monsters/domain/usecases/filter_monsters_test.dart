import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section.dart';
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

  group('game filter (US2)', () {
    test('a single game yields only that game', () {
      final sections = filter(monsters, const MonsterQuery(game: Game.wilds));
      expect(sections.map((s) => s.game), [Game.wilds]);
      expect(sections.single.monsters.map((m) => m.id.game).toSet(), {
        Game.wilds,
      });
    });

    test('a game without monsters yields no sections', () {
      expect(
        filter(monsters, const MonsterQuery(game: Game.riseSunbreak)),
        isEmpty,
      );
    });

    test('the same monster in three games gives three entries (FR-013)', () {
      final rathalos = [
        for (final game in Game.values) buildMonster(game: game),
      ];
      final sections = filter(rathalos, const MonsterQuery());
      expect(sections, hasLength(3));
      for (final section in sections) {
        expect(section.monsters.single.id.game, section.game);
      }
    });
  });

  group('text search (US3)', () {
    final searchable = [
      buildMonster(slug: 'rathalos', en: 'Rathalos'),
      buildMonster(slug: 'rathian', en: 'Rathian'),
      buildMonster(
        slug: 'pink-rathian',
        en: 'Pink Rathian',
        ptBr: 'Rathian Rosa',
      ),
      buildMonster(slug: 'anjanath', en: 'Anjanath'),
      buildMonster(game: Game.wilds, slug: 'rathalos', en: 'Rathalos'),
      buildMonster(
        game: Game.wilds,
        slug: 'jin-dahaad',
        en: 'Jin Dahaad',
        ptBr: 'Jin Dahaad',
      ),
    ];

    List<String> names(List<MonsterSection> sections) => [
      for (final section in sections)
        for (final m in section.monsters)
          '${m.id.game.datasetKey}/${m.id.slug}',
    ];

    test('partial match', () {
      final result = filter(searchable, const MonsterQuery(text: 'rath'));
      expect(names(result), [
        'world_iceborne/rathalos',
        'world_iceborne/rathian',
        'world_iceborne/pink-rathian',
        'wilds/rathalos',
      ]);
    });

    test('case and accent insensitive', () {
      expect(
        names(filter(searchable, const MonsterQuery(text: 'RÁTH'))),
        names(filter(searchable, const MonsterQuery(text: 'rath'))),
      );
    });

    test('matches the English name while pt-BR is displayed (FR-023)', () {
      final result = filter(searchable, const MonsterQuery(text: 'pink'));
      expect(names(result), ['world_iceborne/pink-rathian']);
      expect(
        result.single.monsters.single.name.resolve(NameLanguage.ptBr),
        'Rathian Rosa',
      );
    });

    test('combines with the game filter (FR-005)', () {
      final result = filter(
        searchable,
        const MonsterQuery(text: 'rath', game: Game.wilds),
      );
      expect(names(result), ['wilds/rathalos']);
    });

    test('no match gives no sections', () {
      expect(filter(searchable, const MonsterQuery(text: 'zzz')), isEmpty);
    });
  });
}
