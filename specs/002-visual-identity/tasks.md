---

description: "Task list for 002-visual-identity implementation"
---

# Tasks: Identidade Visual "Caderno do Caçador"

**Input**: Design documents from `specs/002-visual-identity/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ui-theme-contract.md](contracts/ui-theme-contract.md),
[quickstart.md](quickstart.md)

**Tests**: REQUIRED (constitution Principle VI). Write each test first and see it fail.
Existing 001 tests must keep passing (FR-012, SC-006); tests that find widgets by the old look
(e.g. `ChoiceChip`) are updated to the new widgets without changing what they assert.

**Organization**: US1 = monster thumbnails, US2 = theme on every screen, US3 = faster reading
(primary weakness, weakness grid, habitat/parts, tabs look).

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup

- [X] T001 [P] Download from the google/fonts GitHub repository (`ofl/cinzel/Cinzel[wght].ttf`, `ofl/cinzel/OFL.txt`, `ofl/alegreyasans/AlegreyaSans-Regular.ttf`, `-Medium.ttf`, `-Bold.ttf`, `ofl/alegreyasans/OFL.txt`) into `assets/fonts/cinzel/` and `assets/fonts/alegreya_sans/`
- [X] T002 Declare fonts in `pubspec.yaml` (family `Cinzel` → variable file; family `AlegreyaSans` → Regular 400, Medium 500, Bold 700) and asset folders `assets/images/monsters/world_iceborne/`, `assets/images/monsters/rise_sunbreak/`, `assets/images/monsters/wilds/` (create them); run `flutter pub get`

---

## Phase 2: Foundational (Blocking Prerequisites)

- [X] T003 [P] Widget test: `MhWikiApp` renders with `ThemeData.brightness == Brightness.dark` and background `#16120E` both when `platformBrightness` is light and dark (`tester.platformDispatcher.platformBrightnessTestValue`) in `test/app/app_theme_test.dart`
- [X] T004 [P] Create color tokens (background, panel, borders, gold variants, text, muted, text-on-gold, five element colors per data-model.md) in `lib/core/presentation/theme/hunter_palette.dart`
- [X] T005 Create `buildHunterTheme()` (dark `ColorScheme` from the palette; `textTheme` with `AlegreyaSans` body and `Cinzel` titles using `fontVariations` `wght`; AppBar, Card, Chip, Radio, SegmentedButton, SnackBar, ProgressIndicator, InputDecoration themes; square corners) in `lib/core/presentation/theme/hunter_theme.dart`
- [X] T006 Use only the hunter theme with `themeMode: ThemeMode.dark` (remove light/dark seed themes) in `lib/app/app.dart` (makes T003 pass)
- [X] T007 [P] Create `HunterPanel` (panel fill, 1 px border, square corners, 16 px padding, optional Cinzel uppercase heading with `Semantics(header: true)`) in `lib/core/presentation/widgets/hunter_panel.dart` and `OrnamentHeader` (line — title — line) in `lib/core/presentation/widgets/ornament_header.dart`
- [X] T008 Run `flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`; commit

**Checkpoint**: theme applied app-wide (colors/fonts), existing tests green.

---

## Phase 3: User Story 1 - Reconhecer os monstros pela miniatura (Priority: P1) 🎯 MVP

**Goal**: all 30 monsters show their own game's hunter's-notes icon in list and detail; fallback marker in the same style.

**Independent Test**: scroll the list: 30 thumbnails, Rathalos differs per game; open a detail: framed large thumbnail; a monster without image shows the styled marker.

### Tests (write first, must fail) ⚠️

- [X] T009 [P] [US1] Extend `test/features/monsters/data/real_datasets_test.dart`: every monster has `imageAsset` and the asset loads through `rootBundle` (SC-001)
- [X] T010 [P] [US1] Widget test `MonsterImage`: with an asset → `Image` inside a gold frame; `asset == null` → styled marker (no `Image`); asset that fails to load → marker via `errorBuilder` in `test/core/presentation/widgets/monster_image_test.dart`

### Implementation

- [X] T011 [US1] In a scratchpad script (not shipped): download the 30 icons from `https://monsterhunterwiki.org/wiki/Special:FilePath/<file>` (research R1 naming; `Great_Jagras`, `Pink_Rathian`, `Violet_Mizutsune`, `Guardian_Rathalos`, `Rey_Dau`, `Uth_Duna`, `Nu_Udra`, `Jin_Dahaad`, `Gore_Magala`, …), convert to 256×256 WebP with alpha (Pillow), write to `assets/images/monsters/<game>/<slug>.webp`; fail loudly on any 404
- [X] T012 [US1] Add `image` to every monster and a "Monster Hunter Wiki (icons)" entry to `sources` in `assets/data/world_iceborne/monsters.json`, `assets/data/rise_sunbreak/monsters.json`, `assets/data/wilds/monsters.json` (makes T009 pass)
- [X] T013 [US1] Restyle `MonsterImage` (gold frame `#8A6A33`, dark fill, `cacheWidth`, styled marker with a monster silhouette icon for null/error) in `lib/core/presentation/widgets/monster_image.dart` (makes T010 pass)
- [X] T014 [US1] Detail header: 104 dp thumbnail with double gold frame, name in Cinzel, classification, game label in `lib/features/monsters/presentation/views/widgets/monster_detail_view.dart`
- [X] T015 [US1] Run gates; commit

**Checkpoint**: MVP — every monster recognizable by its icon.

---

## Phase 4: User Story 2 - Visual do caderno do caçador em todo o app (Priority: P2)

**Goal**: every screen, state and layout follows prototype A.

**Independent Test**: with the device in light and dark mode, list/detail/settings (compact and expanded) always show the hunter theme.

### Tests (write first, must fail) ⚠️

- [X] T016 [P] [US2] Widget test `GameTabs`: four tabs "Todos", "World", "Rise", "Wilds"; active tab exposes `selected` semantics and gold fill; tapping calls `onChanged` with the game (null for "Todos"); ≥48 dp tall in `test/core/presentation/widgets/game_tabs_test.dart`
- [X] T017 [P] [US2] Widget test: list in "Todos" shows one `OrnamentHeader` per game in order; single-game filter shows none in `test/features/monsters/presentation/views/game_filter_test.dart` (update the existing test to find tabs via `GameTabs` instead of `ChoiceChip`; keep all current assertions)

### Implementation

- [X] T018 [US2] Create `GameTabs` (4 equal-width tabs, wrap to 2 rows when text scale needs it) in `lib/core/presentation/widgets/game_tabs.dart`; replace `GameFilterBar`'s chips with it in `lib/features/monsters/presentation/views/widgets/game_filter_bar.dart` (makes T016 pass)
- [X] T019 [US2] List pane: `OrnamentHeader` for sections (uppercase game name, e.g. "WORLD : ICEBORNE" via new ARB keys), framed tiles, themed loading/empty/error/banner states in `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart` (makes T017 pass)
- [X] T020 [P] [US2] App bar "MH WIKI" + subtitle "Caderno do Caçador" (ARB) and framed settings button in `lib/features/monsters/presentation/views/monsters_page.dart` and `lib/features/settings/presentation/settings_page.dart`
- [X] T021 [P] [US2] Framed search field in `lib/features/monsters/presentation/views/widgets/search_field.dart`
- [X] T022 [US2] Replace `SectionCard` internals with `HunterPanel` (keep the class name and API so sections need no call-site changes) in `lib/features/monsters/presentation/views/widgets/section_card.dart`
- [X] T023 [US2] Settings page panels and gold radios in `lib/features/settings/presentation/settings_page.dart`; expanded layout divider/pane background in `monsters_page.dart`
- [X] T024 [US2] Update `integration_test/app_test.dart` to select Wilds through `GameTabs`; run gates; commit

**Checkpoint**: identity applied everywhere; US1 still works.

---

## Phase 5: User Story 3 - Informação mais rápida de ler (Priority: P3)

**Goal**: primary weakness in list items; 5-column weakness grid with element icons/colors; habitat and parts side by side; "Cortável" tag; rank tabs styled.

**Independent Test**: list items show the right primary weakness (none below 2★); detail shows the grid with the highlight, habitat/parts layout and tag.

### Tests (write first, must fail) ⚠️

- [X] T025 [P] [US3] Unit test `WeaknessProfile.primaryWeakness` (single max; tie → first in fire, water, thunder, ice, dragon order; below 2★ → null) in `test/features/monsters/domain/entities/weakness_profile_test.dart`
- [X] T026 [P] [US3] Widget test list tile: shows primary weakness name + `ElementIcon` in the element color; no badge when null in `test/features/monsters/presentation/views/primary_weakness_badge_test.dart`
- [X] T027 [P] [US3] Update `test/features/monsters/presentation/views/widgets/weakness_section_test.dart`: five cells in one row (same `dy`), `ElementIcon` per cell, highlighted cell framed; keep existing semantics/immune/state assertions
- [X] T028 [P] [US3] Widget test: Habitat and Parts side by side at 400 dp (same `dy`), stacked at 320 dp; "Cortável" tag present in `test/features/monsters/presentation/views/widgets/habitat_parts_layout_test.dart`

### Implementation

- [X] T029 [US3] Add `primaryWeakness` to `lib/features/monsters/domain/entities/weakness_profile.dart` (makes T025 pass)
- [X] T030 [P] [US3] Create `ElementIcon` (`CustomPainter` with flame, drop, bolt, snowflake, four-point star paths; color from palette) and `elementColor(ElementType)` in `lib/core/presentation/widgets/element_icon.dart`
- [X] T031 [US3] Primary weakness badge in list tiles in `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart` (makes T026 pass)
- [X] T032 [US3] Rewrite `WeaknessSection` as a 5-column grid (icon, name, stars/✕/Imune; highlighted cells framed) keeping state blocks, in `lib/features/monsters/presentation/views/widgets/weakness_section.dart`; adapt `StarRating` in `lib/core/presentation/widgets/star_rating.dart` (makes T027 pass)
- [X] T033 [US3] Habitat/Parts side-by-side (`LayoutBuilder`, ≥360 dp) and gold "Cortável" tag in `monster_detail_view.dart`, `habitat_section.dart`, `parts_section.dart` (makes T028 pass)
- [X] T034 [US3] Materials rank selector in tab style; rates in gold in `lib/features/monsters/presentation/views/widgets/materials_section.dart`
- [X] T035 [US3] Run gates; commit

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T036 Run the accessibility suite (`test/features/monsters/presentation/views/accessibility_test.dart`: 200% text, tap targets, `textContrastGuideline`) and fix any failure
- [ ] T037 [P] Update README (theme, fonts and icons credits with licenses/sources)
- [ ] T038 Final gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`), `flutter build web --release --no-web-resources-cdn`; commit
- [ ] T039 Manual quickstart scenarios 1–9 on Windows (`flutter run -d windows`), comparing with prototype A

---

## Dependencies & Execution Order

- Setup → Foundational (theme) → US1, US2, US3.
- US1 is independent of US2/US3 (only `MonsterImage` and data).
- US2 and US3 both edit `monster_list_pane.dart` (T019, T031): run sequentially (US2 first).
- US3's `WeaknessSection` rewrite is independent of US2 except for `SectionCard` (T022) — do T022 first.

## Parallel Example

```text
T001 fonts  ‖  T004 palette  ‖  T003 theme test
T009 dataset image test  ‖  T010 MonsterImage test  ‖  T011 icon download
T025 ‖ T026 ‖ T027 ‖ T028 (US3 tests)  ‖  T030 ElementIcon
```

## Implementation Strategy

1. Setup + Foundational → dark theme and fonts everywhere.
2. US1 → thumbnails (MVP; most visible request).
3. US2 → full identity (tabs, headers, panels, settings).
4. US3 → reading improvements.
5. Polish → accessibility and docs.
