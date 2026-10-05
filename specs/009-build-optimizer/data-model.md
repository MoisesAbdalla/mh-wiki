# Data Model: Otimizador de builds (Montar build)

## Asset: `assets/data/rise_sunbreak/optimizer.json`

```json
{
  "schemaVersion": 1,
  "game": "rise_sunbreak",
  "skills": [
    { "id": "attack-boost", "name": { "en": "Attack Boost", "ptBr": "Reforço de Ataque" }, "max": 7 }
  ],
  "decorations": [
    { "id": "attack-jewel-2", "name": { "en": "Attack Jewel 2", "ptBr": "Joia do Ataque 2" },
      "slot": 2, "skill": "attack-boost", "points": 1 }
  ],
  "pieces": [
    { "id": "flaming-espinas-brain", "name": { "en": "Flaming Espinas Brain", "ptBr": "Cérebro Espinas F" },
      "part": "head", "rarity": 10, "slots": [3, 2], "defense": 178,
      "skills": [ { "skill": "attack-boost", "level": 2 } ] }
  ],
  "weapons": [
    { "id": "fine-kamura-cleaver", "name": { "en": "Fine Kamura Cleaver", "ptBr": "Ótimo Cutelo Kamura" },
      "type": "great-sword", "rarity": 10, "slots": [4, 2], "attack": 330,
      "image": "assets/images/weapons/rise_sunbreak/fine-kamura-cleaver.webp" }
  ]
}
```

**Validation**:
- the schema version and the game must match;
- ids must be unique within each list;
- slots are 0–4 and at most 3 per item;
- every skill a decoration or piece refers to must exist;
- decoration points are at least 1;
- parts must be known (head, chest, arms, waist, legs);
- weapon types must be among the 14 type ids.

## Domain (pure Dart, `lib/features/assistant/domain/`)

- `OptimizerCatalog`: skills by id, decorations by skill, pieces by part, weapons by type.
- `OptimizerSkill(id, name, max)`, `OptimizerDecoration(id, name, slot, skill, points)`,
  `OptimizerPiece(id, name, part, rarity, slots, defense, skills)`,
  `OptimizerWeapon(id, name, type, rarity, slots, attack, image?)`.
- `UserTalisman(id, skills: [(skill, level)] up to 2, slots: [int; 3])`.
- `BuildRequest`:
  - `skills`: an ordered map from skill id to wanted level;
  - `weaponType`, `progress`;
  - `fixedWeaponId?`;
  - `useTalismans` (default true), `onlyMyProgress` (default true).
- `maxRarityFor(Progress)`: the table in research R3.
- `BuildSet`, a result:
  - `weapon`, `pieces` (one per part, or null);
  - `alternatives` per part;
  - `talisman?`;
  - `decorations` per holder (weapon, part, talisman) and slot;
  - `skills` (all, capped), `missing` (skill → levels short);
  - `freeSlots`, `defense`;
  - `complete` (true when `missing` is empty).
- `SearchBuilds(catalog, request, talismans, {onProgress})` returns the ranked `List<BuildSet>`
  (at most 10). It is pure; research R4 has the algorithm.
- `suggestSkills(curatedBuilds, weaponType, progress, chosen)` returns the top 8 skill ids.
- `BuildSet.toCuratedBuild(request, names)` gives a `CuratedBuild`, which is saved as a
  `SavedBuild` (008).

## Data (`lib/features/assistant/data/`)

- `readOptimizerDataset` reads and validates the asset into an `OptimizerCatalog`.
- `AssetOptimizerRepository implements OptimizerRepository` loads the asset lazily and caches it;
  a failure is an `Err`.
- `PrefsTalismanRepository` (key `assistant.talismans.v1`) and `PrefsRequestRepository` (key
  `assistant.optimizer.request.v1`) work like the 008 repositories; a corrupt value falls back to
  empty or the defaults.
- `IsolateBuildSearcher implements BuildSearcher`:
  - it runs `SearchBuilds` with `Isolate.spawn`;
  - it streams progress counts;
  - `cancel()` kills the isolate.

## Presentation

- `OptimizerController` (ChangeNotifier) has the states `idle`, `loading` (catalog), `failed`,
  `searching(checked)`, `results(list, selected?)` and `noResults`. It holds:
  - the request and the talismans;
  - the suggestions;
  - the fixed weapon search text.

  It shares the progress and weapon type with `AssistantController` (they are read from it, and
  "alterar" switches to Recomendadas). The results are cleared when the progress, type or skills
  change.
- Views:
  - `build_request_view.dart` (screen 1);
  - `talismans_page.dart` (screen 2, form and list);
  - `build_results_list.dart` (screen 3);
  - `build_result_detail.dart` (screen 4). It reuses the 008 `BuildDetailView` pieces, with the
    equipment rows and decoration tiles extracted for reuse, plus the "Habilidades pedidas" card.

## Localisation (ARB, pt-BR)

These strings are added:
- the request screen:
  - `skillsWanted`, `searchSkill`, `commonForType`;
  - `weaponAndTalismans`, `anyWeaponUpTo`, `chooseWeapon`, `myTalismans`;
  - `talismansCount`, `useAll`, `onlyMyProgress`, `upToRarity`, `buildIt`;
- the search: `searching`, `searchingChecked`, `cancel` (exists);
- the results:
  - `setsFound`, `optionN`, `complete`, `almost`, `missingN`;
  - `maxDefense`, `freeSlots`, `alsoComes`, `requestedSkills`, `resultOf`;
  - `noSetsFound`, `rankingNote`;
- the talismans:
  - `talismansTitle`, `talismansNote`, `registered`, `newTalisman`;
  - `skillN`, `skill2Optional`, `none`, `slotN`;
  - `saveTalisman`, `editTalisman`, `deleteTalismanConfirm`, `noTalismans`;
- accessibility: `skillProgressSemantics` ("{skill}, {got} de {want}{missing}").
