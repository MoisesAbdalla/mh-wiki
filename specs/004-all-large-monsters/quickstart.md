# Quickstart: validating feature 004

## Rebuild a game's data (maintainers)

```sh
python tool/data/build.py wilds      # or rise_sunbreak / world_iceborne
flutter test test/features/monsters/data/real_datasets_test.dart
```

The build uses cached pages in `tool/data/.cache/`. Delete that folder to fetch fresh pages.

## Automated gates (every phase)

`flutter analyze` · `dart format --set-exit-if-changed .` · `flutter test` ·
`flutter build windows --release`

## Manual checks per game phase

| # | Scenario | Expected | Spec |
|---|----------|----------|------|
| 1 | Open the game's list | One row per base monster, sorted A–Z; count = roster (R1) minus versions | FR-001, FR-006, SC-001 |
| 2 | A monster with versions (Wilds: Rathalos) | Row shows "N versões"; detail shows the selector (Base, Temperado, Guardião…) | FR-006a/b |
| 3 | Pick a tempered version | Weaknesses/parts/habitat/items show "Igual à forma base"; HP/materials only its own data or unknown | FR-006c |
| 4 | Search "guardiao" / "arquitemperado" | Base row appears with the version name; tap opens that version | FR-006a |
| 5 | Subspecies (Rise: Silver Rathalos) | Own row, not a version | FR-006b |
| 6 | Base missing in game (Wilds: Guardian Ebony Odogaron) | Own row | spec edge case |
| 7 | Switch games and scroll fast | List appears in ≤ 1 s, smooth scrolling | SC-004 |
| 8 | Type quickly in search | Results follow each key | SC-005 |
| 9 | 320 dp, 200 % text on a version | No overflow | FR-009 |
| 10 | Sample of 10 new monsters | Values match the sources in each monster's `sources` | SC-002 |
