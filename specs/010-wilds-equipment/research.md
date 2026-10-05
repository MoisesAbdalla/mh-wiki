# Research: Armas e Armaduras da Wilds

## R1. Equipment data

- **Decision**: wilds.mhdb.io, fetched in `en` and `pt-BR` and cached in `tool/data/.cache/`.
  - **Weapons** (1,188, all 14 types): name, rarity, `damage.display`, affinity, element or status
    (`specials`), sharpness and handicraft, slots, weapon skills, forge and upgrade materials, and the
    tree (`crafting.previous` and `branches`).
  - **Armor sets** (194): pieces with part, rank, rarity, slots, defense (base and max),
    resistances, skills and materials. A set also has a set bonus (steps of 2 and 4 pieces) and a
    group bonus (3 pieces).
  - **Skills**, with their kind (`weapon`, `armor`, `set`, `group`) and levels.
  - **Decorations** (361), with kind `weapon` or `armor`, slot 1–3, and one or two skills.
  - **Talismans** (64), with ranks I, II, III… Each rank has a skill, a rarity and materials.
- **Rationale**: the pt-BR names are the game's own. The data is structured (no scraping), and
  checked: Sieglinde, Arkveld α and the charms match the game.
- **Alternatives**:
  - Kiranico Wilds: complete, but a client-rendered site that is hard to parse.
  - The wiki's `Module:MHWilds/data/*.json`: rich, but en only. It is used for icons, renders and
    Artian (R2, R3).

## R2. Artian weapons

- **Decision**:
  - **Primary**: the wiki's `Module:MHWilds/data/Weapons.json`. Its trees include `Artian` (the
    weapon module skips that tree in normal listings), with base stats per type and rarity.
  - **Fallback and check**: the Game8 Artian page of each type, for example Great Sword
    `502879`: Artian Blade I 816, II 864, Varianza 912; element 450, or Poison and Blast 300, or
    Sleep and Paralysis 250; slots ②②② at rarity 6–7 and ③③③ at rarity 8.
  - **Rules**, from the Game8 guide `503103`:
    - **Production**: 3 parts. Three parts of the same element give an element infusion (+20 to +30
      element, depending on the type). Otherwise each part gives Attack (+5 raw) or Affinity (+5%).
    - **Reinforcement**: 5 random rolls. Each roll is one of Attack +5 (up to 5), Affinity +5% (up
      to 3), Element (+20 to +80 depending on the type, up to 4), Sharpness +30 (up to 2), or Ammo
      +1 (bowguns only, up to 2).
  - **Task**: confirm the infusion and element-boost values for each type, record them in the
    dataset, and keep the source.
- **Rationale**: mhdb has no Artian. The wiki data is structured; Game8 gives readable tables to
  check it against.

## R3. Wilds icons and images

- **Decision**:
  - **Equipment icons by rarity**: the wiki's `MHWA-<Kind>_Icon_Rare_<N>.png` files. They cover
    Helmet, Chestplate, Armguards, Waist, Leggings, Talisman, the 14 weapon types, and the Artian
    parts (Relic Blade, Device, Disc, Tube).
    - They are fetched for rarities 1–8.
    - They are saved as 64 px WebP in `assets/images/wilds/icons/<kind>-<rarity>.webp`.
    - Each part name maps to our part: Helmet → head, Chestplate → chest, Armguards → arms,
      Waist → waist, Leggings → legs, Talisman → talisman.
  - **Decoration icons**: the wiki's `MHWilds-Decoration_Level_<1–3>-Sword|Armor_Icon_<Color>.png`
    files. The colour is the one mhdb gives each decoration (`icon.color`).
  - **Slot icons**: the base `MHWilds-Decoration_Level_<N>_Icon_Base`, tinted gold in the app's
    style, so they match the Rise slot icons.
  - **Weapon images**:
    - from the wiki's `Module:MHWilds/data/Weapons/RendersDict.json` (renders by tree or name);
    - otherwise from Kiranico Wilds (`tex_thumbnail`);
    - otherwise the type's rarity icon.
  - **Armor piece images**: Kiranico Wilds `tex_thumbnail` renders, like the Rise piece renders in
    007. The equipment rows use the part's rarity icon.
- **Rarity colour table** (wiki `GameColorLookup`, MHWilds): it is kept in the builder's
  SOURCES.md for reference. The `Rare_N` files already come in the right colours, so the app does
  not tint them.
- **Rationale**: these are the game's own icons, in the Wilds colour table, as the user asked.

## R4. Materials to monsters

- **Decision**: material ids are the slug of the English item name (`Rathian Scale+` →
  `rathian-scale-plus`). That is how `assets/data/wilds/monsters.json` names drops, so the existing
  `MonsterMaterialIndex` gives "Dropado por" and "Armas feitas com ele" with no new code.
- **Task**: measure how many weapon and armor materials match a Wilds drop, and report the rest.
  Ores, Hunter's Symbols and other gathered items have no monster.

## R5. Architecture

- **Datasets**: `assets/data/wilds/weapons.json` and `armor.json` use the same schemas as the Rise
  files, with optional additions (data-model). The readers accept them. Rise data is unchanged.
- **Areas with game tabs**: Armas and Armaduras get the existing `GameTabs` (logos).
  - Each game has its own controller (`game: Game.wilds`).
  - The pages sit in an `IndexedStack`, so each game keeps its state.
  - A game's controller is built on that tab's first visit.
  - World shows "em breve".
- **Feature code**: `weapons` and `armor` gain Wilds-aware entities and widgets:
  - weapon skills;
  - set and group bonuses;
  - decoration kind;
  - talismans;
  - an `artian` sub-module in `weapons` (the simulator is a pure domain function).
- **Persistence**: saved Artians are kept in `weapons.wilds.myArtians.v1` (versioned JSON), like
  the 008 saved builds.

## R6. Tests

- DTO tests for the new fields, real-dataset tests (counts, Sieglinde, Arkveld α, a two-skill
  decoration, a talisman with ranks), and Artian simulator unit tests (limits, 5 combinations from
  Game8, SC-004).
- Widget and accessibility tests for the game tabs, the weapon skills card, the set bonus card, the
  Joias filters, Talismãs and the simulator.
- The integration flow is extended: Armas → Wilds → Sieglinde → skill → Armaduras.

### R2 results (T004, 2026-10-05)

- **Corrected rule**, from the wiki page "Artian Weapons (MHWilds)": the weapon has an element only
  when **at least 2** of its 3 parts share it. With all 3, it also gets the Element Infusion.
  Otherwise it has no element. Each part also carries its own Artian bonus: Attack +5 raw, or
  Affinity +5%.
- **Values** (wiki tables; displayed attack = raw × the type multiplier from mhdb):

  | Type | Attack R6/7/8 | Element R6–7 → R8 | Infusion | Element boost |
  |------|---------------|-------------------|----------|---------------|
  | Great Sword | 816/864/912 | 300 → 450 | +30 | +80 |
  | Long Sword | 561/594/627 | 230 → 270 | +30 | +50 |
  | Sword & Shield | 238/252/266 | → 260 | +20 | +30 |
  | Dual Blades | 238/252/266 | → 250 | +20 | +20 |
  | Hammer | 884/936/988 | → 320 | +30 | +50 |
  | Hunting Horn | 714/756/798 | → 320 | +30 | +50 |
  | Lance | 391/414/437 | → 270 | +30 | +50 |
  | Gunlance | 391/414/437 | → 320 | +30 | +50 |
  | Switch Axe | 595/630/665 | → 260 | +20 | +30 |
  | Charge Blade | 612/648/684 | → 270 | +30 | +50 |
  | Insect Glaive | 527/558/589 | → 260 | +20 | +30 |
  | Bow | 204/216/228 | 180 → 210 (Blast 30 → 60; other statuses give coatings) | +20 | +30 |
  | Light / Heavy Bowgun | 221–247 / 255–285 | none (ammo) | — | — |

  - Status values: Poison and Blast are the element value −150; Paralysis and Sleep are −200.
  - Sharpness boost: +30, or +20 for the Insect Glaive.
  - Ammo: +1 for bowguns.
  - Limits: Attack ×5, Affinity ×3, Element ×4, Sharpness ×2, Ammo ×2. There are 5 rolls.
- **Check against Game8**:
  - Great Sword 816/864/912 with element 450, and Long Sword 561/594/627 with 270: both match.
  - The wiki's Long Sword rarity 8 shows 643, which is a wiki typo; raw 190 × 3.3 = 627.
- **pt-BR names**: from Kiranico, for example Lâmina Artiana I, Varianza, Sabre Artiano I,
  Dimensius.
- **Gogma Artian**: the second rarity-8 Artian of each type (for example Ostrak Oblivion) is already
  among the normal weapons from mhdb. It is not part of the simulator.

### R1/R3/R4 results (T001–T003)

- **Weapons**: 1,188, all with pt-BR names. 1,138 have a render; the rest use the type icon by
  rarity.
- **Armor**: 183 sets with pieces. The 11 skipped sets are cosmetic-only entries with no pieces.
  - 714 pieces, all with pt-BR names; 602 have a Kiranico render, and the rest use the part icon by
    rarity.
  - 179 skills, 361 decorations (each with its Wilds icon) and 64 talismans.
- **Materials matched to Wilds monster drops**: weapons 276 of 311, armor 348 of 431. The rest are
  ores, bones and other gathered items, which have no monster.
- **Icons**:
  - 181 `MHWA` rarity icons. The Relic part icons exist only for rarities 6–8.
  - 69 decoration icons. Colours the wiki spells differently are aliased, and missing ones are
    tinted from the white icon.
  - 4 slot icons.
  - Images take 3.3 MB in total. The datasets take 1.6 MB (weapons, with Artian) and 1.3 MB (armor).

