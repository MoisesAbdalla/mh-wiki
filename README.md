# MH Wiki

Offline wiki of large monsters from **Monster Hunter World: Iceborne**, **Monster Hunter
Rise: Sunbreak** and **Monster Hunter Wilds**, built with Flutter (Android, tablet, web and
Windows).

- List monsters by game, with accent- and case-insensitive search (pt-BR and English names).
- Detail view: elemental weaknesses (including per-state variations), habitats, breakable
  parts, and materials by rank with acquisition method and drop rate.
- Game names shown in Portuguese (Brazil) or English (Configurações).
- Side-by-side list and detail on wide screens (≥ 840 dp).

> Fan-made, non-commercial study project. Not affiliated with or endorsed by Capcom.
> Monster Hunter and all related names are trademarks of Capcom.

## Architecture

Clean Architecture per feature with MVC in the presentation layer. The rules are in
[.specify/memory/constitution.md](.specify/memory/constitution.md), and the design is in
[specs/001-monster-wiki/](specs/001-monster-wiki/).

```text
lib/
├── app/                 # MaterialApp + composition root (app/di)
├── core/                # shared domain types and presentation helpers
└── features/
    ├── monsters/{domain,data,presentation}
    └── settings/{domain,data,presentation}
assets/data/<game>/monsters.json   # versioned datasets (schemaVersion 1)
```

## Running

```powershell
flutter pub get
flutter run -d windows          # needs Windows Developer Mode (plugin symlinks)
flutter run -d chrome
flutter run -d <android-device>
```

Web build that works offline after the first load (custom service worker in `web/sw.js`;
CanvasKit is self-hosted so nothing depends on a CDN):

```powershell
flutter build web --release --no-web-resources-cdn
```

## Quality gates

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter test integration_test -d <device>
```

## Adding or fixing monster data

Data changes never require code changes. Edit `assets/data/<game>/monsters.json` following
[the dataset schema](specs/001-monster-wiki/contracts/monster-dataset.schema.json) and the
validation rules in [data-model.md](specs/001-monster-wiki/data-model.md). Then run
`flutter test test/features/monsters/data/real_datasets_test.dart` to confirm the file is
still valid.

- Every dataset and every monster must list its `sources`.
- Omit `ratePercent` when a drop rate is not verified. The app then shows "Taxa desconhecida"
  and never shows an invented value.

**Data status:** 10 large monsters per game (30 in total, about 1,800 drop entries with rates).
Sources are Kiranico, the Monster Hunter Wiki, mhw-db.com and Fextralife. Every monster lists
its sources, and the choices behind them are in
[research.md](specs/001-monster-wiki/research.md) (R12, R15). Rise and Wilds star ratings are
derived from hitzones by a documented rule, so they may differ slightly from the in-game field
guide.
