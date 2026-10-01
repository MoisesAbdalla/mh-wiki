import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/assistant_page.dart';

import '../../fakes/build_fixtures.dart';
import '../../helpers/pump_app.dart';

/// 008 T014 / T016 / T018 / T020: the Assistente page.
void main() {
  late FakeSavedBuildsRepository saved;
  late FakeAssistantPrefsRepository prefs;
  late AssistantController controller;
  late List<CatalogRef> opened;

  setUp(() {
    saved = FakeSavedBuildsRepository();
    prefs = FakeAssistantPrefsRepository()
      ..prefs = (
        progress: const Progress(ProgressRank.master, 'M2'),
        weaponType: 'great-sword',
      );
    controller = AssistantController(
      loadCatalog: LoadBuildCatalog(FakeBuildRepository()),
      saved: saved,
      prefs: prefs,
      clock: () => DateTime(2026, 10, 1),
    );
    opened = [];
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(420, 900),
  }) async {
    setWindowSize(tester, size);
    await pumpApp(
      tester,
      AssistantPage(
        controller: controller,
        typeName: (id) => id == 'great-sword' ? 'Espadão' : id,
        typePicker: (context, selected, onChanged) => Wrap(
          children: [
            for (final t in ['great-sword', 'bow'])
              TextButton(
                key: Key('type-$t'),
                onPressed: () => onChanged(t),
                child: Text(t == selected ? '[$t]' : t),
              ),
          ],
        ),
        onOpen: opened.add,
      ),
    );
  }

  /// Scrolls the front vertical list (the detail when it is open) until
  /// [finder] is on screen; a negative [delta] scrolls up.
  Future<void> scrollTo(
    WidgetTester tester,
    Finder finder, {
    double delta = 200,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('tabs: Montar build is "em breve" and disabled', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    expect(find.text('Recomendadas'), findsOneWidget);
    expect(find.text('Minhas builds'), findsOneWidget);
    final soon = find.bySemanticsLabel('Montar build, em breve');
    expect(soon, findsOneWidget);
    expect(
      tester.getSemantics(soon).flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    handle.dispose();
  });

  testWidgets('progress picker: rank tabs and step chips', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    expect(find.text('Onde você está?'), findsOneWidget);
    expect(find.text('M1★'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Mestre M2★'))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );

    await tester.tap(find.text('Pós-jogo'));
    await tester.pumpAndSettle();
    expect(find.text('MR 100+'), findsOneWidget);
    // Only a chip changes the progress.
    expect(controller.progress, const Progress(ProgressRank.master, 'M2'));
    await tester.tap(find.text('MR 180+'));
    await tester.pumpAndSettle();
    expect(controller.progress, const Progress(ProgressRank.post, '180'));
    expect(prefs.prefs.progress, const Progress(ProgressRank.post, '180'));
    handle.dispose();
  });

  testWidgets('Para agora and Próximas, with "A partir de"', (tester) async {
    await pumpPage(tester);
    expect(find.text('Para agora'), findsOneWidget);
    expect(find.text('Próximas'), findsOneWidget);
    expect(find.text('Kamura Warrior Cleaver Raw Affinity'), findsOneWidget);
    await scrollTo(tester, find.text('blood-awakening'));
    expect(find.text('A partir de M3★'), findsOneWidget);
    expect(find.text('Depois da história'), findsOneWidget);
    expect(find.text('A partir de MR 180+'), findsOneWidget);
  });

  testWidgets('the type picker changes the list', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('type-bow')));
    await tester.pumpAndSettle();
    expect(find.text('bow-build'), findsOneWidget);
    expect(find.text('Kamura Warrior Cleaver Raw Affinity'), findsNothing);
  });

  testWidgets('empty states', (tester) async {
    prefs.prefs = (progress: Progress.first, weaponType: 'hammer');
    await pumpPage(tester);
    expect(find.text('Nenhuma build pronta para esta arma.'), findsOneWidget);
    await tester.tap(find.text('Minhas builds'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhuma build salva'), findsOneWidget);
  });

  testWidgets('detail: the three cards and the links', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    await tester.tap(find.text('Kamura Warrior Cleaver Raw Affinity'));
    await tester.pumpAndSettle();

    expect(find.text('Equipamento'), findsOneWidget);
    expect(find.text('Cutelo Guerreiro Kamura'), findsOneWidget);
    expect(find.text('Elmo do Caçador X'), findsOneWidget);
    expect(find.text('ou Nephilim Tassets'), findsOneWidget);
    expect(find.text('Olho Crítico Nv 3'), findsOneWidget);
    expect(find.textContaining('Espadão · Game8'), findsOneWidget);

    await tester.tap(find.text('Elmo do Caçador X'));
    expect(opened.single.id, 'hunters-helm-x');

    await scrollTo(tester, find.text('Habilidades'));
    expect(
      find.bySemanticsLabel('Reforço de Ataque, nível 7 de 7'),
      findsOneWidget,
    );
    await scrollTo(tester, find.text('×3'));
    expect(find.text('×1'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('save, then rename and delete in Minhas builds', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Kamura Warrior Cleaver Raw Affinity'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Salvar em Minhas builds'));
    await tester.tap(find.text('Salvar em Minhas builds'));
    await tester.pump();
    expect(find.text('Build salva em Minhas builds'), findsOneWidget);
    expect(saved.saved, hasLength(1));

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minhas builds'));
    await tester.pumpAndSettle();
    expect(
      find.text('baseada em: Kamura Warrior Cleaver Raw Affinity · 01/10/2026'),
      findsOneWidget,
    );

    await tester.tap(find.text('Kamura Warrior Cleaver Raw Affinity'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Renomear'));
    await tester.tap(find.text('Renomear'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Meu Espadão');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(saved.saved.single.name, 'Meu Espadão');
    await scrollTo(tester, find.text('Meu Espadão'), delta: -200);
    expect(
      find.text('baseada em: Kamura Warrior Cleaver Raw Affinity'),
      findsOneWidget,
    );

    await scrollTo(tester, find.text('Excluir'));
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir "Meu Espadão"?'), findsOneWidget);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(saved.saved, isEmpty);
    expect(find.textContaining('Nenhuma build salva'), findsOneWidget);
  });

  testWidgets('expanded: list and detail side by side', (tester) async {
    await pumpPage(tester, size: const Size(1200, 900));
    expect(find.text('Escolha uma build na lista'), findsOneWidget);
    await tester.tap(find.text('Kamura Warrior Cleaver Raw Affinity'));
    await tester.pumpAndSettle();
    expect(find.text('Equipamento'), findsOneWidget);
    expect(find.text('Onde você está?'), findsOneWidget);
  });

  testWidgets('320 dp at 200 % text: no overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpPage(tester, size: const Size(320, 700));
    await scrollTo(tester, find.text('blood-awakening'));
    await tester.tap(find.text('blood-awakening'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Salvar em Minhas builds'));
    expect(tester.takeException(), isNull);
  });
}
