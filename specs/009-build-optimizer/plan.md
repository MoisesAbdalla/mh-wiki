# Implementation Plan: Otimizador de builds (Montar build)

**Branch**: `009-build-optimizer` | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/009-build-optimizer/spec.md`

## Summary

Enable the Assistente's Montar build tab. The hunter picks skills and levels, registers their
talismans, and the app finds offline the weapon, pieces, talisman and decorations that reach the
request within their progress.

- **Data**: `tool/data/build_rise_optimizer.py` writes a compact
  `assets/data/rise_sunbreak/optimizer.json` (about 1 MB) from `armor.json` and `weapons.json`
  (research R2).
- **Search**: a pure-Dart algorithm in `domain` (research R4):
  1. pareto pruning per part;
  2. dynamic programming over the capped wanted-skill vector and the free slots;
  3. an exact decoration check;
  4. ranking.

  It runs in a background isolate and can be cancelled.
- **App**:
  - the `assistant` feature gains the request screen, Meus talismãs, the results list and the
    result detail;
  - the 008 equipment rows are reused;
  - a result is saved as a 008 `SavedBuild`;
  - the progress and weapon type stay shared with Recomendadas.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged). Data tooling: Python 3.

**Primary Dependencies**: none added. `dart:isolate` handles the search, and `shared_preferences`
(already present) keeps the talismans and the request.

**Storage**:
- a new asset, `optimizer.json`;
- preferences keys for the talismans and the request (research R6).

**Testing**:
- domain unit tests for sums, pruning, the decoration check and ranking;
- an SC-001 property test on the real data;
- an SC-003 test over the curated builds;
- a benchmark;
- widget, accessibility and integration tests.

**Target Platform**: Android, tablet, web, Windows (unchanged). On web, isolates are not available,
so the search runs on the main isolate in time slices, with the same interface.

**Project Type**: cross-platform client app.

**Performance Goals**: results for up to 5 skills in ≤ 10 s on a mid-range phone, with the UI
responsive (spec SC-002).

**Constraints**:
- offline;
- no new packages;
- the optimizer dataset loads lazily, only when Montar build opens;
- other areas are unaffected by its failure.

**Scale/Scope**:
- about 15 new files in `assistant`;
- 1 Python builder;
- 1 asset.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | Optimizer domain (catalog, request, search) is pure Dart in `assistant/domain`; data has the DTO, asset repository, prefs repositories and isolate runner | ✅ | ✅ |
| II. MVC | `OptimizerController` uses use cases (`LoadOptimizerCatalog`, `SearchBuilds` via `BuildSearcher`, talisman CRUD); views have no logic | ✅ | ✅ |
| III. Dependency rule / DI | `OptimizerRepository`, `TalismanRepository`, `RequestRepository` and `BuildSearcher` abstractions, wired in `AppDependencies` | ✅ | ✅ |
| IV. Offline, versioned data | `optimizer.json` with `schemaVersion` 1, derived from the versioned datasets; saved data versioned | ✅ | ✅ |
| V. Multi-game | catalog and rarity table per game; Rise only | ✅ | ✅ |
| VI. Tests | research R7 | ✅ | ✅ |
| VII. i18n, lints | strings in ARB; names in en and pt-BR from the catalog | ✅ | ✅ |
| New packages justified | none | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/009-build-optimizer/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/approved.html
└── checklists/requirements.md
```

### Source Code (changes)

```text
tool/data/build_rise_optimizer.py          # NEW: armor + weapons → optimizer.json
assets/data/rise_sunbreak/optimizer.json   # NEW
lib/
├── app/di/app_dependencies.dart           # + optimizer, talisman, request repositories,
│                                          #   searcher, OptimizerController
├── app/app_home.dart                      # passes the optimizer to AssistantPage; weapon links
├── features/assistant/
│   ├── domain/optimizer/                  # NEW: catalog entities, request, rarity table,
│   │                                      #   pruning, DP search, decoration check, ranking,
│   │                                      #   suggestions, BuildSet → CuratedBuild
│   ├── data/                              # + optimizer DTO, asset repository, prefs
│   │                                      #   repositories, isolate searcher
│   └── presentation/
│       ├── optimizer_controller.dart      # NEW
│       └── views/                         # + build_request_view, talismans_page,
│                                          #   build_results_list, build_result_detail; the
│                                          #   008 equipment rows extracted for reuse
└── l10n/app_pt.arb
test/features/assistant/optimizer/ …       # domain, data, real-data (SC-001/003), benchmark,
                                           # controller, widgets
```

**Structure Decision**: the optimizer lives inside the `assistant` feature, because it shares the
progress, the tabs and the saved builds. It has its own sub-folder in `domain`, so it stays readable.
The equipment rows of `build_detail_view.dart` move to a shared widget file, used by both details.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|------|------------|--------------------------------------|
| Dynamic programming with pareto states (R4) | The full space is about 10¹² sets at rarity 10 | Brute force or greedy is too slow or misses sets (SC-002, SC-003) |
| Isolate runner with a web fallback | The UI must stay responsive and cancellable (FR-010) | Running on the main isolate would freeze the UI for seconds |
