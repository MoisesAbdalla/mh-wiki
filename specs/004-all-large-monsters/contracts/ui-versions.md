# Contract: Versions in the list and the detail

## List row (one per base monster)

- The row shows the thumbnail, the base name and its classification, as today.
- When the monster has versions, the row adds a small muted line: "N versões" (1 → "1 versão").
- A search that matches only a version shows the base row, with the matched version's name
  under it ("Rathalos Arquitemperado"). Tapping the row opens that version.
- Semantics: "<name>, <classification>, N versões".

## Detail header: version selector

- Shown only when the monster has versions. It uses the themed tabs style (`HunterTabs`).
- Options: "Base" followed by each version label in kind order: "Temperado", "Arquitemperado",
  "Aflito", "Frenesi", "Apex", "Ressurgido", "Guardião".
- The selected option drives every section. The header name and thumbnail are the version's own
  (its thumbnail falls back to the base icon).
- Selection goes through the controller (same `select(id)` as the list), so the wide layout
  keeps it.

## Inherited sections

- A section inherited from the base (weaknesses, habitat, parts, hunting items) shows an
  "Igual à forma base" line under its title, in the muted text style.
- The HP and materials sections of a version show only its own data, or the existing
  "HP desconhecido" / "Sem materiais" messages.

## Accessibility

- The rules of features 002 and 003 apply (contrast, 48 dp targets, 200 % text, 320 dp width).
- The selector's tabs are labeled "Versão: <label>".
