import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/armor_page.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_detail_views.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_set_card.dart';

import '../../../fakes/fake_armor_repository.dart';
import '../../../helpers/pump_app.dart';

/// 007 ui-contract: list, set, skill and decoration screens.
void main() {
  late FakeArmorRepository repository;
  late ArmorController controller;

  setUp(() {
    repository = FakeArmorRepository();
    controller = buildArmorController(repository);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(1200, 2400),
  }) async {
    setWindowSize(tester, size);
    await pumpApp(tester, ArmorPage(controller: controller));
  }

  group('Conjuntos', () {
    testWidgets('tabs, rank filter and one card per set', (tester) async {
      await pumpPage(tester);
      for (final tab in ['Conjuntos', 'Habilidades', 'Joias']) {
        expect(find.text(tab), findsOneWidget);
      }
      expect(find.byType(ArmorSetCard), findsNWidgets(2));
      expect(find.text('Elmo de Rathalos X'), findsOneWidget);
      expect(
        find.textContaining('Reforço de Ataque 7'),
        findsOneWidget,
      ); // footer sum

      await tester.tap(find.text('Mestre'));
      await tester.pumpAndSettle();
      expect(find.byType(ArmorSetCard), findsOneWidget);
    });

    testWidgets('a skill suggestion becomes a removable seal', (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'antiv');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ActionChip, 'Antivento'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Antivento'), findsOneWidget);
      expect(find.byType(ArmorSetCard), findsOneWidget);
      // The chosen skill leads the footer, in bold.
      final footer = tester.widget<RichText>(
        find.descendant(
          of: find.byType(ArmorSetCard),
          matching: find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().startsWith('Conjunto'),
          ),
        ),
      );
      final spans = <TextSpan>[];
      footer.text.visitChildren((s) {
        if (s is TextSpan && s.text != null) spans.add(s);
        return true;
      });
      expect(spans[1].text, 'Antivento 3');
      expect(spans[1].style?.fontWeight, FontWeight.w700);

      await tester.tap(find.byTooltip('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.byType(ArmorSetCard), findsNWidgets(2));
    });

    testWidgets('empty and failure states', (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum conjunto encontrado'), findsOneWidget);
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.byType(ArmorSetCard), findsNWidgets(2));

      repository.failure = const DatasetUnavailable(Game.riseSunbreak);
      controller = buildArmorController(repository);
      await pumpPage(tester);
      expect(
        find.text('Não foi possível carregar as armaduras.'),
        findsOneWidget,
      );
    });
  });

  group('Set detail', () {
    testWidgets('Defesa, Habilidades with pips, Peças with materials', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpPage(tester);
      await tester.tap(find.text('Rathalos X').first);
      await tester.pumpAndSettle();

      expect(find.byType(ArmorSetDetailView), findsOneWidget);
      expect(find.text('570 → 870'), findsOneWidget);
      expect(find.text('−10'), findsOneWidget); // thunder
      final negative = tester.widget<Text>(find.text('−15'));
      expect(negative.style?.color, HunterPalette.negative);
      expect(
        find.bySemanticsLabel('Reforço de Ataque, nível 7 de 7'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Reforço Crítico, nível 2 de 3'),
        findsOneWidget,
      );

      // A skill opens its detail.
      await tester.tap(find.bySemanticsLabel('Antivento, nível 3 de 3'));
      await tester.pumpAndSettle();
      expect(find.byType(SkillDetailView), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a piece expands its forge materials', (tester) async {
      await pumpPage(tester);
      await controller.select(ArmorTab.sets, 'rathalos-x');
      await tester.pumpAndSettle();
      final detail = find.byType(ArmorSetDetailView);
      await tester.tap(
        find.descendant(of: detail, matching: find.text('Elmo de Rathalos X')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nenhum material registrado'), findsOneWidget);
    });
  });

  group('Habilidades e joias', () {
    testWidgets('skill detail: levels, decorations, pieces by rank', (
      tester,
    ) async {
      await pumpPage(tester);
      await controller.select(ArmorTab.skills, 'attack-boost');
      await tester.pumpAndSettle();

      expect(find.text('Nv 7'), findsWidgets);
      expect(find.text('Attack Boost effect 7'), findsOneWidget);
      expect(find.text('Joia do Ataque 2 · Nv 1'), findsOneWidget);
      expect(find.text('Joia Ataque+ 4 · Nv 2'), findsOneWidget);
      expect(find.text('Rank Mestre'), findsOneWidget);
      expect(find.text('Rank Baixo'), findsOneWidget);

      await tester.tap(find.text('Joia Ataque+ 4 · Nv 2'));
      await tester.pumpAndSettle();
      expect(find.byType(DecorationDetailView), findsOneWidget);
      expect(find.text('Slot nível 4'), findsOneWidget);
    });

    testWidgets('skills tab search; decorations slot filter', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Habilidades'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).hitTestable(), 'tampoes');
      await tester.pumpAndSettle();
      expect(find.text('Tampões'), findsOneWidget);
      expect(find.text('máx. 5'), findsOneWidget);

      // The tab row scrolls sideways when the tabs do not fit.
      await tester.ensureVisible(find.text('Joias'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Joias'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Slot nível 4').hitTestable());
      await tester.pumpAndSettle();
      expect(find.text('Joia Ataque+ 4'), findsOneWidget);
      expect(find.text('Joia do Ataque 2'), findsNothing);
    });
  });
}
