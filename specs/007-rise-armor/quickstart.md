# Quickstart: validating 007

## Data

```powershell
python tool/data/fetch_rise_armor_pages.py      # Kiranico armor and decoration pages (cached)
python tool/data/fetch_rise_item_pages.py       # new material item pages
python tool/data/build_rise_armor.py --icons    # armor.json + icons
python tool/data/build_rise_weapons.py          # + Rampage skills and decorations
flutter test test/features/armor/data/real_armor_dataset_test.dart
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

1. The **Armaduras** area opens on Conjuntos; Assistente is still "em breve".
2. Set the rank to **Mestre**, then search "ataque" and pick "Reforço de Ataque". The Rathalos X
   card shows "Reforço de Ataque 7" first in the footer.
3. Open **Rathalos X**:
   - Defesa reads 570 → 870;
   - the resistances are fogo 15, água 5, trovão −10 (red), gelo 5 and dragão −15 (red);
   - Habilidades shows Reforço de Ataque with 7 of 7 pips.
4. Tap **Elmo de Rathalos X** under Peças. The materials include "Resto Pesado Rathalos", and the
   Rathalos seal opens the monster.
5. Tap **Reforço de Ataque**:
   - the 7 levels are listed;
   - Joias shows "Joia do Ataque 2" (Nv 1, slot 2) and "Joia Ataque+ 4" (Nv 2, slot 4);
   - Armaduras lists the Rathalos X pieces.
6. In **Joias**, filter slot 4. The list shows only level-4 decorations, and a decoration's detail
   shows its skill and materials.
7. Open the weapon **Lâmina D. Kamura V**. The Habilidades Rampage card lists Ref. de Afinid. III,
   Reforço de Defesa II and Mestre em Montaria.
8. Open a Master Rank weapon with Rampage slot 3. The Rampage card shows the slot and the Rampage
   decorations of level 3 or lower.
9. In Configurações, switch names to English. Sets, skills and decorations show English names.
10. At 320 dp with large text there is no overflow, and the tabs scroll.
