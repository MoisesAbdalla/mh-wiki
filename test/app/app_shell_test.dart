import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/app_shell.dart';

import '../helpers/pump_app.dart';

/// 006 ui-contract "App shell": four areas, two of them "em breve".
void main() {
  Future<void> pumpShell(WidgetTester tester) => pumpApp(
    tester,
    const AppShell(
      monsters: Scaffold(body: TextField(key: Key('monster-search'))),
      weapons: Scaffold(body: Text('weapons-area')),
    ),
  );

  Finder area(String label) => find.bySemanticsLabel(label);

  testWidgets('four areas; Armaduras and Assistente are "em breve"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpShell(tester);

    for (final label in ['Monstros', 'Armas']) {
      expect(area(label), findsOneWidget);
    }
    for (final label in ['Armaduras, em breve', 'Assistente, em breve']) {
      expect(area(label), findsOneWidget);
      expect(
        tester.getSemantics(area(label)).flagsCollection.isEnabled,
        Tristate.isFalse,
        reason: label,
      );
    }

    await tester.tap(find.text('Armaduras'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('monster-search')), findsOneWidget);
    expect(find.text('weapons-area'), findsNothing);
    handle.dispose();
  });

  testWidgets('a bottom bar below 840 dp, a rail from 840 dp', (tester) async {
    setWindowSize(tester, const Size(400, 800));
    await pumpShell(tester);
    expect(find.byKey(const Key('area-bar')), findsOneWidget);
    expect(find.byKey(const Key('area-rail')), findsNothing);

    setWindowSize(tester, const Size(1200, 800));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('area-rail')), findsOneWidget);
    expect(find.byKey(const Key('area-bar')), findsNothing);
  });

  testWidgets('switching areas keeps each area state', (tester) async {
    await pumpShell(tester);
    await tester.enterText(find.byKey(const Key('monster-search')), 'rath');

    await tester.tap(find.text('Armas'));
    await tester.pumpAndSettle();
    expect(find.text('weapons-area'), findsOneWidget);

    await tester.tap(find.text('Monstros'));
    await tester.pumpAndSettle();
    expect(find.text('rath'), findsOneWidget);
  });
}
