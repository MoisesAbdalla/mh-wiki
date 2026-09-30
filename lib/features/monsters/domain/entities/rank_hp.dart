import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';

/// Where a reference HP comes from (003 research R1).
enum HpBasis {
  /// Expedition / free-hunt HP: shown as is.
  expedition,

  /// Lowest HP among the rank's regular quests: shown as "a partir de".
  minQuest,
}

/// Solo reference HP of a monster in one rank (003 FR-001).
final class RankHp {
  const RankHp({required this.rank, required this.solo, required this.basis});

  final Rank rank;
  final int solo;
  final HpBasis basis;

  /// Estimated party HP for [players] (2–4) from the game's documented
  /// factors (003 FR-002), rounded to the nearest 10; `null` without factors.
  HpRange? partyEstimate(PartyHpFactors? factors, int players) {
    final factor = factors?.factorFor(players);
    if (factor == null) return null;
    int round(double v) => (v / 10).round() * 10;
    return HpRange(round(solo * factor.min), round(solo * factor.max));
  }
}

/// An HP value or range (when the source gives a factor range).
final class HpRange {
  const HpRange(this.min, this.max);

  final int min;
  final int max;

  bool get isExact => min == max;

  @override
  bool operator ==(Object other) =>
      other is HpRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => isExact ? '$min' : '$min–$max';
}
