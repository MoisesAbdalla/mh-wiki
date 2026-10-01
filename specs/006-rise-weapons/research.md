# Research: Armas da Rise: Sunbreak

Decisions for the 006 plan. Each has the decision, the rationale and the alternatives.

## R1. Source of the weapon data

- **Decision**: The **Monster Hunter Wiki** MHRS weapon pages are the main source. Kiranico adds the
  pt-BR names and the icons.
  - Each wiki page (e.g. `Gnashing Flammenzahn+ (MHRS)`) has a structured `{{GenericWeapon}}`
    template with these fields: `Weapon Type`, `Tree` ("Anjanath Tree"), `Rarity`,
    `Description`, `Attack`, `Affinity`, `Level N Decos`, `Elemental Damage` /
    `Elemental Damage Type`, the `Sharpness` bar with the Handicraft extension (`HW`, `HB`…),
    `Rampage Decoration` level, `Previous Name`, `Next N Name`, the forge/upgrade materials with
    quantities, and costs.
  - The pages are listed by the categories `MHRS <type>` (e.g. `MHRS Sword and Shield`) and read
    40 per API request. That is about 100 requests for the whole catalog, cached like the other
    wiki queries in `tool/data/.cache/`.
  - Kiranico weapon lists (`/data/weapons?view=0..13`, en and pt-BR: 28 pages) give the
    Kiranico id, the pt-BR name, the icon URL (`avatar/weapons/<id>.webp`) and a second copy of
    attack, element, affinity, slots and sharpness for cross-checking.
- **Rationale**:
  - Kiranico has no upgrade tree. Its "Previous / Next" links are only the neighbours in the
    list (`rel="prev"`, e.g. Gnashing Flammenzahn+ → Lohenzahn happens to match, but most do
    not). Its materials need one page per weapon (~3,950 pages, more than an hour of polite
    fetching).
  - The wiki gives the real tree and the materials in about 100 requests.
- **Counts**: per type, the wiki categories match the Kiranico lists exactly (Great Sword 282,
  Long Sword 300, Bow 313…). The one exception is Sword and Shield (287 vs 286): the extra page
  is found by name matching and left out. The total is about 3,950 weapons.
- **Alternatives**: Kiranico detail pages (no tree, too many pages); a single source for
  everything (the wiki has no pt-BR names).

## R2. What counts as obtainable

- **Decision**: Kiranico rows with attack 0 are excluded. There are 28, such as "Stuffed Rathalos"
  (description `#Rejected#`). A weapon is also excluded when no wiki page matches it.
- **Rationale**: FR-003 / SC-001. These are cut items left in the game data.

## R3. Rank and quest stars

- **Rank: exact, from rarity.** In Sunbreak, rarity 1–3 is Low Rank, 4–7 High Rank and 8–10
  Master Rank. The wiki's own summary confirms it (Gnashing Flammenzahn+, rarity 8: "a Master
  Rank (MR) Great Sword"). **Correction to the mockup**: it labelled that weapon "High Rank".
- **Stars: estimated** (FR-005).
  1. Each forge or upgrade material that the Rise dataset knows as a monster drop (by English
     name) points to the monsters that drop it at the weapon's rank.
  2. For each such monster, take the lowest quest star of that rank. The source is the quest
     table already cached from the Kiranico monster pages, where Village and Gathering Hub
     1–3★ are Low, Hub 4–7★ High and MR 1–6★ Master, as in `hp_extract.py`.
  3. The weapon's stars are the **highest** of those values: the hunter needs every material,
     so the last monster unlocked decides.
  4. Weapons whose materials come from no known monster (ores, bones) get the first star of
     their rank.
  5. The value is stored with `estimated: true` and the rule above, and the app shows it as an
     estimate.
- **Rationale**: the sources do not say when each weapon unlocks. The progress picker of 008
  needs a number per weapon.
- **Alternatives**: no stars at all (008 would have only the rank); manual curation of about
  3,950 weapons (not sustainable).

## R4. Weapon trees in the list

- **Decision**: group by the wiki's `Tree` field. Inside a tree, order the weapons by walking the
  graph from its roots (weapons without a previous weapon in the tree), depth first, siblings by
  rarity then name. The indent equals the depth, capped at 3 levels in the list; the detail shows
  the full path.
- Trees that span ranks (Low → Master) stay one card. Filtering by rank keeps only the weapons of
  that rank inside each card, and empty cards are hidden.
- Weapons whose `Previous` lies in another tree keep their own tree's card, and the link still
  works.
- The tree is built in the domain layer (`WeaponTree`), with unit tests: cycles are rejected and
  missing previous weapons become roots.

## R5. Sharpness

- **Decision**: store the 7 segments (red → purple) in game units (hits ×10, from the wiki
  `SharpnessBar` values) plus the Handicraft extension. "Max Handicraft" is the base bar plus
  `HR…HW` added to the last colours, as the wiki template draws it.
- The UI draws both bars on a fixed scale of 400 units, the maximum, so weapons compare
  visually.
- Bows and bowguns have no sharpness (the template field is absent) and the card is hidden.

## R6. Data files and loading

- **Decision**:
  - A new `tool/data/build_rise_weapons.py` writes `assets/data/rise_sunbreak/weapons.json`:
    `schemaVersion` 1, `game`, `sources`, `weaponTypes` (14 with en/pt-BR names),
    `materials` (id, names) and `weapons`.
  - Icons go to `assets/images/weapons/rise_sunbreak/<slug>.webp`, 96 px, so about 3,950 small
    files of ~5 KB, roughly 20 MB.
    - **Size check**: the APK grows by about 20 MB, from about 25 to 45 MB. This is noted
      against research R6 of feature 004.
    - **Fallback**: if that is judged too large in review, the icons can be grouped per type
      in a sprite. The weapon renders on the wiki are larger and not used.
- **Loading**: a separate `WeaponRepository` / `AssetWeaponDatasource`. It decodes off the UI
  thread (`compute`, as monsters do since 004) and loads on first entry into the Armas area,
  not at app start. A failure produces a `Failure` shown only in that area (FR-011).

- **Results (T035, 2026-10-01)**:
  - Release APK, arm64 (`flutter build apk --release --analyze-size --target-platform
    android-arm64`): **31.4 MB** in total, 13 MB of it `flutter_assets`. That is below the
    ~45 MB estimate: the WebP icons barely compress, but they are smaller than estimated, and
    the JSON compresses well.
  - `weapons.json` is 5.5 MB with 3,925 weapons and 1,204 materials. 3,799 weapons (96.8 %) have
    an icon (SC-007), and 126 icons return 404 on Kiranico. All 14 type icons are bundled.
  - Opening the Armas area (load, decode in an isolate, first build), from the Windows
    integration run in debug mode: **882 ms**. The monster lists load in 459 ms in the same run.

## R7. Link to monsters

- **Decision**: material ids use the same slug rule as the monster datasets, so a weapon
  material equals a monster drop material by id. A use case in the app composition layer,
  `GetWeaponsUsingMaterialsOf(monster)`, crosses the two catalogs. The monsters feature does not
  import the weapons feature: the detail view receives an optional `extraSections` builder from
  the page that owns both controllers.
- **Rationale**: Constitution I/III. Features stay independent, and the link lives in the
  composition root.

## R8. Navigation between areas

- **Decision**: a new `AppShell` in `lib/app/`.
  - Below 840 dp (the existing breakpoint) it uses a `NavigationBar`, and from 840 dp a
    `NavigationRail`.
  - Destinations: Monstros, Armas, Armaduras (disabled), Assistente (disabled, with an
    "em breve" tooltip and semantics).
  - An `IndexedStack` keeps each area's state (FR-012).
  - Styled with the 005 tokens: gold for the selected item, IM Fell labels.
- **Rationale**: the platform widgets bring accessibility and adaptive behaviour. Disabled
  destinations are rendered as visible but not selectable.

## R9. Weapon type names in pt-BR

- **Decision**: take the pt-BR type names from Kiranico's pt-BR navigation, which uses the
  official localisation. Fall back to the community names in the spec's entity list when one is
  missing.
- Type icons are the in-game weapon type icons from the wiki (`MHRS-<Type> Icon`), converted to
  WebP. They are only 14 files.

## R10. Performance

- About 300 weapons per type are shown at once (one type at a time), in at most ~45 tree cards.
  The list uses a lazy builder over cards, and the rows inside a card are built eagerly (≤ 25
  per card).
- Search over ~3,950 names uses names normalized once at load, as `FilterMonsters` does.
- The 004 performance test pattern is extended with a synthetic catalog of 4,000 weapons: the
  list builds and a type switch settles within the frame budget, and a query takes under 50 ms.

## R11. Tests to add

- **Domain**:
  - the `WeaponTree` build (order, depth, roots, branches, cycle rejection);
  - `FilterWeapons` (type, rank, search);
  - the stars estimate is surfaced, not computed, in the app.
- **Data**:
  - DTO validation;
  - a real-dataset test: 14 types, counts equal to the Kiranico lists minus the excluded rows,
    no zero-attack weapon, every `previous` and `next` resolves, no cycles, ≥ 95 % icons
    (SC-007).
- **Presentation**: the list (tree cards, filters, search, empty state), the detail (4 cards,
  ranged weapons without sharpness, material → monster link), the monster's "Armas feitas com
  ele" card, the `AppShell` (disabled areas, preserved state, rail on wide screens) and
  accessibility at 320 dp / 200 %.

## R12. Kiranico weapon pages as the materials and sharpness source

- **Finding (T036 spot check)**: 21 weapons, at least one per type, were compared field by field
  with their Kiranico pages. Attack, element/status, affinity, slots and Rampage slot all matched.
  These fields differed:
  - **Handicraft sharpness**: in 217 weapons, the wiki's `SharpnessBar` has no Handicraft values,
    so the Handicraft bar repeated the normal one. For example, Buster Blade showed green 50
    instead of 100.
  - **Materials**: in 2 of 21 weapons the wiki differed from the game. It left out
    `Anjanath Scrap+` on Flammengewehr I and listed an extra `Rajang Apoplexy` on Le Miracle.
- **Decision**:
  - `tool/data/fetch_rise_weapon_pages.py` caches the 3,925 Kiranico weapon pages, with 4
    requests at a time; one pass takes about 35 minutes.
  - `build_rise_weapons.py` then takes from those pages the forge and upgrade materials with
    their quantities, and both sharpness bars (SVG widths × 5 units).
  - The points requirements ("Anjanath Material(s) x10 pts.") still come from the wiki, because
    Kiranico does not list them. They are now one material per monster (`anjanath-material-s`),
    with the points in the cost.
  - Without a cached page, the builder falls back to the wiki.
- **Result**: after the rebuild, all 21 weapons match on every field. 108 melee weapons have the
  same normal and Handicraft bars in the game data. 57 bonus weapons (Champion, Guardian,
  Hand-Me-Down) have no materials, as in the game.

## R13. Type traits and material sources (US4, US5)

- **Type traits**: the Kiranico weapon lists (en and pt-BR, already cached for the names) have a
  type-specific cell per weapon. Each row is the page slice between two weapon icons, because the
  bowgun ammo tables nest `<tr>`. What is read:
  - Charge Blade and Switch Axe: the phial ("Impact Phial" → "Impacto");
  - Gunlance: the shelling ("Amplo 6");
  - Insect Glaive: the kinsect level;
  - Hunting Horn: three songs;
  - Bow: the arc shot (green), the charge shots and the coatings (grey means locked or unusable);
  - bowguns: deviation, recoil, reload, and the ammo table.
  Ammo names come as English abbreviations on both pages ("Nrm", "Fir/P."), so the app translates
  them (`AmmoKind`). Every weapon of these 8 types has its traits.
- **Material sources**: `tool/data/fetch_rise_item_pages.py` caches the en and pt-BR Kiranico item
  page of the 1,076 items the weapons use (~20 min, 4 requests at a time). The builder keeps:
  - "Locale": the best rate per map and rank;
  - "Monsters": the best row per monster and rank, with `slug` when it is a large monster of the
    app, else `small`;
  - "Quests": category, stars and the best rate.
  en and pt-BR rows pair by position. Quests carry no rank, because the categories do not map
  reliably to one, so they are always shown.
- **Coverage**: 946 of 1,204 materials have sources: 47 gathering, 113 small monsters, 780 large
  monsters, 456 quests. The rest are:
  - points requirements, which already link to their monster in the app;
  - scraps, tickets and some endemic life, whose Kiranico pages list no source. These show
    "Origem desconhecida".
- `weapons.json` grows from 5.5 to 8.3 MB.
- **Spot check**: Novacrystal, Lightcrystal, Dragonite Ore, Guild Ticket, Izuchi Pelt+ and
  Bird Wyvern Gem match their Kiranico pages: maps, ranks, best rates, monsters and quests.
