# Contract: "Caderno do Caçador" UI

Visual reference: prototype A (canvas "MH Wiki — Direções de Design"). This contract updates
[001 ui-contract](../../001-monster-wiki/contracts/ui-contract.md); behaviour there is unchanged
(FR-012).

## Global

- Fixed dark theme; ignores the system brightness (FR-001).
- Titles, section headings, tabs: Cinzel, gold, letter-spaced, uppercase for section headings.
- Body: Alegreya Sans, `#EFE4C8`; secondary text `#B9A67F`.
- Panels (`HunterPanel`): `#1F1812` fill, 1 px `#5A4526` border, square corners, 16 px padding,
  heading inside in Cinzel.

## MonstersPage (list)

- App bar: "MH WIKI" (Cinzel, gold) with subtitle "Caderno do Caçador"; settings button (framed
  circle, ≥48 dp).
- Search field: framed, dark fill, gold icon.
- `GameTabs`: 4 equal tabs; active = gold fill with dark text; inactive = gold outline text.
- "Todos": `OrnamentHeader` per game (line — "WORLD : ICEBORNE" — line).
- List tile: thumbnail (48 dp, gold frame) · name (bold) + classification · primary-weakness
  badge (element color outline, element icon, element name) when present.
- Loading, empty and error states use the same panel/typography.

## Monster detail

- Header: thumbnail 104 dp in a double gold frame; name in Cinzel 30; classification; game label.
- Weakness panel: 5-column grid, each cell = element icon (element color) + name + stars or ✕;
  immune shows the "Imune" badge; cells of `mostEffective` get a gold frame and brighter text;
  per-state blocks below as before.
- Habitat and Parts panels side by side when the content width ≥ 360 dp, stacked otherwise;
  "Cortável" = small gold tag.
- Materials panel: rank tabs in the `GameTabs` style (smaller); rows as before (method left,
  rate right in gold).

## Settings

- Same app bar and panels; radio options in gold.

## Accessibility (unchanged rules, FR-011)

- Semantics labels kept ("Fogo: 3 de 3", "Gelo: imune"); tabs expose `selected`.
- ≥48 dp targets; 200% text without overflow at 320 dp; `textContrastGuideline` passes.
