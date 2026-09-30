import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// 005 FR-015: a short fade (and slide in the detail) when the content
/// changes; none when the platform asks for reduced motion.
void main() {
  Future<void> pumpSwitcher(
    WidgetTester tester,
    String key, {
    bool disableAnimations = false,
    bool slide = true,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: NotebookSwitcher(
          slide: slide,
          child: Text(key, key: ValueKey(key)),
        ),
      ),
    ),
  );

  testWidgets('cross-fades the old and new content over 220 ms', (
    tester,
  ) async {
    await pumpSwitcher(tester, 'Rathalos');
    await pumpSwitcher(tester, 'Nergigante');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Rathalos'), findsOneWidget);
    expect(find.text('Nergigante'), findsOneWidget);
    final fade = tester.widget<FadeTransition>(
      find.ancestor(
        of: find.text('Nergigante'),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    expect(
      find.ancestor(
        of: find.text('Nergigante'),
        matching: find.byType(SlideTransition),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Rathalos'), findsNothing);
  });

  testWidgets('the list variant fades without sliding', (tester) async {
    await pumpSwitcher(tester, 'World', slide: false);
    await pumpSwitcher(tester, 'Rise', slide: false);
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.ancestor(
        of: find.text('Rise'),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('reduced motion swaps the content in one frame', (tester) async {
    await pumpSwitcher(tester, 'Rathalos', disableAnimations: true);
    await pumpSwitcher(tester, 'Nergigante', disableAnimations: true);
    await tester.pump();

    expect(find.text('Rathalos'), findsNothing);
    expect(find.text('Nergigante'), findsOneWidget);
  });

  testWidgets('the page animates the detail and the list', (tester) async {
    final controller = buildController(
      FakeMonsterRepository(
        monsters: [
          buildMonster(slug: 'a', en: 'Alpha'),
          buildMonster(),
        ],
      ),
    );
    addTearDown(controller.dispose);
    await controller.load();
    setWindowSize(tester, const Size(1200, 900));
    await pumpApp(tester, MonstersPage(controller: controller));

    // One switcher for the list; one for the detail pane.
    expect(find.byType(NotebookSwitcher), findsNWidgets(2));
  });
}
