# Implementation Plan: Informações de Caçada

**Branch**: `003-hunting-info` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

## Summary

Add to the monster detail: solo HP per rank (Kiranico: World expeditions; Rise/Wilds lowest
regular-quest HP, shown "a partir de"), party HP as a labeled estimate from per-game factors
(World: Fextralife; Wilds: community testing; Rise: unknown), and reactions to hunting items
(Flash, Sonic/Screamer, Dung, Pitfall, Shock) from the Monster Hunter Wiki, plus vision derived
from the Flash reaction. Additive optional fields in schema v1; new domain types; two new
themed panels.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged) · **Dependencies**: none added
**Storage**: datasets gain `partyHpFactors`, `huntingItems`, per-monster `hp`, `itemReactions`
**Testing**: DTO validation, domain (party estimate, vision), widget tests for both panels,
real-dataset test, accessibility suite
**Platforms/Constraints**: unchanged (offline, pt-BR, a11y, fixed dark theme)
**Scale**: 30 monsters now; the same scripts feed feature 004 (all large monsters)

## Constitution Check

| Principle | Pre | Post |
|-----------|-----|------|
| I Clean Architecture (domain pure Dart) | ✅ | ✅ `HuntingInfo`, `RankHp`, `ItemReaction` pure Dart |
| II MVC (logic out of views) | ✅ | ✅ estimates computed in domain |
| III Dependency rule | ✅ | ✅ |
| IV Offline, versioned data, sources recorded | ✅ | ✅ additive v1 fields; every value sourced (research R1–R3) |
| V Multi-game | ✅ | ✅ items and factors per game dataset |
| VI Tests first | ✅ | ✅ |
| VII i18n, lints | ✅ | ✅ new ARB strings |

**Result**: PASS.

## Project Structure

```text
lib/features/monsters/domain/entities/  hunting_info.dart, rank_hp.dart, party_hp_factors.dart,
                                        item_reaction.dart, hunting_item.dart, vision.dart
lib/features/monsters/data/dtos/        monster_dataset_dto.dart (+ optional fields, validation),
                                        monster_dataset_mapper.dart
lib/features/monsters/presentation/views/widgets/  hp_section.dart, hunting_items_section.dart
assets/data/*/monsters.json             + new fields (scratchpad scripts; not shipped)
test/…                                  mirrors
```

## Complexity Tracking

None.
