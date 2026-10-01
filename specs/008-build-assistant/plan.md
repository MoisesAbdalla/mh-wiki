# Implementation Plan: Assistente de builds da Rise: Sunbreak

**Branch**: `008-build-assistant` | **Date**: 2026-10-01 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/008-build-assistant/spec.md`

## Summary

Turn on the Assistente area: the hunter says where they are in the game and which weapon type
they use, and sees curated builds for now and next. Builds can be opened and saved.

- **Data**: `tool/data/build_rise_builds.py` reads the Game8 build pages of the 14 weapon types
  (Master Rank, plus High and Low Rank from base Rise) and writes
  `assets/data/rise_sunbreak/builds.json` (research R1–R4). It also writes an import report of
  unmatched items.
- **App**: a new `assistant` feature (domain, data, presentation) with:
  - the progress picker, persisted;
  - the "Para agora" and "Próximas" list (mockup option A);
  - the build detail cards;
  - Minhas builds (save, rename, delete), stored on the device with the existing
    `shared_preferences`.
- **Links**: weapons, pieces, skills and decorations open their detail in Armas and Armaduras
  through app-layer callbacks.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged). Data tooling: Python 3 (stdlib).

**Primary Dependencies**: none added. `shared_preferences` is already used by the settings.

**Storage**:
- new asset `builds.json`, estimated 0.5–1 MB;
- on the device: the progress and the saved builds, under preferences keys.

**Testing**: unit (stage scale, split, sums), DTO, real-dataset, repositories (with in-memory
preferences), widget, accessibility; the integration flow is extended.

**Target Platform**: Android, tablet, web, Windows (unchanged).

**Project Type**: cross-platform client app.

**Performance Goals**: the list appears in ≤ 1 s; about 400 builds in total.

**Constraints**:
- offline;
- the builds dataset loads lazily and independently;
- no new packages.

**Scale/Scope**:
- 1 new feature module (~20 files);
- 1 Python builder;
- the Game8 pages: 14 Master Rank, plus about 26 High and Low Rank.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | `assistant` with domain / data / presentation; links to Armas and Armaduras only in `lib/app/` | ✅ | ✅ |
| II. MVC | `AssistantController`; split and sums in domain use cases | ✅ | ✅ |
| III. Dependency rule / DI | `BuildRepository`, `SavedBuildsRepository` and `AssistantPrefsRepository` abstractions; wiring in `AppDependencies` | ✅ | ✅ |
| IV. Offline, versioned data | `builds.json` with `schemaVersion` 1 and a source per build; saved data versioned | ✅ | ✅ |
| V. Multi-game | ids and data per game; Rise only | ✅ | ✅ |
| VI. Tests | research R6 | ✅ | ✅ |
| VII. i18n, lints | strings in ARB; build names kept as in the source; item names in en and pt-BR | ✅ | ✅ |
| New packages justified | none | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/008-build-assistant/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/approved.html
└── checklists/requirements.md
```

### Source Code (changes)

```text
tool/data/
├── build_rise_builds.py           # NEW: Game8 pages → builds.json + report
└── README.md
assets/data/rise_sunbreak/builds.json   # NEW
lib/
├── app/
│   ├── app_shell.dart             # Assistente enabled (AppArea.assistant)
│   ├── app_home.dart              # + AssistantPage, links to Armas / Armaduras
│   └── di/app_dependencies.dart   # + build, saved-build and prefs repositories, controller
├── features/assistant/            # NEW
│   ├── domain/                    # progress, curated_build, saved_build, use cases, repositories
│   ├── data/                      # dto (+ validation), asset datasource, prefs-backed repositories
│   └── presentation/              # controller, assistant_page (tabs), progress picker, build
│                                  # card and list, build detail, saved builds
└── l10n/app_pt.arb
test/ … mirrors the above
```

**Structure Decision**: a new feature module, like `armor`. The builds carry their own item names
(research R4), so the assistant does not depend on the weapons or armor datasets. Links to them go
through `lib/app/`.

## Complexity Tracking

No violations.
