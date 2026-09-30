import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/version_selector.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

/// 004 contract "Detail header: version selector" and "Inherited sections".
void main() {
  final rathalos = richMonster(game: Game.wilds);
  final guardian = buildVersion(
    rathalos,
    VersionKind.guardian,
    slug: 'guardian-rathalos',
    en: 'Guardian Rathalos',
  );
  final tempered = buildVersion(
    rathalos,
    VersionKind.tempered,
    slug: 'tempered-rathalos',
    en: 'Tempered Rathalos',
  );
  final family = [rathalos, tempered, guardian];

  Future<MonsterId?> pumpDetail(
    WidgetTester tester,
    Monster monster, {
    List<Monster> versions = const [],
  }) async {
    MonsterId? selected;
    setWindowSize(tester, const Size(400, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: monster,
          language: NameLanguage.ptBr,
          versions: versions,
          onSelectVersion: (id) => selected = id,
        ),
      ),
    );
    return selected;
  }

  testWidgets('no selector without versions', (tester) async {
    await pumpDetail(tester, rathalos, versions: [rathalos]);
    expect(find.byType(VersionSelector), findsNothing);
  });

  testWidgets('labels in kind order, current one selected', (tester) async {
    await pumpDetail(tester, tempered, versions: family);

    final labels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(VersionSelector),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data)
        .toList();
    expect(labels, ['Base', 'Temperado', 'Guardião']);
  });

  testWidgets('selecting a tab reports that version', (tester) async {
    MonsterId? selected;
    setWindowSize(tester, const Size(400, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: rathalos,
          language: NameLanguage.ptBr,
          versions: family,
          onSelectVersion: (id) => selected = id,
        ),
      ),
    );
    await tester.tap(find.text('Guardião'));
    expect(selected, guardian.id);
  });

  testWidgets('tabs are labeled "Versão: <label>"', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDetail(tester, rathalos, versions: family);
    expect(find.bySemanticsLabel('Versão: Temperado'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('inherited sections say "Igual à forma base"', (tester) async {
    await pumpDetail(tester, tempered, versions: family);
    // Weaknesses, habitat, parts and hunting items.
    expect(find.text('Igual à forma base'), findsNWidgets(4));
  });

  testWidgets('a version without drops or HP shows no base data', (
    tester,
  ) async {
    await pumpDetail(tester, tempered, versions: family);
    expect(find.text('HP desconhecido'), findsOneWidget);
    expect(find.text('Rathalos Ruby'), findsNothing);
  });

  testWidgets('the base shows no inherited note', (tester) async {
    await pumpDetail(tester, rathalos, versions: family);
    expect(find.text('Igual à forma base'), findsNothing);
  });
}
