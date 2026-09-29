# Contract: UI (screens, states, behaviours)

What each view must render for each state. Widget tests assert these (Principle VI).
All visible strings come from `lib/l10n/app_pt.arb`; game names come from data via
`LocalizedText.resolve(settings.nameLanguage)`.

## Layout switch (FR-019, FR-020)

| Available width | Layout |
|-----------------|--------|
| `< 840 dp` | **Compact**: `MonstersPage` shows the list; selecting pushes `MonsterDetailPage` |
| `≥ 840 dp` | **Expanded**: list pane (≈360 dp) + detail pane side by side |

- Selection, filter and search live in `MonsterListController`, so crossing the breakpoint keeps
  them. Expanded → compact with a selection: detail route is pushed. Compact → expanded with the
  detail route open: route is popped; detail pane shows the same monster.
- Expanded with no selection: detail pane shows a prompt ("Selecione um monstro").

## MonstersPage (list)

App bar: title, settings action (opens `SettingsPage`).

Controls (always visible when Loaded):
- Search field — updates results on every keystroke; clear button when non-empty.
- Game filter — segmented/chips: "Todos", World: Iceborne, Rise: Sunbreak, Wilds.

| State | Renders |
|-------|---------|
| Loading | progress indicator |
| LoadFailed (all games) | error message + "Tentar novamente" |
| Loaded, results | sections; with "Todos": sticky header per game; single game: no header needed |
| Loaded, no results | "Nenhum monstro encontrado" + "Limpar filtros" (mentions active filter when any) |
| Loaded, `failedGames` non-empty | non-blocking banner: "Não foi possível carregar os dados de: <jogos>" |

List tile: image or generic placeholder, monster name (selected language), game label,
classification. Selected tile highlighted in expanded layout. Scroll position is preserved
when returning from detail (FR-015).

## MonsterDetailPage / detail pane

Header: image/placeholder, name, game, classification.

Sections, in order (FR-007):
1. **Fraquezas elementais** — 5 elements, 0–3 stars; `immune` shown with a distinct
   "Imune" badge; elements in `mostEffective` highlighted (none highlighted if empty). If
   `states` is non-empty, a sub-block per state titled with the state name.
2. **Habitat** — list of habitat names, or "Nenhum habitat fixo".
3. **Partes quebráveis** — part names, "Cortável" tag when `severable`; or "Nenhuma parte
   quebrável".
4. **Materiais** — tabs or segmented control per available rank (Baixo / Alto / Mestre; only
   ranks present). Per material: name (+ rarity when known), then one row per acquisition
   method: method label (for `breakPart`: "Quebrar: <part name>"), rate "NN%" or
   "Taxa desconhecida". No ranks at all → "Nenhum material registrado".

Long names wrap to at most 2 lines then ellipsize; no overflow at 320 dp width.

## SettingsPage

- "Idioma dos nomes do jogo": radio Português (Brasil) / English. Change applies immediately
  to all screens (FR-022). Storage failure → snackbar "Não foi possível salvar a preferência";
  choice still applies for the session.

## Accessibility

- Stars have semantic labels (e.g. "Fogo: 3 de 3", "Gelo: imune").
- Tap targets ≥ 48 dp; text scales to 200% without clipping section headers.
