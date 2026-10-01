# Quickstart: validating feature 006

## Build the weapon data (maintainers)

```sh
python tool/data/build_rise_weapons.py          # wiki MHRS pages + Kiranico lists → weapons.json
python tool/data/build_rise_weapons.py --icons  # also the weapon and type icons
flutter test test/features/weapons/data/real_weapons_dataset_test.dart
```

The pages are cached in `tool/data/.cache/`, so rerunning the script on the same cache gives the
same file.

## Automated gates

`flutter analyze` · `dart format --set-exit-if-changed .` · `flutter test` ·
`flutter build windows --release`

## Manual checks

| # | Scenario | Expected | Spec |
|---|----------|----------|------|
| 1 | Open the app | Navigation bar: Monstros, Armas, Armaduras (dimmed), Assistente (dimmed) | FR-001 |
| 2 | Tap Armas | Rise selected, World/Wilds "em breve"; Espada Grande selected; tree cards | FR-002, FR-006, FR-007 |
| 3 | Find the Anjanath tree (Espada Grande) | 6 weapons in upgrade order with indent; Gnashing Flammenzahn+ 280 / Fogo 28 / −20 % | FR-007 |
| 4 | Filter Mestre, search "lohen" | Only Lohenzahn and Lohenzahn+ | FR-006 |
| 5 | Open Gnashing Flammenzahn+ | Rarity 8, Mestre, stars marked estimated; slot 3, Rampage 2; two sharpness bars; 4 upgrade materials; "Dropado por: Anjanath"; tree previous/next | FR-004, FR-005, FR-008 |
| 6 | Open a Bow | No sharpness card | FR-008 |
| 7 | Tap "Dropado por: Anjanath" | The Anjanath detail (Rise) opens in Monstros | FR-009 |
| 8 | Anjanath (Rise) detail | "Armas feitas com ele" card with count; "Ver todas" opens the filtered Armas list | FR-010 |
| 9 | Rathalos (World) detail | No weapons card | FR-010 |
| 10 | Switch Monstros ↔ Armas | Each keeps its filters, search, scroll and selection | FR-012 |
| 11 | Window ≥ 840 dp | Navigation rail on the left; list and detail side by side in Armas | FR-001 |
| 12 | 320 dp, 200 % text: list, detail, monster card | No overflow; pickers scroll | FR-013 |
| 13 | Spot check of 20 weapons (≥ 1 per type) against the wiki and Kiranico pages | Every field matches | SC-002 |
| 14 | Rename `weapons.json` and run | Armas shows the error; Monstros works | FR-011, SC-005 |
