# Data pipeline

Offline scripts that build `assets/data/<game>/monsters.json` and the monster thumbnails from
public sources. They are not part of the app build. You need Python 3 with Pillow
(`pip install pillow`).

```sh
python tool/data/build.py wilds          # or rise_sunbreak / world_iceborne
flutter test test/features/monsters/data/real_datasets_test.dart
```

Downloaded pages are cached in `tool/data/.cache/`, which git ignores. Delete that folder to
fetch fresh pages. Running the build again on the same cache gives the same dataset.

| Script | What it does | Rules |
|--------|--------------|-------|
| `roster_wilds.py`, `roster_rise.py`, `roster_world.py` | Rosters with versions → `rosters/<game>.json` | [004 research R4](../../specs/004-all-large-monsters/research.md) |
| `build_wilds.py`, `build_rise.py`, `build_world.py` (+ `kiranico_world.py`) | Names en/pt-BR, classification, weaknesses, habitats, parts, drops | [001 research](../../specs/001-monster-wiki/research.md) |
| `hp_extract.py [game…]` (+ `macaron.py`) | Solo HP per rank, party HP factors; Wilds tempered and arch-tempered HP from the macarongamemo table | [003 research R1/R2](../../specs/003-hunting-info/research.md) |
| `items_extract.py [game…]` (+ `item_parse.py`) | Hunting items and reactions | [003 research R3](../../specs/003-hunting-info/research.md) |
| `fetch_icons.py [game…]` | Hunter's-notes icons → 256 px WebP | [002 research](../../specs/002-visual-identity/research.md) |
| `fetch_game_logos.py` | Official game logos → `assets/images/games/*.webp` (138 px, alpha) | [005 research R5](../../specs/005-visual-refresh/research.md) |
| `build_rise_weapons.py [--icons]` | Every Rise: Sunbreak weapon → `assets/data/rise_sunbreak/weapons.json`: stats, sharpness, slots, materials, upgrade tree and estimated stars from the monsterhunterwiki.org MHRS pages, pt-BR names from Kiranico. `--icons` also fetches the weapon icons (96 px WebP) and the 14 type icons | [006 research R1–R5](../../specs/006-rise-weapons/research.md) |
| `fetch_rise_weapon_pages.py`, `fetch_rise_armor_pages.py`, `fetch_rise_item_pages.py` | Cache the Kiranico weapon, armor, decoration and item pages (en + pt-BR), 4 requests at a time | [006 R12/R13](../../specs/006-rise-weapons/research.md), [007 R1](../../specs/007-rise-armor/research.md) |
| `build_rise_armor.py [--icons]` | Rise armor → `assets/data/rise_sunbreak/armor.json`: pieces (Kiranico lists), sets, body parts and max defense (wiki set pages), forge materials (Kiranico pages), skills and decorations; `--icons` fetches the piece renders | [007 research R1–R7](../../specs/007-rise-armor/research.md) |
| `kiranico_items.py` | Shared: slugs, name keys and material sources from the Kiranico item pages | [007 research R5](../../specs/007-rise-armor/research.md) |
| `common.py` | Paths (repo, cache), game selection, helpers | |

Each step rewrites the dataset file, so run them in the order `build.py` uses. Every value keeps
its source in the dataset's and monster's `sources`. Values the sources do not confirm are left
out, so the app shows "Desconhecido".
