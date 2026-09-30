import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hp_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  const factors = PartyHpFactors(
    factors: {
      2: FactorRange(1.5, 1.5),
      3: FactorRange(2.2, 2.6),
      4: FactorRange(2.2, 2.6),
    },
    source: SourceRef(name: 'Fextralife', url: 'https://example.com'),
  );

  Future<void> pump(WidgetTester tester, HuntingInfo info) async {
    setWindowSize(tester, const Size(400, 1200));
    await pumpSection(tester, HpSection(info: info));
  }

  testWidgets('rows per rank in pt-BR format; "a partir de" for quests', (
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
    expect(find.text('Baixo'), findsOneWidget);
    expect(find.text('4.908'), findsOneWidget);
    expect(find.text('Mestre'), findsOneWidget);
    expect(find.text('a partir de 20.800'), findsOneWidget);
  });

  testWidgets('party estimate with "aprox." label, ranges and source', (
    tester,
  ) async {
    await pump(
      tester,
      const HuntingInfo(
        hp: [RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.expedition)],
        partyFactors: factors,
      ),
    );

    expect(find.text('Grupo (aprox.)'), findsOneWidget);
    expect(find.text('2 caçadores'), findsOneWidget);
    expect(find.text('9.850'), findsOneWidget);
    expect(find.text('4 caçadores'), findsOneWidget);
    expect(find.text('14.440 – 17.070'), findsNWidgets(2)); // 3 and 4
    expect(find.text('Fonte: Fextralife'), findsOneWidget);
  });

  testWidgets('without factors the party shows "Desconhecido"', (tester) async {
    await pump(
      tester,
      const HuntingInfo(
        hp: [RankHp(rank: Rank.high, solo: 6565, basis: HpBasis.minQuest)],
      ),
    );
    expect(find.text('Grupo (aprox.)'), findsOneWidget);
    expect(find.text('Desconhecido'), findsOneWidget);
  });

  testWidgets('no hp at all shows "HP desconhecido"', (tester) async {
    await pump(tester, const HuntingInfo());
    expect(find.text('HP desconhecido'), findsOneWidget);
  });
}
