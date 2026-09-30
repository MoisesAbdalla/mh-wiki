# Quickstart & Validation: Wiki de Monstros (001-monster-wiki)

How to run the feature and prove it works end to end. Design details live in
[data-model.md](data-model.md) and [contracts/](contracts/); this file is only a run/validation
guide.

## Prerequisites

- Flutter stable 3.47.x (`flutter --version`), Dart 3.13.
- `flutter doctor` green for: Android toolchain, Chrome, Visual Studio (Windows desktop).
- An Android phone or emulator (plus a tablet-sized emulator, e.g. Pixel Tablet).

## Setup

```powershell
flutter pub get
flutter gen-l10n
```

## Quality gates (constitution — all must pass)

```powershell
flutter analyze                          # expect: No issues found!
dart format --set-exit-if-changed .      # expect: exit code 0
flutter test                             # unit + widget + dataset tests, all green
```

Dependency-rule check (Principles I & III) — each must print nothing:

```powershell
# domain must not import flutter or packages (other than this app's own domain code)
Get-ChildItem lib -Recurse -Filter *.dart | Where-Object FullName -match '\\domain\\' |
  Select-String -Pattern "import 'package:(?!mh_wiki/)"
# presentation must not import data
Get-ChildItem lib -Recurse -Filter *.dart | Where-Object FullName -match '\\presentation\\' |
  Select-String -Pattern "import .*/data/"
```

## Run

```powershell
flutter run -d <android-device-id>
flutter run -d windows
flutter run -d chrome
flutter build web --release --no-web-resources-cdn   # self-hosts CanvasKit so offline works; serve build/web with any static server
```

## End-to-end integration test (SC-008)

```powershell
flutter test integration_test -d <android-device-id>
flutter test integration_test -d windows
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome
```

Expected: the scripted flow (open list → filter Wilds → search "rath" → open Rathalos →
see 4 sections → back keeps filter/search) passes on all three.

## Manual validation scenarios

| # | Scenario | Expected | Spec |
|---|----------|----------|------|
| 1 | Open app, tap any monster | detail with weaknesses, habitat, parts, materials | US1, FR-007 |
| 2 | Filter "Todos" | three sections in order World → Rise → Wilds, alphabetical | FR-006 |
| 3 | Rathalos under "Todos" | appears once in each game's section | FR-013 |
| 4 | Search `RATH`, then `ratha` | same results; Rathalos + Rathian variants | FR-004 |
| 5 | Settings → English, search `rathalos`; then pt-BR | names switch instantly; search still finds both names | FR-021–FR-023 |
| 6 | Restart app | language choice kept | FR-022 |
| 7 | Search `zzz` with Wilds filter | empty state mentions filter; "Limpar filtros" works | US3.3 |
| 8 | Alatreon (World) detail | general weaknesses + per-state blocks | FR-008a |
| 9 | Any monster → Materiais | ranks as tabs; each method row shows % or "Taxa desconhecida"; break rows name the part | FR-011, FR-011a/b |
| 10 | Windows: resize window across ~840 px with a monster selected | switches 1↔2 panes keeping selection/filter/search | FR-019, FR-020 |
| 11 | Tablet emulator: rotate | same as #10 | FR-020 |
| 12 | Airplane mode on Android; web: DevTools → Network → Offline → reload (after one online load) | everything works | FR-012, SC-004 |
| 13 | Temporarily corrupt `assets/data/wilds/monsters.json` (debug build) | World/Rise still usable; banner names Wilds | FR-017 |
| 14 | Detail open → back | list at same scroll position, same filter/search | FR-015 |

## Data accuracy spot-check (SC-005)

For every monster in the v1 roster, open its `sources` URLs and compare: 5 general weaknesses,
habitats, breakable parts, and at least 3 material drops per rank (method + rate). Record
discrepancies as data fixes, not code changes (FR-002a).
