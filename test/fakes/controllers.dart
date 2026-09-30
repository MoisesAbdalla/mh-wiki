import 'package:mh_wiki/features/monsters/domain/usecases/filter_monsters.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_by_id.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/load_monster_catalog.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';

import 'fake_monster_repository.dart';

/// Controllers receive use cases only (Principle II); the fake repository is
/// wrapped by the real use cases.
MonsterListController buildController(FakeMonsterRepository repository) =>
    MonsterListController(
      loadCatalog: LoadMonsterCatalog(repository),
      filterMonsters: const FilterMonsters(),
      getMonsterById: const GetMonsterById(),
    );
