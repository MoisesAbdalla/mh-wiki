import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/star_rating.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_state.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/weakness_section.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  Future<void> pump(WidgetTester tester, WeaknessProfile profile) =>
      pumpSection(
        tester,
        WeaknessSection(profile: profile, language: NameLanguage.ptBr),
      );

  testWidgets('shows the five elements with star semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, richMonster().weaknesses);

    expect(find.text('Fraquezas elementais'), findsOneWidget);
    for (final name in ['Fogo', 'Água', 'Raio', 'Gelo', 'Dragão']) {
      expect(find.text(name), findsWidgets);
    }
    expect(find.bySemanticsLabel('Dragão: 3 de 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Raio: 2 de 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Fogo: imune'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('immune is shown with its own badge, distinct from 0 stars', (
    tester,
  ) async {
    await pump(tester, richMonster().weaknesses);
    expect(find.text('Imune'), findsOneWidget);
  });

  testWidgets('highlights only the most effective elements', (tester) async {
    await pump(tester, richMonster().weaknesses);

    final highlighted = tester
        .widgetList<StarRating>(find.byType(StarRating))
        .where((r) => r.highlighted);
    expect(highlighted, hasLength(1));
    expect(highlighted.single.effectiveness, Effectiveness.high);
  });

  testWidgets('highlights nothing when no element reaches 2 stars', (
    tester,
  ) async {
    await pump(
      tester,
      WeaknessProfile(general: weaknesses(fire: Effectiveness.low)),
    );
    expect(
      tester
          .widgetList<StarRating>(find.byType(StarRating))
          .where((r) => r.highlighted),
      isEmpty,
    );
  });

  testWidgets('shows a block per named state only when states exist', (
    tester,
  ) async {
    await pump(tester, richMonster().weaknesses);
    expect(find.text('Enfurecido'), findsOneWidget);

    await pump(tester, WeaknessProfile(general: weaknesses()));
    expect(find.text('Enfurecido'), findsNothing);
    expect(find.text('Variações por estado'), findsNothing);
  });

  testWidgets('state name falls back to English', (tester) async {
    await pump(
      tester,
      WeaknessProfile(
        general: weaknesses(),
        states: [
          WeaknessState(
            id: 'charged',
            name: const LocalizedText(en: 'Charged'),
            values: weaknesses(),
          ),
        ],
      ),
    );
    expect(find.text('Charged'), findsOneWidget);
  });

  group('grid layout (002 FR-006)', () {
    testWidgets('five cells side by side, each with its element icon', (
      tester,
    ) async {
      setWindowSize(tester, const Size(400, 900));
      await pump(tester, richMonster().weaknesses);

      final cells = find.byType(WeaknessCell);
      // General row only: the state block adds five more below it.
      final general = [for (var i = 0; i < 5; i++) cells.at(i)];
      final rows = general.map((c) => tester.getTopLeft(c).dy).toSet();
      expect(rows, hasLength(1));
      for (final cell in general) {
        expect(
          find.descendant(of: cell, matching: find.byType(ElementIcon)),
          findsOneWidget,
        );
      }
    });

    testWidgets('the most effective cell is framed', (tester) async {
      setWindowSize(tester, const Size(400, 900));
      await pump(tester, richMonster().weaknesses);

      final framed = tester
          .widgetList<WeaknessCell>(find.byType(WeaknessCell))
          .where((c) => c.highlighted);
      expect(framed.single.element, ElementType.dragon);
    });

    testWidgets('narrow screen with 200% text does not overflow (U1)', (
      tester,
    ) async {
      setWindowSize(tester, const Size(320, 1400));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pump(tester, richMonster().weaknesses);

      expect(tester.takeException(), isNull);
      expect(find.byType(WeaknessCell), findsNWidgets(10));
    });
  });
}
