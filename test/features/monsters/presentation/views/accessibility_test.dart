import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/features/settings/domain/usecases/load_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/set_name_language.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';
import 'package:mh_wiki/features/settings/presentation/settings_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_settings_repository.dart';
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
    // Scroll through every section (HP and hunting items included, 003);
    // any overflow fails the test.
    await tester.scrollUntilVisible(find.text('Fonte: Fextralife'), 300);
    await tester.scrollUntilVisible(find.text('Cápsula de Grito'), 300);
    expect(tester.takeException(), isNull);
    // The page scrolls vertically; the version tabs scroll sideways (005).
    await tester.scrollUntilVisible(
      find.text('Materiais'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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

  testWidgets('detail and settings meet text contrast (002 SC-003)', (
    tester,
  ) async {
    setWindowSize(tester, const Size(400, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: richMonster(),
          language: NameLanguage.ptBr,
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    final repo = FakeSettingsRepository();
    final settings = SettingsController(
      loadSettings: LoadSettings(repo),
      setNameLanguage: SetNameLanguage(repo),
    );
    await pumpApp(tester, SettingsPage(controller: settings));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    settings.dispose();
  });

  testWidgets('settings fit 320 dp at 200% (005)', (tester) async {
    final repo = FakeSettingsRepository();
    final settings = SettingsController(
      loadSettings: LoadSettings(repo),
      setNameLanguage: SetNameLanguage(repo),
    );
    await pumpScaled(tester, SettingsPage(controller: settings));
    expect(tester.takeException(), isNull);
    settings.dispose();
  });

  testWidgets('detail tabs meet tap targets (005)', (tester) async {
    setWindowSize(tester, const Size(400, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: richMonster(),
          language: NameLanguage.ptBr,
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('a version detail with the selector fits 320 dp at 200% (004)', (
    tester,
  ) async {
    final base = richMonster(game: Game.wilds);
    final family = [
      base,
      buildVersion(
        base,
        VersionKind.tempered,
        slug: 'tempered-rathalos',
        en: 'Tempered Rathalos',
      ),
      buildVersion(
        base,
        VersionKind.archTempered,
        slug: 'arch-tempered-rathalos',
        en: 'Arch-Tempered Rathalos',
      ),
      buildVersion(
        base,
        VersionKind.guardian,
        slug: 'guardian-rathalos',
        en: 'Guardian Rathalos',
      ),
    ];
    await pumpScaled(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: family[1],
          language: NameLanguage.ptBr,
          versions: family,
          onSelectVersion: (_) {},
        ),
      ),
    );
    // The page scrolls vertically; the version tabs scroll sideways (005).
    await tester.scrollUntilVisible(
      find.text('Materiais'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('version selector meets contrast and tap targets (004)', (
    tester,
  ) async {
    final base = richMonster(game: Game.wilds);
    final family = [
      base,
      buildVersion(
        base,
        VersionKind.tempered,
        slug: 'tempered-rathalos',
        en: 'Tempered Rathalos',
      ),
    ];
    setWindowSize(tester, const Size(400, 3200));
    await pumpApp(
      tester,
      Scaffold(
        body: MonsterDetailView(
          monster: family[1],
          language: NameLanguage.ptBr,
          versions: family,
          onSelectVersion: (_) {},
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
