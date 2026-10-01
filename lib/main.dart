import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();

  final settings = dependencies.createSettingsController();
  final monsters = dependencies.createMonsterListController();
  final weapons = dependencies.createWeaponListController();
  final armor = dependencies.createArmorController();
  linkNameLanguage(
    settings: settings,
    monsters: monsters,
    weapons: weapons,
    armor: armor,
  );

  await settings.load();
  monsters.load();

  runApp(
    MhWikiApp(
      monsterListController: monsters,
      settingsController: settings,
      weaponListController: weapons,
      armorController: armor,
    ),
  );
}
