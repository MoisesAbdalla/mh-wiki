import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';

import '../../../../fakes/dataset_json_fixtures.dart';

void main() {
  MonsterDatasetDto parse(
    Map<String, Object?> json, {
    Game game = Game.worldIceborne,
  }) => MonsterDatasetDto.fromJson(json, expectedGame: game);

  void expectFormatError(
    Map<String, Object?> json, {
    Game game = Game.worldIceborne,
  }) {
    expect(
      () => parse(json, game: game),
      throwsA(isA<DatasetFormatException>()),
    );
  }

  test('valid dataset parses and maps to entities', () {
    final monsters = MonsterDatasetMapper.toMonsters(parse(validDatasetJson()));

    expect(monsters, hasLength(1));
    final rathalos = monsters.single;
    expect(rathalos.id.game, Game.worldIceborne);
    expect(rathalos.id.slug, 'rathalos');
    expect(rathalos.weaknesses.general[ElementType.fire], Effectiveness.immune);
    expect(rathalos.weaknesses.states.single.name.en, 'Enraged');
    expect(rathalos.habitats.single.name.ptBr, 'Floresta Antiga');
    expect(rathalos.parts.last.severable, isTrue);
    expect(rathalos.drops, hasLength(3));
    expect(rathalos.drops[1].method, DropMethod.breakPart);
    expect(rathalos.drops[1].partId, 'head');
    expect(rathalos.drops[1].ratePercent, isNull);
    expect(rathalos.drops[1].rank, Rank.high);
    expect(rathalos.drops[2].methodLabel?.en, 'Investigation');
    expect(rathalos.drops[0].material.rarity, 4);
    expect(rathalos.sources.single.url, 'https://example.com/rathalos');
  });

  test('rule 1: unknown schemaVersion is rejected as unsupported', () {
    final json = validDatasetJson()..['schemaVersion'] = 2;
    expect(
      () => parse(json),
      throwsA(
        isA<UnsupportedSchemaVersionException>().having(
          (e) => e.found,
          'found',
          2,
        ),
      ),
    );
  });

  test('rule 2: file game must match the requested game', () {
    expectFormatError(validDatasetJson(game: 'wilds'));
  });

  test('rule 3: duplicate monster slug is rejected', () {
    final json = validDatasetJson();
    json['monsters'] = <Object?>[
      ...json['monsters']! as List<Object?>,
      Map<String, Object?>.of(firstMonster(json)),
    ];
    expectFormatError(json);
  });

  test('rule 3: duplicate part id is rejected', () {
    final json = validDatasetJson();
    final parts = firstMonster(json)['parts']! as List<Object?>;
    parts.add(parts.first);
    expectFormatError(json);
  });

  test('rule 4: weakness map missing an element is rejected', () {
    final json = validDatasetJson();
    final weaknesses =
        firstMonster(json)['weaknesses']! as Map<String, Object?>;
    (weaknesses['general']! as Map<String, Object?>).remove('ice');
    expectFormatError(json);
  });

  test('rule 5: master rank is rejected for Wilds', () {
    final json = validDatasetJson(game: 'wilds');
    final drops = firstMonster(json)['drops']! as List<Object?>;
    (drops.first! as Map<String, Object?>)['rank'] = 'master';
    expectFormatError(json, game: Game.wilds);
  });

  test('rule 6: breakPart without partId is rejected', () {
    final json = validDatasetJson();
    final drops = firstMonster(json)['drops']! as List<Object?>;
    (drops[1]! as Map<String, Object?>).remove('partId');
    expectFormatError(json);
  });

  test('rule 6: breakPart with unknown partId is rejected', () {
    final json = validDatasetJson();
    final drops = firstMonster(json)['drops']! as List<Object?>;
    (drops[1]! as Map<String, Object?>)['partId'] = 'wing';
    expectFormatError(json);
  });

  test('rule 6: other method without methodLabel is rejected', () {
    final json = validDatasetJson();
    final drops = firstMonster(json)['drops']! as List<Object?>;
    (drops[2]! as Map<String, Object?>).remove('methodLabel');
    expectFormatError(json);
  });

  test('rule 6: unknown habitat or material reference is rejected', () {
    final badHabitat = validDatasetJson();
    firstMonster(badHabitat)['habitatIds'] = ['nowhere'];
    expectFormatError(badHabitat);

    final badMaterial = validDatasetJson();
    final drops = firstMonster(badMaterial)['drops']! as List<Object?>;
    (drops.first! as Map<String, Object?>)['materialId'] = 'unknown';
    expectFormatError(badMaterial);
  });

  test('rule 7: ratePercent must be in (0, 100]', () {
    for (final rate in [0, 101]) {
      final json = validDatasetJson();
      final drops = firstMonster(json)['drops']! as List<Object?>;
      (drops.first! as Map<String, Object?>)['ratePercent'] = rate;
      expectFormatError(json);
    }
  });

  test('rule 8: sources must not be empty', () {
    expectFormatError(validDatasetJson()..['sources'] = <Object?>[]);

    final json = validDatasetJson();
    firstMonster(json)['sources'] = <Object?>[];
    expectFormatError(json);
  });

  test('wrong field type is a format error', () {
    final json = validDatasetJson();
    firstMonster(json)['name'] = 'Rathalos';
    expectFormatError(json);
  });

  group('hunting info (003)', () {
    Map<String, Object?> hunting() => withHuntingInfo(validDatasetJson());

    List<Object?> listOf(Map<String, Object?> m, String key) =>
        m[key]! as List<Object?>;

    Map<String, Object?> itemAt(List<Object?> list, int i) =>
        list[i]! as Map<String, Object?>;

    test('datasets without the optional fields still parse', () {
      final monster = MonsterDatasetMapper.toMonsters(parse(validDatasetJson()))
          .single;
      expect(monster.huntingInfo.hp, isEmpty);
      expect(monster.huntingInfo.items, isEmpty);
      expect(monster.huntingInfo.partyFactors, isNull);
    });

    test('valid hunting info parses and maps', () {
      final info = MonsterDatasetMapper.toMonsters(parse(hunting()))
          .single
          .huntingInfo;

      expect(info.hp.map((h) => (h.rank, h.solo, h.basis)), [
        (Rank.low, 4908, HpBasis.expedition),
        (Rank.high, 6565, HpBasis.minQuest),
      ]);
      expect(info.partyFactors!.factorFor(3)!.max, 2.6);
      expect(info.partyFactors!.source.name, 'Fextralife');
      expect(info.items.map((i) => i.id), [
        'flash',
        'sonic',
        'dung',
        'pitfallTrap',
        'shockTrap',
      ]);
      expect(info.reactionFor('flash').effect, ReactionEffect.affects);
      expect(info.reactionFor('flash').detail?.ptBr, 'Duração: 20 s');
      expect(info.reactionFor('dung').effect, ReactionEffect.conditional);
    });

    test('duplicate hp rank is rejected', () {
      final json = hunting();
      itemAt(listOf(firstMonster(json), 'hp'), 1)['rank'] = 'low';
      expectFormatError(json);
    });

    test('hp rank not allowed for the game is rejected', () {
      final json = withHuntingInfo(validDatasetJson(game: 'wilds'));
      firstMonster(json)['drops'] = <Object?>[];
      itemAt(listOf(firstMonster(json), 'hp'), 1)['rank'] = 'master';
      expectFormatError(json, game: Game.wilds);
    });

    test('solo hp must be positive', () {
      final json = hunting();
      itemAt(listOf(firstMonster(json), 'hp'), 0)['solo'] = 0;
      expectFormatError(json);
    });

    test('reaction item must be a dataset hunting item', () {
      final json = hunting();
      itemAt(listOf(firstMonster(json), 'itemReactions'), 0)['item'] =
          'barrelBomb';
      expectFormatError(json);
    });

    test('conditional reaction requires a detail', () {
      final json = hunting();
      itemAt(listOf(firstMonster(json), 'itemReactions'), 2).remove('detail');
      expectFormatError(json);
    });

    test('party factors must have 0 < min <= max and keys 2 to 4', () {
      final badRange = hunting();
      (badRange['partyHpFactors']! as Map<String, Object?>)['2'] = {
        'min': 2.0,
        'max': 1.5,
      };
      expectFormatError(badRange);

      final zero = hunting();
      (zero['partyHpFactors']! as Map<String, Object?>)['3'] = {
        'min': 0,
        'max': 1,
      };
      expectFormatError(zero);

      final badKey = hunting();
      (badKey['partyHpFactors']! as Map<String, Object?>)['5'] = {
        'min': 3,
        'max': 3,
      };
      expectFormatError(badKey);
    });
  });
}
