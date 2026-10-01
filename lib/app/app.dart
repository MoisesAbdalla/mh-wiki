import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app_shell.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';
import 'package:mh_wiki/features/settings/presentation/settings_page.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class MhWikiApp extends StatelessWidget {
  const MhWikiApp({
    required this.monsterListController,
    required this.settingsController,
    required this.weaponListController,
    super.key,
  });

  final MonsterListController monsterListController;
  final SettingsController settingsController;
  final WeaponListController weaponListController;

  static final _theme = buildHunterTheme();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // Fixed dark "Caderno do Caçador" theme, whatever the system uses (FR-001).
      theme: _theme,
      darkTheme: _theme,
      themeMode: ThemeMode.dark,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: AppShell(
        monsters: MonstersPage(
          controller: monsterListController,
          actions: [SettingsButton(controller: settingsController)],
        ),
        weapons: WeaponsPage(
          controller: weaponListController,
          actions: [SettingsButton(controller: settingsController)],
        ),
      ),
    );
  }
}
