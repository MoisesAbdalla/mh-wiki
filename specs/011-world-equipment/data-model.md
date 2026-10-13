# Data Model: Armas e Armaduras do World: Iceborne

The schemas are the same as Rise and Wilds (schemaVersion 1); every addition is optional, so Rise
and Wilds files stay valid.

## `assets/data/world_iceborne/weapons.json`

The fields work as in 006 and 010:
- `weaponTypes`, `materials` (with `sources.monsters` from the World monster drops) and `weapons`;
- each weapon: `slug`, `type`, `name`, `description`, `rarity`, `tree`, `treeName`, `attack`
  (displayed), `affinity`, `special`, `slots` (levels 1–4), `sharpness` (`base` and `handicraft`
  at level 5), `previous`, `next`, `forge`, `upgrade`, `stars`, `traits`, `sources` and `image`.

New optional fields:
- `special[].hidden`: `true` for a hidden element or status, e.g.
  `{ "kind": "dragon", "value": 540, "hidden": true }`;
- `elderseal`: `"low" | "average" | "high"`;
- `defenseBonus`: an integer above 0;
- `worldSpecial`: `"kulve" | "kjarr" | "safi"` for weapons outside the trees (research R2). Their
  `tree` is their own slug, and `previous` and `next` are empty.

No `rampageSlot`, `skills` or `artian`.

## `assets/data/world_iceborne/armor.json`

The same as 010:
- `skills[]` with `kind` `armor`, `set` or `secret` (**`secret` is new**);
- `decorations[]` with `slotLevel` from 1 to 4, one or two `skills`, and `icon` (the colour);
- `sets[]` with `rank` (low, high, master) and `bonus` (`skill` and `steps` by pieces, with name and
  description); there is no `groupBonus` in World;
- `pieces[]` with `defense`, `maxDefense`, `resistances`, `slots`, `skills`, `forge` and `image`;
- `talismans[]` with ranks 1–5, each with rarity, skills and forge.

## Domain

- **`WeaponSpecial`**: `+ hidden` (bool, default `false`).
- **`Weapon`**:
  - `+ elderseal` (`Elderseal?` enum: low, average, high);
  - `+ defenseBonus` (int, 0 by default);
  - `+ worldSpecial` (`WorldSpecial?` enum: kulve, kjarr, safi);
  - `augmentSlots`, derived: World rarity 10 → 3, 11 → 2, 12 → 1, otherwise 0.
- **`WeaponCatalog`**: `+ specialsOf(type)`, the special weapons in order: kulve, kjarr, safi, then
  name.
- **`FilterWeapons`**: leaves `worldSpecial` weapons out of the trees, as with `gogma`.
- **`SkillKind`**: `+ secret`.

## Presentation

- **`GameIcons`**:
  - `weaponType`, `armorPart` and `slot` for `Game.worldIceborne`, using `assets/images/world/…`
    (rarity 0–12);
  - `decoration(level, color)` for World.
- **Weapon detail**:
  - an Elderseal row and a defense bonus row;
  - a hidden element in parentheses, with a note;
  - an augments row (Mestre).
- **Especiais group**: `WorldSpecialGroup` at the end of a World type's list. A tap opens the normal
  detail with a "Como obter" card.
- **Strings (ARB)**:
  - `elderseal`, `eldersealLow/Average/High`, `defenseBonus`;
  - `hiddenElementNote`, `augmentSlots`;
  - `worldSpecials`, `specialKulve/Kjarr/Safi`, `specialHowTo…`;
  - `skillKindSecret`.
