import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();

  final settings = dependencies.createSettingsController();
  final monsters = dependencies.createMonsterListController();
  linkNameLanguage(settings: settings, monsters: monsters);

  await settings.load();
  monsters.load();

  runApp(
    MhWikiApp(monsterListController: monsters, settingsController: settings),
  );
}
