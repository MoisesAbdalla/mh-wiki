# Research: Armas e Armaduras do World: Iceborne

## R1. Weapon data

- **Decision**: use the wiki's `Module:MHWI/data/Weapons.json` (`action=raw`), cached in
  `tool/data/.cache/`. It has 3,123 weapons of the 14 types, rarity 1–12, World and Iceborne.
  - **Fields**:
    - `Name`, `Type` (GS, LS, SnS, DB, Hm, HH, Ln, GL, SA, CB, IG, LBG, HBG, Bo), `Rarity`;
    - `Attack` (true raw), `Affinity`, `Defense`, `Elderseal`;
    - `Element1/ElementDmg1` and `Element2/ElementDmg2` (status is an element);
    - `Decos1..4` (number of slots of each level);
    - `Sharpness` (`[base 7 colours, Handicraft additions]`);
    - `PreviousName` and `Next1..3Name`, `Tree` and `RootTree`;
    - `ForgeMaterials`, `UpgradeMaterials` and their costs;
    - `Description`;
    - the type traits: `CbPhialType`, `SaPhialType`, `GlShellingType` and `GlShellingLevel`,
      `IgKinsectBonus`, `HhNote1..3`, `BoCoatings`, and the bowgun deviation and special ammo.
  - **Rules**:
    - A **hidden** element comes in parentheses: `(Dragon)` / `(54)`.
    - Element values are stored /10, so `54` displays as 540.
    - Displayed attack = raw × the type multiplier: GS 4.8, LS 3.3, SnS 1.4, DB 1.4, Hm 5.2,
      HH 4.2, Ln 2.3, GL 2.3, SA 3.5, CB 3.6, IG 3.1, LBG 1.3, HBG 1.5, Bo 1.2. Check: Immovable
      Dharma 280 × 4.8 = 1344.
    - **Handicraft**: the second sharpness array is what 5 levels add; the max bar = base + that.
- **Rationale**: mhw-db.com stops at rarity 8 (1,299 weapons, base World only). The wiki module is
  structured (no scraping) and complete through Iceborne. 006 already took Rise stats from the wiki.
- **Alternatives**:
  - mhw-db weapons: no Iceborne.
  - The Kiranico pages per weapon: about 3,000 pages to scrape.

## R2. Especiais (Kulve Taroth, Kjárr, Safi'jiiva)

- **Decision**: weapons with `Tree == "Unavailable"` (586) are the specials:
  - Kulve Taroth (`Taroth …`, the R7–8 Kulve weapons);
  - Kjárr (`Kjárr …`);
  - Safi'jiiva (`Safi's …`).

  The builder tags them with `special: kulve | kjarr | safi`. The app lists them in an "Especiais"
  group per type, outside the trees, read only, like the Gogma Artian of 010. The detail shows the
  stats from the source and how to get them:
  - Kulve Taroth and Kjárr: random rewards from the Kulve Taroth siege;
  - Safi'jiiva: crafted, then awakened with Safi'jiiva Dragonvein Crystals.

  The awakened abilities are not simulated.
- **Rationale**: the user's decision ("Grupo Especiais"). Their "trees" in the source are fake
  (`Unavailable`).

## R3. Armor data

- **Decision**:
  - **Sets and pieces**: the wiki's `Module:MHWI/data/Armor.json`. It has 360 sets and 1,638
    pieces, with:
    - name, rarity, part (`IconType`);
    - `Defense` and `MaxDefense`, the five resistances, `Decos1..4`;
    - skills with level, materials and forging cost;
    - the set skill (`SetSkill1/2`, names only);
    - male renders.
  - **Rank** from rarity: 1–4 Baixo, 5–8 Alto, 9–12 Mestre.
  - **Set bonus steps** (pieces → skill and description) from mhw-db.com `armor/sets` (`bonus.ranks`),
    matched by the bonus name. For example, Fatalis Legend: 2 pieces give Inheritance, 4 pieces give
    Transcendence.
- **Rationale**: the wiki gives the max defense that mhw-db lacks for Fatalis (`max: 0`) and some
  Iceborne pieces. mhw-db gives the structured bonus steps.

## R4. Skills, decorations and talismans

- **Decision**: from mhw-db.com:
  - `skills`: 181, with ranks and descriptions;
  - `decorations`: 405, slot 1–4, with one or two skills (level 4 combos such as Attack/Fortitude
    4);
  - `charms`: 109, with ranks 1–5. Each rank has a rarity, skills, and materials (`crafting`).
- **Skill kind**:
  - `set` when the skill appears as a set bonus step;
  - `secret` when its name ends in "Secret" (Agitator Secret …);
  - `armor` otherwise.
- **Decoration colour**: from the wiki's `Module:MHWI/data/Decorations.json` (the icon colour). If
  it is missing, the colour of the main skill.

## R5. pt-BR names

- **Decision**: Kiranico World, which lists the same IDs in `/en/` and `/pt-BR/`:
  - `weapons?type=0..13` gives one page per type, about 270–280 rows each;
  - `armorseries`, `skilltrees` and `decorations` give the rest.

  The en name links each row to the wiki or mhw-db name.
  - **Materials**: reuse the World monster dataset's `materials` (703, already en + pt-BR).
  - **Talisman names**: Kiranico has no charms list (404). Take them from the item pages
    (`items`, names like "Amuleto …"). If a name is missing it stays in en and is counted in the
    build report.
- **Target**: ≥ 99 % with pt-BR (SC-001). The report lists any misses.

## R6. World icons and images

- **Decision**: the wiki's MHWI set.
  - **Weapon type by rarity**: `MHWI-<Type>_Icon_Rare_<0..12>.png`, saved as
    `assets/images/world/icons/<type>-<rarity>.webp` (64 px).
  - **Armor part by rarity**: `MHWI-Helmet|Chestplate|Armguards|Waist|Leggings|Talisman_Icon_Rare_<N>`,
    saved as `world/icons/<part>-<rarity>.webp`.
  - **Decorations by level and colour**: `MHWI-Decoration_Level_<1–4>_Icon_<Color>`, saved as
    `world/decorations/<level>-<color>.webp`.
  - **Slots**: `MHWI-Decoration_Level_<N>_Icon_Base`, tinted gold as in 010, saved as
    `world/slots/slot<N>.webp`.
  - **Weapon renders**: `MHWI-<Name>_Render.png`, at 96 px WebP. **Armor renders**: the module's
    male piece renders, at 96 px. If the size budget is exceeded (R8), renders are cut first; rows
    already use the rarity icons.
- **Rationale**: the user asked for each game's own look, the same approach as 010.

## R7. Augments (Iceborne)

- **Decision**: augment slots by rarity, a fixed game rule: 10 → 3, 11 → 2, 12 → 1. Safi'jiiva and
  Kjárr follow their rarity. The app derives it in the domain from rarity and game; it is not stored.
  Only the count is shown.

## R8. Size and performance

- **Estimates**:
  - `world_iceborne/weapons.json`: about 4–5 MB;
  - `armor.json`: about 2 MB;
  - icons: about 1 MB;
  - renders: about 3,000 + 1,600 at roughly 3 KB each, about 12 MB.
- **Budget**: the APK grows by ≤ 20 MB. If it goes over, drop the armor renders, then the weapon
  renders.
- **Performance**: as in 010, each dataset is loaded on its tab's first visit. Trees are built once
  per type, so the 1 s list target holds (SC-004).

## R9. Tests

- **DTO tests**:
  - hidden element, Elderseal, defense bonus, two elements;
  - sharpness with Handicraft;
  - `special`, set bonus steps, skill kinds, level 4 decorations, charm ranks.
- **Real-dataset tests**:
  - counts;
  - Immovable Dharma (1344, (540), Alto, +30, ①①, 1 augment);
  - Fatalis α+ bonus steps 2 and 4;
  - Attack/Fortitude Jewel 4 with two skills;
  - Attack Charm I–V;
  - ≥ 99 % pt-BR, ≥ 95 % with an icon or render.
- **Widget tests**: the World list, the Especiais group, the detail (hidden element note, augments),
  and the set bonus card.
- **Accessibility**: 320 dp at 200 %. **Integration**: Armas → World → Dharma → material →
  Shara Ishvalda; then Armaduras → World → Fatalis α+.
