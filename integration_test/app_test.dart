import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';

/// End-to-end flow on the real app with the bundled datasets (SC-008):
/// list → filter Wilds → search "rath" → open Rathalos → four sections →
/// back keeps filter and search.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('browse, filter, search and open a monster', (tester) async {
    final dependencies = await AppDependencies.create();
    final settings = dependencies.createSettingsController();
    final monsters = dependencies.createMonsterListController();
    linkNameLanguage(settings: settings, monsters: monsters);
    await settings.load();
    await monsters.load();

    await tester.pumpWidget(
      MhWikiApp(monsterListController: monsters, settingsController: settings),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(GameTabs), matching: find.text('Wilds')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'rath');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rathalos').first);
    await tester.pumpAndSettle();

    expect(find.byType(MonsterDetailView), findsOneWidget);
    for (final title in [
      'Fraquezas elementais',
      'Habitat',
      'Partes quebráveis',
      'Materiais',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        200,
        scrollable: find
            .descendant(
              of: find.byType(MonsterDetailView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text(title), findsOneWidget);
    }

    // Compact layout: leave the detail route. Expanded: detail is a pane.
    if (find.byType(MonsterDetailPage).evaluate().isNotEmpty) {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }

    expect(monsters.query.text, 'rath');
    expect(monsters.query.game, Game.wilds);
  });
}
