import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/material_sources.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';

import '../../../../fakes/weapon_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// 006 ui-contract "Armas: detail".
void main() {
  late WeaponCatalog catalog;
  late List<MaterialDropper> opened;
  late List<String> openedWeapons;

  const anjanath = MaterialDropper(id: 'anjanath', name: 'Anjanath');
  final sources = MaterialSourceLookup(
    (id) => id.startsWith('anjanath-hard') ? const [anjanath] : const [],
  );

  setUp(() {
    catalog = weaponCatalog();
    opened = [];
    openedWeapons = [];
  });

  Weapon weapon(String slug) => catalog.byId(wid(slug))!;

  Future<void> pumpDetail(WidgetTester tester, String slug) async {
    setWindowSize(tester, const Size(420, 3000));
    await pumpApp(
      tester,
      Scaffold(
        body: WeaponDetailView(
          weapon: weapon(slug),
          catalog: catalog,
          sources: sources,
          onOpenMonster: opened.add,
          onSelectWeapon: (w) => openedWeapons.add(w.id.slug),
        ),
      ),
    );
  }

  List<int?> sectionNumbers(WidgetTester tester) => [
    for (final s in tester.widgetList<NotebookSection>(
      find.byType(NotebookSection),
    ))
      s.number,
  ];

  testWidgets('header: name, subtitle, plate and description', (tester) async {
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    expect(find.text('Presardente Rangedora+'), findsWidgets);
    expect(
      find.text('Espadão · Raridade 8 · Rank Mestre · 4★ (estimado)'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('monster-image-frame')), findsOneWidget);
    expect(find.text('A weapon.'), findsOneWidget);
  });

  testWidgets('cards 1–4 for melee; 1, 3 and 4 for ranged', (tester) async {
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');
    expect(sectionNumbers(tester), [1, 2, 3, 4]);

    await pumpDetail(tester, 'hunters-bow');
    expect(sectionNumbers(tester), [1, 3, 4]);
  });

  testWidgets('Atributos: values, slot badges and their semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    expect(find.text('280'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
    expect(find.text('−20%'), findsOneWidget);
    expect(find.byKey(const ValueKey('slot-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('rampage-slot')), findsOneWidget);
    expect(
      find.bySemanticsLabel('Slots: nível 3; Rampage: nível 2'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('Afiação: segments proportional to units over 400', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    final red = tester.getSize(find.byKey(const ValueKey('sharpness-0')).first);
    final white = find.byKey(const ValueKey('sharpness-5'));
    // red 130/400 of the bar; white 10 (normal) and 60 (Artesanato).
    expect(
      tester.getSize(white.first).width / red.width,
      closeTo(10 / 130, .01),
    );
    expect(
      tester.getSize(white.last).width / red.width,
      closeTo(60 / 130, .01),
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'^Afiação Normal: vermelho 130, laranja 100'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('Materiais: groups, amounts and "Dropado por" links', (
    tester,
  ) async {
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    expect(find.text('Melhorar'), findsOneWidget);
    expect(find.text('Criar'), findsNothing);
    expect(find.text('×3'), findsOneWidget);
    expect(find.text('10 pts.'), findsOneWidget);

    // Only the material known from a monster has a link.
    expect(find.text('Dropado por: Anjanath'), findsOneWidget);
    await tester.tap(find.text('Dropado por: Anjanath'));
    expect(opened, [anjanath]);
  });

  testWidgets('Árvore: previous, this and every next; tap opens', (
    tester,
  ) async {
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    for (final caption in ['anterior', 'esta']) {
      expect(find.text(caption), findsOneWidget);
    }
    expect(find.text('próxima'), findsNWidgets(2)); // a branch
    expect(find.text('Aardzahn'), findsOneWidget);

    await tester.tap(find.text('Lohenzahn'));
    await tester.tap(find.text('Gnashing Flammenzahn'));
    expect(openedWeapons, ['lohenzahn', 'gnashing-flammenzahn']);
  });
}
