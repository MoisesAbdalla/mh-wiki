import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.create();
  final monsterListController = dependencies.createMonsterListController()
    ..load();

  runApp(MhWikiApp(home: MonstersPage(controller: monsterListController)));
}
