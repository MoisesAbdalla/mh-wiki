import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/equipment_area.dart';
import 'package:mh_wiki/core/domain/game.dart';

import '../helpers/pump_app.dart';

/// 010 T009: an area with one page per game behind the game logos.
void main() {
  testWidgets('tabs per game; World is "em breve"; each page keeps state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final game = ValueNotifier(Game.riseSunbreak);
    addTearDown(game.dispose);
    var wildsBuilt = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: EquipmentArea(
          game: game,
          pages: {
            Game.riseSunbreak: (header) => Column(
              children: [
                header,
                const Expanded(child: TextField(key: Key('rise-search'))),
              ],
            ),
            Game.wilds: (header) {
              wildsBuilt++;
              return Column(children: [header, const Text('wilds-page')]);
            },
          },
        ),
      ),
    );

    expect(wildsBuilt, 0, reason: 'built on its first visit');
    final world = find.bySemanticsLabel(
      RegExp('Monster Hunter World.*em breve'),
    );
    expect(world, findsOneWidget);
    expect(
      tester.getSemantics(world).flagsCollection.isEnabled,
      Tristate.isFalse,
    );

    await tester.enterText(find.byKey(const Key('rise-search')), 'rath');
    await tester.tap(find.bySemanticsLabel('Monster Hunter Wilds').first);
    await tester.pumpAndSettle();
    expect(game.value, Game.wilds);
    expect(find.text('wilds-page'), findsOneWidget);
    expect(wildsBuilt, greaterThan(0));

    game.value = Game.riseSunbreak;
    await tester.pumpAndSettle();
    expect(find.text('rath'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a game with a page is enabled (World, 011)', (tester) async {
    final handle = tester.ensureSemantics();
    final game = ValueNotifier(Game.riseSunbreak);
    addTearDown(game.dispose);
    await pumpApp(
      tester,
      Scaffold(
        body: EquipmentArea(
          game: game,
          pages: {
            Game.worldIceborne: (header) =>
                Column(children: [header, const Text('world-page')]),
            Game.riseSunbreak: (header) => header,
          },
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp('Monster Hunter World.*em breve')),
      findsNothing,
    );
    await tester.tap(
      find.bySemanticsLabel(RegExp('Monster Hunter World')).first,
    );
    await tester.pumpAndSettle();
    expect(game.value, Game.worldIceborne);
    expect(find.text('world-page'), findsOneWidget);
    handle.dispose();
  });
}
