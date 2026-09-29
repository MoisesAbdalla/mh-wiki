# Research: Wiki de Monstros (001-monster-wiki)

**Date**: 2026-09-29 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

Each entry records the decision, why it was chosen, and what was rejected. All
`NEEDS CLARIFICATION` items from the Technical Context are resolved here.

---

## R1. Toolchain and target platforms

- **Decision**: Flutter stable 3.47.x / Dart 3.13 (installed locally). Create the project with
  `--platforms=android,web,windows`. Tablet support is Android at larger widths; iOS is not a
  v1 target.
- **Rationale**: matches FR-018 (celular Android, tablet, web, desktop Windows). Adding iOS
  later is a `flutter create --platforms=ios .` away and needs a Mac, which is not available.
- **Alternatives considered**: all platforms (adds iOS/macOS/Linux folders nobody tests —
  rejected, untested platforms rot).

## R2. State management

- **Decision**: `ChangeNotifier` controllers (Flutter SDK), consumed in views with
  `ListenableBuilder`. No third-party state library.
- **Rationale**: mandated by the constitution (Principle II; Restrições Técnicas). The
  feature's state is small (list filter/search/selection + one preference).
- **Alternatives considered**: provider/riverpod/bloc — require a constitution amendment and
  add nothing needed at this scale.

## R3. Dependency injection

- **Decision**: manual composition root in `lib/app/di/app_dependencies.dart`. `main()` builds
  datasources → repositories → use cases → controllers, and passes controllers into the widget
  tree through constructors. No service locator.
- **Rationale**: Principle III (explicit constructor injection, single composition root). The
  graph has ~10 objects; a container would be ceremony.
- **Alternatives considered**: get_it (service locator — allowed only in the composition root,
  but unnecessary), provider as DI (third-party, blurs with state management).

## R4. Data format and packaging (offline-first)

- **Decision**: one JSON asset per game: `assets/data/<game>/monsters.json`, each with a
  top-level `schemaVersion` (integer, starting at `1`), `game`, `generatedAt`, `sources`, and a
  `monsters` array. Schema in [contracts/monster-dataset.schema.json](contracts/monster-dataset.schema.json).
  Loaded via `rootBundle` in the data layer, parsed into DTOs, mapped to domain entities.
- **Rationale**: per-game files isolate failures (FR-017: one broken game must not block the
  others) and keep diffs reviewable. Assets ship inside the app on every platform, satisfying
  FR-012 with no network code. `schemaVersion` satisfies Principle IV.
- **Alternatives considered**: single combined file (one parse error kills all games);
  SQLite/drift (needs codegen + native deps + web workaround, overkill for ~30–200 monsters);
  remote API (no API covers the three games; violates offline-first as primary source).

## R5. JSON parsing

- **Decision**: hand-written `fromJson` factories on DTOs in the data layer, with explicit
  validation that throws a typed `DatasetFormatException` caught by the repository and mapped
  to a `Failure`.
- **Rationale**: avoids `json_serializable`/`build_runner` codegen for a handful of classes;
  validation logic (allowed ranks per game, part references) has to be hand-written anyway.
- **Alternatives considered**: json_serializable/freezed (codegen overhead, adds packages
  needing justification; revisit if DTO count grows past ~15).

## R6. Search normalization (FR-004, FR-023)

- **Decision**: a pure-Dart `normalizeForSearch(String)` in `core/domain` that lowercases and
  folds Latin diacritics via an explicit mapping table (á→a, ç→c, ñ→n, etc.). Match = substring
  of the normalized query in the normalized pt-BR **or** English name.
- **Rationale**: domain must be pure Dart (Principle I), so no `diacritic` package. The
  character set in pt-BR/English monster names is small and fully testable.
- **Alternatives considered**: `diacritic` package (external dep in domain — forbidden);
  Unicode NFD normalization (not available in `dart:core` without a package).

## R7. Name-language preference storage (FR-021, FR-022)

- **Decision**: `shared_preferences` in `features/settings/data`, behind a domain
  `SettingsRepository` interface. Stored key `name_language` with values `ptBr` | `en`.
- **Rationale**: the only package that persists a key–value on Android, web (localStorage) and
  Windows with one API. Justification required by the constitution: no SDK alternative exists
  for cross-platform persistence.
- **Alternatives considered**: writing a file with `path_provider` (does not work on web;
  two packages instead of one); in-memory only (violates FR-022).

## R8. Localization (UI in pt-BR, i18n-ready)

- **Decision**: Flutter `gen-l10n` with `flutter_localizations` + `intl`, ARB template
  `lib/l10n/app_pt.arb` (pt-BR as the only UI locale in v1), `l10n.yaml` at repo root.
  Game-content names are **not** in ARB files; they come from the datasets (`LocalizedText`).
- **Rationale**: Principle VII; official Flutter approach; adding a UI language later is just a
  new ARB file. Separating UI strings (ARB) from game names (data) keeps FR-021 independent of
  the UI locale.
- **Alternatives considered**: easy_localization/slang (extra packages, no gain).

## R9. Adaptive layout (FR-019, FR-020)

- **Decision**: a single `MonstersPage` using `LayoutBuilder` with a breakpoint at **840 dp**
  of available width (Material 3 "expanded" window class) — this is the "largura mínima" referenced
  by FR-019; the decision is width-based, never device-based. `< 840`: list only; tapping pushes a detail route
  with `Navigator`. `≥ 840`: two panes (list ~360 dp + detail). The **selected monster lives in
  the controller**, not in the route, so resizing/rotating switches layouts while keeping the
  selection, filter and search (FR-020). When the layout collapses to narrow with a selection,
  the detail route is shown; when it expands, the pushed route is popped and the right pane
  shows the same monster.
- **Rationale**: Material guidance; tablet landscape (≥ 840 dp on most tablets) gets two panes
  per spec; no router package needed for two screens.
- **Alternatives considered**: go_router (useful for deep links on web, not required by spec;
  can be added later); breakpoint 600 dp (tablets in portrait would get cramped two panes).

## R10. Web offline after first load (SC-004)

- **Decision**: ship a small **custom service worker** (`web/sw.js`) that precaches the build
  output (`index.html`, `main.dart.js`, `flutter_bootstrap.js`, `assets/**`, canvaskit files)
  and serves cache-first, registered from a custom `web/flutter_bootstrap.js`. Cache name is
  versioned by the app build version.
- **Rationale**: Flutter has deprecated its default service worker; since 3.44 the generated
  `flutter_service_worker.js` only unregisters itself and does no caching, and the Flutter team
  recommends a custom worker injected via `flutter_bootstrap.js`/`index.html`.
- **Alternatives considered**: relying on HTTP cache (not reliable offline); workbox build step
  (adds Node toolchain to a Flutter project).
- **Risk**: must be validated in quickstart (DevTools → Network: Offline → reload).

## R11. Error handling model

- **Decision**: sealed `Result<T>` (`Success`/`Err`) and sealed `Failure` hierarchy in
  `core/domain` (`DatasetUnavailable`, `DatasetFormatInvalid`, `UnsupportedSchemaVersion`,
  `MonsterNotFound`, `PreferenceStorageFailure`). Use cases return `Result`; controllers map
  to view states. The catalog load returns partial success: loaded monsters + list of games
  that failed (FR-017).
- **Rationale**: constitution "Restrições Técnicas" (errors modeled explicitly); Dart 3 sealed
  classes give exhaustive `switch` in controllers.
- **Alternatives considered**: exceptions to the UI (forbidden); `dartz`/`fpdart` Either
  (external dep in domain — forbidden).

## R12. Weakness scale normalization

- **Decision**: store effectiveness as an enum `immune | none(0★) | low(1★) | medium(2★) |
  high(3★)` per element, general + optional named states. Dataset curators convert each game's
  source representation to this scale; the conversion rule used is recorded in the dataset
  `sources[].notes`.
- **Rationale**: World and Wilds present star ratings directly; Rise sources commonly present
  per-part hitzone values, which must be summarized into stars. Recording the rule keeps
  SC-005 auditable.
- **Alternatives considered**: storing raw hitzone numbers (out of scope per spec assumptions;
  not comparable across games).

## R13. Materials and drop rates (FR-011, FR-011a/b)

- **Decision**: `MaterialDrop` = (material, rank, method, optional partId, optional
  ratePercent). Methods enum: `carve`, `tailCarve`, `capture`, `breakPart`, `questReward`,
  `droppedMaterial`, `other` (+ optional label). Ranks allowed per game: World & Rise →
  `low | high | master`; Wilds → `low | high`. `partId` required iff method is `breakPart`
  and must reference an existing breakable part. `ratePercent` null ⇒ "taxa desconhecida".
- **Rationale**: covers the acquisition methods the spec names and enforces FR-011a/b at parse
  time. `other` + label avoids schema churn for game-specific methods (e.g., investigations).
- **Alternatives considered**: free-text method (not filterable, error-prone).

## R14. Data sources and curation

- **Decision**: datasets are curated manually (or with ad-hoc scripts outside the app) from
  community references (e.g., Kiranico, mhw-db.com for World data, Fextralife/Game8 wikis),
  cross-checked where possible. Each dataset and each monster record lists `sources` (name +
  URL + optional notes). No scraper ships in the repo in v1.
- **Rationale**: no official API; SC-005 requires traceability; constitution requires the
  source to be recorded.
- **Risk**: drop-rate accuracy is the highest data risk (chosen by user: Q2 = C). Mitigation:
  `ratePercent` optional, dataset tests validate structure, manual spot-check list in quickstart.

## R15. Initial monster roster (FR-002, ~10 per game)

- **Decision (proposed, final list confirmed during data curation)**:
  - **World: Iceborne**: Great Jagras, Anjanath, Rathian, Pink Rathian, Rathalos, Diablos,
    Nergigante, Zinogre, Velkhana, Alatreon.
  - **Rise: Sunbreak**: Great Izuchi, Rathian, Rathalos, Tigrex, Zinogre, Mizutsune,
    Soulseer Mizutsune, Magnamalo, Rajang, Malzeno.
  - **Wilds**: Chatacabra, Doshaguma, Rey Dau, Uth Duna, Nu Udra, Jin Dahaad, Rathalos,
    Guardian Rathalos, Gore Magala, Arkveld.
- **Coverage of FR-002 criteria**: Rathalos appears in all three games; variants/subspecies
  (Pink Rathian, Soulseer Mizutsune, Guardian Rathalos); state-dependent weaknesses (Alatreon's
  elemental modes in World) exercise FR-008a; a monster without breakable parts or fixed
  habitat is included only if one exists in the chosen roster — otherwise the edge case is
  covered by test fixtures instead of real data.
- **Rationale**: mixes early/mid/late monsters, flagships and cross-game repeats.

## R16. Testing approach

- **Decision**: `flutter_test` for unit + widget tests using hand-written fakes (no mocking
  package); `integration_test` (SDK) for one end-to-end flow run on Android, Windows and
  Chrome (SC-008). Dataset tests load the real JSON assets and assert they parse and pass
  validation. TDD order per task: failing test → implementation → refactor.
- **Rationale**: Principle VI; fakes keep tests readable and avoid another dependency.
- **Alternatives considered**: mocktail (fine, but unnecessary given small interfaces).

## R17. Performance

- **Decision**: load all three datasets once at startup (in parallel), keep entities in memory,
  filter/search synchronously in the controller via use cases. Images as compressed WebP
  (~256 px list thumbnails, larger for detail), `cacheWidth` hints in list tiles.
- **Rationale**: ~30 monsters (v1) to ~200 (future) fits comfortably in memory; in-memory
  filtering over 200 items is well under the 0.5 s target (SC-002).
- **Alternatives considered**: lazy per-game loading (unneeded complexity at this size).
