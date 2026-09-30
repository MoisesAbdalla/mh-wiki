import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';

/// One element in display order of the weaknesses (005 FR-010/FR-011).
final class RankedWeakness {
  const RankedWeakness({
    required this.element,
    required this.effectiveness,
    this.best = false,
  });

  final ElementType element;
  final Effectiveness effectiveness;

  /// The most effective element (2 stars or more), highlighted in the UI.
  final bool best;
}

/// The five elements from most to least effective; immunity is last and ties
/// keep the order fire, water, thunder, ice, dragon. Missing elements count
/// as [Effectiveness.none].
List<RankedWeakness> rankWeaknesses(
  Map<ElementType, Effectiveness> values, {
  Set<ElementType> best = const {},
}) {
  final rows = [
    for (final element in ElementType.values)
      RankedWeakness(
        element: element,
        effectiveness: values[element] ?? Effectiveness.none,
        best: best.contains(element),
      ),
  ];
  // List.sort is not stable, so ties fall back to the element order.
  rows.sort((a, b) {
    final byEffect = b.effectiveness.index.compareTo(a.effectiveness.index);
    return byEffect != 0
        ? byEffect
        : a.element.index.compareTo(b.element.index);
  });
  return rows;
}
