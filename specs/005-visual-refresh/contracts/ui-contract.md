# Contract: "Caderninho" UI

What each screen must show and announce after 005. Reference:
[mockups/approved.html](../mockups/approved.html).

## App bar

- The title is "Caderninho" in the title font, size 24, colour `text`. There is no subtitle.
- The settings action keeps its icon, tooltip and semantics.

## Game tabs (list)

- Order: "Todos" (text), then the World: Iceborne, Rise: Sunbreak and Wilds logos, about 46 dp
  tall.
- Selected tab: full colour, with a 2 dp gold underline.
- Unselected tabs: text in `textMuted`; logos at 55 % opacity with reduced saturation.
- Minimum tap target 48 × 48 dp. The row scrolls horizontally when it does not fit; it never
  wraps or shrinks the logos below 40 dp.
- Semantics: each tab is a button with `selected`. A logo tab's label is the game's full name
  ("Monster Hunter World: Iceborne", "Monster Hunter Rise: Sunbreak", "Monster Hunter Wilds").
- If a logo fails to load, the tab shows the game's short name as text.

## List

- Each row is a card (revision after US1): `panel` background, 1 dp `borderSubtle` edge,
  4 dp corners, 8 dp between cards.
- Each row shows, from left to right:
  - the thumbnail (44 dp);
  - the name in the title font, 18;
  - the classification and "N versões" in body small, `textMuted` (the count in Averia);
  - the primary weakness at the right, as the element symbol in the element colour plus the
    element name.
- Selected row (expanded layout): `panelHighlight` background and a gold edge.
- "Todos": each game block starts with a caption row, the game name in the title font 16 with a
  hairline. There is no ornament.
- The count line ("71 monstros · 46 versões") stays if it exists today. Otherwise it is out of
  scope.
- Loading, empty and error states use plain text, icons and the title font, with no panels.
- Semantics are unchanged from 004: "<name>, <classification>, N versões"; the primary weakness
  is read as "<elemento>".

## Detail header

- Thumbnail plate: 92 dp, 1 dp `border`, rotated +3°, no shadow.
- Monster name: title font, 40 (32 below 360 dp), wraps to at most 3 lines.
- Classification and habitats: body, `textMuted`.
- The game name is not shown above the name.
  - Compact layout (full page): the back row shows "‹ Monstros" and, at the right, the game
    name, because there are no tabs on that page.
  - Expanded layout: the game name shows only when the list filter is "Todos".
- Version tabs: `UnderlineTabs` with text labels, as in 004, restyled. Semantics: "Versão:
  <label>", selected.

## Numbered sections

- Order: 1 Fraquezas, 2 Vida, 3 Itens de caça, 4 Materiais, 5 Habitat, 6 Partes.
- Title row: the number in Averia 18 gold, then the title in the title font 20. Optional
  right-aligned note in body small italic `textMuted`: "igual à forma base" for inherited
  sections, or the rank for single-rank HP and materials.
- Each section is a card: `panel` background, 1 dp `borderSubtle` edge, 4 dp corners, 16 dp
  inner padding, 12 dp between cards. Inside, rows are ruled. Cards are never nested.
- Semantics: the title is a header. The note is read after the title.

## 1 Fraquezas

- Five rows ordered by `WeaknessProfile.ranked`. Each row, left to right:
  - the element symbol (20 dp, element colour);
  - the element name (body, bold when best);
  - for best rows, a "Melhor" stamp;
  - at the right edge, three star icons (filled `text`, empty `textDisabled`; gold when best), or
    "Imune" in `textMuted` for immunity. 0 stars shows three empty stars.
- A 1 dp rule separates rows.
- Per-state weaknesses (e.g. Alatreon) follow under a caption with the state name, using the
  same rows and no highlight.
- Semantics per row: "<elemento>: N de 3" (plus ", melhor fraqueza" when best), or
  "<elemento>: imune" (the existing strings of 002).

## 2 Vida

- With more than one rank, the rank tabs (`UnderlineTabs`) are shown. With one rank, the rank is
  the section note.
- Solo value: Averia 40 bold, with "solo" (and "a partir de" for `minQuest`) in body small
  `textMuted`.
- Ruler (only when party factors exist):
  - a 2 dp axis in `border`, from 0 to the largest estimate;
  - a gold tick at solo;
  - ticks at 2 players and a span (a 6 dp `border` band) for 3–4 players;
  - the values under each mark in Averia 13, with the player count ("1", "2", "3–4") above them.
- At text scale above 1.3 or width below 300 dp, the values are listed under the ruler instead
  of placed along it.
- No HP: "HP desconhecido", with no ruler.
- Semantics: the ruler is excluded from semantics. The section reads "HP solo X; 2 caçadores Y;
  3 a 4 caçadores Z".
- The source line of the factors stays as body small `textMuted`.

## 3 Itens de caça

- Ruled rows: the item name at the left, the reaction at the right (bold `text`), with detail
  text after a middle dot.
- Vision is the first row. Semantics are unchanged from 003.

## 4 Materiais

- Rank tabs when there is more than one rank.
- Groups from `Monster.dropsByMethod(rank)`. Each group has:
  - a caption row in body small upper case `textMuted` with the method label;
  - ruled rows: the material name (plus rarity in `textMuted`) at the left and the rate at the
    right (Averia 14 bold, tabular), or "Taxa desconhecida".
- The existing empty texts stay ("Sem materiais", "igual à forma base" where it applies).

## 5 Habitat · 6 Partes

- Ruled rows, side by side from 360 dp of content, stacked below it. The "Cortável" label stays,
  as body small `textMuted` text instead of a bordered chip.

## Settings

- Same app bar. The options are grouped under numbered-style section titles, without the number.
  Choices are ruled rows with radio semantics. No panels.

## Motion

- Changing monster, version or game: the new content fades in and the detail also slides 2 %
  upward, over 220 ms with ease-out-cubic.
- With the platform's reduce-motion setting on, the content changes with no animation.
