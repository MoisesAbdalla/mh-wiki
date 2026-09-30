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

/// 005 US2: weaknesses as ruled rows, best → worst, element symbol + stars,
/// the best one in gold with a "Melhor" stamp (FR-010, FR-011).
void main() {
  Future<void> pump(WidgetTester tester, WeaknessProfile profile) =>
      pumpSection(
        tester,
        WeaknessSection(profile: profile, language: NameLanguage.ptBr),
      );

  /// Element names of the general rows, top to bottom.
  List<ElementType> order(WidgetTester tester) {
    final rows = tester.widgetList<WeaknessRow>(find.byType(WeaknessRow));
    return [for (final r in rows.where((r) => !r.inState)) r.weakness.element];
  }

  testWidgets('rows go from best to worst, immune last', (tester) async {
    setWindowSize(tester, const Size(400, 1200));
    await pump(tester, richMonster().weaknesses);

    expect(order(tester), [
      ElementType.dragon,
      ElementType.thunder,
      ElementType.water,
      ElementType.ice,
      ElementType.fire,
    ]);
    final tops = [
      for (final row in find.byType(WeaknessRow).evaluate().take(5))
        tester.getTopLeft(find.byWidget(row.widget)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
  });

  testWidgets('each row has the element symbol and star semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, richMonster().weaknesses);

    expect(find.text('Fraquezas elementais'), findsOneWidget);
    for (final row in find.byType(WeaknessRow).evaluate().take(5)) {
      expect(
        find.descendant(
          of: find.byWidget(row.widget),
          matching: find.byType(ElementIcon),
        ),
        findsOneWidget,
      );
    }
    expect(
      find.bySemanticsLabel('Dragão: 3 de 3, melhor fraqueza'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Raio: 2 de 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Fogo: imune'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('immunity is text, distinct from 0 stars', (tester) async {
    await pump(tester, richMonster().weaknesses);
    expect(find.text('Imune'), findsOneWidget);
  });

  testWidgets('only the best row has the stamp and gold stars', (tester) async {
    await pump(tester, richMonster().weaknesses);

    expect(find.text('Melhor'), findsOneWidget);
    final highlighted = tester
        .widgetList<StarRating>(find.byType(StarRating))
        .where((r) => r.highlighted);
    expect(highlighted.single.effectiveness, Effectiveness.high);
  });

  testWidgets('tied best elements are all stamped', (tester) async {
    await pump(
      tester,
      WeaknessProfile(
        general: weaknesses(
          water: Effectiveness.medium,
          ice: Effectiveness.medium,
        ),
      ),
    );
    expect(find.text('Melhor'), findsNWidgets(2));
  });

  testWidgets('no stamp when no element reaches 2 stars', (tester) async {
    await pump(
      tester,
      WeaknessProfile(general: weaknesses(fire: Effectiveness.low)),
    );
    expect(find.text('Melhor'), findsNothing);
    expect(
      tester
          .widgetList<StarRating>(find.byType(StarRating))
          .where((r) => r.highlighted),
      isEmpty,
    );
  });

  testWidgets('a block per named state, ranked, without a stamp', (
    tester,
  ) async {
    await pump(tester, richMonster().weaknesses);
    expect(find.text('Enfurecido'), findsOneWidget);
    expect(find.text('Melhor'), findsOneWidget, reason: 'general row only');

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

  testWidgets('320 dp with 200% text does not overflow', (tester) async {
    setWindowSize(tester, const Size(320, 1600));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pump(tester, richMonster().weaknesses);

    expect(tester.takeException(), isNull);
    expect(find.byType(WeaknessRow), findsNWidgets(10));
  });
}
