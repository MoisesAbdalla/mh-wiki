import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

/// 002 FR-008: Habitat and Parts side by side when wide enough.
void main() {
  Future<void> pumpDetail(WidgetTester tester, double width) async {
    setWindowSize(tester, Size(width, 3000));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: richMonster(),
          language: NameLanguage.ptBr,
        ),
      ),
    );
  }

  testWidgets('side by side at 400 dp', (tester) async {
    await pumpDetail(tester, 400);
    expect(
      tester.getTopLeft(find.text('Habitat')).dy,
      tester.getTopLeft(find.text('Partes quebráveis')).dy,
    );
    expect(find.text('Cortável'), findsOneWidget);
  });

  testWidgets('stacked at 320 dp', (tester) async {
    await pumpDetail(tester, 320);
    expect(
      tester.getTopLeft(find.text('Habitat')).dy,
      lessThan(tester.getTopLeft(find.text('Partes quebráveis')).dy),
    );
  });
}
