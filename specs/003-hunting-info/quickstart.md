# Quickstart & Validation: Informações de Caçada (003-hunting-info)

## Gates

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

## Manual checks

| # | Scenario | Expected | Spec |
|---|----------|----------|------|
| 1 | World Rathalos → HP | Baixo 4.908 · Alto 6.565 · Mestre 20.800; grupo aprox. with Fextralife source | US1, FR-001/002 |
| 2 | Rise Rathalos → HP | "a partir de" values per rank; Grupo: Desconhecido | FR-001/002 |
| 3 | Wilds Rathalos → HP | Alto "a partir de"; grupo aprox. 2/3/4 | FR-001/002 |
| 4 | Any monster → Itens de caça | 5 items of its game, each with a status; Rise shows "Bomb" names | US2, FR-004 |
| 5 | Wilds Rathalos → Flash Pod | "Afeta" (infobox wins over 0 s) | research R3 |
| 6 | Switch names to English | item names follow the setting | FR-008 |
| 7 | 320 dp, 200% text | no overflow | FR-007 |

## Data accuracy (SC-001/SC-002)

For the 30 monsters, compare HP and reactions with the recorded sources; fix data only.
