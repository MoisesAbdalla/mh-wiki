---

description: "Task list for 011 Armas e Armaduras do World: Iceborne"
---

# Tasks: Armas e Armaduras do World: Iceborne

**Input**: Design documents from `specs/011-world-equipment/` ([plan.md](plan.md),
[spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md),
[contracts/ui-contract.md](contracts/ui-contract.md), [quickstart.md](quickstart.md)).

**Tests**: mandatory (constitution VI). Each story writes its tests before its implementation.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup (data)

- [X] T001 Write `tool/data/fetch_world_equipment.py` and run it. It caches in `tool/data/.cache/`:
  - the wiki modules `Module:MHWI/data/{Weapons,Armor,Decorations}.json` (`action=raw`);
  - mhw-db.com `armor/sets`, `skills`, `decorations` and `charms`;
  - the Kiranico World lists in `/en/` and `/pt-BR/`: `weapons?type=0..13`, `armorseries`,
    `skilltrees`, `decorations` and `items`.

  The script reuses cached files.
- [X] T002 Write `tool/data/fetch_world_icons.py` (research R6) and run it. Everything goes to
  `assets/images/world/` as WebP, with a SOURCES.md:
  - the MHWI rarity icons 0–12 for the 14 weapon types, the 5 armor parts and Talisman →
    `icons/<kind>-<rarity>.webp`;
  - the decoration icons by level and colour → `decorations/<level>-<color>.webp`;
  - the slot icons, tinted gold → `slots/slot<N>.webp`;
  - weapon renders → `weapons/`, and armor male renders → `armor/`, both at 96 px. The R8 budget
    is checked and the coverage reported.
- [X] T003 Write `tool/data/build_world_equipment.py` and run it. It writes
  `assets/data/world_iceborne/weapons.json` and `armor.json` per data-model.md.
  - **Weapons**:
    - displayed attack = raw × the type multiplier;
    - elements and status, with `hidden`; `elderseal`; `defenseBonus`;
    - slots from `Decos1..4`; sharpness with Handicraft; type traits;
    - trees from previous/next; `worldSpecial` for the `Unavailable` tree;
    - forge and upgrade materials, as slugs of their English names, with sources from the World
      monster drops.
  - **Armor**:
    - sets and pieces from the wiki module (rank from rarity, max defense, renders);
    - set `bonus` steps from mhw-db;
    - skill `kind` (set or secret);
    - decorations with `slotLevel` 1–4, `icon` and up to two skills;
    - talismans with ranks 1–5.
  - **pt-BR names** from the Kiranico ID match (R5) and the World monster materials.
  - It reports counts, pt-BR misses, unmatched materials and image coverage, and registers the
    assets in `pubspec.yaml`.
- [X] T004 [P] Add the ARB strings of data-model.md › Strings, then run `flutter gen-l10n`.

---

## Phase 2: Foundational

- [X] T005 [P] DTO tests for the optional fields:
  - weapons: `special[].hidden`, `elderseal`, `defenseBonus`, `worldSpecial`, two elements;
  - armor: skill kind `secret`, level 4 decorations, 5 charm ranks.

  Rise and Wilds files still parse unchanged.
- [X] T006 Implement the domain and DTO additions:
  - `WeaponSpecial.hidden`, `Weapon.elderseal`, `defenseBonus` and `worldSpecial`;
  - `augmentSlots` (R7), `WeaponCatalog.specialsOf`;
  - `FilterWeapons` leaves the specials out of the trees;
  - `SkillKind.secret`, and the readers.
- [X] T007 [P] Real-dataset tests in `test/features/{weapons,armor}/data/real_world_*_test.dart`:
  - counts (SC-001), with ≥ 99 % pt-BR;
  - **Dharma Inabalável**: 1344, (Dragão 540) hidden, Alto, +30, slots [1, 1], 1 augment, upgrades
    from Espada Selo Dragão I;
  - the Especiais of Espadão;
  - **Fatalis α+**: 5 pieces of rarity 12, bonus steps 2 and 4;
  - Joia Ataque/Fortitude 4 (Fortitude/Attack Jewel 4) with two skills;
  - Amuleto de Ataque I–V;
  - ≥ 95 % with an image or icon (SC-003);
  - the material and monster match rate is printed.
- [X] T008 `GameIcons` for `Game.worldIceborne`: type, part, slot and decoration. Enable World in
  `EquipmentArea`, add the World controllers in `AppDependencies` and `main.dart`, and wire
  `app_home.dart`, including the World monster "Armas feitas com ele". Update the
  `equipment_area` test, since World is no longer "em breve".

**Checkpoint**: World data loads in both areas.

---

## Phase 3: User Story 1 - Armas do World (P1) 🎯 MVP

- [X] T009 [P] [US1] Widget tests:
  - the World list: World icons, Mestre rank, a hidden element in parentheses in a row;
  - the Dharma detail: hidden note, Selo do Ancião, Defesa, augments, sharpness with Handicraft,
    materials with "Dropado por", the tree; no Rampage or skills card;
  - the Especiais group: a row opens the detail with "Como obter".
- [X] T010 [US1] Implement:
  - the attribute rows (hidden in parentheses, Selo do Ancião, Defesa, Aumentos) in
    `WeaponAttributesSection` and `WeaponRow`;
  - the "Com Artesanato (nível 5)" label for World;
  - the Especiais group card in the World list;
  - the "Como obter" card for specials;
  - the semantics ("Dragão 540, oculto").

---

## Phase 4: User Story 2 - Armaduras do World (P2)

- [X] T011 [P] [US2] Widget tests:
  - the World tabs (Conjuntos, Habilidades, Joias, Talismãs);
  - Fatalis α+ with World part icons, slots 1–4, defense base → max and the bonus card with 2 and
    4 pieces;
  - the "segredo" seal;
  - the Joias level 4 filter and two-skill rows with World colour icons;
  - Talismãs I–V.
- [X] T012 [US2] Implement what remains in the armor views:
  - World part, decoration and slot icons;
  - the secret seal;
  - the slot filter up to 4;
  - the World rank tabs (Baixo, Alto, Mestre).

---

## Phase 5: Polish

- [X] T013 [P] Accessibility: 320 dp at 200 % on the World list, detail, Especiais, set, Joias and
  Talismãs; tap targets and semantics.
- [X] T014 [P] Integration flow: Armas → World → Dharma Inabalável → a material → its monster in
  Monstros; then Armaduras → World → Fatalis α+.
- [X] T015 SC-002 spot check: 10 weapons, 10 sets and 10 decorations against another source.
  Record it in research.md.
- [X] T016 Update `README.md` and `tool/data/README.md`: World equipment, sources, icons, sizes.
- [ ] T017 Gates: analyze, format, test, integration on Windows, Windows release build, web build,
  and APK size (R8 budget).
- [ ] T018 The user runs the quickstart checks 1–9. Fix the findings, then merge into `main`.

---

## Dependencies & Execution Order

- **Setup**: T001 → T002 → T003. T004 runs in parallel.
- **Foundational**: T005 → T006. T007 needs T003 and T006. T008 needs T006. This phase blocks the
  stories.
- **US1**: T009 → T010. **US2**: T011 → T012. US1 and US2 are independent once T008 is done.
- **Polish**: after the stories.

## Parallel Example

- T004 (ARB) alongside T001–T003.
- T005 and T007 tests while the domain is written.
- US1 (T009–T010) and US2 (T011–T012) side by side.

## Implementation Strategy

- **MVP**: Setup + Foundational + US1 (World weapons), checked with Dharma Inabalável.
- Then US2, the armor, which mostly reuses the 010 views.
- Then polish, the user's checks and the merge.
