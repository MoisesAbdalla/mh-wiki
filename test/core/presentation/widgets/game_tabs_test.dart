import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';

import '../../../helpers/pump_app.dart';

/// 005 FR-006/FR-007: "Todos" as text, then the official game logos, each
/// announced by the game's full name.
void main() {
  Future<List<Game?>> pump(
    WidgetTester tester, {
    Game? selected,
    Size size = const Size(400, 800),
  }) async {
    final picked = <Game?>[];
    setWindowSize(tester, size);
    await pumpApp(
      tester,
      Scaffold(
        body: GameTabs(selected: selected, onChanged: picked.add),
      ),
    );
    return picked;
  }

  const names = {
    Game.worldIceborne: 'Monster Hunter World: Iceborne',
    Game.riseSunbreak: 'Monster Hunter Rise: Sunbreak',
    Game.wilds: 'Monster Hunter Wilds',
  };

  /// A tab found by its spoken label.
  Finder tab(String label) => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  );

  testWidgets('"Todos" in text, then one logo per game', (tester) async {
    await pump(tester);

    expect(find.text('Todos'), findsOneWidget);
    final options = tester
        .widget<UnderlineTabs<Game?>>(find.byType(UnderlineTabs<Game?>))
        .options;
    expect(options.first.image, isNull);
    expect(
      [for (final o in options.skip(1)) o.image],
      [
        'assets/images/games/world_iceborne.webp',
        'assets/images/games/rise_sunbreak.webp',
        'assets/images/games/wilds.webp',
      ],
    );
    for (final name in names.values) {
      expect(tab(name), findsOneWidget);
    }
  });

  testWidgets('tapping a logo reports its game; Todos reports null', (
    tester,
  ) async {
    final picked = await pump(tester, selected: Game.wilds);

    await tester.tap(tab(names[Game.riseSunbreak]!));
    await tester.tap(find.text('Todos'));

    expect(picked, [Game.riseSunbreak, null]);
  });

  testWidgets('the active logo is announced as selected', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, selected: Game.worldIceborne);

    expect(
      tester.getSemantics(tab(names[Game.worldIceborne]!)),
      isSemantics(
        label: 'Monster Hunter World: Iceborne',
        isButton: true,
        isSelected: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('logos are 46 dp tall and tabs at least 48 dp', (tester) async {
    await pump(tester);

    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      expect(image.height, 46);
    }
    for (final name in names.values) {
      expect(tester.getSize(tab(name)).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('scrolls sideways at 320 dp and 200% text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(tester, size: const Size(320, 800));

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(GameTabs),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });
}
