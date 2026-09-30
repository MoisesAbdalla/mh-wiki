# Contract: Domain Interfaces

Signatures only (Dart). These are the seams between layers (constitution Principles I–III):
`presentation` depends on use cases; use cases depend on repository interfaces; `data`
implements the interfaces. Types are defined in [../data-model.md](../data-model.md).

## Repositories (implemented in `data`)

```dart
// lib/features/monsters/domain/repositories/monster_repository.dart
abstract interface class MonsterRepository {
  /// Loads every game's dataset independently. Never throws.
  /// A game whose dataset fails is reported in MonsterCatalog.failedGames.
  Future<MonsterCatalog> loadCatalog();
}

// lib/features/settings/domain/repositories/settings_repository.dart
abstract interface class SettingsRepository {
  Future<AppSettings> load();                       // defaults when nothing stored
  Future<Result<void>> saveNameLanguage(NameLanguage language);
}
```

## Data sources (data layer, swappable local ↔ remote — Principle IV)

```dart
// lib/features/monsters/data/datasources/monster_datasource.dart
abstract interface class MonsterDatasource {
  /// Returns the raw decoded JSON map for one game's dataset.
  /// Throws DatasetUnavailableException / DatasetFormatException (caught by the repository).
  Future<Map<String, Object?>> fetchDataset(Game game);
}
// v1 implementation: AssetMonsterDatasource(AssetBundle bundle)
```

## Use cases (domain, one public `call`)

```dart
final class LoadMonsterCatalog   { Future<MonsterCatalog> call(); }
final class FilterMonsters       { List<MonsterSection> call(List<Monster> all, MonsterQuery q); }
final class GetMonsterById       { Result<Monster> call(List<Monster> all, MonsterId id); }
final class LoadSettings         { Future<AppSettings> call(); }
final class SetNameLanguage      { Future<Result<void>> call(NameLanguage language); }
```

Behavioural guarantees (each backed by a unit test):

| Use case | Guarantee | Spec |
|----------|-----------|------|
| FilterMonsters | `game == null` → sections for every game with results, in Game order | FR-003, FR-006 |
| FilterMonsters | text matched case/accent-insensitively against pt-BR **and** en names | FR-004, FR-023 |
| FilterMonsters | game + text combined with AND | FR-005 |
| FilterMonsters | sorted by `name.resolve(language)`; empty sections omitted | FR-006, FR-025 |
| LoadMonsterCatalog | one failing game does not remove others' monsters | FR-017 |
| GetMonsterById | unknown id → `Err(MonsterNotFound)` | — |
| SetNameLanguage | persisted value returned by next `LoadSettings` | FR-022 |

## Controllers (presentation, `ChangeNotifier`)

```dart
final class MonsterListController extends ChangeNotifier {
  MonsterListState get state;
  Future<void> load();
  void setGame(Game? game);          // null = "Todos"
  void setSearchText(String text);   // updates as the user types (FR-005)
  void clearFilters();
  void select(MonsterId id);
  void clearSelection();
  void onLanguageChanged(NameLanguage language); // re-sorts (FR-025)
}

final class SettingsController extends ChangeNotifier {
  AppSettings get settings;
  Future<void> load();
  Future<void> setNameLanguage(NameLanguage language); // applies immediately (FR-022)
}
```

Controllers MUST NOT import `package:flutter/widgets.dart` beyond `foundation.dart`
(`ChangeNotifier`) and MUST NOT depend on `BuildContext` (Principle II).
