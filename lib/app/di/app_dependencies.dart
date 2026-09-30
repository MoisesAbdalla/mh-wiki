import 'package:flutter/services.dart';
import 'package:mh_wiki/features/monsters/data/datasources/asset_monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/repositories/monster_repository_impl.dart';
import 'package:mh_wiki/features/monsters/domain/repositories/monster_repository.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/filter_monsters.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_by_id.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_versions.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/load_monster_catalog.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/settings/data/shared_prefs_settings_repository.dart';
import 'package:mh_wiki/features/settings/domain/settings_repository.dart';
import 'package:mh_wiki/features/settings/domain/usecases/load_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/set_name_language.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root (constitution Principle III): the only place that knows
/// concrete implementations. Everything else receives abstractions through
/// constructors.
final class AppDependencies {
  AppDependencies._({
    required this.monsterRepository,
    required this.settingsRepository,
  });

  static Future<AppDependencies> create({AssetBundle? bundle}) async {
    final prefs = await SharedPreferences.getInstance();
    return AppDependencies._(
      monsterRepository: MonsterRepositoryImpl(
        AssetMonsterDatasource(bundle ?? rootBundle),
      ),
      settingsRepository: SharedPrefsSettingsRepository(prefs),
    );
  }

  final MonsterRepository monsterRepository;
  final SettingsRepository settingsRepository;

  MonsterListController createMonsterListController() => MonsterListController(
    loadCatalog: LoadMonsterCatalog(monsterRepository),
    filterMonsters: const FilterMonsters(),
    getMonsterById: const GetMonsterById(),
    getMonsterVersions: const GetMonsterVersions(),
  );

  SettingsController createSettingsController() => SettingsController(
    loadSettings: LoadSettings(settingsRepository),
    setNameLanguage: SetNameLanguage(settingsRepository),
  );
}

/// Keeps the monster list in the name language chosen in settings, applied
/// immediately on change (FR-022).
void linkNameLanguage({
  required SettingsController settings,
  required MonsterListController monsters,
}) {
  void sync() => monsters.onLanguageChanged(settings.settings.nameLanguage);
  settings.addListener(sync);
  sync();
}
