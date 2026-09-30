import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';

/// HP multiplier (or range) for a party size, from a documented source.
final class FactorRange {
  const FactorRange(this.min, this.max);

  final double min;
  final double max;
}

/// Per-game party HP scaling factors for 2, 3 and 4 hunters (003 R2).
final class PartyHpFactors {
  const PartyHpFactors({required this.factors, required this.source});

  /// Keyed by number of hunters (2, 3, 4).
  final Map<int, FactorRange> factors;
  final SourceRef source;

  FactorRange? factorFor(int players) => factors[players];
}
