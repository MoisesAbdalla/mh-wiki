import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/datasources/asset_monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_mapper.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';

/// Guards the shipped data: every bundled dataset must parse and validate,
/// and every monster must have a bundled thumbnail (002 SC-001).
/// Base monsters the sources list without a habitat (arena, story or
/// collab fights), per game slug (SC-003 exceptions).
const noHabitat = <String>{};

/// Base monsters without quest HP in the sources (004 research R4): Wilds
/// free title updates and the collab fight are not in Kiranico's quest list.
const noHp = <String>{
  'lagiacrus',
  'seregios',
  'gogmazios',
  'mizutsune',
  'omega-planetes',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final datasource = AssetMonsterDatasource(rootBundle);

  Future<List<Monster>> load(Game game) async {
    final json = await datasource.fetchDataset(game);
    final dataset = MonsterDatasetDto.fromJson(json, expectedGame: game);
    return MonsterDatasetMapper.toMonsters(dataset);
  }

  for (final game in Game.values) {
    test('${game.datasetKey} dataset is valid', () async {
      final monsters = await load(game);

      expect(monsters, isNotEmpty);
      expect(
        monsters.map((m) => m.id.slug).toSet(),
        hasLength(monsters.length),
      );
    });

    test('${game.datasetKey} monsters all have a bundled thumbnail', () async {
      for (final monster in await load(game)) {
        final asset = monster.imageAsset;
        expect(asset, isNotNull, reason: '${monster.id} has no image');
        final bytes = await rootBundle.load(asset!);
        expect(bytes.lengthInBytes, greaterThan(0), reason: asset);
      }
    });

    test(
      '${game.datasetKey} base monsters have a reference HP (003)',
      () async {
        for (final monster in await load(game)) {
          // Versions carry only the HP their sources give (004 R3).
          if (monster.isVersion || noHp.contains(monster.id.slug)) continue;
          expect(monster.huntingInfo.hp, isNotEmpty, reason: '${monster.id}');
        }
      },
    );

    test('${game.datasetKey} documents party HP factors (003)', () async {
      final factors = (await load(game)).first.huntingInfo.partyFactors;
      expect(factors, isNotNull);
      expect(factors!.factors.keys, containsAll([2, 3, 4]));
    });

    test(
      '${game.datasetKey} reactions only use the game items (003)',
      () async {
        for (final monster in await load(game)) {
          final info = monster.huntingInfo;
          final ids = {for (final item in info.items) item.id};
          expect(ids, hasLength(5), reason: '${monster.id}');
          for (final reaction in info.reactions) {
            expect(ids, contains(reaction.item), reason: '${monster.id}');
          }
          expect(
            info.reactions.map((r) => r.item).toSet(),
            hasLength(info.reactions.length),
            reason: '${monster.id} has a duplicate reaction',
          );
        }
      },
    );
  }

  test('World Rathalos item reactions match the wiki (003)', () async {
    final info = (await load(Game.worldIceborne))
        .singleWhere((m) => m.id.slug == 'rathalos')
        .huntingInfo;
    expect(info.reactionFor('flash').effect, ReactionEffect.affects);
    expect(info.reactionFor('sonic').effect, ReactionEffect.noEffect);
    final dung = info.reactionFor('dung');
    expect(dung.effect, ReactionEffect.affects);
    expect(dung.detail!.ptBr, '50% de chance de fugir');
    expect(info.vision, Vision.sees);
  });

  test('Wilds: Rathalos sees, Gore Magala is not flashed (003)', () async {
    final monsters = await load(Game.wilds);
    HuntingInfo info(String slug) =>
        monsters.singleWhere((m) => m.id.slug == slug).huntingInfo;
    expect(
      info('rathalos').reactionFor('flash').effect,
      ReactionEffect.affects,
    );
    expect(
      info('gore-magala').reactionFor('flash').effect,
      ReactionEffect.noEffect,
    );
    expect(info('gore-magala').vision, Vision.unknown);
  });

  test('World Rathalos HP matches Kiranico expeditions (003)', () async {
    final rathalos = (await load(Game.worldIceborne))
        .singleWhere((m) => m.id.slug == 'rathalos');
    expect(
      [for (final hp in rathalos.huntingInfo.hp) (hp.rank, hp.solo, hp.basis)],
      [
        (Rank.low, 4908, HpBasis.expedition),
        (Rank.high, 6565, HpBasis.expedition),
        (Rank.master, 20800, HpBasis.expedition),
      ],
    );
  });

  test('Wilds Rathalos HP matches the Kiranico quest list (003)', () async {
    final rathalos = (await load(Game.wilds))
        .singleWhere((m) => m.id.slug == 'rathalos');
    final hp = rathalos.huntingInfo.hp.single;
    expect((hp.rank, hp.solo), (Rank.high, 13500));
    expect(
      hp.partyEstimate(rathalos.huntingInfo.partyFactors, 4),
      const HpRange(32400, 32400), // Kiranico: 4 players = 32,400
    );
  });

  group('full roster (004)', () {
    /// Slugs of `tool/data/rosters/<game>.json`; empty until the game's
    /// phase builds it.
    Map<String, Map<String, Object?>> roster(Game game) {
      final file = File('tool/data/rosters/${game.datasetKey}.json');
      if (!file.existsSync()) return const {};
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      return {
        for (final m
            in (json['monsters']! as List<Object?>)
                .cast<Map<String, Object?>>())
          m['slug']! as String: m,
      };
    }

    for (final game in Game.values) {
      test('${game.datasetKey} matches its roster (SC-001)', () async {
        final expected = roster(game);
        if (expected.isEmpty) return; // phase not started
        final monsters = await load(game);
        expect(monsters.map((m) => m.id.slug).toSet(), expected.keys.toSet());
        for (final m in monsters) {
          final entry = expected[m.id.slug]!;
          expect(m.versionOf?.slug, entry['versionOf'], reason: '${m.id}');
          expect(m.versionKind?.name, entry['versionKind'], reason: '${m.id}');
        }
      });

      test('${game.datasetKey} base monsters are complete (SC-003)', () async {
        for (final m in await load(game)) {
          if (m.isVersion) continue;
          expect(m.classification.en, isNot('Unknown'), reason: '${m.id}');
          expect(
            m.habitats.isNotEmpty || noHabitat.contains(m.id.slug),
            isTrue,
            reason: '${m.id} has no habitat and is not a documented exception',
          );
        }
      });
    }

    test('Wilds Guardian Rathalos is a guardian version of Rathalos', () async {
      final guardian = (await load(Game.wilds))
          .singleWhere((m) => m.id.slug == 'guardian-rathalos');
      expect(guardian.versionOf?.slug, 'rathalos');
      expect(guardian.versionKind, VersionKind.guardian);
      expect(guardian.inheritedSections, isEmpty);
    });

    test('Wilds arch-tempered versions come from their quests', () async {
      final monsters = await load(Game.wilds);
      final arch = monsters.where(
        (m) => m.versionKind == VersionKind.archTempered,
      );
      expect(arch.map((m) => m.versionOf!.slug).toSet(), {
        'rey-dau',
        'uth-duna',
        'nu-udra',
        'jin-dahaad',
        'arkveld',
      });
      for (final m in arch) {
        // Event quests are not on Kiranico: no HP, rewards without rates.
        expect(m.huntingInfo.hp, isEmpty, reason: '${m.id}');
        expect(m.drops, isNotEmpty, reason: '${m.id}');
        for (final d in m.drops) {
          expect(d.rank, Rank.high, reason: '${m.id}');
          expect(d.method, DropMethod.questReward, reason: '${m.id}');
          expect(d.ratePercent, isNull, reason: '${m.id}');
        }
      }
      final reyDau = arch.singleWhere(
        (m) => m.id.slug == 'arch-tempered-rey-dau',
      );
      expect(
        reyDau.drops.map((d) => d.material.name.en),
        containsAll(['Rey Dau Plate', 'Rey Dau Certificate γ']),
      );
    });
  });

  test('the same monster uses a different thumbnail in each game', () async {
    final images = <List<int>>[];
    for (final game in Game.values) {
      final rathalos = (await load(game))
          .singleWhere((m) => m.id.slug == 'rathalos');
      final data = await rootBundle.load(rathalos.imageAsset!);
      images.add(data.buffer.asUint8List());
    }
    expect(images[0], isNot(equals(images[1])));
    expect(images[1], isNot(equals(images[2])));
    expect(images[0], isNot(equals(images[2])));
  });
}
