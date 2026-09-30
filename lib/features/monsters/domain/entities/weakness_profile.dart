import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_state.dart';

/// General elemental weaknesses plus optional per-state overrides.
final class WeaknessProfile {
  const WeaknessProfile({required this.general, this.states = const []});

  final Map<ElementType, Effectiveness> general;
  final List<WeaknessState> states;

  /// Elements tied for the highest general rating, only when that rating is
  /// at least 2 stars (FR-008); otherwise nothing is highlighted.
  Set<ElementType> get mostEffective {
    final best = general.values.fold(
      Effectiveness.immune,
      (max, value) => value.index > max.index ? value : max,
    );
    if (best.index < Effectiveness.medium.index) return const {};
    return {
      for (final entry in general.entries)
        if (entry.value == best) entry.key,
    };
  }
}
