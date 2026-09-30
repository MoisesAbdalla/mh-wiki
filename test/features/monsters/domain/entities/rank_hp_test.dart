import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';

void main() {
  const hp = RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.expedition);
  const factors = PartyHpFactors(
    factors: {
      2: FactorRange(1.5, 1.5),
      3: FactorRange(2.2, 2.6),
      4: FactorRange(2.2, 2.6),
    },
    source: SourceRef(name: 'Fextralife', url: 'https://example.com'),
  );

  test('exact factor gives a single value rounded to 10', () {
    final estimate = hp.partyEstimate(factors, 2)!;
    expect(estimate.isExact, isTrue);
    expect(estimate.min, 9850); // 6565 * 1.5 = 9847.5
  });

  test('factor range gives a rounded range', () {
    final estimate = hp.partyEstimate(factors, 4)!;
    expect(estimate.isExact, isFalse);
    expect((estimate.min, estimate.max), (14440, 17070));
  });

  test('no factors (e.g. Rise) gives null', () {
    expect(hp.partyEstimate(null, 3), isNull);
  });

  test('a party size without a factor gives null', () {
    const partial = PartyHpFactors(
      factors: {2: FactorRange(1.63, 1.63)},
      source: SourceRef(name: 'x', url: 'https://example.com'),
    );
    expect(hp.partyEstimate(partial, 4), isNull);
  });
}
