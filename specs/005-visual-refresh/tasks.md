---
description: "Task list for feature 005: Renovação Visual Caderninho"
---

# Tasks: Renovação Visual "Caderninho"

**Input**: Design documents from `specs/005-visual-refresh/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/ui-contract.md](contracts/ui-contract.md),
[quickstart.md](quickstart.md), approved mockup [mockups/approved.html](mockups/approved.html)

**Tests**: required by the constitution (VI). Domain getters get unit tests. New and restyled views
get widget tests, and accessibility tests are updated. Where a test pins behaviour (semantics,
order), write it before the implementation.

**Organization**: tasks are grouped by user story, so each story can be implemented and checked on
its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: US1, US2 or US3 (spec.md)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: assets and strings every story needs.

- [X] T001 [P] Download the three OFL font families from `https://raw.githubusercontent.com/google/fonts/main/ofl/` (research R1) into `assets/fonts/im_fell_english_sc/` (`IMFeENsc28P.ttf`, `OFL.txt`), `assets/fonts/averia_serif_libre/` (`AveriaSerifLibre-Regular.ttf`, `AveriaSerifLibre-Bold.ttf`, `OFL.txt`) and `assets/fonts/atkinson_hyperlegible/` (`AtkinsonHyperlegible-Regular.ttf`, `-Bold.ttf`, `-Italic.ttf`, `OFL.txt`). Register the families `IMFellEnglishSC`, `AveriaSerifLibre` (400, 700) and `AtkinsonHyperlegible` (400, 700, italic) in `pubspec.yaml`. Keep Cinzel and Alegreya Sans until T034.
- [X] T002 [P] Create `tool/data/fetch_game_logos.py` (uses `common.fetch`; Pillow).
  - Download `MHWI-Logo.png`, `MHRS-Logo.png` and `MHWilds-Logo.png` from `https://monsterhunterwiki.org/wiki/Special:FilePath/<file>`.
  - Convert each to RGBA, trim it to its bounding box, resize it to 138 px tall, and save it as lossless-alpha WebP to `assets/images/games/{world_iceborne,rise_sunbreak,wilds}.webp`.
  - Write `assets/images/games/SOURCES.md` (origin URLs, Capcom trademark note, personal/study use as in feature 001).
  - Run the script, register `assets/images/games/` in `pubspec.yaml`, and add the script to the table in `tool/data/README.md`.
- [X] T003 [P] Update `lib/l10n/app_pt.arb`: `appTitle` = "Caderninho"; remove `appSubtitle`; add `bestWeakness` ("Melhor"), `gameLogoLabel`, `weaknessRowSemantics`, `hpRulerSemantics` and `hpSoloLabel` ("solo"), per data-model.md › Localisation. Reuse the existing immunity/"sem efeito" label if there is one. Regenerate the l10n files with `flutter gen-l10n`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: the design tokens and the shared layout widgets that replace panels and filled tabs.

**⚠️ CRITICAL**: US1–US3 build on these.

- [X] T004 Create `lib/core/presentation/theme/notebook_tokens.dart` with:
  - `Space` (section 32, title 12, row 8, gutter 22/16);
  - `Motion` (220 ms, `Curves.easeOutCubic`, and `Motion.duration(context)` returning `Duration.zero` when `MediaQuery.disableAnimationsOf(context)`);
  - type helpers `notebookTitle({size, color})` (IMFellEnglishSC, w400) and `notebookNumber({size, color, bold})` (AveriaSerifLibre, tabular figures), per data-model.md.
- [X] T005 Update `lib/core/presentation/theme/hunter_theme.dart`:
  - body font `AtkinsonHyperlegible` (bodyLarge 16, bodyMedium 14, bodySmall 12.5);
  - app bar title style `notebookTitle(24)`;
  - dividers `borderSubtle` 1 px.
  Keep `hunterDisplay` for now (removed in T034). Update `test/app/app_theme_test.dart` for the new families.
- [X] T006 [P] Write `test/core/presentation/widgets/notebook_section_test.dart`. It checks that `NotebookSection` renders the number (Averia) and the title (IM Fell) as a semantics header, shows the optional note after the title, draws no `Card`, no bordered `Material` and no `DecoratedBox` with a border around its child, and wraps without overflow at 320 dp / 200 % text.
- [X] T007 Create `lib/core/presentation/widgets/notebook_section.dart`: `NotebookSection` (number, title, optional note, optional trailing, child; hairline under the title; `Space` tokens). Move `EmptySectionText` there from `section_card.dart` and re-export it for now, so `T006` passes.
- [X] T008 [P] Create `lib/core/presentation/widgets/ruled_row.dart`: `RuledRow` (leading, label, trailing, optional caption; 1 px `borderSubtle` bottom rule, 8 dp vertical padding, wraps at large text) and `RuledCaption` (small upper-case muted group caption).
- [X] T009 [P] Write `test/core/presentation/widgets/underline_tabs_test.dart` covering:
  - text and image options, with the image falling back to text on error;
  - the selected tab has the gold underline, and the unselected image tab has reduced opacity;
  - `Semantics(button, selected, label)`, with the label override used for images;
  - 48 dp minimum height;
  - horizontal scrolling instead of wrapping when the width is 320 dp or the text is at 200 %.
- [X] T010 Create `lib/core/presentation/widgets/underline_tabs.dart`: `UnderlineTabs<T>` with `TabOption<T>` (value, text, optional image asset, semantics label), per research R4 and the contract, so `T009` passes.

**Checkpoint**: the tokens and shared widgets exist; screens still use the old look.

---

## Phase 3: User Story 1 - Um caderno, não um template (Priority: P1) 🎯 MVP

**Goal**: the "Caderninho" title, no cards anywhere, numbered sections, the three fonts, underlined
version tabs, no repeated game name, and discreet inherited notes (spec US1).

**Independent Test**: quickstart checks 1 (title only), 2, 3 (numbering and header), 5 (version
tabs and notes), 10 and 12; `monsters_page_*`, `monster_list_pane`, `version_selector` and
accessibility tests pass.

- [ ] T011 [P] [US1] Unit tests in `test/features/monsters/domain/entities/monster_test.dart` for `Monster.dropsByMethod(rank)`:
  - groups keyed by (method, partId, methodLabel.en) in first-appearance order;
  - `breakPart` groups split by part;
  - `other` groups split by label;
  - an empty rank gives an empty list.
- [ ] T012 [US1] Add `lib/features/monsters/domain/entities/method_drop_group.dart` (`MethodDropGroup`) and `Monster.dropsByMethod(Rank)` in `lib/features/monsters/domain/entities/monster.dart`, so `T011` passes.
- [ ] T013 [P] [US1] Write `test/features/monsters/presentation/views/widgets/notebook_layout_test.dart`:
  - the detail of a fixture monster shows sections numbered 1 Fraquezas, 2 Vida, 3 Itens de caça, 4 Materiais, 5 Habitat, 6 Partes;
  - the detail and the list contain no `Card`, `HunterPanel` or bordered `Material`;
  - the expanded detail under the World filter shows no game name above the monster name;
  - an inherited section shows the note next to its title once.
- [ ] T014 [US1] Restyle `lib/features/monsters/presentation/views/widgets/monster_detail_view.dart`:
  - header plate 92 dp (1 dp border, +3° rotation, via `MonsterImage`);
  - name `notebookTitle(40/32)`, up to 3 lines; classification in muted body;
  - no game name, except with a `showGame` flag;
  - version tabs;
  - sections in the new order, wrapped in `NotebookSection` with numbers 1–6;
  - habitat and parts side by side from 360 dp.
  Pass `showGame` from `lib/features/monsters/presentation/views/monsters_page.dart` (only when the filter is "Todos").
- [ ] T015 [US1] Restyle `lib/features/monsters/presentation/views/widgets/version_selector.dart` to `UnderlineTabs` (text options, semantics "Versão: <label>"), and update `test/features/monsters/presentation/views/widgets/version_selector_test.dart` to semantics-based finders.
- [ ] T016 [P] [US1] Restyle `lib/features/monsters/presentation/views/widgets/hunting_items_section.dart`, `habitat_section.dart` and `parts_section.dart` to `NotebookSection` + `RuledRow`. "Cortável" becomes muted text, not a chip. Keep the semantics. Update `hunting_items_section_test.dart`, `habitat_parts_sections_test.dart` and `habitat_parts_layout_test.dart` if their finders depend on the old panels.
- [ ] T017 [US1] Rewrite `lib/features/monsters/presentation/views/widgets/materials_section.dart`:
  - `NotebookSection`, with `UnderlineTabs` for ranks, or the rank as the section note when there is only one;
  - groups from `monster.dropsByMethod(rank)`, each a `RuledCaption` (method label) followed by `RuledRow`s: name (+ rarity) and rate (`notebookNumber(14, bold)`) or "Taxa desconhecida".
  Update `test/features/monsters/presentation/views/widgets/materials_section_test.dart` for method grouping, e.g. the World Arch-Tempered Nergigante fixture with a "Prêmio da missão" group.
- [ ] T018 [US1] Restyle `lib/features/monsters/presentation/views/widgets/monster_list_pane.dart`:
  - `_MonsterTile` as a ruled row (thumbnail 44, name `notebookTitle(18)`, classification and "N versões" with the count in Averia);
  - selected row `panelHighlight` with a 2 dp gold left bar;
  - "Todos" game captions (name `notebookTitle(16)` + hairline) replacing `OrnamentHeader`;
  - `_LoadFailed` and `_NoResults` without `HunterPanel`.
  Keep the current weakness badge until T023. Update `test/features/monsters/presentation/views/widgets/monster_list_pane_test.dart`.
- [ ] T019 [US1] Update `lib/features/monsters/presentation/views/monsters_page.dart` and `monster_detail_page.dart`: app bar title "Caderninho" with no subtitle; the compact detail back row "‹ Monstros" with the game name at the right. Update `monsters_page_compact_test.dart` and `monsters_page_adaptive_test.dart`.
- [ ] T020 [P] [US1] Restyle `lib/features/settings/presentation/settings_page.dart`: no `HunterPanel`; the options are ruled rows with radio semantics under a title in `notebookTitle(20)`. Update `test/features/settings/presentation/name_language_flow_test.dart` if its finders change.
- [ ] T021 [US1] Update `test/features/monsters/presentation/views/accessibility_test.dart`: list, detail, version detail and settings at 320 dp / 200 % text (no overflow), text contrast guideline, 48 dp tap targets. Run `flutter analyze` and `flutter test`; commit the US1 slice.

**Checkpoint**: US1 is visible end to end. Weaknesses, HP and the game tabs keep their old
widgets, restyled only through the theme.

---

## Phase 4: User Story 2 - Ler fraquezas e vida de relance (Priority: P2)

**Goal**: weakness rows ordered best → worst, with element symbol, stars and the gold "Melhor"
stamp; the list badge with the element symbol; HP with a rank selector and a party ruler (spec
US2).

**Independent Test**: quickstart checks 3 (weaknesses), 4, 6, 7 and 11 (weakness and HP
semantics); `weakness_section`, `primary_weakness_badge` and `hp_section` tests pass.

- [ ] T022 [P] [US2] Unit tests in `test/features/monsters/domain/entities/weakness_profile_test.dart` for `ranked`:
  - order high → none, immune last;
  - ties in the order fire, water, thunder, ice, dragon;
  - missing elements count as none;
  - `best` only for `mostEffective` (≥ 2 stars, ties included);
  - states ranked with no `best`.
- [ ] T023 [US2] Add `lib/features/monsters/domain/entities/ranked_weakness.dart` and `WeaknessProfile.ranked` (and ranking of state values) in `weakness_profile.dart`, so `T022` passes. In `monster_list_pane.dart`, `_WeaknessBadge` becomes an `ElementIcon` in the element colour plus the element name, with no border; update `test/features/monsters/presentation/views/primary_weakness_badge_test.dart`.
- [ ] T024 [P] [US2] Rewrite `test/features/monsters/presentation/views/widgets/weakness_section_test.dart` with semantics-based finders:
  - Rathalos order Dragão, Raio, Água, Gelo, Fogo;
  - "Melhor" only on the best rows (two on a tie, none without ≥ 2 stars);
  - immunity read as "sem efeito";
  - each row's semantics "<elemento>, N de 3 estrelas[, melhor fraqueza]";
  - state rows with no stamp.
- [ ] T025 [US2] Rewrite `lib/features/monsters/presentation/views/widgets/weakness_section.dart` as ruled rows from `profile.ranked`, per the contract:
  - `ElementIcon` 20 dp in the element colour and the name (bold when best);
  - a "Melhor" stamp widget (`notebookTitle(11)`, gold, 1.5 dp gold border, −3°);
  - `StarRating`, or immunity text;
  - state blocks under captions.
  Restyle `lib/core/presentation/widgets/star_rating.dart` (filled `text`, empty `textDisabled`, gold when highlighted). Remove `WeaknessCell` and `_ElementGrid`, so `T024` passes.
- [ ] T026 [P] [US2] Extend `test/features/monsters/presentation/views/widgets/hp_section_test.dart`:
  - rank tabs only with more than one rank;
  - single rank shown as the section note;
  - the solo value with "a partir de" for `minQuest`;
  - the ruler semantics "HP solo X; 2 caçadores Y; 3 a 4 caçadores Z";
  - only the solo value without party factors;
  - "HP desconhecido" with no ruler;
  - values listed under the ruler at 200 % text, with no overflow at 320 dp.
- [ ] T027 [US2] Create `lib/features/monsters/presentation/views/widgets/hp_ruler.dart`. It draws the axis, the gold solo tick, the 2-player tick, the 3–4 span and the labelled values with `notebookNumber(13)`, and switches to a list when the text scale is above 1.3 or the width below 300. Rewrite `hp_section.dart` as a stateful `NotebookSection`:
  - rank `UnderlineTabs`;
  - solo value `notebookNumber(40, bold)` plus "solo"/"a partir de";
  - the `HpRuler` wrapped in `ExcludeSemantics` under a `Semantics` label;
  - the factor source line;
  - the rank resets when the monster changes.
  This makes `T026` pass. Run the gates; commit the US2 slice.

**Checkpoint**: US1 + US2 match the detail screen of the mockup.

---

## Phase 5: User Story 3 - Jogos pelos logos e trocas suaves (Priority: P3)

**Goal**: official game logos as tabs, and a short transition when switching monster, version or
game that respects reduce-motion (spec US3).

**Independent Test**: quickstart checks 1, 8, 9 and 11 (tabs); `game_tabs`, `game_filter` and
motion tests pass.

- [ ] T028 [P] [US3] Rewrite `test/core/presentation/widgets/game_tabs_test.dart`:
  - "Todos" as text;
  - three image tabs using `assets/images/games/<game>.webp`;
  - semantics labels "World: Iceborne", "Rise: Sunbreak", "Wilds" with `selected`;
  - the text fallback when an asset is missing;
  - scrolling at 320 dp / 200 %.
  Update `test/features/monsters/presentation/views/game_filter_test.dart` to tap tabs by semantics label instead of `HunterTabs` text.
- [ ] T029 [US3] Rewrite `lib/core/presentation/widgets/game_tabs.dart` on `UnderlineTabs`: "Todos" as text, logos at 46 dp from `assets/images/games/`, fallback to the short game name, semantics from `gameLogoLabel`. Delete `HunterTabs` and `_Tab` from this file once no caller is left (materials and HP already use `UnderlineTabs`). This makes `T028` pass.
- [ ] T030 [P] [US3] Write `test/features/monsters/presentation/views/motion_test.dart`:
  - switching monster in the expanded layout runs an `AnimatedSwitcher` of 220 ms (a `FadeTransition` is present mid-animation);
  - switching version does the same;
  - switching game fades the list;
  - with `MediaQueryData(disableAnimations: true)` the switch finishes in one frame with no transition in progress.
- [ ] T031 [US3] Add the transitions:
  - an `AnimatedSwitcher` in `monster_detail_view.dart` (or around it in `monsters_page.dart`), keyed by monster id, using a fade plus a 2 % upward `SlideTransition`;
  - an `AnimatedSwitcher` around the list body in `monster_list_pane.dart`, keyed by game filter, fade only;
  - both use `Motion.duration(context)` and `Motion.curve`.
  This makes `T030` pass. Check that `test/features/monsters/presentation/performance/*` still passes. Run the gates; commit the US3 slice.

**Checkpoint**: all three stories match the approved mockup.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T032 Audit for leftovers: `grep -r "HunterPanel\|OrnamentHeader\|SectionCard\|HunterTabs\|WeaknessCell\|hunterDisplay\|Cinzel\|AlegreyaSans" lib test` must be empty after T033–T034.
- [ ] T033 Delete `lib/core/presentation/widgets/hunter_panel.dart`, `ornament_header.dart` and `lib/features/monsters/presentation/views/widgets/section_card.dart`. Move the remaining imports to `notebook_section.dart`. Remove unused `HunterPalette` tokens (`panel`, `panelRaised`, `goldFrame`) if nothing references them.
- [ ] T034 Remove `hunterDisplay` and `HunterFonts.display/body` (Cinzel, Alegreya Sans) from `hunter_theme.dart`, delete `assets/fonts/cinzel/` and `assets/fonts/alegreya_sans/`, and remove them from `pubspec.yaml`.
- [ ] T035 [P] Update `README.md`: the app name "Caderninho", the visual identity (fonts and licences, palette roles), the logo source in the sources section (FR-019), and a screenshot note.
- [ ] T036 Run the gates (`flutter analyze`, `dart format --set-exit-if-changed .`, `flutter test`, `flutter build windows --release`), then commit and push.
- [ ] T037 Manual quickstart checks 1–13 (user), comparing with [mockups/approved.html](mockups/approved.html). Fix the findings, then merge `005-visual-refresh` into `main`.

---

## Dependencies & Execution Order

- **Setup (T001–T003)**: no dependencies, parallel.
- **Foundational (T004–T010)**: depends on Setup (fonts for tokens, strings for semantics). Blocks every story.
- **US1 (T011–T021)**: after Foundational. It is the MVP and stands on its own.
- **US2 (T022–T027)**: after Foundational. It touches `weakness_section`, `hp_section` and the list badge, and can run in parallel with US1 except for the shared `monster_list_pane.dart` (T018 before T023).
- **US3 (T028–T031)**: after Foundational. T029 removes `HunterTabs`, so T017 and T027 (the rank tabs moving to `UnderlineTabs`) must be done first. T031 touches `monster_detail_view.dart` and `monster_list_pane.dart`, so it comes after T014, T018 and T023.
- **Polish (T032–T037)**: after all stories.

## Parallel Example

```text
Setup:        T001 fonts  ‖  T002 logos  ‖  T003 ARB strings
Foundational: T006 section test ‖ T008 ruled rows ‖ T009 tabs test   (then T007, T010)
US1:          T011 dropsByMethod tests ‖ T013 layout tests ‖ T016 items/habitat/parts ‖ T020 settings
US2:          T022 ranked tests ‖ T024 weakness tests ‖ T026 HP tests
US3:          T028 tabs tests ‖ T030 motion tests
```

## Implementation Strategy

1. **MVP (US1)**: title, no cards, numbered sections, fonts and underlined version tabs. This
   alone removes most of the "AI look" signals listed in the diagnosis. Stop, run the gates and
   show the user.
2. **US2**: the weakness rows and the HP ruler, the most-read information.
3. **US3**: logos and motion, the finish.
4. **Polish**: remove the old widgets, fonts and palette tokens, update the README, get the
   user's manual checks, and merge.
