import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Pumps [child] inside a localized MaterialApp (pt-BR), like the real app.
/// Set [settle] to false when an endless animation (e.g. a progress
/// indicator) is expected on screen.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

/// Pumps a section widget inside a scrollable scaffold.
Future<void> pumpSection(WidgetTester tester, Widget section) =>
    pumpApp(tester, Scaffold(body: ListView(children: [section])));

/// Sets the logical window size for the rest of the test.
void setWindowSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
