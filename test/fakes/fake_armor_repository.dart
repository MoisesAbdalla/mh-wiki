import 'dart:async';

import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/repositories/armor_repository.dart';
import 'package:mh_wiki/features/armor/domain/usecases/load_armor_catalog.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';

import 'armor_fixtures.dart';

/// Returns [catalog], or [failure] when set; [completer] holds the load open.
class FakeArmorRepository implements ArmorRepository {
  FakeArmorRepository({ArmorCatalog? catalog, this.failure})
    : catalog = catalog ?? armorCatalog();

  ArmorCatalog catalog;
  Failure? failure;
  Completer<void>? completer;
  int loadCount = 0;

  @override
  Future<Result<ArmorCatalog>> loadCatalog(Game game) async {
    loadCount++;
    await completer?.future;
    final f = failure;
    return f != null ? Err(f) : Success(catalog);
  }
}

ArmorController buildArmorController([FakeArmorRepository? repository]) =>
    ArmorController(
      loadCatalog: LoadArmorCatalog(repository ?? FakeArmorRepository()),
    );
