---

description: "Task list for 010 Armas e Armaduras da Wilds"
---

# Tasks: Armas e Armaduras da Wilds

**Input**: Design documents from `specs/010-wilds-equipment/` ([plan.md](plan.md),
[spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md),
[contracts/ui-contract.md](contracts/ui-contract.md), [quickstart.md](quickstart.md)).

**Tests**: mandatory (constitution VI). Each story writes its tests before its implementation.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (data)

- [X] T001 Write `tool/data/fetch_wilds_equipment.py`. It caches the wilds.mhdb.io endpoints in
  `en` and `pt-BR` into `tool/data/.cache/`: weapons, armor/sets, skills, decorations, charms and
  items. Fetches are slow and resumable. Run it.
- [X] T002 Write `tool/data/fetch_wilds_icons.py` per research R3:
  - the wiki's `MHWA-<Kind>_Icon_Rare_<1..8>`: Helmet, Chestplate, Armguards, Waist, Leggings,
    Talisman, the 14 weapon types and the Relic parts;
  - `MHWilds-Decoration_Level_<1..3>-Sword|Armor_Icon_<Color>` for the colours mhdb uses;
  - the weapon renders from `Module:MHWilds/data/Weapons/RendersDict.json`;
  - the Kiranico Wilds piece thumbnails.

  Save everything as WebP in `assets/images/wilds/`, with a SOURCES.md. Report the coverage. Run it.
- [X] T003 Write `tool/data/build_wilds_equipment.py`. It writes `assets/data/wilds/weapons.json`
  and `armor.json` per data-model.md, in the 006/007 schemas plus the optional fields:
  - material ids as slugs of the English item names (R4), with Wilds monster drops in
    `sources.monsters`;
  - weapon skills; set `bonus` and `groupBonus`; skill `kind`;
  - decoration `kind`, `icon` and up to two skills; `talismans`;
  - image paths from T002.

  Report the counts, missing pt-BR names, unmatched materials and image coverage. Register the
  assets in `pubspec.yaml`. Run it.
- [X] T004 Artian data (R2): read the wiki's `Module:MHWilds/data/Weapons.json` (Artian tree) and
  the Game8 Artian page of each type. Add the `artian` section per data-model: bases by rarity,
  element values by rarity, production values, reinforcement values and limits, and materials.
  Record the per-type infusion and element-boost values in research.md, with sources.
- [X] T005 [P] Add the ARB strings of data-model.md › Localisation, then run `flutter gen-l10n`.

---

## Phase 2: Foundational

- [X] T006 [P] DTO tests (weapons and armor) for the optional fields: Wilds weapon skills, no
  Rampage, `artian`; skill kind, decoration kind and two skills, set bonus steps, group bonus and
  talisman ranks. Rise files still parse unchanged.
- [X] T007 Implement the domain and DTO additions: `WeaponSkill`, the Artian entities, `SkillKind`,
  `DecorationKind`, `SetBonus`, `Talisman`, and the readers.
- [X] T008 [P] Real-dataset tests `test/features/{weapons,armor}/data/real_wilds_*_test.dart`:
  - counts match the source (SC-001), with pt-BR names for at least 99%;
  - Sieglinde (1008, 15%, Veneno 300, ③②①, Prolongar Veneno 1, Status Crítico 3);
  - Arkveld α (bonus steps and group);
  - Joia Stat. Crít./Artesanato 3 (two skills);
  - Amuleto da Fartura I–III;
  - at least 95% of the images resolve (SC-003);
  - the material and monster match rate is printed.
- [X] T009 `lib/app/equipment_area.dart`: the `GameTabs` over an `IndexedStack` of per-game pages,
  built on each tab's first visit, with World disabled. Add the per-game repositories and
  controllers in `AppDependencies`, and wire Armas and Armaduras in `app_home.dart`. Write the
  tests: tabs, state kept per game, failure isolation.

**Checkpoint**: Wilds data loads in both areas behind the tabs.

---

## Phase 3: User Story 1 - Armas da Wilds (P1) 🎯 MVP

- [X] T010 [P] [US1] Widget tests:
  - the Wilds list (rarity groups, Wilds icons);
  - the detail: attributes, sharpness, slots, the "Habilidades da arma" card, materials with
    "Dropado por", the tree;
  - no Rampage card;
  - a skill tap opens Armaduras (Wilds);
  - Monstros (Wilds) shows "Armas feitas com ele".
- [X] T011 [US1] Implement the Wilds icons in the weapon list and detail, the weapon skills card,
  hiding Rampage for Wilds, and the skill links. Turn on `_extraSections` for Wilds monsters in
  `app_home.dart`.

---

## Phase 4: User Story 2 - Armaduras da Wilds (P2)

- [ ] T012 [P] [US2] Widget tests:
  - the Wilds tabs: Conjuntos, Habilidades, Joias, Talismãs;
  - set pieces with the Wilds part icons by rarity;
  - the "Bônus do conjunto" card (steps and group);
  - summed set and group skills shown as a piece count;
  - the skill kind seal;
  - the Joias kind and slot filters, with two-skill rows;
  - the Talismãs ranks.
- [ ] T013 [US2] Implement them in the armor views and controller: a talismans tab only when the
  catalog has talismans, and a decoration kind filter.

---

## Phase 5: User Story 3 - Artian (P3)

- [ ] T014 [P] [US3] Simulator unit tests:
  - limits (3 parts, 5 rolls, each maximum);
  - an element infusion only with 3 matching parts;
  - no element;
  - status values by rarity;
  - 5 combinations checked against Game8 (SC-004).

  Plus `MyArtian` repository tests (save, rename, delete, corrupt data).
- [ ] T015 [US3] Implement `simulateArtian`, `ArtianController`, `PrefsMyArtianRepository` and the
  wiring.
- [ ] T016 [P] [US3] Widget tests: the Artian group in the list (bases and "minha"), the simulator
  (element chips, part and roll steppers with "restam N", live result), and save, rename and delete.
- [ ] T017 [US3] Implement the Artian group and the simulator page.

---

## Phase 6: Polish

- [ ] T018 [P] Accessibility: 320 dp at 200% on the Wilds list, detail, set, Joias, Talismãs and
  simulator; tap targets; semantics.
- [ ] T019 [P] Integration flow: Armas → Wilds → Sieglinde → skill → Armaduras (Wilds); then
  Artian → save.
- [ ] T020 SC-002 spot check: 10 weapons, 10 sets and 10 decorations against the wiki or game.
  Record them in research.md.
- [ ] T021 Update `README.md` and `tool/data/README.md` (Wilds equipment, icons, Artian, sources,
  sizes).
- [ ] T022 Run the gates (analyze, format, test, integration on Windows, build Windows release,
  build web) and record the APK and asset size growth.
- [ ] T023 The user runs the quickstart checks 1–9. Fix the findings, then merge into `main`.

---

## Dependencies & Execution Order

- **Setup**: T001 → T002 → T003 → T004; T005 runs in parallel.
- **Foundational**: T006 → T007; T008 needs T003, T004 and T007; T009 needs T007. This phase blocks
  every story.
- **US1 → US2** (skill links from weapons to armor). **US3** needs only US1.
- **Polish** comes after all stories.

## Implementation Strategy

1. Data first (T001–T004), checked by the real-dataset tests (T008).
2. The game tabs (T009) make Wilds reachable in both areas.
3. MVP: Wilds weapons (US1); then armor (US2); then Artian (US3).
4. Polish, the user's checks, then merge.
