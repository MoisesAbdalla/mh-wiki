import 'package:flutter/services.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/data/repositories/prefs_my_artian_repository.dart';
import 'package:mh_wiki/features/armor/data/armor_repository_impl.dart';
import 'package:mh_wiki/features/armor/data/asset_armor_datasource.dart';
import 'package:mh_wiki/features/armor/domain/repositories/armor_repository.dart';
import 'package:mh_wiki/features/armor/domain/usecases/load_armor_catalog.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/assistant/data/assistant_repositories.dart';
import 'package:mh_wiki/features/assistant/data/build_searcher.dart';
import 'package:mh_wiki/features/assistant/data/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/presentation/optimizer_controller.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
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
import 'package:mh_wiki/features/weapons/data/datasources/asset_weapon_datasource.dart';
import 'package:mh_wiki/features/weapons/data/repositories/weapon_repository_impl.dart';
import 'package:mh_wiki/features/weapons/domain/repositories/weapon_repository.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/load_weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Composition root (constitution Principle III): the only place that knows
/// concrete implementations. Everything else receives abstractions through
/// constructors.
final class AppDependencies {
  AppDependencies._({
    required this.monsterRepository,
    required this.settingsRepository,
    required this.weaponRepository,
    required this.armorRepository,
    required this.buildRepository,
    required this.savedBuildsRepository,
    required this.assistantPrefsRepository,
    required this.optimizerRepository,
    required this.talismanRepository,
    required this.requestRepository,
    required this.myArtianRepository,
  });

  static Future<AppDependencies> create({AssetBundle? bundle}) async {
    final prefs = await SharedPreferences.getInstance();
    final assets = bundle ?? rootBundle;
    return AppDependencies._(
      monsterRepository: MonsterRepositoryImpl(AssetMonsterDatasource(assets)),
      settingsRepository: SharedPrefsSettingsRepository(prefs),
      weaponRepository: WeaponRepositoryImpl(AssetWeaponDatasource(assets)),
      armorRepository: ArmorRepositoryImpl(AssetArmorDatasource(assets)),
      buildRepository: AssetBuildRepository(assets),
      savedBuildsRepository: PrefsSavedBuildsRepository(prefs),
      assistantPrefsRepository: PrefsAssistantPrefsRepository(prefs),
      optimizerRepository: AssetOptimizerRepository(assets),
      talismanRepository: PrefsTalismanRepository(prefs),
      requestRepository: PrefsRequestRepository(prefs),
      myArtianRepository: PrefsMyArtianRepository(prefs),
    );
  }

  final MonsterRepository monsterRepository;
  final SettingsRepository settingsRepository;
  final WeaponRepository weaponRepository;
  final ArmorRepository armorRepository;
  final BuildRepository buildRepository;
  final SavedBuildsRepository savedBuildsRepository;
  final AssistantPrefsRepository assistantPrefsRepository;
  final OptimizerRepository optimizerRepository;
  final TalismanRepository talismanRepository;
  final RequestRepository requestRepository;
  final MyArtianRepository myArtianRepository;

  MonsterListController createMonsterListController() => MonsterListController(
    loadCatalog: LoadMonsterCatalog(monsterRepository),
    filterMonsters: const FilterMonsters(),
    getMonsterById: const GetMonsterById(),
    getMonsterVersions: const GetMonsterVersions(),
  );

  WeaponListController createWeaponListController({
    Game game = Game.riseSunbreak,
  }) => WeaponListController(
    loadCatalog: LoadWeaponCatalog(weaponRepository),
    game: game,
  );

  ArmorController createArmorController({Game game = Game.riseSunbreak}) =>
      ArmorController(
        loadCatalog: LoadArmorCatalog(armorRepository),
        game: game,
      );

  ArtianController createArtianController() =>
      ArtianController(repository: myArtianRepository);

  AssistantController createAssistantController() => AssistantController(
    loadCatalog: LoadBuildCatalog(buildRepository),
    saved: savedBuildsRepository,
    prefs: assistantPrefsRepository,
  );

  OptimizerController createOptimizerController(
    AssistantController assistant,
  ) => OptimizerController(
    assistant: assistant,
    loadCatalog: LoadOptimizerCatalog(optimizerRepository),
    talismanRepository: talismanRepository,
    requestRepository: requestRepository,
    searcher: createBuildSearcher(),
  );

  SettingsController createSettingsController() => SettingsController(
    loadSettings: LoadSettings(settingsRepository),
    setNameLanguage: SetNameLanguage(settingsRepository),
  );
}

/// Keeps the monster and weapon lists in the name language chosen in settings, applied
/// immediately on change (FR-022).
void linkNameLanguage({
  required SettingsController settings,
  required MonsterListController monsters,
  WeaponListController? weapons,
  ArmorController? armor,
  AssistantController? assistant,
  List<WeaponListController> moreWeapons = const [],
  List<ArmorController> moreArmor = const [],
}) {
  void sync() {
    final language = settings.settings.nameLanguage;
    monsters.onLanguageChanged(language);
    weapons?.onLanguageChanged(language);
    armor?.onLanguageChanged(language);
    assistant?.onLanguageChanged(language);
    for (final w in moreWeapons) {
      w.onLanguageChanged(language);
    }
    for (final a in moreArmor) {
      a.onLanguageChanged(language);
    }
  }

  settings.addListener(sync);
  sync();
}
