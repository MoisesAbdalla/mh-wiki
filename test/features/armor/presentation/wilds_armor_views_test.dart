import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/armor/data/armor_dataset_dto.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/armor/domain/usecases/load_armor_catalog.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/armor_page.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_detail_views.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_widgets.dart';

import '../../../fakes/fake_armor_repository.dart';
import '../../../helpers/pump_app.dart';

/// 010 T012: the Wilds armor screens.
void main() {
  late ArmorCatalog catalog;

  setUpAll(() {
    final json = jsonDecode(
      File('assets/data/wilds/armor.json').readAsStringSync(),
    ) as Map<String, Object?>;
    catalog = readArmorDataset(json, expectedGame: Game.wilds);
  });

  testWidgets('Arkveld α: set bonus steps and the group bonus', (tester) async {
    final handle = tester.ensureSemantics();
    final opened = <Skill>[];
    final set = catalog.sets.firstWhere((s) => s.name.en == 'Arkveld α');
    setWindowSize(tester, const Size(420, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: ArmorSetDetailView(
          set: set,
          catalog: catalog,
          onOpenSkill: opened.add,
        ),
      ),
    );
    expect(find.text('Bônus do conjunto'), findsOneWidget);
    expect(find.text('2 peças'), findsWidgets);
    expect(find.text('4 peças'), findsOneWidget);
    expect(find.textContaining('Regeneração Veloz I'), findsWidgets);
    expect(find.textContaining('Fortificar'), findsWidgets);
    expect(find.textContaining('(grupo)'), findsOneWidget);

    // The set skill in the totals reads as a piece count, not pips.
    final bonus = catalog.skill(set.bonus!.skillId)!;
    expect(
      find.bySemanticsLabel('${bonus.name.ptBr}, 5 peças'),
      findsOneWidget,
    );

    await tester.tap(find.textContaining('(grupo)'));
    expect(opened.single.kind, SkillKind.group);
    handle.dispose();
  });

  testWidgets('decorations: kind tabs and a two-skill jewel', (tester) async {
    final controller = ArmorController(
      loadCatalog: LoadArmorCatalog(FakeArmorRepository(catalog: catalog)),
      game: Game.wilds,
    );
    addTearDown(controller.dispose);
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(tester, ArmorPage(controller: controller));
    await tester.pumpAndSettle();
    await tapIt(tester, find.text('Joias'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('decoration-kind')), findsOneWidget);
    await tapIt(tester, find.text('De arma'));
    await tester.pumpAndSettle();
    final state = controller.state as ArmorLoaded;
    expect(state.decorations, isNotEmpty);
    expect(
      state.decorations.every((d) => d.kind == DecorationKind.weapon),
      isTrue,
    );
    expect(find.byType(DecorationIcon), findsWidgets);

    final two = catalog.decorations.firstWhere(
      (d) => d.name.ptBr == 'Joia Stat. Crít./Artesanato 3',
    );
    await controller.select(ArmorTab.decorations, two.id);
    await tester.pumpAndSettle();
    expect(find.byType(DecorationDetailView), findsOneWidget);
    for (final s in two.skills) {
      expect(
        find.descendant(
          of: find.byType(DecorationDetailView),
          matching: find.textContaining(catalog.skill(s.skillId)!.name.ptBr!),
        ),
        findsWidgets,
      );
    }
  });

  testWidgets('talismans: a tab, a list and the ranks in the detail', (
    tester,
  ) async {
    final controller = ArmorController(
      loadCatalog: LoadArmorCatalog(FakeArmorRepository(catalog: catalog)),
      game: Game.wilds,
    );
    addTearDown(controller.dispose);
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(tester, ArmorPage(controller: controller));
    await tester.pumpAndSettle();
    await tapIt(tester, find.text('Talismãs'));
    await tester.pumpAndSettle();
    expect(find.text('Amuleto da Fartura'), findsOneWidget);

    await tapIt(tester, find.text('Amuleto da Fartura'));
    await tester.pumpAndSettle();
    expect(find.byType(TalismanDetailView), findsOneWidget);
    for (final rank in ['I', 'II', 'III']) {
      expect(find.text('Amuleto da Fartura $rank'), findsOneWidget);
    }
  });

  testWidgets('Wilds skills carry their kind seal', (tester) async {
    final controller = ArmorController(
      loadCatalog: LoadArmorCatalog(FakeArmorRepository(catalog: catalog)),
      game: Game.wilds,
    );
    addTearDown(controller.dispose);
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(tester, ArmorPage(controller: controller));
    await tester.pumpAndSettle();
    await tapIt(tester, find.text('Habilidades'));
    await tester.pumpAndSettle();
    expect(find.byType(SkillKindSeal), findsWidgets);
  });
}

Future<void> tapIt(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}
