import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_materials_section.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_tree_section.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/weapon_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// 006 ui-contract "Accessibility": 320 dp at 200 % text, contrast and tap
/// targets on the weapon list.
void main() {
  testWidgets('list at 320 dp and 200 % text: no overflow, tap targets', (
    tester,
  ) async {
    final controller = buildWeaponController();
    setWindowSize(tester, const Size(320, 640));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHunterTheme(),
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: WeaponsPage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Scroll through the trees; any overflow fails the test.
    await tester.scrollUntilVisible(
      find.text('Aardzahn'),
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('list meets text contrast and label guidelines', (tester) async {
    final controller = buildWeaponController();
    setWindowSize(tester, const Size(400, 1600));
    await pumpApp(tester, WeaponsPage(controller: controller));

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });

  for (final slug in ['gnashing-flammenzahn-plus', 'hunters-bow']) {
    testWidgets('detail of $slug at 320 dp and 200 % text', (tester) async {
      final catalog = weaponCatalog();
      setWindowSize(tester, const Size(320, 640));
      await tester.pumpWidget(
        MaterialApp(
          theme: buildHunterTheme(),
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: WeaponDetailView(
              weapon: catalog.byId(wid(slug))!,
              catalog: catalog,
              onSelectWeapon: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final page = find.byType(Scrollable).first;
      for (final section in [WeaponMaterialsSection, WeaponTreeSection]) {
        await tester.scrollUntilVisible(
          find.byType(section),
          300,
          scrollable: page,
        );
        expect(tester.takeException(), isNull, reason: '$section');
      }
    });
  }

  testWidgets('ammo and opened sources at 320 dp and 200 % text', (
    tester,
  ) async {
    const sources = MaterialSources(
      gathering: [
        GatheringSource(
          map: LocalizedText(en: 'Shrine Ruins', ptBr: 'Ruínas do Templo'),
          rank: Rank.low,
          rate: 30,
        ),
      ],
      monsters: [
        MonsterSource(
          name: LocalizedText(en: 'Great Izuchi'),
          rank: Rank.low,
          method: LocalizedText(en: 'Broken Part Rewards'),
          rate: 12,
        ),
      ],
    );
    final gun = buildWeapon(
      'a11y-gun',
      en: 'An Exceptionally Long Light Bowgun Name',
      type: bowType,
      traits: const WeaponTraits(
        deviation: LocalizedText(en: 'Deviation L Severe'),
        recoil: LocalizedText(en: 'Recoil Average'),
        reload: LocalizedText(en: 'Reload Below Avg.'),
        ammo: [
          AmmoCapacity(kind: AmmoKind.tranq, capacity: [2]),
          AmmoCapacity(kind: AmmoKind.flaming, capacity: [3, 2]),
        ],
      ),
      forge: [
        cost(
          'exceptionally-long-ore',
          'Exceptionally Long Ore Name',
          sources: sources,
        ),
      ],
    );
    final catalog = weaponCatalog([...anjanathWeapons(), gun]);
    setWindowSize(tester, const Size(320, 640));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHunterTheme(),
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: WeaponDetailView(
            weapon: gun,
            catalog: catalog,
            onSelectWeapon: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final page = find.byType(Scrollable).first;
    final material = find.text('Exceptionally Long Ore Name');
    await tester.scrollUntilVisible(material, 300, scrollable: page);
    await tester.pumpAndSettle();
    await tester.tap(material);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Great Izuchi · Broken Part Rewards'),
      300,
      scrollable: page,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail meets contrast and tap targets', (tester) async {
    final catalog = weaponCatalog();
    setWindowSize(tester, const Size(420, 2400));
    await pumpApp(
      tester,
      Scaffold(
        body: WeaponDetailView(
          weapon: catalog.byId(wid('gnashing-flammenzahn-plus'))!,
          catalog: catalog,
          onSelectWeapon: (_) {},
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
