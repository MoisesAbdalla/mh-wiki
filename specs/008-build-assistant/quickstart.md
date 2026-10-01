# Quickstart: validating 008

## Data

```powershell
python tool/data/build_rise_builds.py           # Game8 pages (cached) → builds.json + report
flutter test test/features/assistant/data/real_builds_dataset_test.dart
```

## Gates

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter test integration_test -d windows
flutter build windows --release
```

## Manual checks

1. The **Assistente** area opens on Recomendadas, and Montar build reads "em breve".
2. Pick **Mestre · M2★** and **Espadão**:
   - Para agora shows "Kamura Warrior Cleaver Raw Affinity" (MR 1–2);
   - Próximas shows the MR 3–6 and later builds, dimmed.
3. Close and reopen the app: the progress and the weapon type are still chosen.
4. Open "Fine Kamura Cleaver Dereliction Strongarm":
   - the waist reads "Escarcela Caótica ou Nephilim Tassets";
   - the talisman reads "Olho Crítico 3";
   - Habilidades shows Reforço de Ataque at 7 of 7;
   - tapping a piece opens it in Armaduras.
5. Save it, rename it to "Meu Espadão", and restart the app: it is still in Minhas builds. Then
   delete it.
6. Pick **Baixo** and a type with no Low Rank builds: the empty message shows.
7. In Configurações, switch names to English: pieces and skills show English names.
8. At 320 dp with large text there is no overflow.
