import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_list_pane.dart';

import '../../../../../fakes/controllers.dart';
import '../../../../../fakes/fake_monster_repository.dart';
import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

/// 004 contract "List row": versions collapsed in the base row.
void main() {
  final rathalos = buildMonster(game: Game.wilds, en: 'Rathalos');
  final tempered = buildVersion(
    rathalos,
    VersionKind.tempered,
    slug: 'tempered-rathalos',
    en: 'Tempered Rathalos',
  );
  final guardian = buildVersion(
    rathalos,
    VersionKind.guardian,
    slug: 'guardian-rathalos',
    en: 'Guardian Rathalos',
    ptBr: 'Rathalos Guardião',
  );
  final arkveld = buildMonster(
    game: Game.wilds,
    slug: 'arkveld',
    en: 'Arkveld',
  );

  late MonsterListController controller;
  Monster? tapped;

  Future<void> pump(WidgetTester tester) async {
    controller = buildController(
      FakeMonsterRepository(monsters: [guardian, arkveld, tempered, rathalos]),
    );
    await controller.load();
    tapped = null;
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterListPane(
          controller: controller,
          onSelect: (m) => tapped = m,
        ),
      ),
    );
  }

  tearDown(() => controller.dispose());

  testWidgets('one row per base, with the version count', (tester) async {
    await pump(tester);

    expect(find.text('Rathalos'), findsOneWidget);
    expect(find.text('Tempered Rathalos'), findsNothing);
    expect(find.text('2 versões'), findsOneWidget);
    // A monster without versions shows no hint.
    expect(find.text('1 versão'), findsNothing);
  });

  testWidgets('a search matching a version shows it and opens it', (
    tester,
  ) async {
    await pump(tester);
    controller.setSearchText('guardiao');
    await tester.pumpAndSettle();

    expect(find.text('Rathalos'), findsOneWidget);
    expect(find.text('Rathalos Guardião'), findsOneWidget);
    await tester.tap(find.text('Rathalos'));
    expect(tapped, guardian);
  });

  testWidgets('tapping a base row opens the base', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Rathalos'));
    expect(tapped, rathalos);
  });

  testWidgets('row semantics name the versions', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    expect(
      find.bySemanticsLabel('Rathalos, Flying Wyvern, 2 versões'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Arkveld, Flying Wyvern'), findsOneWidget);
    handle.dispose();
  });
}
