---

description: "Task list for 003-hunting-info implementation"
---

# Tasks: Informações de Caçada

**Input**: Design documents from `specs/003-hunting-info/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ui-hunting-info.md](contracts/ui-hunting-info.md),
[quickstart.md](quickstart.md)

**Tests**: REQUIRED (constitution Principle VI); write each test first and see it fail.

**Organization**: US1 = HP per rank (solo + party estimate), US2 = hunting item reactions + vision.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup

- [X] T001 Add the new UI strings to `lib/l10n/app_pt.arb` (section titles "HP" and "Itens de caça", "Solo", "Grupo (aprox.)", "a partir de {value}", "{n} caçadores", "Fonte: {name}", "HP desconhecido", "Desconhecido", "Visão", "Enxerga", "Afeta", "Não afeta", "Afeta com condição") and run `flutter gen-l10n`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [X] T002 [P] Unit tests for the new optional dataset fields in `test/features/monsters/data/dtos/monster_dataset_dto_test.dart`: dataset without them still parses; valid `partyHpFactors`, `huntingItems`, `hp`, `itemReactions` parse; rejected: duplicate hp rank, rank not allowed for the game, `solo <= 0`, reaction item not in `huntingItems`, `conditional` without `detail`, factor with `min > max` or `min <= 0`, factor key outside 2–4 (extend `test/fakes/dataset_json_fixtures.dart`)
- [X] T003 [P] Create domain entities per data-model.md (pure Dart): `RankHp` (rank, solo, basis `expedition|minQuest`), `PartyHpFactors` (factors for 2/3/4 as min/max + `SourceRef`), `HuntingItem` (id, name), `ItemReaction` (item, effect `affects|noEffect|conditional|unknown`, detail), `HuntingInfo` (hp, partyFactors, items, reactions) in `lib/features/monsters/domain/entities/` (one file each); add `huntingInfo` to `Monster` in `lib/features/monsters/domain/entities/monster.dart` with an empty default
- [X] T004 Extend DTOs with the optional fields and validation rules of T002 and map them to the new entities (dataset-level factors and items shared by all its monsters) in `lib/features/monsters/data/dtos/monster_dataset_dto.dart` and `lib/features/monsters/data/dtos/monster_dataset_mapper.dart` (makes T002 pass)
- [X] T005 Add a "Monster Hunter Wiki (hunting info)" and "HP sources" note to `specs/001-monster-wiki/contracts/monster-dataset.schema.json` documenting the new optional properties (schema stays v1, research R5)
- [X] T006 Run gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`); commit

---

## Phase 3: User Story 1 - Saber quanto HP o monstro tem (Priority: P1) 🎯 MVP

**Goal**: solo HP per rank (with "a partir de" for quest-based values) and a labeled party estimate.

**Independent Test**: open World, Rise and Wilds Rathalos and compare HP per rank with Kiranico; party shows "aprox." + source (World, Wilds) or "Desconhecido" (Rise).

### Tests ⚠️

- [X] T007 [P] [US1] Unit test `RankHp.partyEstimate(players)` (min/max rounded to 10; single value when min == max; `null` without factors) in `test/features/monsters/domain/entities/rank_hp_test.dart`
- [X] T008 [P] [US1] Widget test `HpSection` in `test/features/monsters/presentation/views/widgets/hp_section_test.dart`: rows per rank in pt-BR number format ("20.800"); "a partir de" for `minQuest`; party rows "Grupo (aprox.)" for 2/3/4 with ranges and "Fonte: Fextralife"; "Desconhecido" without factors; "HP desconhecido" without hp

### Implementation

- [X] T009 [US1] Implement `partyEstimate` in `lib/features/monsters/domain/entities/rank_hp.dart` (makes T007 pass)
- [X] T010 [US1] Implement `HpSection` (HunterPanel, rank rows, party block, source line, semantics per row) in `lib/features/monsters/presentation/views/widgets/hp_section.dart` and insert it after `WeaknessSection` in `lib/features/monsters/presentation/views/widgets/monster_detail_view.dart` (makes T008 pass)
- [X] T011 [US1] Scratchpad script (not shipped): extract solo HP per rank per research R1 — World: Kiranico expeditions (lowest per rank; fallback lowest regular quest by ★ prefix); Rise: Kiranico quest table (Village, Gathering Hub 1–7★, MR; lowest HP); Wilds: Kiranico `/data/quests` (Assignments/Optional; rank read from each quest page); write `hp` for the 30 monsters and `partyHpFactors` (World: Fextralife 1.5 / 2.2–2.6 / 2.2–2.6; Wilds: 1.63 / 2.00 / 2.34; Rise: none) with sources into `assets/data/*/monsters.json`
- [X] T012 [US1] Extend `test/features/monsters/data/real_datasets_test.dart`: every monster has ≥1 `hp` entry; World Rathalos = 4908 / 6565 / 20800 (spot check against Kiranico); run gates; commit

**Checkpoint**: MVP — HP visible for all 30 monsters.

---

## Phase 4: User Story 2 - Como o monstro reage aos itens de caça (Priority: P2)

**Goal**: per-game hunting items with a status each, details (duration, flee chance, condition) and vision.

**Independent Test**: open a World, a Rise and a Wilds monster; each shows its game's 5 items with statuses matching the Monster Hunter Wiki; Rise uses "Bomb" names; Wilds Rathalos Flash = "Afeta".

### Tests ⚠️

- [X] T013 [P] [US2] Unit test vision derivation (`HuntingInfo.vision`: `sees` when flash `affects`/`conditional`, else `unknown`) and "missing item → unknown" lookup in `test/features/monsters/domain/entities/hunting_info_test.dart`
- [X] T014 [P] [US2] Widget test `HuntingItemsSection` in `test/features/monsters/presentation/views/widgets/hunting_items_section_test.dart`: one row per dataset item; status labels "Afeta" / "Não afeta" / "Afeta com condição" + detail / "Desconhecido"; "Visão: Enxerga" vs "Visão: Desconhecido"; item names follow the name-language setting; semantics "<item>: <status>. <detail>"

### Implementation

- [X] T015 [US2] Implement `vision` and `reactionFor(itemId)` on `HuntingInfo` in `lib/features/monsters/domain/entities/hunting_info.dart` (makes T013 pass)
- [X] T016 [US2] Implement `HuntingItemsSection` (HunterPanel, status badges per contract) in `lib/features/monsters/presentation/views/widgets/hunting_items_section.dart` and add it after `HpSection` in `monster_detail_view.dart` (makes T014 pass)
- [X] T017 [US2] Scratchpad script (not shipped): parse Monster Hunter Wiki `<Name>_(MHWI|MHRS|MHWilds)` pages per research R3 (infobox Dung/Flash/Sonic-Screamer row; "Trap & Flash Pod Effectiveness" and "Other Items" tables; mapping rules; infobox wins on Flash conflicts, noted in sources); write `huntingItems` per dataset and `itemReactions` for the 30 monsters into `assets/data/*/monsters.json`
- [X] T018 [US2] Extend `real_datasets_test.dart`: every monster has a reaction for each dataset item or none (unknown), never an item outside `huntingItems`; spot check World Rathalos (Flash affects, Dung 50%, Sonic no effect) and Wilds Rathalos (Flash affects); run gates; commit

---

## Phase 5: Polish & Cross-Cutting Concerns

- [ ] T019 Extend `test/features/monsters/presentation/views/accessibility_test.dart`: detail with HP and items at 320 dp / 200% text (no overflow) and text contrast
- [ ] T020 [P] README: document the new sections and their sources (HP factors are estimates)
- [ ] T021 Final gates, `flutter build windows --release`; commit and push
- [ ] T022 Manual quickstart checks 1–7 (user, on Windows/phone)

---

## Dependencies & Execution Order

- Setup → Foundational → US1 → US2 → Polish. US1 and US2 touch different widgets and data
  fields, but both edit `monster_detail_view.dart` (T010, T016) and the datasets (T011, T017):
  run those sequentially.

## Parallel Example

```text
T002 DTO tests ‖ T003 entities
T007 ‖ T008 (US1 tests)     T013 ‖ T014 (US2 tests)
```

## Implementation Strategy

MVP = Phases 1–3 (HP for 30 monsters); then US2 (item reactions); then polish. The extraction
scripts are reused by feature 004 (all large monsters).
