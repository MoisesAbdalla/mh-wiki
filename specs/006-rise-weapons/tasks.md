---
description: "Task list for feature 006: Armas da Rise: Sunbreak"
---

# Tasks: Armas da Rise: Sunbreak

**Input**: Design documents from `specs/006-rise-weapons/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ui-contract.md](contracts/ui-contract.md),
[quickstart.md](quickstart.md), approved mockup [mockups/approved.html](mockups/approved.html)

**Tests**: required by the constitution (VI). Domain use cases get unit tests, the dataset gets
DTO/mapper and real-data tests, and the views get widget, accessibility and performance tests.
Write the test before its implementation where it pins behaviour.

**Organization**: by user story (spec.md), so each story can be implemented and checked alone.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: US1, US2 or US3

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: the weapon data and the strings every story needs.

- [X] T001 Create `tool/data/build_rise_weapons.py` (research R1–R3, R5, R6), using `common.fetch` / `common.wiki_api` and the cache in `tool/data/.cache/`. It must:
  - **Read the Kiranico lists.** Read the 14 Kiranico lists in en and pt-BR (`/data/weapons?view=0..13` and `/pt-BR/data/weapons?view=…`). From each row take the Kiranico id, the en and pt-BR names, the icon URL, and attack, element, affinity, slots and sharpness for the cross-check. Drop the rows with attack 0.
  - **Read the wiki pages.** List the wiki categories `MHRS <type>` (Sword & Shield is `MHRS Sword and Shield`), keeping the titles that end in `(MHRS)`. Read the pages 40 per request and parse `{{GenericWeapon}}`: type, `Tree`, rarity, description, attack, affinity, `Level N Decos`, `Elemental Damage`/`Type` (and the status fields), the `SharpnessBar` base plus the H* extension, the `Rampage Decoration` level, `Previous Name`, `Next N Name`, and the forge/upgrade materials with quantities.
  - **Join the two sources by English name** (normalized). Report the unmatched names from each side, and fail if more than 1 % of the weapons are unmatched.
  - **Compute the slugs and links.** Use the same slug rule as `build_rise.py`. Turn `previous` and `next` into slugs, and give every material an id (and a pt-BR name when the Rise monster dataset or Kiranico has one).
  - **Set the rank and stars.** Rank comes from rarity. Stars use rule R3: material → monsters in `assets/data/rise_sunbreak/monsters.json` → lowest quest star of that rank from the cached Kiranico monster pages; the weapon gets the highest of those, or 1 when no monster is involved. Store them as `{value, estimated: true}`.
  - **Write the file.** Write `assets/data/rise_sunbreak/weapons.json` exactly as in data-model.md, with `weaponTypes` (en names from Kiranico, pt-BR names from the pt-BR navigation), `materials`, `sources` and `starRule`.
- [X] T002 Add `--icons` to `tool/data/build_rise_weapons.py`:
  - download each Kiranico weapon icon (`avatar/weapons/<id>.webp`) and convert it to 96 px WebP at `assets/images/weapons/rise_sunbreak/<slug>.webp`;
  - download the 14 type icons from the wiki (`Special:FilePath/MHRS-<Type> Icon.png`, falling back to the Kiranico list header icon) into `assets/images/weapons/types/<type-id>.webp`;
  - set `image` per weapon;
  - register the folders in `pubspec.yaml`;
  - add the script to `tool/data/README.md`, and record the icon source in `assets/images/weapons/SOURCES.md`.
- [X] T003 Run `python tool/data/build_rise_weapons.py --icons`. Check the counts per type against research R1 (sum ≈ 3,925 after excluding 28), the unmatched report and the APK-size estimate. Commit the data and icons separately from the code.
- [X] T004 [P] Add the strings of data-model.md › Localisation to `lib/l10n/app_pt.arb` and run `flutter gen-l10n`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: the weapon domain, data layer and app shell that all stories use.

**⚠️ CRITICAL**: no story can start before this phase is done.

- [X] T005 [P] Create the domain entities in `lib/features/weapons/domain/entities/`, per data-model.md, with value equality where the monster entities have it:
  - `weapon_id.dart`, `weapon_type.dart`, `special_kind.dart` and `weapon_special.dart`;
  - `sharpness.dart`, with `maxUnits` = 400;
  - `material_cost.dart`, which reuses `MonsterMaterial`;
  - `estimated_stars.dart`;
  - `weapon.dart`, whose `rank` is derived from `rarity`;
  - `weapon_tree.dart` and `weapon_catalog.dart`.
- [X] T006 [P] Write unit tests in `test/features/weapons/domain/usecases/build_weapon_trees_test.dart`:
  - roots (no previous weapon in the tree) come first, ordered by rarity then name;
  - children are depth-first, with siblings by rarity then name;
  - a branch (two next weapons) gives two subtrees;
  - a weapon whose previous one is in another tree stays in its own tree as a root;
  - a cycle is reported as an error.
- [X] T007 Implement `lib/features/weapons/domain/usecases/build_weapon_trees.dart`, so that T006 passes.
- [X] T008 [P] Write unit tests in `test/features/weapons/domain/usecases/filter_weapons_test.dart`:
  - filter by type;
  - filter by rank, keeping each tree's order and dropping empty trees;
  - accent- and case-insensitive search over en and pt-BR names ("lohen", "flammen");
  - an empty result.
- [X] T009 Implement `lib/features/weapons/domain/entities/weapon_query.dart` and `lib/features/weapons/domain/usecases/filter_weapons.dart`, normalizing names once per catalog as `FilterMonsters` does, so that T008 passes.
- [X] T010 [P] Write DTO and mapper tests in `test/features/weapons/data/weapon_dataset_dto_test.dart`. Use the small JSON fixtures in `test/fakes/weapon_json_fixtures.dart` and cover every validation rule of data-model.md, including: wrong game or version; a duplicate slug; an unknown type, material or previous weapon; previous/next that disagree; sharpness on a ranged weapon; a missing sharpness on a melee weapon; and out-of-range slots. Also check that the mapper derives the rank from rarity.
- [X] T011 Implement the data layer, so that T010 passes:
  - `lib/features/weapons/data/dtos/weapon_dataset_dto.dart` (reusing `JsonReader`);
  - `weapon_dataset_mapper.dart`;
  - `lib/features/weapons/data/datasources/asset_weapon_datasource.dart`, which decodes with `compute`, as the monster datasource does;
  - `lib/features/weapons/domain/repositories/weapon_repository.dart` and `lib/features/weapons/data/repositories/weapon_repository_impl.dart`, which map errors to `Failure`;
  - `lib/features/weapons/domain/usecases/load_weapon_catalog.dart`.
- [X] T012 [P] Write the real-dataset test `test/features/weapons/data/real_weapons_dataset_test.dart`. It checks that the dataset parses, that it has 14 types, that every type count matches T003's record, that no weapon has attack 0, that every previous/next resolves, that there is no cycle, that the Anjanath Great Sword tree has 6 weapons with Gnashing Flammenzahn+ = 280 / fire 28 / −20 % / slot 3 / Rampage 2 / rarity 8 / Master, and that ≥ 95 % of the weapons have an image (SC-007).
- [X] T013 Wire DI in `lib/app/di/app_dependencies.dart`: add the `weaponRepository` and `createWeaponListController()`. Use fakes in `test/fakes/fake_weapon_repository.dart` and add weapon fixtures in `test/fakes/weapon_fixtures.dart`, with a small tree, a ranged weapon and a branch.
- [X] T014 [P] Write `test/app/app_shell_test.dart`:
  - four destinations, with Armaduras and Assistente disabled and announced as "em breve" (a tap does nothing);
  - a bottom bar below 840 dp and a rail from 840 dp;
  - switching areas keeps the monster list's search and scroll (`IndexedStack`).
- [X] T015 Create `lib/app/app_shell.dart`, styled with the 005 tokens, and point `lib/app/app.dart` `home` to it. The Monstros area is the current `MonstersPage`, and the Armas area is a placeholder until T018. Update the integration and app tests that pumped `MonstersPage` directly if needed, so that T014 passes.

**Checkpoint**: weapons load and filter in tests, and the app has its area navigation.

---

## Phase 3: User Story 1 - Consultar as armas de um tipo (Priority: P1) 🎯 MVP

**Goal**: the Armas area with game tabs, the type picker, the rank filter, search and tree cards
(spec US1).

**Independent Test**: quickstart checks 1–4 and 10.

- [X] T016 [P] [US1] Write `test/features/weapons/presentation/controllers/weapon_list_controller_test.dart`. It covers the states: loading → loaded (the first type selected), failure → retry, and type / rank / search changes recomputing the visible trees. It also checks that the query survives a reload.
- [X] T017 [US1] Implement `lib/features/weapons/presentation/controllers/weapon_list_controller.dart` and `lib/features/weapons/presentation/models/weapon_list_state.dart`, so that T016 passes. The catalog loads on the first `load()` call, which happens when the Armas area is opened.
- [X] T018 [P] [US1] Write `test/features/weapons/presentation/views/weapon_list_pane_test.dart`:
  - game tabs, with only Rise selectable and World/Wilds announced "em breve";
  - the 14-type picker, with the selected type marked and a scroll at 320 dp;
  - rank tabs;
  - the search field;
  - tree cards, with the count, the rows in tree order and the indent growing with depth;
  - rows that show attack, special (symbol + value) and affinity (negative in the error colour), and no special when there is none;
  - the empty state with "Limpar filtros";
  - the failure state with retry.
- [X] T019 [US1] Implement the list per the contract, so that T018 passes:
  - `lib/features/weapons/presentation/views/weapons_page.dart` (list only on compact screens; list plus detail pane from 840 dp, as `MonstersPage` does);
  - `lib/features/weapons/presentation/views/widgets/weapon_list_pane.dart`, `weapon_type_picker.dart`, `weapon_tree_card.dart`, `weapon_row.dart` and `weapon_special_label.dart` (reusing `ElementIcon` for elements; statuses get text plus a colour token).

  Reuse `GameTabs` for the game tabs, with a new `enabledGames` parameter for the "em breve" state, and `UnderlineTabs`, `NotebookSection` and `MonsterImage` (or a generic image plate) for the rest.
- [X] T020 [US1] Plug the Armas area into `lib/app/app_shell.dart`, replacing the placeholder: create the controller through DI and call `load()` on first visit. Extend `test/features/monsters/presentation/views/accessibility_test.dart`, or add `test/features/weapons/presentation/views/weapons_accessibility_test.dart`, with the list at 320 dp / 200 % and the contrast and tap-target guidelines.
- [X] T021 [P] [US1] Write the performance test `test/features/weapons/presentation/performance/weapons_performance_test.dart`. Using a synthetic catalog of 4,000 weapons (300 per type), check that the list builds and a type switch settles within the frame budget, and that `FilterWeapons` runs under 50 ms per query (SC-004).
- [X] T022 [US1] Run the gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`) and commit the US1 slice.

**Checkpoint**: the weapon catalog is browsable. MVP.

---

## Phase 4: User Story 2 - Ver tudo sobre uma arma (Priority: P2)

**Goal**: the weapon detail in the numbered cards Atributos, Afiação, Materiais and Árvore
(spec US2).

**Independent Test**: quickstart checks 5–7.

- [X] T023 [P] [US2] Write `test/features/weapons/presentation/views/weapon_detail_view_test.dart`:
  - the header: name, "<tipo> · Raridade n · <rank> · n★ (estimado)", the plate and the description;
  - the cards numbered 1–4 in order, and only 1, 3 and 4 for a ranged weapon;
  - Atributos: attack, special, affinity, slot level badges, the Rampage badge, and the semantics "Slots: nível 3; Rampage: nível 2";
  - Afiação: two bars whose segment widths are proportional to the units over 400, with semantics per colour;
  - Materiais: "Melhorar" and/or "Criar" groups with quantities; a material known from a monster shows "Dropado por: <monstro>" and calls `onOpenMonster`; an unknown material has no link;
  - Árvore: the previous, current (gold) and next weapons, where tapping one calls `onOpenWeapon`, and a branch shows every next weapon.
- [X] T024 [US2] Implement the detail, so that T023 passes:
  - `lib/features/weapons/presentation/views/widgets/weapon_detail_view.dart`, `weapon_attributes_section.dart`, `sharpness_bar.dart`, `slot_badges.dart`, `weapon_materials_section.dart` and `weapon_tree_section.dart`;
  - the compact page `weapon_detail_page.dart`;
  - the selection wiring in `weapon_list_controller.dart`;
  - transitions with `NotebookSwitcher`.

  The monster names for "Dropado por" come from a `MaterialSourceLookup` passed in by the app layer (Monster name and id per material), so the weapons feature does not import monsters.
- [X] T025 [US2] Create `lib/app/weapons_of_monster.dart` (research R7). It provides `MaterialSourceLookup.fromMonsters(catalog)`, which maps each material id to the Rise monsters that drop it, and `WeaponsUsingMaterialsOf(monster, weapons)`. Unit-test both in `test/app/weapons_of_monster_test.dart`.
- [X] T026 [US2] Implement "Dropado por → monstro" navigation in `lib/app/app_shell.dart`: switch to Monstros and select that monster through `MonsterListController.select`, keeping the Armas state. Cover it in `test/app/app_shell_test.dart`.
- [X] T027 [US2] Extend the accessibility tests with the detail of a melee and a ranged weapon at 320 dp / 200 % (no overflow; the attribute grid wraps to one column). Run the gates and commit the US2 slice.

**Checkpoint**: list and detail are complete.

---

## Phase 5: User Story 3 - Do monstro às armas e navegação entre áreas (Priority: P3)

**Goal**: the "Armas feitas com ele" card on Rise monsters, "Ver todas" filtering the Armas area,
and the wide-screen rail (spec US3).

**Independent Test**: quickstart checks 8, 9 and 11.

- [X] T028 [P] [US3] Write `test/features/monsters/presentation/views/widgets/monster_extra_sections_test.dart`. It checks that `MonsterDetailView` renders the cards from an optional `extraSections` builder after its own, numbered from 7, and that it renders nothing extra when the builder is null.
- [X] T029 [US3] Add the optional `extraSections` parameter to `lib/features/monsters/presentation/views/widgets/monster_detail_view.dart` (`List<Widget> Function(BuildContext, Monster, int nextNumber)?`) and pass it through `monsters_page.dart` and `monster_detail_page.dart`, so that T028 passes. Keep the monsters feature unaware of weapons.
- [X] T030 [P] [US3] Write `test/app/monster_weapons_card_test.dart`:
  - a Rise monster with weapons shows "Armas feitas com ele (n)" with at most 5 rows (name, type, rank) and "Ver todas (n)";
  - World and Wilds monsters, and monsters without weapons, show no card;
  - tapping a row opens the weapon in Armas;
  - "Ver todas" opens Armas filtered to those weapons, with a removable chip.
- [X] T031 [US3] Implement `lib/app/monster_weapons_card.dart` and wire it as the `extraSections` builder in `lib/app/app_shell.dart`. Add `WeaponQuery.onlyIds` and the removable chip to the weapon list (`weapon_list_pane.dart`, `filter_weapons.dart` with a unit test), so that T030 passes.
- [X] T032 [US3] Extend `integration_test/app_test.dart`: open Armas, choose Espada Grande, search "flammen", open Gnashing Flammenzahn+, follow "Dropado por: Anjanath", and check the "Armas feitas com ele" card. Run the gates and commit the US3 slice.

**Checkpoint**: all three stories are done.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T033 [P] Update `README.md`: the Armas area, the data sources (wiki MHRS pages, Kiranico lists, icons), the estimated-stars rule, the new data counts and the APK size.
- [X] T034 [P] Correct the mockup note: Gnashing Flammenzahn+ is rarity 8, Master Rank (research R3). Update `specs/006-rise-weapons/mockups/approved.html` labels if they mislead.
- [X] T035 Measure the release APK size (`flutter build apk --release --analyze-size --target-platform android-arm64`) and the time to open the Armas list (profile integration run). Record both in `specs/006-rise-weapons/research.md` (R6 results).
- [X] T036 SC-002 spot check: 20 weapons, at least one per type, compared field by field with their wiki and Kiranico pages. Fix the data only in `tool/data/build_rise_weapons.py`, rebuild, and record the result in research.md.
- [X] T037 Run the gates and `flutter build windows --release`, then commit and push.
- [ ] T038 Manual quickstart checks 1–14 (user). Fix the findings, then merge `006-rise-weapons` into `main`.

---

## Phase 7: User Story 4 - Dados próprios de cada tipo (Priority: P4)

**Goal**: phial, shelling, kinsect level, songs, bow shots and coatings, bowgun ammo (spec US4,
FR-014; mockup `mockups/approved-sources.html`, option B).

- [X] T039 [US4] Parse the type-specific cell of the Kiranico weapon lists (en + pt-BR, already cached) in `tool/data/build_rise_weapons.py` into a `traits` object per weapon: `phial`, `shelling`, `kinsectLevel`, `songs`, `arcShot`, `chargeShots`, `coatings`, `deviation`, `recoil`, `reload`, `ammo` (name + capacity per level). Record the rule in research.md R13.
- [X] T040 [US4] Domain `WeaponTraits` and DTO/mapper validation (types only carry their own fields), with tests in `weapon_dataset_dto_test.dart` and the real-dataset test (every Charge Blade and Switch Axe has a phial, every bow has charge shots, every bowgun has ammo).
- [X] T041 [US4] Detail: traits as extra cells of the Atributos grid (phial, shelling, kinsect, songs) and a "Munição" card for bows and bowguns; widget and accessibility tests.

## Phase 8: User Story 5 - De onde vem cada material (Priority: P5)

**Goal**: material sources beyond large monsters (spec US5, FR-015).

- [X] T042 [US5] `tool/data/fetch_rise_item_pages.py` caches the Kiranico item pages (en + pt-BR); `build_rise_weapons.py` adds `sources` per material: `gathering` (map, rank, best rate), `monsters` (name, slug when it is a large monster of the app, small flag, rank, method, rate) and `quests` (category, stars, name, rank). Record in research.md R13.
- [X] T043 [US5] Domain `MaterialSource` entities on `MonsterMaterial`'s weapon side (`WeaponMaterial.sources`), DTO/mapper with tests, and the rule "sources of the weapon's rank, else the nearest rank, labelled".
- [X] T044 [US5] Materials card option B: chips per material (gathering, large monster link, small monster, quest, unknown origin); tapping a material expands the full list with rates. Large monster links keep using the app layer (`onOpenMonster`). Widget, accessibility and app tests.
- [ ] T045 Gates, spot check of the sources of 10 materials against Kiranico, commit; the user's manual check, then merge.

---

## Dependencies & Execution Order

- **Setup (T001–T004)**: T001 → T002 → T003. T004 runs in parallel.
- **Foundational (T005–T015)**: needs the data from T003 for T012; the rest only needs T005.
  Blocks every story.
- **US1 (T016–T022)**: after Foundational. This is the MVP.
- **US2 (T023–T027)**: after US1's list (selection), with T025 before T024's "Dropado por" wiring
  test can pass end to end.
- **US3 (T028–T032)**: T028–T029 can start after Foundational; T030–T031 need T025 and the US1
  list.
- **Polish (T033–T038)**: after all stories.

## Parallel Example

```text
Foundational: T006 trees test ‖ T008 filter test ‖ T010 DTO test ‖ T014 shell test (after T005)
US1:          T016 controller test ‖ T018 list test ‖ T021 performance test
US2:          T023 detail test ‖ T025 lookup + its test
US3:          T028 extraSections test ‖ T030 card test
```

## Implementation Strategy

1. **Data first (Phase 1)**: produce and check `weapons.json`, since every story depends on its
   correctness.
2. **MVP (US1)**: the browsable catalog with the new navigation. Stop, run the gates and show the
   user.
3. **US2**: the full weapon detail.
4. **US3**: the bridges between monsters and weapons.
5. **Polish**: README, measurements, spot check, the user's manual checks, then merge.
