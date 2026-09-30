---

description: "Task list for 004-all-large-monsters implementation"
---

# Tasks: Todos os Monstros Grandes

**Input**: Design documents from `specs/004-all-large-monsters/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ui-versions.md](contracts/ui-versions.md),
[quickstart.md](quickstart.md)

**Tests**: REQUIRED (constitution Principle VI). Write each test first and see it fail.

**Organization**:
- US1 = full roster with the base data of the detail.
- US2 = HP and hunting items for every entry.
- US3 = the large list stays fast and usable (versions collapsed, selector, thumbnails).

Delivery is one game at a time (spec Q2): Wilds with all three stories (Phases 3–5, then merge),
then Rise (Phase 6), then World (Phase 7).

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup

- [X] T001 Move the data pipeline into the repository (research R8).
  - Copy the scratchpad scripts into `tool/data/`, with shared helpers (`fetch` with cache, `clean`, `payload`, `dump_dataset` that keeps the CRLF / indent-2 / no-trailing-newline format) in `tool/data/common.py`: `build_world.py`, `build_rise.py`, `build_wilds.py`, `kiranico_world.py`, `hp_extract.py`, `items_extract.py`, `item_parse.py`, `fetch_icons.py`.
  - Paths are relative to the repo root; the cache goes in `tool/data/.cache/`.
  - Add `tool/data/.cache/` to `.gitignore`.
  - Add `tool/data/README.md` (usage, rules → links to research of 001–004).
- [X] T002 [P] Add the new UI strings to `lib/l10n/app_pt.arb` and run `flutter gen-l10n`:
  - version labels: "Base", "Temperado", "Arquitemperado", "Aflito", "Frenesi", "Apex", "Ressurgido", "Guardião";
  - "{count, plural, =1{1 versão} other{{count} versões}}";
  - "Igual à forma base";
  - "Versão: {label}".

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: versions in the model, data and use cases. Every game phase needs them.

- [X] T003 [P] DTO tests in `test/features/monsters/data/dtos/monster_dataset_dto_test.dart`, with fixtures in `test/fakes/dataset_json_fixtures.dart` (`withVersion(...)`).
  - A version with `versionOf`/`versionKind` parses.
  - A version may omit `weaknesses`, `parts`, `habitatIds`, `itemReactions` and `classification`; a base may not.
  - Rejected:
    - an unknown base, or a base that is itself a version;
    - `versionKind` without `versionOf`, or `versionOf` without `versionKind`;
    - a kind not allowed for the game (data-model table);
    - two versions of the same kind for one base;
    - a version with neither `hp` nor `drops`;
    - a drop `partId` not in the effective (inherited) parts.
- [X] T004 [P] Mapper tests in `test/features/monsters/data/dtos/monster_dataset_mapper_test.dart`.
  - A version inherits weaknesses, parts, habitats, reactions and classification from its base.
  - `inheritedSections` lists exactly the omitted sections.
  - `hp` and `drops` are never taken from the base.
  - `versionOf` and `versionKind` are set.
- [X] T005 [P] Create the domain types in `lib/features/monsters/domain/entities/`:
  - `version_kind.dart`: `VersionKind` enum in data-model order, plus the per-game allowed set as a pure-Dart map keyed by `Game`;
  - `monster_section_kind.dart`;
  - `monster_entry.dart`: `MonsterEntry` (base, versions, matchedVersion, `target`).
  - In `monster.dart`, add `versionOf`, `versionKind`, `inheritedSections` (default empty) and `isVersion`.
- [X] T006 Extend the DTO and mapper (makes T003/T004 pass): `lib/features/monsters/data/dtos/monster_dataset_dto.dart` (version fields, optional sections for versions, all rules of T003), `lib/features/monsters/data/dtos/monster_dataset_mapper.dart` (inheritance, research R3).
- [X] T007 [P] Use-case tests in `test/features/monsters/domain/usecases/filter_monsters_test.dart` and `test/features/monsters/domain/usecases/get_monster_versions_test.dart`.
  - Versions are grouped under their base; entries are sorted by base name in the selected language.
  - A query matching only a version returns the base entry with `matchedVersion`.
  - A query matching the base has no `matchedVersion`.
  - Accents and case are ignored.
  - The game filter still applies.
  - `GetMonsterVersions` returns base + versions in kind order, given any member id.
- [X] T008 Implement the use cases (makes T007 pass).
  - `lib/features/monsters/domain/entities/monster_section.dart` holds `List<MonsterEntry>`.
  - `lib/features/monsters/domain/usecases/filter_monsters.dart`: grouping, plus normalized names precomputed once per catalog. Use a pure-Dart index built by the use case and cached by catalog identity.
  - New `lib/features/monsters/domain/usecases/get_monster_versions.dart`.
  - Wire it in `lib/app/di/app_dependencies.dart`.
- [X] T009 [P] Controller tests in `test/features/monsters/presentation/controllers/monster_list_controller_test.dart`.
  - `select(versionId)` exposes `selectedMonster` as the version and `selectedVersions` as base + versions.
  - Language change keeps the selected version.
- [X] T010 Update `lib/features/monsters/presentation/controllers/monster_list_controller.dart` (inject `GetMonsterVersions`, expose `selectedVersions`) and `lib/features/monsters/presentation/models/monster_list_state.dart`. Adapt `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart` to render entries: tapping selects `entry.target.id`. Makes T009 pass.
- [X] T011 Document `versionOf` / `versionKind` and the optional sections of versions in `specs/001-monster-wiki/contracts/monster-dataset.schema.json` (schema stays v1).
- [X] T012 Run the gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`) and commit. Update existing tests that built `MonsterSection` with monsters.

**Checkpoint**: the app works as before with the current 30 monsters. Versions are supported end to end in data and domain.

---

## Phase 3: User Story 1 — Wilds roster (Priority: P1) 🎯 MVP

**Goal**: every Wilds large monster with the detail data of 001 (spec US1), versions included.

**Independent Test**: quickstart checks 1, 5, 6 and 10 for Wilds; `real_datasets_test` roster coverage.

- [X] T013 [US1] Source check for Wilds versions (research R4). For each Wilds monster, record which tempered, arch-tempered and frenzied entries have own data in the sources (Kiranico tempered drop group, wiki "Arch-Tempered" section, event quests). Guardians: Rathalos, Doshaguma and Arkveld become versions; Fulgur Anjanath and Ebony Odogaron keep their own rows. Write the result to `tool/data/rosters/wilds.json` (slug, Kiranico slug, wiki title, `versionOf`, `versionKind`) and summarize it in `specs/004-all-large-monsters/research.md` (R4 Wilds).
- [X] T014 [US1] Make `tool/data/build.py wilds` roster-driven. It builds names (en/pt-BR), classification, weaknesses (hitzone star rule), habitats, parts and drops (per rank; tempered drop group for tempered versions) for every roster entry. Versions omit inheritable sections unless the source has their own. It regenerates `assets/data/wilds/monsters.json`, keeping the 30 original entries' values (`guardian-rathalos` gains `versionOf: rathalos`, `versionKind: guardian`).
- [X] T015 [US1] Extend `test/features/monsters/data/real_datasets_test.dart`.
  - Every slug in `tool/data/rosters/wilds.json` is in the dataset (SC-001) and vice versa.
  - Every base monster has weaknesses, classification and ≥ 1 habitat (SC-003).
  - `guardian-rathalos` is a guardian version of `rathalos`.
  - The spot checks of 001–003 still pass.
- [X] T016 [US1] Run the gates; commit the Wilds base data.

---

## Phase 4: User Story 2 — Wilds hunting info (Priority: P2)

**Goal**: HP per rank and item reactions for every Wilds entry (spec US2).

**Independent Test**: quickstart check 3; new monsters show HP/items or "Desconhecido".

- [X] T017 [US2] Run `tool/data/hp_extract.py` and `tool/data/items_extract.py` for the whole Wilds roster (rules of 003).
  - Tempered versions without quest HP get no `hp`.
  - Arch-tempered versions get `hp` only from quests with that monster.
  - Versions get `itemReactions` only when their own wiki page differs from the base's.
  - Update `assets/data/wilds/monsters.json`.
- [X] T018 [US2] Extend `real_datasets_test.dart`: every Wilds base monster has ≥ 1 `hp` entry or is listed in a documented `noHp` set in the test (with the reason, e.g. story-only fights), and reactions use only the dataset items. Run the gates; commit.

---

## Phase 5: User Story 3 — List and detail with versions, thumbnails, performance (Priority: P3)

**Goal**: collapsed versions, the version selector, "Igual à forma base", thumbnails for every entry, speed targets.

**Independent Test**: quickstart checks 2, 3, 4, 7, 8 and 9.

- [X] T019 [P] [US3] Widget tests for the list row in `test/features/monsters/presentation/views/widgets/monster_list_pane_test.dart` (contract "List row"):
  - "N versões" hint;
  - the matched version name under the base name when the search matched a version;
  - tap opens that version;
  - semantics "<name>, <classification>, N versões".
- [X] T020 [P] [US3] Widget tests in `test/features/monsters/presentation/views/widgets/version_selector_test.dart` and `test/features/monsters/presentation/views/widgets/monster_detail_view_test.dart`:
  - the selector is shown only with versions, with labels in kind order;
  - selecting calls back with the id;
  - tabs are labeled "Versão: <label>";
  - inherited sections show "Igual à forma base";
  - HP and materials of a version never show base data.
- [X] T021 [US3] Implement the list row hint and matched version in `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart` (makes T019 pass).
- [X] T022 [US3] Implement the detail changes (makes T020 pass).
  - New `lib/features/monsters/presentation/views/widgets/version_selector.dart` (HunterTabs style).
  - New `lib/features/monsters/presentation/views/widgets/inherited_note.dart`.
  - `monster_detail_view.dart` gains `versions` and `onSelectVersion` parameters.
  - Wire them from the compact detail page and the expanded pane in `lib/features/monsters/presentation/views/monsters_page.dart` and related views.
- [X] T023 [P] [US3] Performance test in `test/features/monsters/presentation/views/performance_test.dart`, with a synthetic catalog of 300 entries (100 bases with 2 versions each, via `copyForTest`):
  - the list builds and a game switch settles within the frame budget;
  - `FilterMonsters` over 300 entries runs < 50 ms per query in the test VM (SC-005 margin).
- [X] T024 [US3] Parse datasets off the UI thread: `compute(...)` in `lib/features/monsters/data/datasources/asset_monster_datasource.dart` for decode + DTO validation, errors still mapped to `DatasetFormatException` / failures. Makes T023 pass together with T008.
- [X] T025 [US3] Run `tool/data/fetch_icons.py wilds` for every Wilds base and own-icon version (Guardians). Tempered and arch-tempered versions reference the base icon (research R7). Record `image` in `assets/data/wilds/monsters.json` and extend `real_datasets_test.dart` with an SC-006 check (≥ 95 % of base monsters with own image).
- [X] T026 [US3] Extend `test/features/monsters/presentation/views/accessibility_test.dart`: a version detail with the selector and inherited notes at 320 dp / 200 % text (no overflow), text contrast, tap targets.
- [ ] T027 [US3] Wilds release gate:
  - run the gates and `flutter build windows --release`;
  - update `README.md` (data status, versions, `tool/data/`);
  - commit and push;
  - manual quickstart checks 1–10 for Wilds (user);
  - merge `004-all-large-monsters` into `main` (Wilds delivered).

---

## Phase 6: Rise: Sunbreak roster (US1 + US2 + US3 data)

**Goal**: the full Rise roster with versions, hunting info and thumbnails.

**Independent Test**: quickstart checks 1–10 for Rise (Silver Rathalos own row; Apex/Risen/Afflicted as versions).

- [ ] T028 [US1] Rise source check (research R4).
  - Apex, Risen and Primordial versions: Primordial Malzeno and similar "Variant"-class monsters keep their own rows (research R2).
  - Afflicted: Anomaly quests and afflicted materials per monster.
  - Write the result to `tool/data/rosters/rise_sunbreak.json` and summarize it in research R4.
- [ ] T029 [US1] Run `tool/data/build.py rise_sunbreak` for the roster and update `assets/data/rise_sunbreak/monsters.json`, keeping the 10 original entries.
- [ ] T030 [US2] Run HP and items extraction for Rise (afflicted HP from Anomaly quests; apex and risen from their own quest rows); update the dataset.
- [ ] T031 [US3] Run `fetch_icons.py rise_sunbreak` (Apex and Risen use their own icons; afflicted versions use the base icon).
- [ ] T032 [US1] Extend `real_datasets_test.dart` for Rise (roster coverage, SC-003, `noHp` set, SC-006). Run the gates, `flutter build windows --release`, update the README data status, commit, push. The user runs the manual checks, then merge to `main`.

---

## Phase 7: World: Iceborne roster (US1 + US2 + US3 data)

**Goal**: the full World roster with tempered and arch-tempered versions, hunting info and thumbnails.

**Independent Test**: quickstart checks 1–10 for World (Ruiner Nergigante own row; Arch-Tempered versions).

- [ ] T033 [US1] World source check (research R4): tempered and arch-tempered quests and rewards (streamstones) per monster in Kiranico. Write the result to `tool/data/rosters/world_iceborne.json` and summarize it in research R4.
- [ ] T034 [US1] Run `tool/data/build.py world_iceborne` for the roster (weakness stars from mhw-db.com as in 001) and update `assets/data/world_iceborne/monsters.json`, keeping the 10 original entries.
- [ ] T035 [US2] Run HP (expeditions / quests, 003 R1) and items extraction for World; update the dataset.
- [ ] T036 [US3] Run `fetch_icons.py world_iceborne`.
- [ ] T037 [US1] Extend `real_datasets_test.dart` for World (roster coverage, SC-003, `noHp` set, SC-006). Run the gates, `flutter build windows --release`, update the README, commit, push. The user runs the manual checks, then merge to `main`.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [ ] T038 Measure the app size (`flutter build apk --release --analyze-size` or the Windows build folder) and the list-open time on a phone. Record both in `specs/004-all-large-monsters/research.md` (R6 results).
- [ ] T039 SC-002 spot check: 10 new monsters per game compared with their `sources`. Fix data only in `tool/data/` and rebuild.

---

## Dependencies & Execution Order

- Setup (T001–T002) → Foundational (T003–T012) → Wilds phases: US1 (T013–T016), then US2
  (T017–T018), then US3 (T019–T027).
- US3's UI tasks (T019–T024) depend only on the Foundational phase and can run in parallel with
  T013–T018. The icons (T025) need the Wilds roster (T013).
- Rise (T028–T032) starts after the Wilds merge (T027). World (T033–T037) starts after the Rise
  merge.
- Polish (T038–T039) runs after World.
- Data tasks of the same game edit the same JSON file, so they run one after another.

## Parallel Example

```text
T003 DTO tests ‖ T004 mapper tests ‖ T005 domain types ‖ T007 use-case tests
T019 list-row tests ‖ T020 selector/detail tests ‖ T023 performance test
T013–T018 (Wilds data) ‖ T019–T024 (UI)
```

## Implementation Strategy

- **MVP**: Phases 1–5, meaning the full Wilds roster with versions, hunting info, thumbnails and
  the new list and detail, merged to `main`.
- **Then**: Rise and World as data-only increments on the same code, each merged when complete.
- **Every phase** ends with the gates green and a commit.
