import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/decoration_plan.dart';

import '../../../fakes/optimizer_fixtures.dart';

/// 009 T003: the optimizer domain.
void main() {
  group('maxRarityFor (research R3)', () {
    test('every step', () {
      final expected = {
        'low': [3, 3, 3],
        'high': [5, 6, 7, 7],
        'master': [8, 8, 9, 9, 10, 10],
        'post': [10, 10, 10, 10, 10],
      };
      for (final rank in ProgressRank.values) {
        expect(
          [
            for (final s in Progress.stepsOf(rank))
              maxRarityFor(Progress(rank, s)),
          ],
          expected[rank.name],
          reason: rank.name,
        );
      }
    });
  });

  group('planDecorations', () {
    final bySkill = fixtureCatalog().decorationsBySkill;

    test('a +2 jewel in a level-4 slot', () {
      final plan = planDecorations(
        deficit: {'attack': 2},
        slots: [4],
        bySkill: bySkill,
      );
      expect(plan.missing, isEmpty);
      expect(plan.jewels.single.id, 'attack+4');
      expect(plan.freeSlots, isEmpty);
    });

    test('equal free levels: more free slots wins', () {
      // One +2 jewel in the 4 leaves 2+2; two +1 jewels leave the 4. Both
      // leave 4 levels; two slots are more useful than one.
      final plan = planDecorations(
        deficit: {'attack': 2},
        slots: [4, 2, 2],
        bySkill: bySkill,
      );
      expect(plan.missing, isEmpty);
      expect(plan.jewels.map((j) => j.id), ['attack+4']);
      expect(plan.freeSlots, [2, 2]);
    });

    test('a level-3 jewel does not fit a level-2 slot', () {
      final plan = planDecorations(
        deficit: {'guard': 1},
        slots: [2, 2],
        bySkill: bySkill,
      );
      expect(plan.missing, {'guard': 1});
      expect(plan.freeSlots, [2, 2]);
    });

    test('an infeasible deficit covers as much as it can', () {
      final plan = planDecorations(
        deficit: {'attack': 3, 'crit': 2, 'nodeco': 1},
        slots: [2, 2],
        bySkill: bySkill,
      );
      expect(plan.missingTotal, 4);
      expect(plan.missing['nodeco'], 1);
    });

    test('jewels go into the smallest slot that fits', () {
      final plan = planDecorations(
        deficit: {'crit': 1},
        slots: [4, 2],
        bySkill: bySkill,
      );
      expect(plan.freeSlots, [4]);
    });
  });

  group('searchBuilds', () {
    final catalog = fixtureCatalog();
    BuildRequest req(
      Map<String, int> skills, {
      String? weapon,
      bool talismans = true,
      bool onlyMine = true,
      Progress progress = const Progress(ProgressRank.post, '10'),
    }) => BuildRequest(
      skills: skills,
      weaponType: 'great-sword',
      progress: progress,
      fixedWeaponId: weapon,
      useTalismans: talismans,
      onlyMyProgress: onlyMine,
    );

    test('finds a complete set and its skills add up', () {
      final sets = searchBuilds(
        catalog,
        req({'attack': 7, 'crit': 3}),
        const [],
      );
      expect(sets, isNotEmpty);
      final best = sets.first;
      expect(best.complete, isTrue);
      expect(best.skills['attack'], 7);
      expect(best.skills['crit'], greaterThanOrEqualTo(3));
      expect(best.weapon?.type, 'great-sword');
    });

    test(
      'pareto: a dominated piece is never used; twins become alternatives',
      () {
        final sets = searchBuilds(catalog, req({'attack': 7}), const []);
        for (final s in sets) {
          expect(s.pieces[BuildPart.head]?.id, isNot('head-b'));
        }
        final withA = sets.firstWhere(
          (s) => s.pieces[BuildPart.head]?.id == 'head-a',
        );
        expect(withA.alternatives[BuildPart.head]?.single.id, 'head-twin');
      },
    );

    test('"quase" results when nothing is complete', () {
      final sets = searchBuilds(catalog, req({'nodeco': 3}), const []);
      expect(sets, isNotEmpty);
      expect(sets.first.complete, isFalse);
      expect(sets.first.missing, {'nodeco': 2});
    });

    test('ranking: complete first, then fewer missing, then free slots', () {
      final sets = searchBuilds(catalog, req({'attack': 5}), const []);
      var lastComplete = true;
      for (final s in sets) {
        if (!s.complete) lastComplete = false;
        if (s.complete) expect(lastComplete, isTrue);
      }
      for (var i = 1; i < sets.length; i++) {
        final a = sets[i - 1], b = sets[i];
        if (a.complete == b.complete && a.missingTotal == b.missingTotal) {
          expect(
            a.freeSlots.fold<int>(0, (x, y) => x + y),
            greaterThanOrEqualTo(b.freeSlots.fold<int>(0, (x, y) => x + y)),
          );
        }
      }
    });

    test('at most 10 distinct sets', () {
      final sets = searchBuilds(catalog, req({'attack': 1}), const []);
      expect(sets.length, lessThanOrEqualTo(10));
      expect(sets.map((s) => s.signature).toSet(), hasLength(sets.length));
    });

    test('weapon filters: phial and element', () {
      BuildRequest cb({String? trait, String? element}) => BuildRequest(
        skills: const {'attack': 3},
        weaponType: 'charge-blade',
        progress: const Progress(ProgressRank.post, '10'),
        weaponTrait: trait,
        weaponElement: element,
      );
      // Unfiltered, the best slots win (the fire Element blade).
      expect(
        searchBuilds(catalog, cb(), const []).first.weapon?.id,
        'cb-element',
      );
      final impact = searchBuilds(catalog, cb(trait: 'impact'), const []);
      expect(impact.every((s) => s.weapon?.id == 'cb-impact'), isTrue);
      final ice = searchBuilds(catalog, cb(element: 'ice'), const []);
      expect(ice.every((s) => s.weapon?.id == 'cb-ice'), isTrue);
      final raw = searchBuilds(
        catalog,
        cb(element: BuildRequest.noElement),
        const [],
      );
      expect(raw.every((s) => s.weapon?.id == 'cb-impact'), isTrue);
    });

    test('a fixed weapon is always used', () {
      final sets = searchBuilds(
        catalog,
        req({'attack': 5}, weapon: 'sword-weak'),
        const [],
      );
      expect(sets.every((s) => s.weapon?.id == 'sword-weak'), isTrue);
    });

    test('only my progress drops higher rarities; off brings them back', () {
      const m2 = Progress(ProgressRank.master, 'M2');
      final mine = searchBuilds(
        catalog,
        req({'attack': 3}, progress: m2),
        const [],
      );
      for (final s in mine) {
        expect(s.pieces.values.every((p) => p.rarity <= 8), isTrue);
      }
      final all = searchBuilds(
        catalog,
        req({'attack': 7}, progress: m2, onlyMine: false),
        const [],
      );
      expect(all.first.complete, isTrue);
    });

    test('talismans are tried, and so is none', () {
      final crit = UserTalisman(
        id: 't1',
        skills: {'crit': 3},
        slots: [2, 0, 0],
      );
      final sets = searchBuilds(catalog, req({'attack': 7, 'crit': 6}), [crit]);
      expect(sets.first.complete, isTrue);
      expect(sets.first.talisman?.id, 't1');
      final off = searchBuilds(
        catalog,
        req({'attack': 7, 'crit': 6}, talismans: false),
        [crit],
      );
      expect(off.every((s) => s.talisman == null), isTrue);
    });

    test('decorations sit in slots that exist and fit', () {
      final sets = searchBuilds(
        catalog,
        req({'attack': 7, 'crit': 3}),
        const [],
      );
      for (final s in sets) {
        for (final d in s.decorations) {
          final slots = switch (d.holder) {
            EquipSlot.weapon => s.weapon!.slots,
            EquipSlot.talisman => s.talisman!.slots,
            final h => s.pieces[BuildPart.values[h.index - 1]]!.slots,
          };
          expect(slots[d.index], greaterThanOrEqualTo(d.decoration.slot));
        }
      }
    });

    test('cancel stops the search', () {
      expect(
        () => searchBuilds(
          catalog,
          req({'attack': 7, 'crit': 7, 'guard': 5}),
          const [],
          cancelled: () => true,
        ),
        throwsA(isA<SearchCancelled>()),
      );
    });
  });
}
