import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/assistant/data/build_json.dart';
import 'package:mh_wiki/features/assistant/data/optimizer_json.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';

/// 009 T007: the optimizer on the shipped data (SC-001, SC-002, SC-003).
void main() {
  late OptimizerCatalog catalog;
  late List<CuratedBuild> curated;

  Map<String, Object?> read(String name) =>
      jsonDecode(File('assets/data/rise_sunbreak/$name').readAsStringSync())
          as Map<String, Object?>;

  setUpAll(() {
    catalog = readOptimizerDataset(
      read('optimizer.json'),
      expectedGame: Game.riseSunbreak,
    );
    curated = readBuildsDataset(
      read('builds.json'),
      expectedGame: Game.riseSunbreak,
    ).builds;
  });

  /// Recomputes a set's skills from its parts and checks every jewel fits.
  void verify(BuildSet set, BuildRequest request) {
    final raw = <String, int>{};
    void add(String id, int n) => raw[id] = (raw[id] ?? 0) + n;
    for (final p in set.pieces.values) {
      expect(p.rarity, lessThanOrEqualTo(request.maxRarity));
      p.skills.forEach(add);
    }
    set.talisman?.skills.forEach(add);
    for (final d in set.decorations) {
      final slots = switch (d.holder) {
        EquipSlot.weapon => set.weapon!.slots,
        EquipSlot.talisman => set.talisman!.slots,
        final h => set.pieces[BuildPart.values[h.index - 1]]!.slots,
      };
      expect(slots[d.index], greaterThanOrEqualTo(d.decoration.slot));
      add(d.decoration.skill, d.decoration.points);
    }
    final used = <(EquipSlot, int)>{};
    for (final d in set.decorations) {
      expect(
        used.add((d.holder, d.index)),
        isTrue,
        reason: 'two jewels in one slot',
      );
    }
    for (final e in raw.entries) {
      final capped = e.value.clamp(0, catalog.skills[e.key]!.max);
      expect(set.skills[e.key], capped, reason: e.key);
    }
    for (final e in request.skills.entries) {
      final got = set.skills[e.key] ?? 0;
      expect(set.missing[e.key] ?? 0, got >= e.value ? 0 : e.value - got);
    }
  }

  BuildRequest req(
    Map<String, int> skills, {
    String type = 'great-sword',
    Progress progress = const Progress(ProgressRank.master, 'M6'),
    String? weapon,
  }) => BuildRequest(
    skills: skills,
    weaponType: type,
    progress: progress,
    fixedWeaponId: weapon,
  );

  test('the dataset loads', () {
    expect(catalog.skills, hasLength(147));
    expect(catalog.decorations, hasLength(243));
    expect(catalog.piecesByPart.values.expand((p) => p), hasLength(1371));
    expect(catalog.weapons, hasLength(3925));
  });

  test('M6 Great Sword with the four core skills is complete', () {
    final request = req({
      'attack-boost': 7,
      'critical-eye': 7,
      'critical-boost': 3,
      'weakness-exploit': 3,
    });
    final sets = searchBuilds(catalog, request, const []);
    expect(sets, isNotEmpty);
    expect(sets.first.complete, isTrue);
    for (final s in sets) {
      verify(s, request);
    }
  });

  test('Charge Blade with Impact phial and Gunlance with Wide shelling', () {
    for (final (type, trait, skills) in [
      (
        'charge-blade',
        'impact',
        {'artillery': 3, 'critical-eye': 7, 'attack-boost': 7},
      ),
      ('gunlance', 'wide', {'artillery': 3, 'load-shells': 2, 'guard': 3}),
    ]) {
      final request = BuildRequest(
        skills: skills,
        weaponType: type,
        progress: const Progress(ProgressRank.master, 'M6'),
        weaponTrait: trait,
      );
      final sets = searchBuilds(catalog, request, const []);
      expect(sets.first.complete, isTrue, reason: type);
      for (final s in sets) {
        expect(s.weapon?.trait?.key, trait);
        verify(s, request);
      }
    }
  });

  test('SC-001 and SC-002: 20 requests, every result checks out', () {
    final requests = [
      req({
        'attack-boost': 7,
        'critical-eye': 7,
        'critical-boost': 3,
        'weakness-exploit': 3,
      }),
      req({
        'attack-boost': 4,
        'critical-eye': 4,
      }, progress: const Progress(ProgressRank.high, '7')),
      req({
        'attack-boost': 3,
        'recovery-up': 2,
      }, progress: const Progress(ProgressRank.low, '2')),
      req({
        'agitator': 5,
        'critical-eye': 7,
        'weakness-exploit': 3,
        'handicraft': 3,
      }, type: 'long-sword'),
      req({
        'critical-element': 3,
        'water-attack': 5,
        'critical-eye': 7,
      }, type: 'dual-blades'),
      req({
        'attack-boost': 7,
        'critical-eye': 7,
        'critical-boost': 3,
        'weakness-exploit': 3,
        'agitator': 5,
      }, type: 'hammer'),
      req({
        'guard': 5,
        'guard-up': 3,
        'offensive-guard': 3,
        'attack-boost': 7,
      }, type: 'lance'),
      req(
        {'artillery': 3, 'load-shells': 2, 'guard': 3},
        type: 'gunlance',
        progress: const Progress(ProgressRank.master, 'M3'),
      ),
      req(
        {'evade-extender': 3, 'critical-eye': 7, 'weakness-exploit': 3},
        type: 'bow',
        progress: const Progress(ProgressRank.post, '100'),
      ),
      req({
        'spare-shot': 3,
        'rapid-fire-up': 3,
        'reload-speed': 3,
        'recoil-down': 3,
      }, type: 'light-bowgun'),
      req({
        'normal-rapid-up': 3,
        'weakness-exploit': 3,
        'critical-eye': 7,
        'attack-boost': 7,
      }, type: 'heavy-bowgun'),
      req(
        {'horn-maestro': 1, 'attack-boost': 7, 'critical-eye': 5},
        type: 'hunting-horn',
        progress: const Progress(ProgressRank.master, 'M2'),
      ),
      req({
        'power-prolonger': 3,
        'rapid-morph': 3,
        'critical-eye': 7,
      }, type: 'switch-axe'),
      req(
        {'artillery': 3, 'guard': 3, 'evade-window': 3},
        type: 'charge-blade',
        progress: const Progress(ProgressRank.high, '5'),
      ),
      req({
        'critical-eye': 7,
        'weakness-exploit': 3,
        'wirebug-whisperer': 1,
      }, type: 'insect-glaive'),
      req(
        {
          'attack-boost': 7,
          'critical-eye': 7,
          'critical-boost': 3,
          'weakness-exploit': 3,
          'burst': 3,
          'maximum-might': 3,
        },
        type: 'sword-and-shield',
        progress: const Progress(ProgressRank.post, '180'),
      ),
      req({
        'focus': 3,
        'charge-master': 3,
      }, progress: const Progress(ProgressRank.low, '1')),
      req({
        'divine-blessing': 3,
        'recovery-up': 3,
        'recovery-speed': 3,
      }, type: 'gunlance'),
      req({
        'attack-boost': 7,
        'critical-eye': 7,
        'critical-boost': 3,
      }, weapon: 'fine-kamura-cleaver'),
      req({
        'dereliction': 3,
        'critical-eye': 7,
        'attack-boost': 7,
        'weakness-exploit': 3,
      }, progress: const Progress(ProgressRank.post, '140')),
    ];
    var slowest = Duration.zero;
    for (final (i, r) in requests.indexed) {
      for (final id in r.skills.keys) {
        expect(catalog.skills, contains(id), reason: 'request $i asks for $id');
      }
      final watch = Stopwatch()..start();
      final sets = searchBuilds(catalog, r, const []);
      watch.stop();
      if (watch.elapsed > slowest) slowest = watch.elapsed;
      // ignore: avoid_print
      print(
        'request $i: ${sets.length} sets, ${sets.where((s) => s.complete).length} complete, '
        '${watch.elapsedMilliseconds} ms',
      );
      expect(sets, isNotEmpty, reason: 'request $i');
      for (final s in sets) {
        verify(s, r);
        if (r.fixedWeaponId != null) expect(s.weapon?.id, r.fixedWeaponId);
      }
    }
    // ignore: avoid_print
    print('slowest ${slowest.inMilliseconds} ms');
    expect(slowest, lessThan(const Duration(seconds: 10)));
  });

  test('SC-003: curated Master and Post builds are found complete', () {
    var total = 0, found = 0;
    final misses = <String>[];
    for (final b in curated) {
      if (b.stage.rank != ProgressRank.master &&
          b.stage.rank != ProgressRank.post) {
        continue;
      }
      final weapon = b.weapon.ref.id;
      if (weapon == null || catalog.weapons[weapon] == null) continue;
      final skills = {
        for (final s in b.skills)
          if (s.skill.id case final id? when catalog.skills.containsKey(id))
            id: s.level.clamp(1, catalog.skills[id]!.max),
      };
      // The talisman is the user's; this request has none, so leave its
      // contribution out by asking only what pieces and jewels can give.
      final t = b.talisman;
      if (t != null && t.skill.id != null && skills.containsKey(t.skill.id)) {
        final rest = skills[t.skill.id!]! - t.level;
        if (rest <= 0) {
          skills.remove(t.skill.id);
        } else {
          skills[t.skill.id!] = rest;
        }
      }
      // The build's five main skills: highest level first, as the guide
      // lists them (spec SC-003).
      final main = (skills.entries.toList()..sort((x, y) => y.value - x.value))
          .take(5);
      skills
        ..clear()
        ..addEntries(main);
      if (skills.isEmpty) continue;
      total++;
      final sets = searchBuilds(
        catalog,
        req(
          skills,
          type: b.weaponType,
          progress: b.stage,
          weapon: weapon,
        ).copyAll(),
        const [],
      );
      if (sets.isNotEmpty && sets.first.complete) {
        found++;
      } else {
        misses.add('${b.name} (${sets.isEmpty ? 'none' : sets.first.missing})');
      }
    }
    // ignore: avoid_print
    print(
      'SC-003: $found / $total complete; misses: ${misses.take(15).join('; ')}',
    );
    expect(found / total, greaterThanOrEqualTo(0.95));
  });
}

extension on BuildRequest {
  /// Curated builds may use pieces above their stage's rarity; search all.
  BuildRequest copyAll() => BuildRequest(
    skills: skills,
    weaponType: weaponType,
    progress: progress,
    fixedWeaponId: fixedWeaponId,
    onlyMyProgress: false,
  );
}
