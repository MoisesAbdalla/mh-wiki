import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/decoration_plan.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';

/// Where a decoration sits.
enum EquipSlot { weapon, head, chest, arms, waist, legs, talisman }

EquipSlot equipSlotOf(BuildPart part) => switch (part) {
  BuildPart.head => EquipSlot.head,
  BuildPart.chest => EquipSlot.chest,
  BuildPart.arms => EquipSlot.arms,
  BuildPart.waist => EquipSlot.waist,
  BuildPart.legs => EquipSlot.legs,
};

/// A decoration placed in slot [index] (highest slot first) of [holder].
typedef PlacedDecoration = ({
  EquipSlot holder,
  int index,
  OptimizerDecoration decoration,
});

/// One result of Montar build (009 data-model).
final class BuildSet {
  const BuildSet({
    required this.weapon,
    required this.pieces,
    required this.alternatives,
    required this.talisman,
    required this.decorations,
    required this.skills,
    required this.missing,
    required this.freeSlots,
    required this.defense,
  });

  final OptimizerWeapon? weapon;
  final Map<BuildPart, OptimizerPiece> pieces;

  /// Pieces of the same part that give the same wanted skills and slots.
  final Map<BuildPart, List<OptimizerPiece>> alternatives;
  final UserTalisman? talisman;
  final List<PlacedDecoration> decorations;

  /// Every skill of the set, capped at its max level.
  final Map<String, int> skills;

  /// Wanted skill → levels short.
  final Map<String, int> missing;

  /// Slot levels left empty, highest first.
  final List<int> freeSlots;
  final int defense;

  bool get complete => missing.isEmpty;

  int get missingTotal => missing.values.fold(0, (a, b) => a + b);

  /// The identity used to drop duplicates: weapon, pieces and talisman.
  String get signature => [
    weapon?.id,
    for (final p in BuildPart.values) pieces[p]?.id,
    talisman?.id,
  ].join('|');
}

/// Reports how many combinations were checked so far.
typedef SearchProgress = void Function(int checked);

/// Finds up to [limit] sets for [request] (009 research R4): pareto pruning
/// per choice, then dynamic programming over the capped wanted-skill vector
/// and the free slots, then an exact decoration check and ranking. When no
/// set reaches every level, the closest ones are returned instead.
List<BuildSet> searchBuilds(
  OptimizerCatalog catalog,
  BuildRequest request,
  List<UserTalisman> talismans, {
  SearchProgress? onProgress,
  bool Function()? cancelled,
  int limit = 10,
}) {
  final search = _Search(catalog, request, talismans, onProgress, cancelled);
  final strict = search.run(strict: true, limit: limit);
  if (strict.any((s) => s.complete)) return strict;
  return search.run(strict: false, limit: limit);
}

/// Thrown inside a search when [searchBuilds]'s `cancelled` returns true.
final class SearchCancelled implements Exception {
  const SearchCancelled();
}

// ------------------------------------------------------------------ search

/// One option for a stage: a weapon, a talisman (or none) or a piece.
final class _Cand {
  _Cand(this.item, this.points, this.slots, this.score);

  final Object? item;

  /// Wanted skill points, capped at the wanted levels.
  final List<int> points;

  /// Slot levels, highest first, padded to 3.
  final List<int> slots;

  /// Tie-break among identical profiles: higher is better.
  final int score;
  final alternatives = <OptimizerPiece>[];
}

/// A chain of choices, newest last.
final class _Path {
  const _Path(this.parent, this.choice);

  final _Path? parent;
  final int choice;

  List<int> choices() {
    final out = <int>[];
    for (_Path? p = this; p != null; p = p.parent) {
      out.add(p.choice);
    }
    return out.reversed.toList();
  }
}

final class _State {
  _State(this.skills, this.slots, this.paths);

  final List<int> skills;

  /// Slot counts by level, index 1–4.
  final List<int> slots;
  final List<_Path?> paths;
}

final class _Search {
  _Search(
    this.catalog,
    this.request,
    this.talismans,
    this.onProgress,
    this.cancelled,
  ) : wanted = [
        for (final e in request.skills.entries)
          if (catalog.skills[e.key] case final s?)
            (s.id, e.value.clamp(1, s.max)),
      ];

  final OptimizerCatalog catalog;
  final BuildRequest request;
  final List<UserTalisman> talismans;
  final SearchProgress? onProgress;
  final bool Function()? cancelled;
  final List<(String, int)> wanted;

  static const _pathsPerState = 3;
  static const _strictCap = 40000;
  static const _relaxedCap = 6000;
  int _checked = 0;
  late final _planner = DecorationPlanner(catalog.decorationsBySkill);

  late final List<List<_Cand>> stages = [
    _weapons(),
    _talismans(),
    for (final part in BuildPart.values) _pieces(part),
  ];

  List<int> _pointsOf(Map<String, int> skills) => [
    for (final (id, want) in wanted) (skills[id] ?? 0).clamp(0, want),
  ];

  static List<int> _pad(List<int> slots) {
    final s = [...slots]..sort((a, b) => b - a);
    while (s.length < 3) {
      s.add(0);
    }
    return s;
  }

  List<_Cand> _weapons() {
    final fixed = request.fixedWeaponId;
    final all = fixed != null
        ? [?catalog.weapons[fixed]]
        : [
            for (final w
                in catalog.weaponsByType[request.weaponType] ??
                    const <OptimizerWeapon>[])
              if (w.rarity <= request.maxRarity && request.allows(w)) w,
          ];
    if (all.isEmpty) {
      return [_Cand(null, _pointsOf(const {}), _pad(const []), 0)];
    }
    return _pareto([
      for (final w in all)
        _Cand(w, _pointsOf(const {}), _pad(w.slots), w.attack * 100 + w.rarity),
    ], keepAlternatives: false);
  }

  List<_Cand> _talismans() => _pareto([
    _Cand(null, _pointsOf(const {}), _pad(const []), 0),
    if (request.useTalismans)
      for (final t in talismans)
        _Cand(t, _pointsOf(t.skills), _pad(t.slots), 1),
  ], keepAlternatives: false);

  List<_Cand> _pieces(BuildPart part) {
    final all = [
      for (final p in catalog.piecesByPart[part] ?? const <OptimizerPiece>[])
        if (p.rarity <= request.maxRarity)
          _Cand(p, _pointsOf(p.skills), _pad(p.slots), p.defense),
    ];
    if (all.isEmpty) {
      return [_Cand(null, _pointsOf(const {}), _pad(const []), 0)];
    }
    return _pareto(all, keepAlternatives: true);
  }

  /// Drops every option that another one beats or equals in all wanted
  /// skills and slot positions. Among identical profiles the best [score]
  /// stays; the others become its alternatives.
  static List<_Cand> _pareto(
    List<_Cand> all, {
    required bool keepAlternatives,
  }) {
    final sorted = [...all]..sort((a, b) => b.score - a.score);
    final kept = <_Cand>[];
    outer:
    for (final c in sorted) {
      for (final k in kept) {
        if (_same(k, c)) {
          if (keepAlternatives &&
              k.alternatives.length < 2 &&
              c.item is OptimizerPiece) {
            k.alternatives.add(c.item! as OptimizerPiece);
          }
          continue outer;
        }
        if (_dominates(k, c)) continue outer;
      }
      kept
        ..removeWhere((k) => _dominates(c, k))
        ..add(c);
    }
    return kept;
  }

  static bool _same(_Cand a, _Cand b) {
    for (var i = 0; i < a.points.length; i++) {
      if (a.points[i] != b.points[i]) return false;
    }
    for (var i = 0; i < 3; i++) {
      if (a.slots[i] != b.slots[i]) return false;
    }
    return true;
  }

  static bool _dominates(_Cand a, _Cand b) {
    for (var i = 0; i < a.points.length; i++) {
      if (a.points[i] < b.points[i]) return false;
    }
    for (var i = 0; i < 3; i++) {
      if (a.slots[i] < b.slots[i]) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------- bounds

  /// For stage i: the most points of each wanted skill the stages after i
  /// can still add, and the most slots of level ≥ l they can add.
  late final List<List<int>> _restPoints = _rest(
    (c, s) => c.points[s],
    wanted.length,
  );
  late final List<List<int>> _restSlots = _rest(
    (c, l) => c.slots.where((x) => x >= l).length,
    5,
  );

  List<List<int>> _rest(int Function(_Cand, int) value, int n) {
    final out = List.generate(stages.length, (_) => List.filled(n, 0));
    for (var i = stages.length - 2; i >= 0; i--) {
      for (var k = 0; k < n; k++) {
        var best = 0;
        for (final c in stages[i + 1]) {
          final v = value(c, k);
          if (v > best) best = v;
        }
        out[i][k] = out[i + 1][k] + best;
      }
    }
    return out;
  }

  /// Per wanted skill: the most points one jewel gives and the smallest
  /// slot a jewel of it needs; null when no jewel exists.
  late final List<({int points, int slot})?> _jewelBest = [
    for (final (id, _) in wanted)
      switch (catalog.decorationsBySkill[id]) {
        final list? when list.isNotEmpty => (
          points: list.map((d) => d.points).reduce((a, b) => a > b ? a : b),
          slot: list.map((d) => d.slot).reduce((a, b) => a < b ? a : b),
        ),
        _ => null,
      },
  ];

  /// Whether a state after stage [i] can still reach every wanted level,
  /// optimistically.
  bool _canComplete(int i, List<int> skills, List<int> slots) {
    final need = [0, 0, 0, 0, 0];
    for (var s = 0; s < wanted.length; s++) {
      final short = wanted[s].$2 - skills[s] - _restPoints[i][s];
      if (short <= 0) continue;
      final jewel = _jewelBest[s];
      if (jewel == null) return false;
      need[jewel.slot] += (short + jewel.points - 1) ~/ jewel.points;
    }
    var jewels = 0, have = 0;
    for (var l = 4; l >= 1; l--) {
      jewels += need[l];
      have += slots[l];
      if (jewels > have + _restSlots[i][l]) return false;
    }
    return true;
  }

  // -------------------------------------------------------------- the DP

  int _skillCode(List<int> skills) {
    var code = 0;
    for (var s = 0; s < wanted.length; s++) {
      code = code * (wanted[s].$2 + 1) + skills[s];
    }
    return code;
  }

  /// Slot counts as "level ≥ l" running totals, for dominance.
  static bool _slotsCover(List<int> a, List<int> b) {
    var ca = 0, cb = 0;
    for (var l = 4; l >= 1; l--) {
      ca += a[l];
      cb += b[l];
      if (ca < cb) return false;
    }
    return true;
  }

  static bool _slotsEqual(List<int> a, List<int> b) {
    for (var l = 1; l < 5; l++) {
      if (a[l] != b[l]) return false;
    }
    return true;
  }

  int _heuristic(_State s) {
    var h = 0;
    for (final v in s.skills) {
      h += v * 4;
    }
    for (var l = 1; l < 5; l++) {
      h += s.slots[l] * l;
    }
    return h;
  }

  List<BuildSet> run({required bool strict, required int limit}) {
    var states = <int, List<_State>>{
      _skillCode(List.filled(wanted.length, 0)): [
        _State(List.filled(wanted.length, 0), [0, 0, 0, 0, 0], [null]),
      ],
    };
    for (var i = 0; i < stages.length; i++) {
      if (cancelled?.call() ?? false) throw const SearchCancelled();
      final next = <int, List<_State>>{};
      for (final bucket in states.values) {
        for (final st in bucket) {
          for (final (ci, c) in stages[i].indexed) {
            if (++_checked % 4096 == 0) {
              onProgress?.call(_checked);
              if (cancelled?.call() ?? false) throw const SearchCancelled();
            }
            final skills = [
              for (var s = 0; s < wanted.length; s++)
                (st.skills[s] + c.points[s]).clamp(0, wanted[s].$2),
            ];
            final slots = [...st.slots];
            for (final l in c.slots) {
              if (l > 0) slots[l]++;
            }
            if (strict && !_canComplete(i, skills, slots)) continue;
            _insert(next, skills, slots, [
              for (final p in st.paths) _Path(p, ci),
            ]);
          }
        }
      }
      states = _cap(next, strict ? _strictCap : _relaxedCap);
      if (states.isEmpty) return const [];
    }
    onProgress?.call(_checked);
    final ranked = _rank(states, limit);
    return ranked;
  }

  void _insert(
    Map<int, List<_State>> into,
    List<int> skills,
    List<int> slots,
    List<_Path> paths,
  ) {
    final bucket = into[_skillCode(skills)] ??= [];
    for (var k = 0; k < bucket.length; k++) {
      final e = bucket[k];
      if (_slotsEqual(e.slots, slots)) {
        for (final p in paths) {
          if (e.paths.length >= _pathsPerState) break;
          e.paths.add(p);
        }
        return;
      }
      if (_slotsCover(e.slots, slots)) return;
    }
    bucket
      ..removeWhere((e) => _slotsCover(slots, e.slots))
      ..add(_State(skills, slots, paths.take(_pathsPerState).toList()));
  }

  Map<int, List<_State>> _cap(Map<int, List<_State>> states, int cap) {
    final all = [for (final b in states.values) ...b];
    if (all.length <= cap) return states;
    all.sort((a, b) => _heuristic(b) - _heuristic(a));
    final out = <int, List<_State>>{};
    for (final s in all.take(cap)) {
      (out[_skillCode(s.skills)] ??= []).add(s);
    }
    return out;
  }

  // ------------------------------------------------------------- results

  List<BuildSet> _rank(Map<int, List<_State>> states, int limit) {
    // Rank on cheap keys first; build only the sets that are shown.
    final finals =
        <
          ({
            List<int> choices,
            DecorationPlan plan,
            int missing,
            int freeLevels,
            int defense,
          })
        >[];
    // The exact decoration plan is the costly part, so states go in order of
    // an optimistic key, and planning stops once [limit] results are better
    // than anything the remaining states could give.
    final candidates =
        [
          for (final bucket in states.values)
            for (final st in bucket)
              () {
                final deficit = {
                  for (var s = 0; s < wanted.length; s++)
                    wanted[s].$1: wanted[s].$2 - st.skills[s],
                };
                final slotList = [
                  for (var l = 4; l >= 1; l--)
                    for (var n = 0; n < st.slots[l]; n++) l,
                ];
                return (
                  state: st,
                  deficit: deficit,
                  slots: slotList,
                  bound: _planner.bound(deficit, slotList),
                );
              }(),
        ]..sort((a, b) {
          final m = a.bound.missing - b.bound.missing;
          return m != 0 ? m : b.bound.freeLevels - a.bound.freeLevels;
        });
    // The keys of the best results so far, worst last.
    final best = <(int, int)>[];
    bool beaten((int, int) key) {
      if (best.length < limit) return false;
      final worst = best.last;
      return key.$1 > worst.$1 || (key.$1 == worst.$1 && key.$2 < worst.$2);
    }

    for (final c in candidates) {
      if (beaten((c.bound.missing, c.bound.freeLevels))) break;
      {
        final st = c.state;
        if (cancelled?.call() ?? false) throw const SearchCancelled();
        final plan = _planner.plan(c.deficit, c.slots);
        final key = (
          plan.missingTotal,
          plan.freeSlots.fold<int>(0, (a, b) => a + b),
        );
        for (var n = 0; n < st.paths.length; n++) {
          best
            ..add(key)
            ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : b.$2 - a.$2);
          if (best.length > limit) best.removeLast();
        }
        final freeLevels = plan.freeSlots.fold(0, (a, b) => a + b);
        for (final path in st.paths) {
          final choices = path!.choices();
          var defense = 0;
          for (var i = 2; i < stages.length; i++) {
            if (stages[i][choices[i]].item case final OptimizerPiece p) {
              defense += p.defense;
            }
          }
          finals.add((
            choices: choices,
            plan: plan,
            missing: plan.missingTotal,
            freeLevels: freeLevels,
            defense: defense,
          ));
        }
      }
    }
    finals.sort((a, b) {
      if (a.missing != b.missing) return a.missing - b.missing;
      if (a.freeLevels != b.freeLevels) return b.freeLevels - a.freeLevels;
      final slots = b.plan.freeSlots.length - a.plan.freeSlots.length;
      if (slots != 0) return slots;
      return b.defense - a.defense;
    });
    final out = <BuildSet>[];
    final seen = <String>{};
    for (final f in finals) {
      if (out.length >= limit) break;
      final set = _assemble(f.choices, f.plan);
      if (seen.add(set.signature)) out.add(set);
    }
    return out;
  }

  BuildSet _assemble(List<int> choices, DecorationPlan plan) {
    final weapon = stages[0][choices[0]].item as OptimizerWeapon?;
    final talisman = stages[1][choices[1]].item as UserTalisman?;
    final pieces = <BuildPart, OptimizerPiece>{};
    final alternatives = <BuildPart, List<OptimizerPiece>>{};
    for (final (i, part) in BuildPart.values.indexed) {
      final c = stages[2 + i][choices[2 + i]];
      if (c.item case final OptimizerPiece p) {
        pieces[part] = p;
        if (c.alternatives.isNotEmpty) {
          alternatives[part] = List.of(c.alternatives);
        }
      }
    }

    // Each jewel, largest first, into the smallest free slot that fits.
    final free = <({EquipSlot holder, int index, int level})>[
      if (weapon != null)
        for (final (i, l) in weapon.slots.indexed)
          (holder: EquipSlot.weapon, index: i, level: l),
      for (final e in pieces.entries)
        for (final (i, l) in e.value.slots.indexed)
          (holder: equipSlotOf(e.key), index: i, level: l),
      if (talisman != null)
        for (final (i, l) in talisman.slots.indexed)
          if (l > 0) (holder: EquipSlot.talisman, index: i, level: l),
    ]..sort((a, b) => a.level - b.level);
    final placed = <PlacedDecoration>[];
    for (final jewel in plan.jewels) {
      final i = free.indexWhere((s) => s.level >= jewel.slot);
      if (i < 0) continue;
      final s = free.removeAt(i);
      placed.add((holder: s.holder, index: s.index, decoration: jewel));
    }

    final raw = <String, int>{};
    void add(Map<String, int> skills) {
      for (final e in skills.entries) {
        raw[e.key] = (raw[e.key] ?? 0) + e.value;
      }
    }

    for (final p in pieces.values) {
      add(p.skills);
    }
    if (talisman != null) add(talisman.skills);
    for (final d in placed) {
      add({d.decoration.skill: d.decoration.points});
    }
    final skills = {
      for (final e in raw.entries)
        e.key: e.value.clamp(0, catalog.skills[e.key]?.max ?? e.value),
    };
    final missing = <String, int>{
      for (final (id, want) in wanted)
        if ((skills[id] ?? 0) < want) id: want - (skills[id] ?? 0),
    };
    return BuildSet(
      weapon: weapon,
      pieces: pieces,
      alternatives: alternatives,
      talisman: talisman,
      decorations: placed,
      skills: skills,
      missing: missing,
      freeSlots: [for (final s in free.reversed) s.level],
      defense: pieces.values.fold(0, (a, p) => a + p.defense),
    );
  }
}
