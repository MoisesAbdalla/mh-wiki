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

/// 011 T011: the World armor screens.
void main() {
  late ArmorCatalog catalog;

  setUpAll(() {
    final json = jsonDecode(
      File('assets/data/world_iceborne/armor.json').readAsStringSync(),
    ) as Map<String, Object?>;
    catalog = readArmorDataset(json, expectedGame: Game.worldIceborne);
  });

  Future<ArmorController> pumpPage(WidgetTester tester) async {
    final controller = ArmorController(
      loadCatalog: LoadArmorCatalog(FakeArmorRepository(catalog: catalog)),
      game: Game.worldIceborne,
    );
    addTearDown(controller.dispose);
    setWindowSize(tester, const Size(1200, 2400));
    await pumpApp(tester, ArmorPage(controller: controller));
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> tapIt(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Fatalis α+: World icons, defense and the set bonus', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final set = catalog.sets.firstWhere((s) => s.name.en == 'Fatalis α+');
    setWindowSize(tester, const Size(420, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: ArmorSetDetailView(
          set: set,
          catalog: catalog,
          onOpenSkill: (_) {},
        ),
      ),
    );
    expect(find.text('Bônus do conjunto'), findsOneWidget);
    expect(find.text('2 peças'), findsOneWidget);
    expect(find.text('4 peças'), findsOneWidget);
    expect(
      find.textContaining('Remove o limite de nível dos segredos'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Lenda de Fatalis, 5 peças'), findsOneWidget);
    final icons = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => i.image.toString());
    expect(
      icons.where((a) => a.contains('assets/images/world/icons/head-12.webp')),
      isNotEmpty,
    );
    expect(
      icons.where((a) => a.contains('assets/images/world/slots/')),
      isNotEmpty,
    );
    handle.dispose();
  });

  testWidgets('tabs, ranks, the secret seal, Joias 4 and Talismãs I–V', (
    tester,
  ) async {
    final controller = await pumpPage(tester);
    for (final tab in ['Conjuntos', 'Habilidades', 'Joias', 'Talismãs']) {
      expect(find.text(tab), findsOneWidget);
    }
    expect(find.text('Mestre'), findsWidgets);

    await tapIt(tester, find.text('Habilidades'));
    final secret = catalog.skills.firstWhere((s) => s.kind == SkillKind.secret);
    controller.setSkillText(secret.name.ptBr ?? secret.name.en);
    await tester.pumpAndSettle();
    expect(find.text('segredo'), findsWidgets);

    await tapIt(tester, find.text('Joias'));
    controller.setDecorationSlot(4);
    controller.setDecorationText('Ataque/Fortitude');
    await tester.pumpAndSettle();
    expect(find.text('Joia Ataque/Fortitude 4'), findsOneWidget);
    expect(find.byType(DecorationIcon), findsWidgets);
    expect(find.byKey(const Key('decoration-kind')), findsNothing);

    await tapIt(tester, find.text('Talismãs'));
    await tapIt(tester, find.text('Amuleto de Ataque'));
    expect(find.byType(TalismanDetailView), findsOneWidget);
    for (final rank in ['I', 'II', 'III', 'IV', 'V']) {
      expect(find.text('Amuleto de Ataque $rank'), findsOneWidget);
    }
  });
}
