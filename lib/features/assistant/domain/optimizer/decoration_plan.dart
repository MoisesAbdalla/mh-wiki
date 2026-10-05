import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';

/// The jewels chosen to cover a skill deficit with a set's free slots
/// (009 research R4, step 3).
final class DecorationPlan {
  const DecorationPlan({
    required this.jewels,
    required this.missing,
    required this.freeSlots,
  });

  /// Largest slot first.
  final List<OptimizerDecoration> jewels;

  /// Skill id → levels still short after the jewels.
  final Map<String, int> missing;

  /// Slot levels left empty, highest first.
  final List<int> freeSlots;

  int get missingTotal => missing.values.fold(0, (a, b) => a + b);
}

/// Chooses jewels for [deficit] in [slots]: first the most levels covered,
/// then the most free slot levels left. Exact: it tries every useful jewel
/// mix per skill, so a +2 jewel in a level-4 slot is weighed against two +1
/// jewels in smaller slots.
DecorationPlan planDecorations({
  required Map<String, int> deficit,
  required List<int> slots,
  required Map<String, List<OptimizerDecoration>> bySkill,
}) => DecorationPlanner(bySkill).plan(deficit, slots);

/// [planDecorations] with caches, for many calls in one search: the jewel
/// mixes per (skill, need) and whole plans per (deficit, slots).
final class DecorationPlanner {
  DecorationPlanner(this.bySkill);

  final Map<String, List<OptimizerDecoration>> bySkill;
  final _mixCache = <String, List<_Mix>>{};
  final _planCache = <String, DecorationPlan>{};

  List<_Mix> _mixesOf(String skill, int need) =>
      _mixCache['$skill:$need'] ??= _mixes(need, bySkill[skill] ?? const []);

  final _minLevels = <String, int?>{};

  /// An optimistic view of [plan], cheap to compute: the fewest levels that
  /// stay short (skills with no jewel), and the most slot levels that can
  /// stay free. The real plan is never better than this.
  ({int missing, int freeLevels}) bound(
    Map<String, int> deficit,
    List<int> slots,
  ) {
    var missing = 0;
    var used = 0;
    for (final e in deficit.entries) {
      if (e.value <= 0) continue;
      // The smallest total slot level of a mix that covers the whole need.
      final min = _minLevels.putIfAbsent('${e.key}:${e.value}', () {
        int? best;
        for (final m in _mixesOf(e.key, e.value)) {
          if (m.covered < e.value) continue;
          var levels = 0;
          for (var l = 1; l < 5; l++) {
            levels += m.sizes[l] * l;
          }
          if (best == null || levels < best) best = levels;
        }
        return best;
      });
      if (min == null) {
        missing += e.value;
      } else {
        used += min;
      }
    }
    final total = slots.fold(0, (a, b) => a + b);
    return (missing: missing, freeLevels: total - used);
  }

  DecorationPlan plan(Map<String, int> deficit, List<int> slots) {
    final key = [
      for (final e in deficit.entries)
        if (e.value > 0) '${e.key}:${e.value}',
      slots.join(','),
    ].join('|');
    return _planCache[key] ??= _plan(
      deficit,
      slots,
      (skill, need) => _mixCache['$skill:$need'] ??= _mixes(
        need,
        bySkill[skill] ?? const [],
      ),
    );
  }
}

DecorationPlan _plan(
  Map<String, int> deficit,
  List<int> slots,
  List<_Mix> Function(String skill, int need) mixesOf,
) {
  final skills = [
    for (final e in deficit.entries)
      if (e.value > 0) e.key,
  ];
  final options = [for (final s in skills) mixesOf(s, deficit[s]!)];
  final slotsAtLeast = _atLeast(slots);

  // Best (covered, free) for skills [i..] given the jewel sizes used so far,
  // memoised on (i, jewel counts by size).
  final memo = <int, ({int covered, int free, List<_Mix> picks})>{};

  ({int covered, int free, List<_Mix> picks}) best(int i, List<int> used) {
    if (i == skills.length) {
      return (covered: 0, free: _freeLevels(slots, used), picks: const []);
    }
    // Counts stay below 32 (a set has at most 21 slots).
    final key =
        (((i * 32 + used[1]) * 32 + used[2]) * 32 + used[3]) * 32 + used[4];
    final cached = memo[key];
    if (cached != null) return cached;
    ({int covered, int free, List<_Mix> picks})? top;
    for (final mix in options[i]) {
      final next = [for (var l = 0; l < 5; l++) used[l] + mix.sizes[l]];
      if (!_fits(next, slotsAtLeast)) continue;
      final rest = best(i + 1, next);
      final covered = rest.covered + mix.covered;
      if (top == null ||
          covered > top.covered ||
          (covered == top.covered && rest.free > top.free)) {
        top = (covered: covered, free: rest.free, picks: [mix, ...rest.picks]);
      }
    }
    return memo[key] = top!;
  }

  final result = best(0, const [0, 0, 0, 0, 0]);
  final jewels = [for (final mix in result.picks) ...mix.jewels]
    ..sort((a, b) => b.slot - a.slot);
  final missing = <String, int>{};
  for (final (i, s) in skills.indexed) {
    final short = deficit[s]! - result.picks[i].covered;
    if (short > 0) missing[s] = short;
  }
  return DecorationPlan(
    jewels: jewels,
    missing: missing,
    freeSlots: _leftover(slots, [for (final j in jewels) j.slot]),
  );
}

/// A mix of jewels for one skill: how many levels it covers and the slot
/// sizes it needs (index 1–4).
final class _Mix {
  const _Mix(this.jewels, this.covered, this.sizes);

  final List<OptimizerDecoration> jewels;
  final int covered;
  final List<int> sizes;
}

/// Every mix of [jewels] covering 0..[need] levels, without useless extras:
/// a mix stops as soon as it reaches [need]. Mixes that cover the same and
/// need larger or more slots than another are dropped.
List<_Mix> _mixes(int need, List<OptimizerDecoration> jewels) {
  final types = [...jewels]..sort((a, b) => b.points - a.points);
  final out = <_Mix>[];

  void walk(int t, List<OptimizerDecoration> picked, int points) {
    if (points >= need || t == types.length) {
      final sizes = [0, 0, 0, 0, 0];
      for (final j in picked) {
        sizes[j.slot]++;
      }
      out.add(
        _Mix(List.unmodifiable(picked), points < need ? points : need, sizes),
      );
      return;
    }
    // Take another of type t, or move on to the next type.
    walk(t, [...picked, types[t]], points + types[t].points);
    walk(t + 1, picked, points);
  }

  walk(0, const [], 0);
  final kept = <_Mix>[];
  for (final m in out) {
    final dominated = out.any(
      (o) =>
          !identical(o, m) &&
          o.covered >= m.covered &&
          _sizesNoBigger(o.sizes, m.sizes) &&
          (o.covered > m.covered || !_sizesNoBigger(m.sizes, o.sizes)),
    );
    if (!dominated &&
        !kept.any((k) => k.covered == m.covered && _same(k.sizes, m.sizes))) {
      kept.add(m);
    }
  }
  return kept;
}

/// True when [a] needs no more slots than [b] at every "level or higher".
bool _sizesNoBigger(List<int> a, List<int> b) {
  var ca = 0, cb = 0;
  for (var l = 4; l >= 1; l--) {
    ca += a[l];
    cb += b[l];
    if (ca > cb) return false;
  }
  return true;
}

bool _same(List<int> a, List<int> b) {
  for (var l = 1; l < 5; l++) {
    if (a[l] != b[l]) return false;
  }
  return true;
}

/// Slots of level ≥ l, for l = 1..4.
List<int> _atLeast(List<int> slots) => [
  0,
  for (var l = 1; l <= 4; l++) slots.where((s) => s >= l).length,
];

/// Jewels of size ≥ l fit when there are as many slots of level ≥ l.
bool _fits(List<int> used, List<int> slotsAtLeast) {
  var jewels = 0;
  for (var l = 4; l >= 1; l--) {
    jewels += used[l];
    if (jewels > slotsAtLeast[l]) return false;
  }
  return true;
}

int _freeLevels(List<int> slots, List<int> used) {
  final sizes = [
    for (var l = 4; l >= 1; l--)
      for (var n = 0; n < used[l]; n++) l,
  ];
  return _leftover(slots, sizes).fold(0, (a, b) => a + b);
}

/// The slots left after putting each jewel, largest first, into the
/// smallest slot that fits it. Highest first.
List<int> _leftover(List<int> slots, List<int> jewelSizes) {
  final free = [...slots]..sort();
  for (final size in [...jewelSizes]..sort((a, b) => b - a)) {
    final i = free.indexWhere((s) => s >= size);
    if (i >= 0) free.removeAt(i);
  }
  return free.reversed.toList();
}
