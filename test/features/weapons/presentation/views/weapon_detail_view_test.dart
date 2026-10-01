import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/weapons/domain/entities/rampage.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
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
    // Master Rank with a Rampage slot: the Rampage card is number 5.
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');
    expect(sectionNumbers(tester), [1, 2, 3, 4, 5]);

    await pumpDetail(tester, 'hunters-bow');
    expect(sectionNumbers(tester), [1, 3, 4]);
  });

  testWidgets('Rampage: skills to choose (High Rank), slot and fitting '
      'decorations (Master Rank)', (tester) async {
    const boost = RampageSkill(
      id: 'attack-boost-i',
      name: LocalizedText(en: 'Attack Boost I', ptBr: 'Reforço de Ataque I'),
      effect: LocalizedText(en: 'Attack +4', ptBr: 'Ataque +4'),
    );
    const grinder = RampageSkill(
      id: 'defense-grinder-i',
      name: LocalizedText(en: 'Defense Grinder I'),
      effect: LocalizedText(en: 'Lowers defense'),
    );
    final high = buildWeapon(
      'high-blade',
      en: 'High Blade',
      rarity: 5,
      rampageSkills: const [boost],
    );
    final master = buildWeapon(
      'master-blade',
      en: 'Master Blade',
      rarity: 9,
      rampageSlot: 2,
    );
    final bow = buildWeapon(
      'master-bow',
      en: 'Master Bow',
      type: bowType,
      rarity: 9,
      rampageSlot: 2,
      tree: 'bone-tree',
      treeEn: 'Bone Tree',
    );
    catalog = WeaponCatalog(
      game: Game.riseSunbreak,
      types: const [greatSword, bowType],
      weapons: [...anjanathWeapons(), high, master, bow],
      rampageDecorations: const [
        RampageDecoration(
          id: 'attack-jewel-1',
          name: LocalizedText(en: 'Attack Jewel 1'),
          slotLevel: 1,
          skill: boost,
        ),
        RampageDecoration(
          id: 'defense-edge-jewel-1',
          name: LocalizedText(en: 'Defense Edge Jewel 1'),
          slotLevel: 1,
          skill: grinder,
          weaponTypes: ['great-sword'],
        ),
        RampageDecoration(
          id: 'big-jewel-3',
          name: LocalizedText(en: 'Big Jewel 3'),
          slotLevel: 3,
          skill: boost,
        ),
      ],
    );

    await pumpDetail(tester, 'high-blade');
    expect(find.text('Habilidades Rampage'), findsOneWidget);
    expect(find.text('escolha uma'), findsOneWidget);
    expect(find.text('Reforço de Ataque I'), findsOneWidget);
    expect(find.text('Ataque +4'), findsOneWidget);

    await pumpDetail(tester, 'master-blade');
    expect(find.text('Slot Rampage'), findsOneWidget);
    expect(find.text('Attack Jewel 1'), findsOneWidget);
    expect(find.text('Defense Edge Jewel 1'), findsOneWidget);
    expect(find.text('Big Jewel 3'), findsNothing); // slot 3 > 2

    await pumpDetail(tester, 'master-bow');
    expect(find.text('Defense Edge Jewel 1'), findsNothing); // GS/CB only

    await pumpDetail(tester, 'flammenzahn-i'); // Low Rank, no options
    expect(find.text('Habilidades Rampage'), findsNothing);
    expect(find.text('Rampage'), findsNothing);
  });

  testWidgets('a bow gets the Munição card as number 2', (tester) async {
    final bow = buildWeapon(
      'traits-bow',
      en: 'Traits Bow',
      type: bowType,
      tree: 'bone-tree',
      treeEn: 'Bone Tree',
      traits: const WeaponTraits(
        arcShot: LocalizedText(en: 'Brace', ptBr: 'Defensivo'),
        chargeShots: [
          BowShot(
            name: LocalizedText(en: 'Rapid Level 2', ptBr: 'Rápido nível 2'),
          ),
          BowShot(
            name: LocalizedText(
              en: 'Pierce Level 4',
              ptBr: 'Perfurante nível 4',
            ),
            locked: true,
          ),
        ],
        coatings: [
          BowShot(
            name: LocalizedText(en: 'Power Coating', ptBr: 'Revest. de Poder'),
          ),
          BowShot(name: LocalizedText(en: 'Para Coating'), locked: true),
        ],
      ),
    );
    catalog = weaponCatalog([...anjanathWeapons(), bow]);
    await pumpDetail(tester, 'traits-bow');

    expect(sectionNumbers(tester), [1, 2, 3, 4]);
    expect(find.text('Munição'), findsOneWidget);
    expect(find.text('Defensivo'), findsOneWidget);
    expect(find.text('Rápido nível 2'), findsOneWidget);
    expect(
      find.text('Perfurante nível 4 (precisa de habilidade)'),
      findsOneWidget,
    );
    expect(find.text('Revest. de Poder'), findsOneWidget);
    expect(find.text('Para Coating'), findsNothing); // not usable
  });

  testWidgets('a bowgun lists its ammo; traits fill the Atributos grid', (
    tester,
  ) async {
    final gun = buildWeapon(
      'traits-gun',
      en: 'Traits Gun',
      type: bowType,
      tree: 'bone-tree',
      treeEn: 'Bone Tree',
      traits: const WeaponTraits(
        deviation: LocalizedText(en: 'Deviation None', ptBr: 'Desvio Nenhum'),
        ammo: [
          AmmoCapacity(kind: AmmoKind.normal, capacity: [6, 4, 0]),
        ],
      ),
    );
    final blade = buildWeapon(
      'traits-blade',
      en: 'Traits Blade',
      traits: const WeaponTraits(
        phial: LocalizedText(en: 'Impact', ptBr: 'Impacto'),
      ),
    );
    catalog = weaponCatalog([...anjanathWeapons(), gun, blade]);

    await pumpDetail(tester, 'traits-gun');
    expect(find.text('Desvio Nenhum'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('6 · 4 · –'), findsOneWidget);

    await pumpDetail(tester, 'traits-blade');
    expect(find.text('Frasco'), findsOneWidget);
    expect(find.text('Impacto'), findsOneWidget);
  });

  testWidgets('Atributos: values, slot badges and their semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    expect(find.text('280'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
    expect(find.text('−20%'), findsOneWidget);
    expect(find.byKey(const ValueKey('slot-0-3')), findsOneWidget);
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
    // Each segment is drawn, not only sized.
    expect(red.height, 12);
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
    final handle = tester.ensureSemantics();
    await pumpDetail(tester, 'gnashing-flammenzahn-plus');

    expect(find.text('Melhorar'), findsOneWidget);
    expect(find.text('Criar'), findsNothing);
    expect(find.text('×3'), findsOneWidget);
    expect(find.text('10 pts.'), findsOneWidget);

    // Only the material known from a monster has a link.
    expect(find.text('Anjanath ›'), findsOneWidget);
    expect(find.bySemanticsLabel('Dropado por: Anjanath'), findsOneWidget);
    await tester.tap(find.text('Anjanath ›'));
    expect(opened, [anjanath]);
    // Materials without any known origin say so.
    expect(find.text('Origem desconhecida'), findsWidgets);
    handle.dispose();
  });

  testWidgets('Materiais: seals of the weapon rank; a tap lists the rates', (
    tester,
  ) async {
    const sources = MaterialSources(
      gathering: [
        GatheringSource(
          map: LocalizedText(en: 'Shrine Ruins', ptBr: 'Ruínas do Templo'),
          rank: Rank.master,
          rate: 30,
        ),
        GatheringSource(
          map: LocalizedText(en: 'Jungle', ptBr: 'Selva'),
          rank: Rank.master,
          rate: 25,
        ),
        GatheringSource(
          map: LocalizedText(en: 'Citadel', ptBr: 'Forte'),
          rank: Rank.high,
          rate: 20,
        ),
      ],
      monsters: [
        MonsterSource(
          name: LocalizedText(en: 'Izuchi'),
          rank: Rank.master,
          method: LocalizedText(en: 'Carves Body', ptBr: 'Talha Corpo'),
          rate: 53,
        ),
      ],
      quests: [
        QuestSource(
          name: LocalizedText(en: 'Clouds of Narwa', ptBr: 'Narwa Ribomba'),
          category: LocalizedText(
            en: 'Event Quests',
            ptBr: 'Missões de Eventos',
          ),
          stars: '8',
          rate: 50,
        ),
      ],
    );
    final weapon = buildWeapon(
      'sourced',
      en: 'Sourced Blade',
      rarity: 8, // Master Rank
      forge: [
        cost('carbalite-ore', 'Carbalite Ore', quantity: 8, sources: sources),
      ],
    );
    catalog = weaponCatalog([...anjanathWeapons(), weapon]);
    await pumpDetail(tester, 'sourced');

    expect(find.text('Izuchi · pequeno'), findsOneWidget);
    expect(find.text('Coleta · 2 mapas'), findsOneWidget); // Master Rank only
    expect(find.text('Missão · 8★'), findsOneWidget);
    expect(find.text('Ruínas do Templo'), findsNothing);

    await tester.tap(find.text('Carbalite Ore'));
    await tester.pumpAndSettle();
    expect(find.text('Coleta · Rank Mestre'), findsOneWidget);
    expect(find.text('Ruínas do Templo'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('Forte'), findsNothing); // High Rank
    expect(find.text('Izuchi · Talha Corpo'), findsOneWidget);
    expect(find.text('Missões de Eventos 8★ · Narwa Ribomba'), findsOneWidget);
  });

  testWidgets('Materiais: what to gather and the game description', (
    tester,
  ) async {
    const ore = MaterialSources(
      kind: GatherKind.ore,
      description: LocalizedText(
        en: 'An ore still being studied.',
        ptBr: 'Minério ainda sob estudo.',
      ),
      gathering: [
        GatheringSource(
          map: LocalizedText(en: 'Jungle', ptBr: 'Selva'),
          rank: Rank.master,
          rate: 35,
        ),
      ],
    );
    const bug = MaterialSources(
      kind: GatherKind.bug,
      description: LocalizedText(en: 'A rare insect.', ptBr: 'Inseto raro.'),
    );
    final weapon = buildWeapon(
      'gathered',
      en: 'Gathered Blade',
      rarity: 8,
      forge: [
        cost('carbalite-ore', 'Carbalite Ore', sources: ore),
        cost('split-jaw-buttlefly', 'Split-Jaw Buttlefly', sources: bug),
      ],
    );
    catalog = weaponCatalog([...anjanathWeapons(), weapon]);
    await pumpDetail(tester, 'gathered');

    expect(find.text('Mineração · Selva'), findsOneWidget);
    expect(find.text('Inseto · mapa não informado'), findsOneWidget);
    expect(find.text('Origem desconhecida'), findsNothing);

    await tester.tap(find.text('Carbalite Ore'));
    await tester.pumpAndSettle();
    expect(find.text('Minério ainda sob estudo.'), findsOneWidget);
    expect(find.text('Mineração · Rank Mestre'), findsOneWidget);

    await tester.tap(find.text('Split-Jaw Buttlefly'));
    await tester.pumpAndSettle();
    expect(find.text('Inseto raro.'), findsOneWidget);
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
