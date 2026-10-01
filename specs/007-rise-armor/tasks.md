---

description: "Task list for 007 Armaduras, habilidades e joias da Rise: Sunbreak"
---

# Tasks: Armaduras, habilidades e joias da Rise: Sunbreak

**Input**: Design documents from `specs/007-rise-armor/` ([plan.md](plan.md),
[spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md),
[contracts/ui-contract.md](contracts/ui-contract.md), [quickstart.md](quickstart.md)).

**Tests**: mandatory (constitution VI). Each story writes its tests before its implementation.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (data)

- [X] T001 Move the item-page source logic of `tool/data/build_rise_weapons.py` (`_item_rows`, `material_sources`, `RANKS`) to `tool/data/kiranico_items.py`, and import it from the weapons builder. Rebuilding `weapons.json` must give the same file (diff check).
- [ ] T002 Write `tool/data/fetch_rise_armor_pages.py`. It caches, with 4 workers and resuming:
  - the Kiranico armor lists `/data/armors?view=0..9` (en and pt-BR);
  - every armor page `/data/armors/<id>`;
  - the skills, decorations, Rampage skills and Rampage decorations lists (en and pt-BR);
  - every decoration page.

  Run it.
- [ ] T003 Write `tool/data/build_rise_armor.py` per research R1–R4 and R7:
  - pieces from the lists, with resistances read by element icon and slots from the deco icons;
  - skills by Kiranico id;
  - materials from the armor pages;
  - set, body part and max defense from wiki redirects and set pages, cached;
  - pt-BR set names by common suffix;
  - skills, decorations and materials with sources (`kiranico_items`), new item pages fetched with `fetch_rise_item_pages.py`;
  - `--icons` for the male renders at 96 px WebP.

  It writes `assets/data/rise_sunbreak/armor.json` and a report of dropped and unmatched pieces.
- [X] T004 Extend `tool/data/build_rise_weapons.py` with the Rampage data (research R6): the `rampageSkills` table, `rampageDecorations`, and `rampageSkills` ids per Low/High Rank weapon (from the cached weapon pages). Rebuild `weapons.json`.
- [ ] T005 Register `assets/images/armor/rise_sunbreak/` in `pubspec.yaml`, add the scripts to `tool/data/README.md`, and write `assets/images/armor/SOURCES.md`. Commit the data and icons separately from the code.
- [X] T006 [P] Add the ARB strings of data-model.md › Localisation, then run `flutter gen-l10n`.

## Phase 2: Foundational

- [X] T007 Move `MaterialSources` and its sources, `RankedSources` and `MaterialCost` from `lib/features/weapons/domain/entities/` to `lib/core/domain/`. Move the material row with seals and the rates table from `weapon_materials_section.dart` to `lib/core/presentation/widgets/material_cost_row.dart`, parameterized by name, amount, sources, droppers and rank. Weapons import them from core. All existing tests stay green.
- [ ] T008 [P] Write tests for the armor domain in `test/features/armor/domain/`: `SumSetSkills` (sums, max, overflow, order), `FilterSets` (rank, text in en and pt-BR, skill) and `SkillSources` (decorations and pieces, master rank first). Add fixtures in `test/fakes/armor_fixtures.dart`.
- [ ] T009 Implement the entities and use cases in `lib/features/armor/domain/` so that T008 passes.
- [ ] T010 [P] Write DTO and mapper tests in `test/features/armor/data/armor_dataset_dto_test.dart`. Cover the data-model validation rules: unique ids, references that resolve, part order, levels within the max, slots, and maxDefense ≥ defense.
- [ ] T011 Implement the data layer: DTO, mapper, asset datasource (with `compute`), `ArmorRepository` and its impl, and `LoadArmorCatalog`.
- [ ] T012 [P] Write the real-dataset test `test/features/armor/data/real_armor_dataset_test.dart`. It checks:
  - the counts per rarity from the T003 report;
  - every piece in one set, and every reference resolved;
  - Rathalos X = 570 → 870 with resistances 15/5/−10/5/−15 and skills Attack Boost 7, Earplugs 5, Partbreaker 3, Windproof 3 and Critical Boost 2;
  - the Elmo materials include Heavy Rathalos Scrap;
  - Attack Boost has 7 levels and the decorations Attack Jewel 2 and 4;
  - ≥ 90 % of the pieces have an icon.
- [ ] T013 Wire DI (`armorRepository`, `createArmorController`), enable Armaduras in `AppShell` (`AppArea.armor`, built on its first visit), and update `test/app/app_shell_test.dart`.

## Phase 3: User Story 1 - Conjuntos (P1) 🎯 MVP

- [ ] T014 [P] [US1] Write the controller tests: loading, failure and retry; the tabs; rank, text and skill-seal filters; state kept per tab.
- [ ] T015 [US1] Implement `ArmorController` and its state.
- [ ] T016 [P] [US1] Write the widget tests for `armor_page.dart` and the set list:
  - the tabs and the rank tabs;
  - search with skill suggestions, and the removable seal;
  - set cards with piece rows in part order, slot gems, skills and the footer sum (chosen skill first);
  - the empty and failure states.
- [ ] T017 [US1] Implement `armor_page.dart` (tabs; list plus detail pane from 840 dp), `set_list_pane.dart` and `armor_set_card.dart`.
- [ ] T018 [P] [US1] Add tests for accessibility (320 dp / 200 %, contrast, tap targets) and performance (2,000 synthetic pieces; a filter takes < 50 ms).

## Phase 4: User Story 2 - Detalhe do conjunto (P2)

- [ ] T019 [P] [US2] Write the tests for `armor_set_detail_view.dart`:
  - the header;
  - the Defesa card with base → max and the resistances (negatives in the error colour, semantics);
  - the Habilidades card with pips, overflow and a tap to the skill;
  - the Peças card: a tap expands the materials with seals and rates, and a large-monster seal calls `onOpenMonster`.
- [ ] T020 [US2] Implement the set detail with the cards Defesa, Habilidades and Peças, the `skill_pips.dart` and `resistance_row.dart` widgets, and the compact detail page. Wire monster links for armor materials in `lib/app/app_home.dart`.

## Phase 5: User Story 3 - Habilidades e joias (P3)

- [ ] T021 [P] [US3] Write the tests:
  - the skills tab: search, and rows with the max level;
  - the skill detail: levels, decorations with slot gems, pieces grouped by rank with "Ver todas", and taps to a decoration or set;
  - the decorations tab: slot filter and search;
  - the decoration detail: the skill link and the materials.
- [ ] T022 [US3] Implement `skill_list_pane.dart`, `skill_detail_view.dart`, `decoration_list_pane.dart` and `decoration_detail_view.dart`, with navigation between set, skill and decoration in the controller.

## Phase 6: User Story 4 - Rampage na arma (P4)

- [ ] T023 [P] [US4] Write the weapons DTO tests (rampage tables and ids, unknown id rejected) and widget tests for `weapon_rampage_section.dart`: High Rank options, a Master Rank slot with fitting decorations, and hidden when there is none.
- [ ] T024 [US4] Implement the Rampage entities, DTO, mapper and the card in the weapon detail. Extend the weapons real-dataset test: Kamura C. Blade V has its three options, and every Master Rank weapon has none.

## Phase 7: Polish

- [ ] T025 [P] Extend `integration_test/app_test.dart`: Armaduras → Mestre → search "Reforço de Ataque" → Rathalos X → skill → decoration.
- [ ] T026 [P] Update `README.md` (the Armaduras area, sources, counts and APK size) and record the T003 results and the spot check in research.md.
- [ ] T027 SC-002 spot check: 20 pieces (2 per rarity), 10 skills and 10 decorations against Kiranico and the wiki. Fix any finding in the builder.
- [ ] T028 Gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`, integration on Windows, `flutter build windows --release`) and commit.
- [ ] T029 The user runs the quickstart checks 1–10. Fix the findings, then merge `007-rise-armor` into `main`.

---

## Dependencies & Execution Order

- **Setup (T001–T006)**: T001 → T003; T002 → T003; T004 after T001; T005 after T003; T006 is parallel.
- **Foundational (T007–T013)**: T007 first (shared move). T008/T010 tests come before T009/T011. T012 needs T003. Blocks every story.
- **US1 → US2 → US3**: US2 and US3 open from the US1 list. US4 is independent of the armor UI and only needs T004 and T007.
- **Polish** comes after all stories.

## Parallel Example

```text
Foundational: T008 domain tests ‖ T010 DTO tests ‖ T012 real-dataset test
US1:          T014 controller test ‖ T016 widget tests ‖ T018 a11y/perf
US4:          can run alongside US2/US3
```

## Implementation Strategy

1. **Data first**: build and check `armor.json` and the Rampage data.
2. **MVP (US1)**: the Conjuntos list with the area enabled. Run the gates and show the user.
3. **US2**: the set detail. **US3**: skills and decorations. **US4**: Rampage.
4. **Polish**: integration, README, spot check, the user's manual checks, then merge.
