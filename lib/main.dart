import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppDependencies.create();
  // Temporary home until MonstersPage exists (T047 replaces it).
  runApp(const MhWikiApp(home: Scaffold()));
}
