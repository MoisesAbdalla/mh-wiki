---

description: "Task list for 008 Assistente de builds da Rise: Sunbreak"
---

# Tasks: Assistente de builds da Rise: Sunbreak

**Input**: Design documents from `specs/008-build-assistant/` ([plan.md](plan.md),
[spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md),
[contracts/ui-contract.md](contracts/ui-contract.md), [quickstart.md](quickstart.md)).

**Tests**: mandatory (constitution VI). Each story writes its tests before its implementation.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (data)

- [X] T001 Write `tool/data/build_rise_builds.py` per research R1–R4:
  - it fetches, slowly and cached, the 14 Master Rank pages and the High/Low Rank pages, classified by `<title>`;
  - it parses each build (weapon, decorations per slot, pieces with alternatives, talisman, skills, Rampage);
  - it maps the stage (R3), checking the HR thresholds against the wiki;
  - it matches names against `weapons.json` and `armor.json`, taking the ids, the en/pt-BR names and the skill max levels from them;
  - it writes `assets/data/rise_sunbreak/builds.json` and `tool/data/.cache/rise_builds_report.txt`.

  Run it.
- [X] T002 Add the script to `tool/data/README.md`, and record the counts per type and rank and the match rate in research.md. Commit the data separately.
- [X] T003 [P] Add the ARB strings of data-model.md › Localisation, then run `flutter gen-l10n`.

## Phase 2: Foundational

- [X] T004 [P] Write the domain tests in `test/features/assistant/domain/`:
  - the `Progress` scale and parsing (Baixo < Alto < Mestre < Pós-jogo; M6 < MR 10);
  - `SplitBuilds` (now ≤ progress, latest first; next > progress, nearest first);
  - `TotalDecorations`;
  - skill pips data.

  Add fixtures in `test/fakes/build_fixtures.dart`.
- [X] T005 Implement the entities and use cases in `lib/features/assistant/domain/` so that T004 passes.
- [X] T006 [P] Write the DTO tests: version and game; unique ids; a known type; a stage that fits its rank; distinct parts; refs with and without ids.
- [X] T007 Implement the data layer: the DTO, the asset datasource (`compute`), `BuildRepository` and its impl, and `LoadBuildCatalog`.
- [X] T008 [P] Write the repository tests with `SharedPreferences.setMockInitialValues`: save, rename and delete a build, and keep it after a new repository instance; save and load the progress and type; a corrupt value falls back to empty.
- [X] T009 Implement `SavedBuildsRepository` and `AssistantPrefsRepository` (prefs-backed, versioned JSON).
- [X] T010 [P] Write the real-dataset test `test/features/assistant/data/real_builds_dataset_test.dart`:
  - Master Rank builds for all 14 types;
  - "Kamura Warrior Cleaver Raw Affinity" at M1★ with Hunter's Helm X;
  - "Fine Kamura Cleaver Dereliction Strongarm" with the waist alternative and Attack Boost 7;
  - ≥ 95 % of the refs with an id (SC-002).
- [X] T011 Wire DI, enable Assistente in `AppShell` (`AppArea.assistant`, built on its first visit), and update `app_shell_test.dart`.

## Phase 3: User Story 1 - Builds para onde estou (P1) 🎯 MVP

- [X] T012 [P] [US1] Write the controller tests:
  - loading, then failure and retry;
  - the progress and type, persisted and restored;
  - the now/next lists recomputed;
  - the tabs, with "Montar build" disabled.
- [X] T013 [US1] Implement `AssistantController`.
- [X] T014 [P] [US1] Write the widget tests for `assistant_page.dart`:
  - the tabs, with Montar build reading "em breve";
  - the progress card: rank tabs and step chips, with the chosen one marked;
  - the type picker;
  - the Para agora and Próximas sections, with dimmed next cards and "A partir de …";
  - the empty state.
- [X] T015 [US1] Implement `assistant_page.dart` (tabs; list plus detail pane from 840 dp), `progress_picker.dart`, `build_card.dart` and `recommended_list.dart`.

## Phase 4: User Story 2 - Ver a build inteira (P2)

- [X] T016 [P] [US2] Write the tests for `build_detail_view.dart`:
  - the header;
  - Equipamento rows per part, with decorations, "ou …" alternatives, the talisman requirement, and the "não encontrado no catálogo" mark;
  - Habilidades pips, with a tap to the skill;
  - Joias totals;
  - the source link;
  - item taps calling the `onOpen…` callbacks.
- [X] T017 [US2] Implement the build detail and its compact page. Wire the links in `lib/app/app_home.dart`:
  - weapon → Armas;
  - piece, skill and decoration → Armaduras.

## Phase 5: User Story 3 - Minhas builds (P3)

- [X] T018 [P] [US3] Write the tests:
  - save from the detail (a "Salva" feedback);
  - the Minhas builds list (name, stage, "baseada em", date);
  - rename and delete, with a confirmation;
  - the empty state;
  - a saved build opens the same detail.
- [X] T019 [US3] Implement `saved_builds_list.dart`, the save, rename and delete actions in the controller and detail, and the dialogs.

## Phase 6: Polish

- [X] T020 [P] Write the accessibility tests: 320 dp / 200 % on the list, detail and saved builds; contrast; tap targets.
- [X] T021 [P] Extend `integration_test/app_test.dart`: Assistente → Mestre M2★ → Espadão → open a build → save it → it shows in Minhas builds.
- [ ] T022 SC-002 spot check: 10 builds of different types against their Game8 pages. Fix any finding in the builder, and record it in research.md.
- [ ] T023 Update `README.md` (the Assistente area, the Game8 credit, counts).
- [ ] T024 Run the gates (analyze, format, test, integration on Windows, build Windows release) and commit.
- [ ] T025 The user runs the quickstart checks 1–8. Fix the findings, then merge `008-build-assistant` into `main`.

---

## Dependencies & Execution Order

- **Setup (T001–T003)**: T001 → T002; T003 runs in parallel.
- **Foundational (T004–T011)**: tests come before their implementation. T010 needs T001. Blocks every story.
- **US1 → US2 → US3**: the detail opens from the list, and saving comes from the detail.
- **Polish** comes after all stories.

## Implementation Strategy

1. **Data first**: build and check `builds.json` and the import report.
2. **MVP (US1)**: the Assistente with the progress picker and the list.
3. **US2**: the detail. **US3**: Minhas builds.
4. **Polish**: accessibility, integration, spot check, README, the user's checks, then merge.
