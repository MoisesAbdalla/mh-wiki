---

description: "Task list for 001-monster-wiki implementation"
---

# Tasks: Wiki de Monstros

**Input**: Design documents from `specs/001-monster-wiki/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED — constitution Principle VI mandates unit tests for domain and controllers
and widget tests for critical views, with TDD preferred. Every test task MUST be written first
and observed failing (`flutter test <file>`) before its implementation task.

**Organization**: grouped by user story (US1 = detail/list, US2 = game filter, US3 = search),
followed by the cross-cutting name-language setting and polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: user story from spec.md (US1, US2, US3)
- Package name is `mh_wiki`; all imports use `package:mh_wiki/...`

## Path Conventions

Single Flutter app at repository root: `lib/`, `test/`, `integration_test/`, `assets/`, `web/`
(see plan.md → Project Structure).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: create the Flutter project and tooling without touching `.specify/`, `.claude/`,
`specs/`.

- [X] T001 Run `flutter create --project-name mh_wiki --org dev.mhwiki --platforms=android,web,windows .` at repo root; delete the generated counter demo from `lib/main.dart` and `test/widget_test.dart`; confirm `.specify/`, `.claude/`, `specs/` are untouched (`git status`)
- [X] T002 Update `pubspec.yaml`: `environment.sdk: ^3.13.0`; dependencies `flutter_localizations` (sdk), `intl`, `shared_preferences`; dev_dependencies `flutter_test`, `integration_test` (sdk), `flutter_lints`; `flutter.generate: true`; assets `assets/data/world_iceborne/`, `assets/data/rise_sunbreak/`, `assets/data/wilds/`, `assets/images/monsters/`; run `flutter pub get`
- [X] T003 [P] Configure `analysis_options.yaml`: include `package:flutter_lints/flutter.yaml`, enable `strict-casts`, `strict-inference`, `strict-raw-types`, rules `prefer_final_locals`, `always_declare_return_types`, `avoid_print`, `prefer_single_quotes` (do NOT enable `require_trailing_commas`: the current Dart formatter manages trailing commas and the lint would conflict with the `dart format` gate)
- [X] T004 [P] Create `l10n.yaml` (arb-dir `lib/l10n`, template-arb-file `app_pt.arb`, output-localization-file `app_localizations.dart`, `nullable-getter: false`) and `lib/l10n/app_pt.arb` with `@@locale: pt` and the app title key `appTitle: "MH Wiki"`; run `flutter gen-l10n`
- [X] T005 [P] Create empty folder skeleton with `.gitkeep`: `lib/core/domain/`, `lib/core/presentation/`, `lib/app/di/`, `lib/features/monsters/{domain/{entities,repositories,usecases},data/{datasources,dtos,repositories},presentation/{controllers,models,views/widgets}}`, `lib/features/settings/{domain/usecases,data,presentation}`, `test/fakes/`, `assets/data/{world_iceborne,rise_sunbreak,wilds}/`, `assets/images/monsters/{world_iceborne,rise_sunbreak,wilds}/`
- [X] T006 Verify gates on the empty project: `flutter analyze` (no issues), `dart format --set-exit-if-changed .`, `flutter test` (no tests or pass); commit

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: shared domain types, monster entities, dataset parsing and catalog loading that
every story needs. Types and rules come from [data-model.md](data-model.md); interfaces from
[contracts/domain-interfaces.md](contracts/domain-interfaces.md).

**⚠️ CRITICAL**: no user story work can begin until this phase is complete.

### Tests (write first, must fail)

- [X] T007 [P] Unit test `LocalizedText.resolve` (ptBr present → ptBr; ptBr null → en fallback; en language → en) and value equality in `test/core/domain/localized_text_test.dart`
- [X] T008 [P] Unit test `Game` (order 0/1/2, `datasetKey` values `world_iceborne`/`rise_sunbreak`/`wilds`, `allowedRanks`: Wilds excludes master) and `Game.fromDatasetKey` in `test/core/domain/game_test.dart`
- [X] T009 [P] Unit test `WeaknessProfile.mostEffective` per FR-008 (single max 3★ → that element; tie at 2★ → both; max `low` (1★) → empty; max `none` → empty; all `immune` → empty) and `Effectiveness` ordering in `test/features/monsters/domain/entities/weakness_profile_test.dart`
- [X] T010 [P] Unit test `Monster.dropsByRank` (groups by rank then material, keeps each method row, omits ranks without drops, rank order low→high→master) in `test/features/monsters/domain/entities/monster_test.dart`
- [X] T011 [P] Unit test DTO parsing + validation for every rule 1–8 in data-model.md "Validation rules" (valid fixture parses; `schemaVersion: 2` → `UnsupportedSchemaVersion`; game mismatch, duplicate slug, missing element, `master` in Wilds, `breakPart` without/with unknown `partId`, `other` without `methodLabel`, `ratePercent` 0 or 101, unknown `habitatIds`/`materialId`, empty `sources` → `DatasetFormatException`) in `test/features/monsters/data/dtos/monster_dataset_dto_test.dart`
- [X] T012 [P] Unit test `MonsterRepositoryImpl.loadCatalog` with a fake datasource: all games ok → all monsters, empty `failedGames`; one game throws `DatasetUnavailableException` → other games' monsters present and `failedGames` has that game with `DatasetUnavailable`; bad format → `DatasetFormatInvalid`; never throws, in `test/features/monsters/data/repositories/monster_repository_impl_test.dart`
- [X] T013 [P] Unit test `FilterMonsters` baseline (no game, empty text): one `MonsterSection` per game with results, ordered World→Rise→Wilds, monsters sorted by `name.resolve(language)`, empty games omitted, in `test/features/monsters/domain/usecases/filter_monsters_test.dart`

### Implementation

- [X] T014 [P] Implement `Game` enum (displayOrder, datasetKey, allowedRanks, fromDatasetKey), `Rank` enum, `NameLanguage` enum in `lib/core/domain/game.dart`, `lib/core/domain/rank.dart`, `lib/core/domain/name_language.dart`
- [X] T015 [P] Implement `LocalizedText` (en required, ptBr nullable, `resolve`, `==`/`hashCode`) in `lib/core/domain/localized_text.dart`
- [X] T016 [P] Implement sealed `Result<T>` (`Success`, `Err`) in `lib/core/domain/result.dart` and sealed `Failure` (`DatasetUnavailable`, `DatasetFormatInvalid`, `UnsupportedSchemaVersion`, `MonsterNotFound`, `PreferenceStorageFailure`) in `lib/core/domain/failure.dart`
- [X] T017 Implement monster entities per data-model.md: `MonsterId`, `Element`, `Effectiveness`, `WeaknessState`, `WeaknessProfile` (+`mostEffective`), `Habitat`, `BreakablePart`, `Material`, `DropMethod`, `MaterialDrop`, `MaterialDropGroup`, `SourceRef`, `Monster` (+`dropsByRank`), `MonsterCatalog`, `MonsterQuery`, `MonsterSection` in `lib/features/monsters/domain/entities/` (one file per type, pure Dart, no Flutter imports)
- [X] T018 [P] Define `MonsterRepository` interface in `lib/features/monsters/domain/repositories/monster_repository.dart` and `MonsterDatasource` interface + `DatasetUnavailableException`/`DatasetFormatException` in `lib/features/monsters/data/datasources/monster_datasource.dart`
- [X] T019 Implement DTOs with hand-written `fromJson` and validation rules 1–8 (schema in `contracts/monster-dataset.schema.json`) and DTO→entity mapper resolving `habitatIds`/`materialId` in `lib/features/monsters/data/dtos/monster_dataset_dto.dart` and `lib/features/monsters/data/dtos/monster_dataset_mapper.dart` (makes T011 pass)
- [X] T020 [P] Implement `AssetMonsterDatasource(AssetBundle)` loading `assets/data/<datasetKey>/monsters.json` with `jsonDecode`, mapping missing asset to `DatasetUnavailableException` in `lib/features/monsters/data/datasources/asset_monster_datasource.dart`
- [X] T021 Implement `MonsterRepositoryImpl` loading the three games in parallel (`Future.wait`), catching per-game exceptions into `failedGames` in `lib/features/monsters/data/repositories/monster_repository_impl.dart` (makes T012 pass)
- [X] T022 [P] Implement `LoadMonsterCatalog` use case in `lib/features/monsters/domain/usecases/load_monster_catalog.dart`
- [X] T023 Implement `FilterMonsters` baseline (sections + sort by resolved name; `game`/`text` fields accepted but only baseline behaviour required now) in `lib/features/monsters/domain/usecases/filter_monsters.dart` (makes T013 pass)
- [X] T024 [P] Create test fixtures and fakes: `test/fakes/monster_fixtures.dart` (builders for Monster with options: states, immune element, no parts, no habitats, drops across ranks incl. breakPart/unknown rate/other), `test/fakes/fake_monster_repository.dart`, `test/fakes/fake_monster_datasource.dart`, and `test/fakes/fixtures/valid_dataset.json`
- [X] T025 [P] Create minimal valid placeholder datasets (1 monster each, real Rathalos data with `sources`) in `assets/data/world_iceborne/monsters.json`, `assets/data/rise_sunbreak/monsters.json`, `assets/data/wilds/monsters.json`
- [X] T026 Add real-datasets test that loads every `assets/data/*/monsters.json` through `AssetMonsterDatasource` + mapper and asserts success, unique slugs and ≥1 monster in `test/features/monsters/data/real_datasets_test.dart`
- [X] T027 Create app shell: `lib/app/app.dart` (`MhWikiApp` with `MaterialApp`, Material 3 theme light/dark, `AppLocalizations.localizationsDelegates`, `supportedLocales`, locale `pt_BR`), `lib/app/di/app_dependencies.dart` (composition root building datasource→repository→use cases; exposes factories for controllers), `lib/main.dart` (build `AppDependencies`, `runApp`)
- [X] T028 Run gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`); commit

**Checkpoint**: domain + data load the catalog from assets; all foundational tests green.

---

## Phase 3: User Story 1 - Consultar as fraquezas de um monstro (Priority: P1) 🎯 MVP

**Goal**: list of monsters → detail with weaknesses (general + states), habitats, breakable
parts and materials by rank with method and rate; adaptive list/detail layout.

**Independent Test**: with World: Iceborne data loaded, open the app, tap a monster, and see the
four detail sections with correct data; on a ≥840 dp window the detail appears beside the list
(spec US1 scenarios 1–5).

### Tests for User Story 1 (write first, must fail) ⚠️

- [X] T029 [P] [US1] Unit test `GetMonsterById` (found → `Success`; unknown → `Err(MonsterNotFound)`) in `test/features/monsters/domain/usecases/get_monster_by_id_test.dart`
- [X] T030 [P] [US1] Unit test `MonsterListController` constructed with real use cases (`LoadMonsterCatalog`, `FilterMonsters`, `GetMonsterById`) wrapping `FakeMonsterRepository` — never the repository directly (Principle II): initial `Loading`; `load()` → `Loaded` with sections; all games failed → `LoadFailed`; retry → `Loading`→`Loaded`; partial failure → `Loaded.failedGames` non-empty; `select(id)` sets `selectedId`; `clearSelection()`; notifies listeners on each change, in `test/features/monsters/presentation/controllers/monster_list_controller_test.dart`
- [X] T031 [P] [US1] Widget test `WeaknessSection`: 5 elements with star counts, "Imune" badge distinct from 0★, highlight only `mostEffective`, no highlight when empty, state sub-blocks titled by state name only when `states` non-empty, semantics labels ("Fogo: 3 de 3", "Gelo: imune") in `test/features/monsters/presentation/views/widgets/weakness_section_test.dart`
- [X] T032 [P] [US1] Widget test `HabitatSection` and `PartsSection`: names listed; "Cortável" tag on severable parts; "Nenhum habitat fixo" / "Nenhuma parte quebrável" when empty in `test/features/monsters/presentation/views/widgets/habitat_parts_sections_test.dart`
- [X] T033 [P] [US1] Widget test `MaterialsSection`: tabs only for ranks present (Baixo/Alto/Mestre); per material one row per method; `breakPart` row shows "Quebrar: <part>"; rate "NN%" vs "Taxa desconhecida"; `other` shows its label; "Nenhum material registrado" when no drops in `test/features/monsters/presentation/views/widgets/materials_section_test.dart`
- [X] T034 [P] [US1] Widget test `MonstersPage` compact (width 400): loading indicator; list tiles with name, game, classification, placeholder image; tap pushes detail with the 4 section headings; back returns with same scroll offset; `LoadFailed` shows "Tentar novamente"; partial failure banner lists failed game in `test/features/monsters/presentation/views/monsters_page_compact_test.dart`
- [X] T035 [P] [US1] Widget test adaptive layout: at width 1200 list and detail side by side, selecting a tile updates the pane, "Selecione um monstro" when none selected; resizing 1200→400 with a selection shows detail route, 400→1200 pops the route and keeps selection, in `test/features/monsters/presentation/views/monsters_page_adaptive_test.dart`

### Implementation for User Story 1

- [X] T036 [P] [US1] Implement `GetMonsterById` in `lib/features/monsters/domain/usecases/get_monster_by_id.dart` (makes T029 pass)
- [X] T037 [P] [US1] Implement sealed `MonsterListState` (`MonsterListLoading`, `MonsterListLoaded` with sections/query/failedGames/selectedId/isEmpty/hasActiveFilters, `MonsterListLoadFailed`) in `lib/features/monsters/presentation/models/monster_list_state.dart`
- [X] T038 [US1] Implement `MonsterListController` — constructor takes only use cases (`LoadMonsterCatalog`, `FilterMonsters`, `GetMonsterById`) and the initial `NameLanguage`; it MUST NOT import or receive any repository/datasource (Principle II) — (`load`, `select`, `clearSelection`, `selectedMonster` getter via `GetMonsterById`; holds catalog + `MonsterQuery`; `NameLanguage.ptBr` default via constructor param) in `lib/features/monsters/presentation/controllers/monster_list_controller.dart` (makes T030 pass)
- [X] T039 [US1] Add US1 UI strings to `lib/l10n/app_pt.arb` (section titles, element names Fogo/Água/Raio/Gelo/Dragão, "Imune", "Cortável", rank names Baixo/Alto/Mestre, method labels Entalhe/Entalhe da cauda/Captura/Quebrar: {part}/Recompensa de missão/Material caído, "Taxa desconhecida", empty messages, "Tentar novamente", "Selecione um monstro", failed-games banner with placeholder, game display names, star semantics "{element}: {n} de 3") and run `flutter gen-l10n`
- [X] T040 [P] [US1] Implement shared widgets `MonsterImage` (asset or generic placeholder, `cacheWidth`) and `StarRating` (0–3 stars, immune badge, semantics) in `lib/core/presentation/widgets/monster_image.dart` and `lib/core/presentation/widgets/star_rating.dart`
- [X] T041 [P] [US1] Implement `WeaknessSection` in `lib/features/monsters/presentation/views/widgets/weakness_section.dart` (makes T031 pass)
- [X] T042 [P] [US1] Implement `HabitatSection` and `PartsSection` in `lib/features/monsters/presentation/views/widgets/habitat_section.dart` and `lib/features/monsters/presentation/views/widgets/parts_section.dart` (makes T032 pass)
- [X] T043 [P] [US1] Implement `MaterialsSection` (rank tabs from `dropsByRank`) in `lib/features/monsters/presentation/views/widgets/materials_section.dart` (makes T033 pass)
- [X] T044 [US1] Implement `MonsterDetailView` (header: image, name, game, classification; then the 4 sections; long names max 2 lines + ellipsis) in `lib/features/monsters/presentation/views/widgets/monster_detail_view.dart` and `MonsterDetailPage` (Scaffold wrapper) in `lib/features/monsters/presentation/views/monster_detail_page.dart`
- [X] T045 [US1] Implement `MonsterListPane` (sections list with `PageStorageKey` to keep scroll, tiles, selected highlight, loading/error/banner states) in `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart`
- [X] T046 [US1] Implement `Breakpoints` (`expanded = 840`) in `lib/core/presentation/breakpoints.dart` and `MonstersPage` with `LayoutBuilder` compact/expanded switching and route push/pop sync driven by `controller.selectedId` (see contracts/ui-contract.md "Layout switch") in `lib/features/monsters/presentation/views/monsters_page.dart` (makes T034, T035 pass)
- [X] T047 [US1] Wire `MonsterListController` creation in `lib/app/di/app_dependencies.dart` and set `MonstersPage` as home in `lib/app/app.dart`; controller `load()` on startup
- [ ] T048 [P] [US1] Curate the full World: Iceborne dataset (10 monsters per research.md R15: Great Jagras, Anjanath, Rathian, Pink Rathian, Rathalos, Diablos, Nergigante, Zinogre, Velkhana, Alatreon — Alatreon with elemental-mode `states`) with habitats, parts, drops (low/high/master, method, rate or omitted if unknown) and `sources` in `assets/data/world_iceborne/monsters.json`; confirm the FR-002 roster criteria (≥1 monster shared by all three games, ≥1 variant/subspecies, ≥1 monster without breakable parts or fixed habitat — if none exists in this game, record that under research.md R15); `real_datasets_test.dart` must pass
- [ ] T049 [US1] Run gates and manual quickstart scenarios 1, 8, 9, 14 on Windows (`flutter run -d windows`); commit

**Checkpoint**: MVP — browse and inspect monsters with the adaptive layout.

---

## Phase 4: User Story 2 - Filtrar monstros por jogo (Priority: P2)

**Goal**: game filter ("Todos" + 3 games), sectioned "Todos" view, all three datasets complete.

**Independent Test**: with the three datasets loaded, select a game → only that game's monsters;
"Todos" → three sections in order World → Rise → Wilds; Rathalos appears in each section
(spec US2 scenarios 1–3).

### Tests for User Story 2 (write first, must fail) ⚠️

- [X] T050 [P] [US2] Extend `FilterMonsters` tests: `game = riseSunbreak` → single section with only Rise monsters; `game = null` → all sections; same slug in 3 games → 3 distinct entries, one per section in `test/features/monsters/domain/usecases/filter_monsters_test.dart`
- [X] T051 [P] [US2] Extend controller tests: `setGame` re-filters, keeps `selectedId`, notifies; `clearFilters` resets game; `hasActiveFilters` true when game set in `test/features/monsters/presentation/controllers/monster_list_controller_test.dart`
- [X] T052 [P] [US2] Widget test `GameFilterBar` + list: 4 options ("Todos" + 3 games); selecting Wilds shows only Wilds tiles and no section header; "Todos" shows 3 sticky headers in order; empty result with active filter shows "Nenhum monstro encontrado" + "Limpar filtros" in `test/features/monsters/presentation/views/game_filter_test.dart`

### Implementation for User Story 2

- [X] T053 [US2] Implement game filtering in `FilterMonsters` in `lib/features/monsters/domain/usecases/filter_monsters.dart` (makes T050 pass)
- [X] T054 [US2] Add `setGame(Game?)` and `clearFilters()` to `MonsterListController` in `lib/features/monsters/presentation/controllers/monster_list_controller.dart` (makes T051 pass)
- [X] T055 [US2] Add strings "Todos", "Nenhum monstro encontrado", "Limpar filtros", active-filter hint to `lib/l10n/app_pt.arb`; run `flutter gen-l10n`
- [X] T056 [US2] Implement `GameFilterBar` (SegmentedButton/ChoiceChips) in `lib/features/monsters/presentation/views/widgets/game_filter_bar.dart`; add sticky section headers (only for "Todos") and empty state with "Limpar filtros" to `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart` (makes T052 pass)
- [ ] T057 [P] [US2] Curate the full Rise: Sunbreak dataset (Great Izuchi, Rathian, Rathalos, Tigrex, Zinogre, Mizutsune, Soulseer Mizutsune, Magnamalo, Rajang, Malzeno) with low/high/master drops, weakness conversion rule recorded in `sources[].notes` (research R12) in `assets/data/rise_sunbreak/monsters.json`; confirm the FR-002 roster criteria as in T048 (record absence under research.md R15)
- [ ] T058 [P] [US2] Curate the full Wilds dataset (Chatacabra, Doshaguma, Rey Dau, Uth Duna, Nu Udra, Jin Dahaad, Rathalos, Guardian Rathalos, Gore Magala, Arkveld) with low/high drops only in `assets/data/wilds/monsters.json`; confirm the FR-002 roster criteria as in T048 (record absence under research.md R15)
- [ ] T059 [US2] Run gates and quickstart scenarios 2, 3, 13 (temporarily corrupt Wilds JSON in a debug run, then restore); commit

**Checkpoint**: US1 + US2 work; all three games browsable and filterable.

---

## Phase 5: User Story 3 - Buscar monstro pelo nome (Priority: P3)

**Goal**: live, case- and accent-insensitive partial search over pt-BR and English names,
combined with the game filter.

**Independent Test**: type "rath" → only Rathalos/Rathian entries (respecting the active game);
"RATH" and accent variants give the same result; no match → empty state with clear action
(spec US3 scenarios 1–4).

### Tests for User Story 3 (write first, must fail) ⚠️

- [X] T060 [P] [US3] Unit test `normalizeForSearch` (lowercase; á à â ã ä é ê í ó ô õ ú ü ç ñ folded; trims; empty stays empty) in `test/core/domain/search_normalizer_test.dart`
- [X] T061 [P] [US3] Unit test `LocalizedText.matches` (matches en or ptBr; ptBr null → en only) in `test/core/domain/localized_text_test.dart`
- [X] T062 [P] [US3] Extend `FilterMonsters` tests: partial match; case/accent-insensitive; matches English name while displaying pt-BR; AND with game filter; no match → empty list in `test/features/monsters/domain/usecases/filter_monsters_test.dart`
- [X] T063 [P] [US3] Extend controller tests: `setSearchText` re-filters on each call, keeps game filter and selection; `clearFilters` clears text too in `test/features/monsters/presentation/controllers/monster_list_controller_test.dart`
- [X] T064 [P] [US3] Widget test `SearchField` + list: typing "rath" filters as you type; clear (×) button restores list; no-match empty state and "Limpar filtros" in `test/features/monsters/presentation/views/search_test.dart`

### Implementation for User Story 3

- [X] T065 [P] [US3] Implement `normalizeForSearch` with explicit diacritic map (pure Dart) in `lib/core/domain/search_normalizer.dart` (makes T060 pass)
- [X] T066 [US3] Add `matches(String normalizedQuery)` to `LocalizedText` in `lib/core/domain/localized_text.dart` (makes T061 pass)
- [X] T067 [US3] Implement text filtering in `FilterMonsters` in `lib/features/monsters/domain/usecases/filter_monsters.dart` (makes T062 pass)
- [X] T068 [US3] Add `setSearchText(String)` to `MonsterListController` and include text in `clearFilters` in `lib/features/monsters/presentation/controllers/monster_list_controller.dart` (makes T063 pass)
- [X] T069 [US3] Add search strings (hint "Buscar monstro", clear tooltip) to `lib/l10n/app_pt.arb`; implement `SearchField` in `lib/features/monsters/presentation/views/widgets/search_field.dart` and place it above the filter bar in `monster_list_pane.dart` (makes T064 pass)
- [ ] T070 [US3] Run gates and quickstart scenarios 4 and 7; commit

**Checkpoint**: all three user stories independently functional.

---

## Phase 6: Name-Language Preference (cross-cutting: FR-021 – FR-025)

**Purpose**: user chooses whether game names show in pt-BR or English; persisted; applied
instantly; sorting follows the language. Affects US1–US3 views.

### Tests (write first, must fail) ⚠️

- [X] T071 [P] Unit test `SharedPrefsSettingsRepository` with `SharedPreferences.setMockInitialValues`: nothing stored → `ptBr`; save `en` then load → `en`; unknown stored value → `ptBr` in `test/features/settings/data/shared_prefs_settings_repository_test.dart`
- [X] T072 [P] Unit test `SettingsController` constructed with real use cases (`LoadSettings`, `SetNameLanguage`) wrapping `FakeSettingsRepository` (`test/fakes/fake_settings_repository.dart`): `load`; `setNameLanguage` updates immediately and notifies; save failure keeps in-memory choice and exposes transient error in `test/features/settings/presentation/settings_controller_test.dart`
- [X] T073 [P] Extend `MonsterListController` tests: `onLanguageChanged(en)` re-sorts sections by English name (FR-025) and keeps filters/selection in `test/features/monsters/presentation/controllers/monster_list_controller_test.dart`
- [X] T074 [P] Widget test: switching to English in `SettingsPage` changes names on list and detail without restart; pt-BR missing → English shown; search finds by both names regardless of setting in `test/features/settings/presentation/name_language_flow_test.dart`

### Implementation

- [X] T075 [P] Implement `AppSettings`, `SettingsRepository` interface, `LoadSettings`, `SetNameLanguage` in `lib/features/settings/domain/app_settings.dart`, `lib/features/settings/domain/settings_repository.dart`, `lib/features/settings/domain/usecases/load_settings.dart`, `lib/features/settings/domain/usecases/set_name_language.dart`
- [X] T076 Implement `SharedPrefsSettingsRepository` (key `name_language`, values `ptBr`/`en`, errors → `PreferenceStorageFailure`) in `lib/features/settings/data/shared_prefs_settings_repository.dart` (makes T071 pass)
- [X] T077 Implement `SettingsController` (constructor takes only `LoadSettings` and `SetNameLanguage`; no repository import — Principle II) in `lib/features/settings/presentation/settings_controller.dart` (makes T072 pass)
- [X] T078 Add `onLanguageChanged` to `MonsterListController` in `lib/features/monsters/presentation/controllers/monster_list_controller.dart` (makes T073 pass)
- [X] T079 Add strings ("Configurações", "Idioma dos nomes do jogo", "Português (Brasil)", "English", "Não foi possível salvar a preferência") to `lib/l10n/app_pt.arb`; implement `SettingsPage` (radio options, snackbar on failure) in `lib/features/settings/presentation/settings_page.dart`; add settings action to the `MonstersPage` app bar
- [X] T080 Wire settings in `lib/app/di/app_dependencies.dart` (await `SharedPreferences.getInstance()` / `LoadSettings` before `runApp` in `lib/main.dart`), listen to `SettingsController` to call `MonsterListController.onLanguageChanged`, and pass `settings.nameLanguage` into every `LocalizedText.resolve` call in list/detail widgets (makes T074 pass)
- [ ] T081 Run gates and quickstart scenarios 5 and 6; commit

**Checkpoint**: all functional requirements implemented.

---

## Phase 7: Polish & Cross-Cutting Concerns

- [ ] T082 [P] Implement custom service worker precaching build output (cache-first, cache name versioned by app version) in `web/sw.js` and register it from a custom `web/flutter_bootstrap.js` (research R10); verify quickstart scenario 12 on `flutter build web --release` served locally
- [ ] T083 [P] Add monster images (WebP, ~256 px thumbnails) for the roster where a reference image is available in `assets/images/monsters/<game>/<slug>.webp` and set `image` in each dataset; missing images keep the placeholder
- [X] T084 [P] Create end-to-end test (open list → filter Wilds → search "rath" → open Rathalos → assert 4 sections → back keeps filter/search) in `integration_test/app_test.dart` plus `test_driver/integration_test.dart` for web
- [ ] T085 Run `integration_test` on Android emulator (phone + tablet), Windows and Chrome (SC-008); run quickstart scenarios 10 and 11
- [X] T086 [P] Accessibility pass: verify semantics labels, ≥48 dp tap targets, and 200% text scale without clipping on detail sections; fix in affected widgets under `lib/features/monsters/presentation/views/widgets/`
- [X] T087 [P] Run dependency-rule checks from quickstart.md (domain imports only `mh_wiki`; presentation never imports `/data/`) and fix any violation
- [ ] T088 [P] Add performance test for SC-002: build a synthetic catalog of 200 monsters with `test/fakes/monster_fixtures.dart` and assert that `MonsterListController.setSearchText` and `setGame` each produce the new `Loaded` state in < 500 ms (Stopwatch) in `test/features/monsters/presentation/performance/filter_performance_test.dart`; then, for SC-003, run `flutter run --profile` on Android and use DevTools timeline to confirm detail opens in < 1 s after tap; record measured numbers in the phase commit message
- [ ] T089 Data accuracy spot-check (SC-005) for all 30 monsters against their `sources`; fix discrepancies in `assets/data/*/monsters.json` only
- [X] T090 Add `README.md` at repo root (what the app is, run commands, how to add a monster = edit JSON per `specs/001-monster-wiki/contracts/monster-dataset.schema.json`, fan-made/non-commercial note)
- [ ] T091 Final gates: `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`; full quickstart.md run; commit

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none
- **Foundational (Phase 2)**: after Setup — BLOCKS all stories
- **US1 (Phase 3)**: after Foundational
- **US2 (Phase 4)**: after Foundational; its UI tasks (T056) edit `monster_list_pane.dart` created in T045, so in practice after US1's T045
- **US3 (Phase 5)**: after Foundational; T069 edits `monster_list_pane.dart` (after T045)
- **Name language (Phase 6)**: after US1 (touches list/detail widgets); independent of US2/US3
- **Polish (Phase 7)**: after all desired phases

### User Story Dependencies

- **US1 (P1)**: independent — the MVP
- **US2 (P2)**: domain/controller tasks (T050–T054) independent of US1; UI task T056 needs the list pane from US1
- **US3 (P3)**: domain/controller tasks (T060–T068) independent of US1/US2; UI task T069 needs the list pane from US1
- Controller test file and `filter_monsters.dart` are shared across US2/US3/Phase 6 — run those tasks sequentially, not in parallel across stories

### Within Each Phase

- Tests first and failing → entities/use cases → controller → widgets → wiring → gates
- Dataset curation tasks (T048, T057, T058) are content work and can run in parallel with any code task

---

## Parallel Example: Foundational

```text
Task: "T007 LocalizedText tests in test/core/domain/localized_text_test.dart"
Task: "T008 Game tests in test/core/domain/game_test.dart"
Task: "T009 WeaknessProfile tests in test/features/monsters/domain/entities/weakness_profile_test.dart"
Task: "T011 DTO validation tests in test/features/monsters/data/dtos/monster_dataset_dto_test.dart"
```

## Parallel Example: User Story 1

```text
# Tests together:
Task: "T031 WeaknessSection widget test"
Task: "T032 Habitat/Parts widget tests"
Task: "T033 MaterialsSection widget test"
# Then widgets together:
Task: "T041 WeaknessSection"   Task: "T042 Habitat/PartsSection"   Task: "T043 MaterialsSection"
# Content in parallel with all of the above:
Task: "T048 Curate World: Iceborne dataset"
```

## Parallel Example: User Story 2

```text
Task: "T057 Curate Rise: Sunbreak dataset"
Task: "T058 Curate Wilds dataset"
Task: "T050/T051/T052 tests" (different files)
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 Setup → Phase 2 Foundational
2. Phase 3 (US1) with the World: Iceborne dataset
3. **STOP and VALIDATE**: quickstart scenarios 1, 8, 9, 14 + adaptive layout on Windows

### Incremental Delivery

1. Foundation → US1 (MVP: browse + detail)
2. US2 → all three games + filter
3. US3 → search
4. Phase 6 → pt-BR/English names
5. Phase 7 → offline web, images, e2e on all platforms, data accuracy

---

## Notes

- [P] = different files, no dependency on incomplete tasks
- Every implementation task names the test task it must turn green
- Commit at the end of each phase (gate tasks T006, T028, T049, T059, T070, T081, T091)
- Data fixes never require code changes (FR-002a)
