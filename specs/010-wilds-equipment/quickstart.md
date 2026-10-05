# Quickstart: validating 010

## Data

```powershell
python tool/data/fetch_wilds_equipment.py     # wilds.mhdb.io en + pt-BR (cached)
python tool/data/fetch_wilds_icons.py         # wiki MHWA icons by rarity, decorations, renders
python tool/data/build_wilds_equipment.py     # → assets/data/wilds/weapons.json, armor.json (+ Artian)
flutter test test/features/weapons test/features/armor
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

1. Armas shows the game logos. Wilds → Espadão lists the weapons by rarity, with Wilds icons.
2. Open **Sieglinde**: Ataque 1008, Afinidade 15%, Veneno 300, slots ③②①, Prolongar Veneno 1 and
   Status Crítico 3. Tapping a skill opens it in Armaduras (Wilds).
3. Switch to Rise and back. Each game keeps its type and selection.
4. **Artian**: open Varianza, choose Gelo with 3 Gelo parts, Ataque ×4 and Afinidade ×1. The result
   matches the Game8 numbers. Save it as "Minha Varianza". It shows in the Artian group after
   restarting the app.
5. Armaduras → Wilds → **Arkveld α**:
   - 5 pieces of rarity 8;
   - Bônus do conjunto: Fome de Arkveld (2: Regeneração Veloz I, 4: II) and Pelica Fortificante
     (3: Fortificar).
6. **Joias**: "De arma" filters; "Joia Stat. Crít./Artesanato 3" shows both skills.
7. **Talismãs**: "Amuleto da Fartura" shows I–III.
8. Monstros → Wilds → Rathian shows "Armas feitas com ele".
9. Switch names to English: every Wilds name changes. At 320 dp with large text there is no
   overflow.
