import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/optimizer_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/assistant_page.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/optimizer_views.dart';

import '../../../fakes/build_fixtures.dart';
import '../../../fakes/optimizer_fakes.dart';
import '../../../helpers/pump_app.dart';

/// 009 T010 / T012 / T014 / T016 / T018: the Montar build tab.
void main() {
  late AssistantController assistant;
  late OptimizerController optimizer;
  late FakeSavedBuildsRepository saved;
  late FakeTalismanRepository talismans;
  late FakeRequestRepository requests;
  late FakeBuildSearcher searcher;
  late List<CatalogRef> opened;

  setUp(() async {
    saved = FakeSavedBuildsRepository();
    final prefs = FakeAssistantPrefsRepository()
      ..prefs = (
        progress: const Progress(ProgressRank.post, '10'),
        weaponType: 'great-sword',
      );
    assistant = AssistantController(
      loadCatalog: LoadBuildCatalog(FakeBuildRepository()),
      saved: saved,
      prefs: prefs,
    );
    talismans = FakeTalismanRepository();
    requests = FakeRequestRepository();
    searcher = FakeBuildSearcher();
    optimizer = OptimizerController(
      assistant: assistant,
      loadCatalog: LoadOptimizerCatalog(FakeOptimizerRepository()),
      talismanRepository: talismans,
      requestRepository: requests,
      searcher: searcher,
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
        controller: assistant,
        optimizer: optimizer,
        typeName: (id) => id == 'great-sword' ? 'Espadão' : id,
        onOpen: opened.add,
      ),
    );
    final tab = find.text('Montar build').first;
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  /// Scrolls [finder] into view, then taps it.
  Future<void> tapIt(WidgetTester tester, Finder finder) async {
    await scrollTo(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('the tab is enabled; "alterar" goes to Recomendadas', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    expect(find.bySemanticsLabel('Montar build, em breve'), findsNothing);
    expect(find.text('Habilidades que você quer'), findsOneWidget);
    expect(find.textContaining('Espadão'), findsWidgets);
    await tester.tap(find.text('alterar'));
    await tester.pumpAndSettle();
    expect(assistant.tab, AssistantTab.recommended);
    expect(find.text('Onde você está?'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('search, add, step and remove a skill', (tester) async {
    await pumpPage(tester);
    final build = find.byKey(const Key('build-it'));
    expect(tester.widget<FilledButton>(build).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('skill-search')), 'att');
    await tester.pumpAndSettle();
    await tester.tap(find.text('attack (pt)'));
    await tester.pumpAndSettle();
    expect(optimizer.skills, {'attack': 7});
    expect(tester.widget<FilledButton>(build).onPressed, isNotNull);

    await tester.tap(find.byTooltip('Diminuir attack (pt)'));
    await tester.pumpAndSettle();
    expect(optimizer.skills['attack'], 6);
    await tester.tap(find.byTooltip('Remover attack (pt)'));
    await tester.pumpAndSettle();
    expect(optimizer.skills, isEmpty);
  });

  testWidgets('switches change the request', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('only-my-progress')));
    await tester.pumpAndSettle();
    expect(optimizer.onlyMyProgress, isFalse);
    await tester.tap(find.byKey(const Key('use-talismans')));
    await tester.pumpAndSettle();
    expect(optimizer.useTalismans, isFalse);
    expect(find.textContaining('nenhum cadastrado'), findsOneWidget);
  });

  testWidgets('"procurando…" with cancel, then the results', (tester) async {
    await pumpPage(tester);
    optimizer.addSkill('attack');
    searcher.hold = true;
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('build-it')));
    await tester.pump();
    expect(find.textContaining('procurando…'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('build-it')), findsOneWidget);

    searcher.hold = false;
    await tapIt(tester, find.byKey(const Key('build-it')));
    expect(find.textContaining('conjuntos encontrados'), findsOneWidget);
    expect(find.text('Opção 1'), findsOneWidget);
    expect(find.text('completa'), findsWidgets);
    expect(find.textContaining('attack (pt) 7/7'), findsWidgets);
    expect(find.textContaining('Defesa máx.'), findsWidgets);

    await tester.tap(find.text('editar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('build-it')), findsOneWidget);
    expect(optimizer.skills, {'attack': 7});
  });

  testWidgets('"quase" shows what is short in red', (tester) async {
    await pumpPage(tester);
    optimizer.addSkill('nodeco');
    await tester.pumpAndSettle();
    await tapIt(tester, find.byKey(const Key('build-it')));
    expect(find.text('quase'), findsWidgets);
    expect(find.textContaining('nodeco (pt) 1/3'), findsWidgets);
  });

  testWidgets('a result: requested skills, equipment, navigation, save', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    optimizer
      ..addSkill('attack')
      ..addSkill('crit')
      ..setLevel('crit', 3);
    await tester.pumpAndSettle();
    await tapIt(tester, find.byKey(const Key('build-it')));
    await tapIt(tester, find.text('Opção 1'));

    expect(find.text('Habilidades pedidas'), findsOneWidget);
    expect(find.bySemanticsLabel('attack (pt), 7 de 7'), findsOneWidget);
    expect(find.text('Equipamento'), findsOneWidget);
    expect(find.textContaining('1 de'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(optimizer.selected, 1);
    expect(find.text('Opção 2'), findsOneWidget);

    await scrollTo(tester, find.text('Salvar em Minhas builds'));
    await tester.tap(find.text('Salvar em Minhas builds'));
    await tester.pump();
    expect(find.text('Build salva em Minhas builds'), findsOneWidget);
    expect(
      saved.saved.single.build.name,
      startsWith('Espadão · attack (pt) 7'),
    );
    handle.dispose();
  });

  testWidgets('Meus talismãs: add, edit and delete', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('manage-talismans')));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum talismã cadastrado.'), findsOneWidget);

    await tester.tap(find.textContaining('nenhuma').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('crit (pt)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Aumentar crit (pt)'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('slot-0')),
        matching: find.text('2'),
      ),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(const Key('save-talisman')));
    await tester.tap(find.byKey(const Key('save-talisman')));
    await tester.pumpAndSettle();
    expect(talismans.talismans.single.skills, {'crit': 2});
    expect(talismans.talismans.single.slots, [2, 0, 0]);
    expect(find.text('crit (pt) 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Excluir talismã'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir "crit (pt) 2"?'), findsOneWidget);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(talismans.talismans, isEmpty);
  });

  testWidgets('phial and element chips for a Charge Blade', (tester) async {
    assistant.setWeaponType('charge-blade');
    await pumpPage(tester);
    expect(find.text('Frasco'), findsOneWidget);
    expect(find.text('Elemento ou status'), findsOneWidget);
    await tester.tap(find.text('impact (pt)'));
    await tester.pumpAndSettle();
    expect(optimizer.weaponTrait, 'impact');
    await tester.tap(find.text('Gelo'));
    await tester.pumpAndSettle();
    expect(optimizer.weaponElement, 'ice');
    expect(find.textContaining('Nenhuma arma com esse filtro'), findsOneWidget);
    await scrollTo(tester, find.byKey(const Key('build-it')));
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('build-it'))).onPressed,
      isNull,
    );
  });

  testWidgets('a Great Sword has no phial row', (tester) async {
    await pumpPage(tester);
    expect(find.text('Frasco'), findsNothing);
    expect(find.text('Bombardeio'), findsNothing);
  });

  testWidgets('fix a weapon', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('choose-weapon')));
    await tester.pumpAndSettle();
    expect(find.text('sword-4 (pt)'), findsOneWidget);
    expect(find.text('bow (pt)'), findsNothing);
    await tester.tap(find.text('sword-weak (pt)'));
    await tester.pumpAndSettle();
    expect(optimizer.fixedWeaponId, 'sword-weak');
    expect(find.text('sword-weak (pt)'), findsOneWidget);
  });

  testWidgets('expanded: results and detail side by side', (tester) async {
    await pumpPage(tester, size: const Size(1200, 900));
    optimizer.addSkill('attack');
    await tester.pumpAndSettle();
    await tapIt(tester, find.byKey(const Key('build-it')));
    await tapIt(tester, find.text('Opção 1'));
    expect(find.text('Habilidades pedidas'), findsOneWidget);
    // The results stay listed next to the detail.
    expect(find.byType(ResultCard), findsWidgets);
  });

  testWidgets('320 dp at 200 % text: no overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await talismans.store([
      UserTalisman(id: 't', skills: {'crit': 3}, slots: [2, 1, 0]),
    ]);
    await pumpPage(tester, size: const Size(320, 700));
    optimizer
      ..addSkill('attack')
      ..addSkill('crit');
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(const Key('build-it')));
    await tapIt(tester, find.byKey(const Key('build-it')));
    await tapIt(tester, find.text('Opção 1'));
    await scrollTo(tester, find.text('Salvar em Minhas builds'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tabs disabled without an optimizer stay "em breve"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    setWindowSize(tester, const Size(420, 900));
    await pumpApp(tester, AssistantPage(controller: assistant));
    final soon = find.bySemanticsLabel('Montar build, em breve');
    expect(soon, findsOneWidget);
    expect(
      tester.getSemantics(soon).flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    handle.dispose();
  });

  test('BuildPart order matches the result card icons', () {
    expect(BuildPart.values.first, BuildPart.head);
  });
}
