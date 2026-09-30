import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// T086: text at 200% without overflow on a 320 dp wide screen, and tap
/// targets that meet the Android guideline.
void main() {
  Future<void> pumpScaled(WidgetTester tester, Widget child) async {
    setWindowSize(tester, const Size(320, 640));
    await tester.pumpWidget(
      MaterialApp(
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

  testWidgets('detail sections render at 200% text without overflow', (
    tester,
  ) async {
    final monster = buildMonster(
      en: 'A Monster With An Exceptionally Long Name For Layout Testing',
    );
    await pumpScaled(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: richMonster(),
          language: NameLanguage.ptBr,
        ),
      ),
    );
    // Scroll through every section; any overflow fails the test.
    await tester.scrollUntilVisible(find.text('Materiais'), 300);
    expect(tester.takeException(), isNull);

    await pumpScaled(
      tester,
      Scaffold(
        body: MonsterDetailView(monster: monster, language: NameLanguage.ptBr),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('list at 200% text has no overflow and meets tap targets', (
    tester,
  ) async {
    final controller = buildController(
      FakeMonsterRepository(monsters: [richMonster()]),
    );
    await controller.load();
    await pumpScaled(tester, MonstersPage(controller: controller));

    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    controller.dispose();
  });

  testWidgets('list meets text contrast and label guidelines', (tester) async {
    final controller = buildController(
      FakeMonsterRepository(monsters: [richMonster()]),
    );
    await controller.load();
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, MonstersPage(controller: controller));

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    controller.dispose();
  });
}
