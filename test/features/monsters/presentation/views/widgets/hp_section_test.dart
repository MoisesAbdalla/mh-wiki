import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hp_ruler.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hp_section.dart';

import '../../../../../helpers/pump_app.dart';

/// 003 FR-001/FR-002 with the 005 layout: rank tabs, the solo value large and
/// a ruler with the party estimates (FR-013).
void main() {
  const factors = PartyHpFactors(
    factors: {
      2: FactorRange(1.5, 1.5),
      3: FactorRange(2.2, 2.6),
      4: FactorRange(2.2, 2.6),
    },
    source: SourceRef(name: 'Fextralife', url: 'https://example.com'),
  );

  Future<void> pump(
    WidgetTester tester,
    HuntingInfo info, {
    Size size = const Size(400, 1200),
  }) async {
    setWindowSize(tester, size);
    await pumpSection(tester, HpSection(info: info));
  }

  testWidgets('rank tabs switch the solo value; "a partir de" for quests', (
    tester,
  ) async {
    await pump(
      tester,
      const HuntingInfo(
        hp: [
          RankHp(rank: Rank.low, solo: 4908, basis: HpBasis.expedition),
          RankHp(rank: Rank.master, solo: 20800, basis: HpBasis.minQuest),
        ],
      ),
    );

    expect(find.text('HP'), findsOneWidget);
    expect(find.byType(UnderlineTabs<Rank>), findsOneWidget);
    expect(find.text('4.908'), findsOneWidget);
    expect(find.textContaining('a partir de'), findsNothing);

    await tester.tap(find.text('Mestre'));
    await tester.pumpAndSettle();

    expect(find.text('20.800'), findsOneWidget);
    expect(find.textContaining('a partir de'), findsOneWidget);
  });

  testWidgets('a single rank has no tabs and is named in the note', (
    tester,
  ) async {
    await pump(
      tester,
      const HuntingInfo(
        hp: [RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.expedition)],
      ),
    );

    expect(find.byType(UnderlineTabs<Rank>), findsNothing);
    expect(find.text('Alto'), findsOneWidget);
    expect(find.text('6.565'), findsOneWidget);
  });

  testWidgets('the ruler reads solo, 2 and 3–4 hunters', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      const HuntingInfo(
        hp: [RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.expedition)],
        partyFactors: factors,
      ),
    );

    expect(find.byType(HpRuler), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'HP solo 6.565; 2 caçadores 9.850; 3 a 4 caçadores 14.440–17.070',
      ),
      findsOneWidget,
    );
    expect(find.text('9.850'), findsOneWidget);
    expect(find.text('14.440–17.070'), findsOneWidget);
    expect(find.text('Fonte: Fextralife'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('without party factors only the solo value shows', (
    tester,
  ) async {
    await pump(
      tester,
      const HuntingInfo(
        hp: [RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.minQuest)],
      ),
    );
    expect(find.text('6.565'), findsOneWidget);
    expect(find.byType(HpRuler), findsNothing);
  });

  testWidgets('no HP at all shows "HP desconhecido" and no ruler', (
    tester,
  ) async {
    await pump(tester, const HuntingInfo(partyFactors: factors));
    expect(find.text('HP desconhecido'), findsOneWidget);
    expect(find.byType(HpRuler), findsNothing);
  });

  testWidgets('320 dp with 200% text lists the values without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(
      tester,
      const HuntingInfo(
        hp: [RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.expedition)],
        partyFactors: factors,
      ),
      size: const Size(320, 1600),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('9.850'), findsOneWidget);
    expect(find.text('14.440–17.070'), findsOneWidget);
  });
}
