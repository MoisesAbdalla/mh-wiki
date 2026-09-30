import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<List<Game?>> pump(WidgetTester tester, {Game? selected}) async {
    final picked = <Game?>[];
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(
      tester,
      Scaffold(
        body: GameTabs(selected: selected, onChanged: picked.add),
      ),
    );
    return picked;
  }

  testWidgets('shows Todos, World, Rise and Wilds', (tester) async {
    await pump(tester);
    for (final label in ['Todos', 'World', 'Rise', 'Wilds']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('tapping a tab reports its game; Todos reports null', (
    tester,
  ) async {
    final picked = await pump(tester, selected: Game.wilds);

    await tester.tap(find.text('Rise'));
    await tester.tap(find.text('Todos'));

    expect(picked, [Game.riseSunbreak, null]);
  });

  testWidgets('the active tab is marked selected for accessibility', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, selected: Game.worldIceborne);

    expect(
      tester.getSemantics(find.text('World')),
      isSemantics(label: 'World', isButton: true, isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('tabs are at least 48 dp tall', (tester) async {
    await pump(tester);
    for (final label in ['Todos', 'World', 'Rise', 'Wilds']) {
      final box = tester.getRect(
        find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
      );
      expect(box.height, greaterThanOrEqualTo(48));
    }
  });
}
