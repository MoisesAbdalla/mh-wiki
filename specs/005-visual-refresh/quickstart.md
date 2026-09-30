# Quickstart: validating feature 005

## Prepare the assets (maintainers)

```sh
python tool/data/fetch_game_logos.py    # official logos → assets/images/games/*.webp
```

The fonts are committed under `assets/fonts/` with their `OFL.txt`.

## Automated gates

`flutter analyze` · `dart format --set-exit-if-changed .` · `flutter test` ·
`flutter build windows --release`

## Manual checks

Compare each screen with [mockups/approved.html](mockups/approved.html).

| # | Scenario | Expected | Spec |
|---|----------|----------|------|
| 1 | Open the app | Title "Caderninho"; tabs: "Todos" + three game logos; active one full colour with a gold underline | FR-001, FR-006 |
| 2 | Scroll the list (World) | No bordered rows, hairlines only; primary weakness as symbol + name; titles in IM Fell, counts in Averia | FR-003, FR-005, FR-012 |
| 3 | Open Rathalos (World) | Sections numbered 1–6; weaknesses Dragão ★★★ gold with "Melhor", Raio, Água, Gelo, Fogo "Sem efeito" last; no game name above the monster name (expanded layout, World filter) | FR-004, FR-009–011 |
| 4 | Vida of Rathalos | Rank tabs Low/High/Master; solo value large; ruler with 1, 2 and 3–4 values | FR-013 |
| 5 | Nergigante → Arquitemperado (World) | Version tabs underlined; "igual à forma base" as a note next to inherited titles; materials grouped under "Prêmio da missão: …" with rates | FR-008, FR-009, FR-014 |
| 6 | A monster with no 2-star weakness (Rise: Astalos) | No gold, no stamp; list row without a weakness badge | FR-011, FR-012 |
| 7 | A monster without HP (Wilds: Gogmazios) | "HP desconhecido", no ruler | FR-013 |
| 8 | Switch monster, version and game | Short fade (and slide in the detail), no bounce | FR-015 |
| 9 | Turn on the system's "reduce motion" (Windows: Settings › Accessibility › Visual effects › Animation effects off) | Content changes with no animation | FR-015, SC-008 |
| 10 | 320 dp, 200 % text: list, Rathalos, Arch-Tempered Nergigante, settings | No overflow; tab bar scrolls; ruler values listed under the ruler | FR-017 |
| 11 | Screen reader on the tabs, weaknesses and HP | "World: Iceborne, selecionado"; "Dragão, 3 de 3 estrelas, melhor fraqueza"; "HP solo 6.565; 2 caçadores …" | FR-007, FR-017 |
| 12 | Settings screen | Same style: no panels, ruled options | FR-003 |
| 13 | World list, 300+ entries, fast scroll | Opens in ≤ 1 s, smooth | SC-006 |
