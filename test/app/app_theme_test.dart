import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/features/settings/domain/usecases/load_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/set_name_language.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';

import '../fakes/controllers.dart';
import '../fakes/fake_monster_repository.dart';
import '../fakes/fake_settings_repository.dart';
import '../fakes/monster_fixtures.dart';

/// FR-001 / SC-002: the app is always in the dark hunter theme.
void main() {
  for (final platform in Brightness.values) {
    testWidgets('dark hunter theme when the system is ${platform.name}', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = platform;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final monsters = buildController(
        FakeMonsterRepository(monsters: [buildMonster()]),
      );
      final repo = FakeSettingsRepository();
      final settings = SettingsController(
        loadSettings: LoadSettings(repo),
        setNameLanguage: SetNameLanguage(repo),
      );
      await monsters.load();

      await tester.pumpWidget(
        MhWikiApp(
          monsterListController: monsters,
          settingsController: settings,
          weaponListController: buildWeaponController(),
        ),
      );
      await tester.pumpAndSettle();

      final theme = Theme.of(tester.element(find.byType(Scaffold).first));
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF16120E));
      // 005 FR-005: body in Atkinson Hyperlegible, titles in IM Fell.
      expect(theme.textTheme.bodyMedium?.fontFamily, 'AtkinsonHyperlegible');
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, 'IMFellEnglishSC');

      monsters.dispose();
      settings.dispose();
    });
  }
}
