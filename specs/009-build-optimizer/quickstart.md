# Quickstart: validating 009

## Data

```powershell
python tool/data/build_rise_optimizer.py      # armor.json + weapons.json → optimizer.json
flutter test test/features/assistant/optimizer
```

The optimizer tests include:
- the SC-001 property test;
- the SC-003 curated-build test;
- the benchmark, which prints its timings.

## Gates

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter test integration_test -d windows
flutter build windows --release
```

## Manual checks

1. In the Assistente, **Montar build** opens (not "em breve"). The strip shows the progress and type
   from Recomendadas, and "alterar" goes there.
2. Pick **Mestre · M6★** and **Espadão**, then add Reforço de Ataque 7, Olho Crítico 7, Reforço
   Crítico 3 and Explor. de Fraqueza 3. "Montar build" shows "procurando…" and then results, at
   least one "completa", within 10 s.
3. Open the first result:
   - Habilidades pedidas show 7/7, 7/7, 3/3 and 3/3;
   - add up the pieces' and jewels' skills by hand: they match.
4. Use "›" to go to result 2 and back, then save it. It appears in Minhas builds; rename it.
5. In **Meus talismãs**, add "Olho Crítico 3, slots 2-1-0". Search again: a result uses it and
   needs fewer Critical jewels.
6. Fix the weapon to "Ótimo Cutelo Kamura": every result uses it.
7. Ask for something impossible (e.g. Baixo 1★ with 5 skills at max): "quase" results or the
   no-sets message. Cancel works during a long search.
8. Restart the app: the chosen skills, options and talismans are still there.
9. At 320 dp with large text there is no overflow. With names in English (Configurações), skills
   and pieces show English names.

## Known limitation

"Só peças do meu progresso" filters by rarity (research R3). Inside rarity 10, the Master Rank
level gates (Risen, Afflicted) are not modelled.
