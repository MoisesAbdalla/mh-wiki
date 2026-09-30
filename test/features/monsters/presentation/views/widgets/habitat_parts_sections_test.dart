import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/habitat_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/parts_section.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  group('HabitatSection', () {
    testWidgets('lists habitat names', (tester) async {
      await pumpSection(
        tester,
        HabitatSection(
          habitats: richMonster().habitats,
          language: NameLanguage.ptBr,
        ),
      );
      expect(find.text('Habitat'), findsOneWidget);
      expect(find.text('Ancient Forest'), findsOneWidget);
    });

    testWidgets('says there is no fixed habitat when empty', (tester) async {
      await pumpSection(
        tester,
        const HabitatSection(habitats: [], language: NameLanguage.ptBr),
      );
      expect(find.text('Nenhum habitat fixo'), findsOneWidget);
    });
  });

  group('PartsSection', () {
    testWidgets('lists parts and tags severable ones', (tester) async {
      await pumpSection(
        tester,
        PartsSection(parts: richMonster().parts, language: NameLanguage.ptBr),
      );
      expect(find.text('Partes quebráveis'), findsOneWidget);
      expect(find.text('Cabeça'), findsOneWidget);
      expect(find.text('Cauda'), findsOneWidget);
      expect(find.text('Cortável'), findsOneWidget);
    });

    testWidgets('says there are no breakable parts when empty', (tester) async {
      await pumpSection(
        tester,
        const PartsSection(parts: [], language: NameLanguage.ptBr),
      );
      expect(find.text('Nenhuma parte quebrável'), findsOneWidget);
    });
  });
}
