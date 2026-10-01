import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/armor/domain/usecases/armor_queries.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/armor_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

import '../../../fakes/armor_fixtures.dart';
import '../../../fakes/fake_armor_repository.dart';
import '../../../helpers/pump_app.dart';

/// 007 FR-013 and SC-004.
void main() {
  Future<void> pumpScaled(WidgetTester tester, Widget child) async {
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
        home: child,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('list and set detail at 320 dp and 200 % text', (tester) async {
    final controller = buildArmorController();
    await pumpScaled(tester, ArmorPage(controller: controller));
    expect(tester.takeException(), isNull);

    await controller.select(ArmorTab.sets, 'rathalos-x');
    await tester.pumpAndSettle();
    final page = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(find.text('Peças'), 300, scrollable: page);
    expect(tester.takeException(), isNull);

    await controller.select(ArmorTab.skills, 'attack-boost');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('contrast, labels and tap targets', (tester) async {
    final controller = buildArmorController();
    setWindowSize(tester, const Size(420, 2000));
    await pumpApp(tester, ArmorPage(controller: controller));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  group('2,000 pieces', () {
    final skills = [
      attackBoost,
      partbreaker,
      criticalBoost,
      earplugs,
      windproof,
    ];
    final catalog = ArmorCatalog(
      game: Game.riseSunbreak,
      skills: skills,
      decorations: const [],
      sets: [
        for (var s = 0; s < 400; s++)
          ArmorSet(
            id: 'set-$s',
            name: LocalizedText(en: 'Set $s', ptBr: 'Conjunto $s'),
            rarity: 1 + s % 10,
            pieces: [
              for (final part in BodyPart.values)
                buildPiece(
                  'set-$s-${part.name}',
                  'Set $s ${part.name}',
                  part,
                  set: 'set-$s',
                  rarity: 1 + s % 10,
                  skills: [SkillLevel(skills[s % skills.length].id, 1)],
                ),
            ],
          ),
      ],
    );

    test('a filter takes under 50 ms', () {
      final filter = FilterSets(catalog);
      filter(const SetQuery()); // warm-up
      for (final q in [
        const SetQuery(rank: Rank.master),
        const SetQuery(text: 'conjunto 1'),
        const SetQuery(skillId: 'windproof'),
        const SetQuery(text: 'xyz'),
      ]) {
        final watch = Stopwatch()..start();
        filter(q);
        watch.stop();
        expect(watch.elapsedMilliseconds, lessThan(50));
      }
    });

    testWidgets('the list builds and a rank switch settles', (tester) async {
      final controller = buildArmorController(
        FakeArmorRepository(catalog: catalog),
      );
      setWindowSize(tester, const Size(400, 800));
      await pumpApp(tester, ArmorPage(controller: controller));
      final watch = Stopwatch()..start();
      controller.setRank(Rank.master);
      await tester.pumpAndSettle();
      watch.stop();
      expect(watch.elapsedMilliseconds, lessThan(1000));
      expect(tester.takeException(), isNull);
    });
  });
}
