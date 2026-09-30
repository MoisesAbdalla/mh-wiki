import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/materials_section.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows one selector per rank present, starting at the lowest', (
    tester,
  ) async {
    await pumpSection(
      tester,
      MaterialsSection(monster: richMonster(), language: NameLanguage.ptBr),
    );

    expect(find.text('Materiais'), findsOneWidget);
    expect(find.text('Baixo'), findsOneWidget);
    expect(find.text('Alto'), findsOneWidget);
    expect(find.text('Mestre'), findsNothing);

    expect(find.text('Escama de Rathalos'), findsOneWidget);
    expect(find.text('Entalhe'), findsOneWidget);
    expect(find.text('32%'), findsOneWidget);
    expect(find.text('Entalhe da cauda'), findsOneWidget);
    expect(find.text('Taxa desconhecida'), findsOneWidget);
  });

  testWidgets('break-part rows name the part; other rows use their label', (
    tester,
  ) async {
    await pumpSection(
      tester,
      MaterialsSection(monster: richMonster(), language: NameLanguage.ptBr),
    );

    await tester.tap(find.text('Alto'));
    await tester.pumpAndSettle();

    expect(find.text('Rathalos Ruby'), findsOneWidget);
    expect(find.text('Raridade 8'), findsOneWidget);
    expect(find.text('Quebrar: Cabeça'), findsOneWidget);
    expect(find.text('3%'), findsOneWidget);
    expect(find.text('Investigação'), findsOneWidget);
    expect(find.text('1%'), findsOneWidget);
  });

  testWidgets('formats fractional rates with a comma', (tester) async {
    final gem = material('gem', 'Gem');
    await pumpSection(
      tester,
      MaterialsSection(
        monster: buildMonster(
          drops: [drop(gem, Rank.low, DropMethod.capture, rate: 1.5)],
        ),
        language: NameLanguage.ptBr,
      ),
    );
    expect(find.text('1,5%'), findsOneWidget);
    expect(find.text('Captura'), findsOneWidget);
  });

  testWidgets('says no materials are registered when there are no drops', (
    tester,
  ) async {
    await pumpSection(
      tester,
      MaterialsSection(monster: buildMonster(), language: NameLanguage.ptBr),
    );
    expect(find.text('Nenhum material registrado'), findsOneWidget);
    expect(find.text('Baixo'), findsNothing);
  });
}
