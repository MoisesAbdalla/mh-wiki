import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';
import 'package:mh_wiki/core/domain/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();

  final settings = dependencies.createSettingsController();
  final monsters = dependencies.createMonsterListController();
  final weapons = dependencies.createWeaponListController();
  final armor = dependencies.createArmorController();
  final wildsWeapons = dependencies.createWeaponListController(
    game: Game.wilds,
  );
  final wildsArmor = dependencies.createArmorController(game: Game.wilds);
  final assistant = dependencies.createAssistantController();
  final optimizer = dependencies.createOptimizerController(assistant);
  linkNameLanguage(
    settings: settings,
    monsters: monsters,
    weapons: weapons,
    armor: armor,
    assistant: assistant,
    moreWeapons: [wildsWeapons],
    moreArmor: [wildsArmor],
  );

  await settings.load();
  monsters.load();

  runApp(
    MhWikiApp(
      monsterListController: monsters,
      settingsController: settings,
      weaponListController: weapons,
      armorController: armor,
      wildsWeaponController: wildsWeapons,
      wildsArmorController: wildsArmor,
      assistantController: assistant,
      optimizerController: optimizer,
    ),
  );
}
