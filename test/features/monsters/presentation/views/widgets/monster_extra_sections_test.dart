import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

/// 006 T028: cards added by the app after the monster's own, from 7.
void main() {
  List<int?> numbers(WidgetTester tester) => [
    for (final s in tester.widgetList<NotebookSection>(
      find.byType(NotebookSection),
    ))
      s.number,
  ];

  testWidgets('extra cards come last, numbered from 7', (tester) async {
    setWindowSize(tester, const Size(420, 6000));
    late int given;
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: richMonster(),
          language: NameLanguage.ptBr,
          extraSections: (context, monster, next) {
            given = next;
            return [
              NotebookSection(
                number: next,
                title: 'Extra',
                child: const Text('extra'),
              ),
            ];
          },
        ),
      ),
    );
    expect(given, 7);
    expect(numbers(tester).last, 7);
    expect(find.text('Extra'), findsOneWidget);
  });

  testWidgets('no builder, no extra card', (tester) async {
    setWindowSize(tester, const Size(420, 6000));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: richMonster(),
          language: NameLanguage.ptBr,
        ),
      ),
    );
    expect(numbers(tester), [1, 2, 3, 4, 5, 6]);
  });
}
