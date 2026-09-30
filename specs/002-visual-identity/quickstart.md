# Quickstart & Validation: Identidade Visual (002-visual-identity)

## Gates

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test                                   # all 001 tests still pass + new theme tests
flutter test test/features/monsters/data/real_datasets_test.dart   # images referenced exist
```

## Manual checks

| # | Scenario | Expected | Spec |
|---|----------|----------|------|
| 1 | Windows in light mode → `flutter run -d windows` | dark "Caderno do Caçador" theme | FR-001, SC-002 |
| 2 | Scroll "Todos" | every monster shows its own game's icon; ornamental header per game | FR-003, FR-010, SC-001 |
| 3 | Rathalos in World, Rise, Wilds | three different icons | Edge case |
| 4 | List items | primary weakness badge; none for monsters without a 2★ weakness | FR-005 |
| 5 | Open Alatreon (World) | 5-column weakness grid, dragon framed; state blocks below | FR-006 |
| 6 | Open Rathalos | Habitat and Parts side by side; "Cortável" on Tail | FR-008 |
| 7 | Resize window across 840 px | both layouts themed; selection kept | FR-012 |
| 8 | Settings | themed; switching English still renames instantly | FR-002, FR-012 |
| 9 | Compare with prototype A | same identity elements | SC-005 |
