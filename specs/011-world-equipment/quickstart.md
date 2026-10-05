# Quickstart: validating 011

## Data

```powershell
python tool/data/fetch_world_equipment.py   # wiki modules, mhw-db, Kiranico en/pt-BR (cached)
python tool/data/fetch_world_icons.py       # MHWI icons, decorations, slots, renders
python tool/data/build_world_equipment.py   # → assets/data/world_iceborne/weapons.json, armor.json
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

1. Armas → World (logo enabled) → Espadão → Mestre: the Árvore Dragosso shows Dharma Inabalável
   with "(Dragão 540)".
2. Open **Dharma Inabalável**:
   - Ataque 1344, Afinidade 0 %, Dragão (540) with the hidden note;
   - Selo do Ancião Alto, Defesa +30;
   - slots ①①, Aumentos 1;
   - it upgrades from Espada Selo Dragão I.
3. A material with a source → "Dropado por" opens the monster in Monstros (World).
4. At the end of Espadão, **Especiais** lists the Kulve Taroth, Kjárr and Safi'jiiva great swords.
   One of them opens with "Como obter".
5. Armaduras → World → **Fatalis α+**:
   - defense base → max;
   - Lenda de Fatalis (2 and 4 peças);
   - pieces with World icons and slots 1–4.
6. **Joias** → 4: "Joia Ataque/Fortitude 4" shows both skills.
7. **Talismãs**: "Amuleto de Ataque" shows I–V.
8. Monstros → World → Rathalos shows "Armas feitas com ele".
9. Names in English; 320 dp with large text; switching between World, Rise and Wilds keeps each
   game's state.
