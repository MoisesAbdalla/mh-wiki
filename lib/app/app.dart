import 'package:flutter/material.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';
import 'package:mh_wiki/features/settings/presentation/settings_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class MhWikiApp extends StatelessWidget {
  const MhWikiApp({
    required this.monsterListController,
    required this.settingsController,
    super.key,
  });

  final MonsterListController monsterListController;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF8C4A2F);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MonstersPage(
        controller: monsterListController,
        actions: [SettingsButton(controller: settingsController)],
      ),
    );
  }
}
