import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';

import '../../../../../fakes/monster_fixtures.dart';
import '../../../../../helpers/pump_app.dart';

/// 005 US1: numbered section cards (never nested), no repeated game name,
/// discreet inherited notes (FR-003, FR-004, FR-009).
void main() {
  final rathalos = richMonster();

  Future<void> pumpDetail(
    WidgetTester tester,
    Monster monster, {
    bool showGame = false,
  }) async {
    setWindowSize(tester, const Size(500, 4000));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: monster,
          language: NameLanguage.ptBr,
          showGame: showGame,
        ),
      ),
    );
  }

  testWidgets('sections are numbered 1–6 in the notebook order', (
    tester,
  ) async {
    await pumpDetail(tester, rathalos);

    final sections = tester
        .widgetList<NotebookSection>(find.byType(NotebookSection))
        .map((s) => (s.number, s.title))
        .toList();
    expect(sections, [
      (1, 'Fraquezas elementais'),
      (2, 'HP'),
      (3, 'Itens de caça'),
      (4, 'Materiais'),
      (5, 'Habitat'),
      (6, 'Partes quebráveis'),
    ]);
  });

  testWidgets('each section is one card, never a card inside a card', (
    tester,
  ) async {
    await pumpDetail(tester, rathalos);

    expect(find.byType(Card), findsNothing);
    for (final section in find.byType(NotebookSection).evaluate()) {
      final nested = find.descendant(
        of: find.byWidget(section.widget),
        matching: find.byType(NotebookSection),
      );
      expect(nested, findsNothing);
      final shaped = tester
          .widgetList<Material>(
            find.descendant(
              of: find.byWidget(section.widget),
              matching: find.byType(Material),
            ),
          )
          .where((m) => m.shape is ShapeBorder);
      expect(shaped, hasLength(1), reason: 'only the section card');
    }
  });

  testWidgets('the game name is not repeated above the monster name', (
    tester,
  ) async {
    await pumpDetail(tester, rathalos);
    expect(find.textContaining('Iceborne'), findsNothing);

    await pumpDetail(tester, rathalos, showGame: true);
    expect(find.textContaining('Iceborne'), findsOneWidget);
  });

  testWidgets('an inherited section shows the note once, by its title', (
    tester,
  ) async {
    final tempered = buildVersion(
      richMonster(game: Game.wilds),
      VersionKind.tempered,
      slug: 'tempered-rathalos',
      en: 'Tempered Rathalos',
      inherited: const {MonsterSectionKind.weaknesses},
    );
    await pumpDetail(tester, tempered);

    final weaknesses = tester.widget<NotebookSection>(
      find.widgetWithText(NotebookSection, 'Fraquezas elementais'),
    );
    expect(weaknesses.note, 'Igual à forma base');
    expect(find.text('Igual à forma base'), findsOneWidget);
  });
}
