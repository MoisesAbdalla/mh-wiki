# Data Model: Assistente de builds

## Dataset `assets/data/rise_sunbreak/builds.json` (schemaVersion 1)

```text
{
  schemaVersion: 1, game: "rise_sunbreak", generatedAt, sources[],
  builds: [{
    id,                          // slug of type + name
    name,                        // as in the source (English)
    weaponType,                  // weapon type id ("great-sword")
    stage: { label, rank: low|high|master|post, star: 1..7 | M1..M6 | 10|50|100|140|180 },
    weapon:   item,              // with decorations
    pieces:   [{ part: head|chest|arms|waist|legs, item, alternatives: [item] }],
    talisman?: { skill: ref, level, slots: [1..4], decorations: [ref] },
    skills:   [{ skill: ref, level, maxLevel }],
    rampage:  [ref],
    source:   { name: "Game8", url }
  }]
}
item = { ref, decorations: [ref] }
ref  = { id?, name: { en, ptBr? }, kind: weapon|piece|skill|decoration|rampage }
       // id is absent when the source item is not in the catalog (FR-008)
```

### Validation rules

- Build ids are unique; `weaponType` is one of the 14 types.
- There is one `stage`, and its `rank` and `star` fit together (low 1–3, high 4–7, master M1–M6,
  post 10/50/100/140/180).
- Pieces have distinct parts; there are at most 5 of them.
- Skill levels are ≥ 1. A level may exceed `maxLevel`, which is real data.

## Domain (lib/features/assistant/domain)

| Entity | Fields | Notes |
|--------|--------|-------|
| `Progress` | rank (low/high/master/post), step (star or band) | `compareTo`: the ordered scale of research R3 |
| `CuratedBuild` | id, name, weaponType, stage (`Progress` + label), weapon, pieces, talisman?, skills, rampage, source | |
| `BuildItem` | ref (`CatalogRef`), decorations | |
| `CatalogRef` | id?, name, kind | `known` = id != null |
| `BuildPiece` | part, item, alternatives | |
| `SavedBuild` | build (copy), name, savedAt | |
| `AssistantPrefs` | progress, weaponType | |

### Use cases

- `LoadBuildCatalog`.
- `SplitBuilds(builds, progress, type)` returns `(now, next)`:
  - **now** is the builds whose stage is ≤ the progress, latest stage first;
  - **next** is the builds whose stage is > the progress, nearest first.
- `TotalDecorations(build)` returns each decoration with its count, sorted by slot level
  (descending), then name.
- `SavedBuildsRepository` offers `load`, `save`, `rename` and `delete`; `AssistantPrefsRepository`
  stores the progress and weapon type.

## Presentation state

- `AssistantController` (ChangeNotifier) has the states `loading`, `failed` and `loaded`. When
  loaded, it holds:
  - the tab: recommended, saved, or build (disabled);
  - the progress and weapon type;
  - the `now` and `next` lists;
  - the saved builds;
  - the selection.

## Localisation (ARB, pt-BR)

These strings are added to the ARB:
- the tabs: `assistantTabRecommended`, `assistantTabSaved`, `assistantTabBuild`;
- the progress picker: `whereAreYou`, `rankPost`, `progressStar`, `progressBand`, `stageFrom`;
- the list: `buildsNow`, `buildsNext`, `noBuildsNow`;
- the detail sections: `buildSectionEquipment`, `buildSectionSkills`, `buildSectionDecorations`;
- the equipment card: `partWeapon`, `partTalisman`, `alternativePiece`, `talismanRequirement`,
  `notInCatalog`;
- saving builds: `saveBuild`, `buildSaved`, `savedFrom`, `renameBuild`, `deleteBuild`,
  `noSavedBuilds`;
- the messages: `buildsLoadFailed`, `buildSource`.
