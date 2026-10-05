---

description: "Task list for 009 Otimizador de builds (Montar build)"
---

# Tasks: Otimizador de builds (Montar build)

**Input**: Design documents from `specs/009-build-optimizer/` ([plan.md](plan.md),
[spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md),
[contracts/ui-contract.md](contracts/ui-contract.md), [quickstart.md](quickstart.md)).

**Tests**: mandatory (constitution VI). Each story writes its tests before its implementation.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (data)

- [ ] T001 Write `tool/data/build_rise_optimizer.py` per research R2 and data-model.md.
  - It reads `assets/data/rise_sunbreak/armor.json` and `weapons.json`.
  - It writes `assets/data/rise_sunbreak/optimizer.json` with skills (max), decorations (slot,
    skill, points), pieces (part, rarity, slots, defense, skills) and weapons (type, rarity, slots,
    attack, image).
  - It checks the references, and prints counts and the file size.

  Register the asset in `pubspec.yaml` and run the script.
- [ ] T002 [P] Add the ARB strings of data-model.md › Localisation, then run `flutter gen-l10n`.

---

## Phase 2: Foundational (domain and data)

- [ ] T003 [P] Write the domain tests in `test/features/assistant/optimizer/domain/`, with small
  fixtures in `test/fakes/optimizer_fixtures.dart`:
  - `maxRarityFor` for every progress step (research R3);
  - capped skill sums;
  - pareto pruning per part (dominated pieces dropped, identical profiles kept as alternatives,
    highest defense first);
  - the exact decoration check:
    - a +2 jewel in a level-4 slot;
    - a level-3 jewel that does not fit a level-2 slot;
    - an infeasible deficit;
    - jewels placed in the smallest slot that fits;
  - the search:
    - finds a known complete set in a fixture;
    - "quase" results when nothing is complete;
    - ranking (complete → deficit → free slots → defense);
    - dedupe;
    - at most 10 results;
    - a fixed weapon;
    - talismans plus "none";
    - only-my-progress on and off;
  - `suggestSkills` (top 8, excludes chosen skills);
  - `BuildSet.toCuratedBuild` (name, stage, decorations per item, skills, source).
- [ ] T004 Implement the domain in `lib/features/assistant/domain/optimizer/` so that T003 passes:
  - the entities;
  - `BuildRequest`, `UserTalisman`, `maxRarityFor`;
  - pruning, the DP search, the decoration check and ranking (research R4), with an `onProgress`
    callback and a cooperative cancel check;
  - `suggestSkills`, `toCuratedBuild`;
  - the repository and `BuildSearcher` interfaces.
- [ ] T005 [P] Write the data tests:
  - the DTO: version and game, unique ids, known references, slots 0–4, parts and types;
  - the repositories, with `SharedPreferences.setMockInitialValues`:
    - talismans save, edit and delete, and survive a new instance;
    - the request survives too;
    - corrupt values fall back to empty or the defaults;
  - the searcher returns the same results as `SearchBuilds` and can be cancelled.
- [ ] T006 Implement the data layer:
  - `optimizer_json.dart` (`readOptimizerDataset`);
  - `AssetOptimizerRepository` (lazy, `compute`, cached);
  - `PrefsTalismanRepository`, `PrefsRequestRepository`;
  - `IsolateBuildSearcher` (spawn, progress stream, kill), with a main-isolate fallback for web.
- [ ] T007 [P] Write the real-data tests in `test/features/assistant/optimizer/real_optimizer_test.dart`:
  - the dataset loads, with the counts of R1;
  - **SC-001**: 20 requests (types, ranks, 2–6 skills), where every result's skills are recomputed
    from pieces, talisman and decorations and must match, and every decoration must fit its slot;
  - **SC-003**: for every Master and Post curated build of 008, request its skill levels with its
    weapon and no talisman; at least 95 % must give "complete";
  - the M6★ Espadão request (Reforço de Ataque 7, Olho Crítico 7, Reforço Crítico 3, Explor. de
    Fraqueza 3) gives a complete result;
  - a benchmark that prints the time per request; the slowest must be ≤ 10 s on the dev machine,
    and the phone check is in T024.

  If SC-002 or SC-003 fails, apply the R4 fallbacks and record them in research.md.

**Checkpoint**: the optimizer works and is verified without UI.

---

## Phase 3: User Story 1 - Montar uma build pelas habilidades (Priority: P1) 🎯 MVP

- [ ] T008 [P] [US1] Write the `OptimizerController` tests in `test/features/assistant/optimizer/`:
  - it loads the catalog lazily on first visit, with a failure and retry;
  - add, adjust (1..max) and remove skills;
  - the suggestions come from the curated builds;
  - the toggles, and the request persisted and restored;
  - search states (searching with a count, results, no sets);
  - cancel;
  - results are cleared when the progress, type or skills change.
- [ ] T009 [US1] Implement `OptimizerController` in `lib/features/assistant/presentation/`. It reads
  the progress and type from `AssistantController`. Wire it in `lib/app/di/app_dependencies.dart`
  and `main.dart`, and link the name language.
- [ ] T010 [P] [US1] Write the widget tests:
  - the Montar build tab is enabled, and the strip's "alterar" goes to Recomendadas;
  - search and add a skill, the steppers and pips, remove;
  - the suggestion chips;
  - card 2 rows and switches;
  - the button disabled with no skills;
  - "procurando…" with Cancelar;
  - result cards (seal, part icons, "7/7" and red shortfalls, defense, free slots);
  - the no-sets message.
- [ ] T011 [US1] Implement:
  - `build_request_view.dart` (screen 1);
  - `build_results_list.dart` (screen 3);
  - the searching overlay;
  - enable the tab in `assistant_page.dart`, removing "em breve".

  Update the 008 tests that expected "em breve".

**Checkpoint**: MVP. Pick skills and see correct results.

---

## Phase 4: User Story 2 - Ver e salvar um resultado (Priority: P2)

- [ ] T012 [P] [US2] Write the tests for `build_result_detail.dart`:
  - the Habilidades pedidas pips, with missing levels red and the semantics;
  - "Também vem";
  - the equipment rows with icons and tiles (as in 008);
  - Joias totals;
  - "‹ 1 de N ›" navigation;
  - save gives the feedback and appears in Minhas builds with the default name;
  - item taps call `onOpen`.
- [ ] T013 [US2] Extract the 008 equipment rows and decoration tiles from `build_detail_view.dart`
  into `views/widgets/equipment_rows.dart`, with 008 behaviour unchanged (its tests pass). Then
  implement `build_result_detail.dart` (compact route and expanded pane) and saving through
  `AssistantController.save`.

---

## Phase 5: User Story 3 - Meus talismãs (Priority: P3)

- [ ] T014 [P] [US3] Write the tests:
  - the talisman list and its empty state;
  - the form (skill pickers with levels up to max, optional second skill, three slot choices
    –/1–4), save, edit and delete with a confirmation;
  - "gerenciar" opens the page;
  - the count and the "usar meus talismãs" switch on screen 1;
  - the search uses a registered talisman (controller test with fakes).
- [ ] T015 [US3] Implement `talismans_page.dart`, the form, and the talisman actions in
  `OptimizerController`.

---

## Phase 6: User Story 4 - Fixar a arma (Priority: P4)

- [ ] T016 [P] [US4] Write the tests:
  - the weapon picker lists weapons of the type within the progress (or all when the filter is
    off), with search and "Qualquer";
  - a fixed weapon shows on card 2 and every result uses it.
- [ ] T017 [US4] Implement the weapon picker sheet and the fixed weapon in the controller and
  request.

---

## Phase 7: Polish

- [ ] T018 [P] Write the accessibility tests: 320 dp at 200 % on screens 1–4; tap targets; the
  semantics of steppers, pips and seals.
- [ ] T019 [P] Extend `integration_test/app_test.dart`: Montar build → M6★ Espadão → 4 skills →
  results → open → save → Minhas builds, with prefs mocked.
- [ ] T020 Spot check: 5 results checked by hand against the wiki or game data (skills, slots,
  jewels). Record them in research.md.
- [ ] T021 Update `README.md` (Montar build, the optimizer, the talismans, the rarity limitation)
  and `tool/data/README.md`.
- [ ] T022 Run the gates (analyze, format, test, integration on Windows, build Windows release) and
  commit.
- [ ] T023 Measure the search on an Android device or emulator (release) for the 20 test requests,
  and record the timings (SC-002).
- [ ] T024 The user runs the quickstart checks 1–9. Fix the findings, then merge
  `009-build-optimizer` into `main`.

---

## Dependencies & Execution Order

- **Setup (T001–T002)**: T001 first; T002 runs in parallel.
- **Foundational (T003–T007)**: the tests come before their implementation. T007 needs T001, T004
  and T006. This phase blocks every story.
- **US1 → US2**: the detail opens from the results.
- **US3 and US4** need only US1, and can go in either order.
- **Polish** comes after all stories.

## Parallel Opportunities

- T002 alongside T001; T003 and T005 together (different folders).
- T012, T014 and T016 tests can be written in parallel once US1 is done.
- T018 and T019 together.

## Implementation Strategy

1. **Data and algorithm first** (T001–T007), verified on real data before any UI. This is the
   riskiest part (performance and correctness).
2. **MVP (US1)**: request → results.
3. **US2** detail and save; **US3** talismans; **US4** fixed weapon.
4. **Polish**: accessibility, integration, spot check, README, Android timing, the user's checks,
   then merge.
