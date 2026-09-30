import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_item.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/hunting_items_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  const items = [
    HuntingItem(
      id: 'flash',
      name: LocalizedText(en: 'Flash Pod', ptBr: 'Bomba de Luz'),
    ),
    HuntingItem(
      id: 'sonic',
      name: LocalizedText(en: 'Screamer Pod'),
    ),
    HuntingItem(
      id: 'dung',
      name: LocalizedText(en: 'Dung Pod'),
    ),
    HuntingItem(
      id: 'pitfallTrap',
      name: LocalizedText(en: 'Pitfall Trap'),
    ),
  ];

  const info = HuntingInfo(
    items: items,
    reactions: [
      ItemReaction(
        item: 'flash',
        effect: ReactionEffect.affects,
        detail: LocalizedText(en: '10 s', ptBr: '10 s'),
      ),
      ItemReaction(item: 'sonic', effect: ReactionEffect.noEffect),
      ItemReaction(
        item: 'dung',
        effect: ReactionEffect.conditional,
        detail: LocalizedText(en: 'Only when enraged', ptBr: 'Só enfurecido'),
      ),
    ],
  );

  Future<void> pump(
    WidgetTester tester,
    HuntingInfo info, {
    NameLanguage language = NameLanguage.ptBr,
  }) async {
    setWindowSize(tester, const Size(400, 1200));
    await pumpSection(
      tester,
      HuntingItemsSection(info: info, language: language),
    );
  }

  testWidgets('one row per item with its status and detail', (tester) async {
    await pump(tester, info);

    expect(find.text('Itens de caça'), findsOneWidget);
    expect(find.text('Bomba de Luz'), findsOneWidget);
    expect(find.text('Afeta'), findsOneWidget);
    expect(find.text('10 s'), findsOneWidget);
    expect(find.text('Screamer Pod'), findsOneWidget);
    expect(find.text('Não afeta'), findsOneWidget);
    expect(find.text('Afeta com condição'), findsOneWidget);
    expect(find.text('Só enfurecido'), findsOneWidget);
    // Pitfall Trap has no reaction in the source.
    expect(find.text('Pitfall Trap'), findsOneWidget);
    expect(find.text('Desconhecido'), findsWidgets);
  });

  testWidgets('vision: "Enxerga" when the flash affects it', (tester) async {
    await pump(tester, info);
    expect(find.text('Visão'), findsOneWidget);
    expect(find.text('Enxerga'), findsOneWidget);
  });

  testWidgets('vision unknown without a flash reaction', (tester) async {
    await pump(tester, const HuntingInfo(items: items));
    expect(find.text('Enxerga'), findsNothing);
    // Vision + the four items.
    expect(find.text('Desconhecido'), findsNWidgets(5));
  });

  testWidgets('item names follow the name-language setting', (tester) async {
    await pump(tester, info, language: NameLanguage.en);
    expect(find.text('Flash Pod'), findsOneWidget);
    expect(find.text('Bomba de Luz'), findsNothing);
    expect(find.text('Only when enraged'), findsOneWidget);
  });

  testWidgets('each row reads "<item>: <status>. <detail>"', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, info);

    expect(find.bySemanticsLabel('Bomba de Luz: Afeta. 10 s'), findsOneWidget);
    expect(find.bySemanticsLabel('Screamer Pod: Não afeta'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Dung Pod: Afeta com condição. Só enfurecido'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a game without items shows no item rows', (tester) async {
    await pump(tester, const HuntingInfo());
    expect(find.text('Itens de caça'), findsOneWidget);
    expect(find.text('Visão'), findsOneWidget);
  });
}
