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
| `build_rise_builds.py` | Curated builds → `assets/data/rise_sunbreak/builds.json` from the Game8 build pages of the 14 weapon types (Master, High and Low Rank), matched to our weapons and armor datasets; report of unmatched items | [008 research R1–R4](../../specs/008-build-assistant/research.md) |
| `build_rise_optimizer.py` | Compact optimizer view → `assets/data/rise_sunbreak/optimizer.json` (skills, decorations, pieces, weapons) from `armor.json` and `weapons.json` | [009 research R2](../../specs/009-build-optimizer/research.md) |
| `fetch_wilds_equipment.py` | Caches the wilds.mhdb.io weapons, armor, skills, decorations and charms (en + pt-BR) in `.cache/wilds_mhdb_<endpoint>_<lang>.json` | [010 research](../../specs/010-wilds-equipment/research.md) |
| `fetch_wilds_icons.py` | Wilds icons → `assets/images/wilds/`: equipment icons by rarity (`icons/`), decoration icons (`decorations/`), gold slot icons (`slots/`), weapon renders (`weapons/`, Monster Hunter Wiki), piece renders (`armor/`, Kiranico, black background removed). 5.4 MB in all | [010 research R3](../../specs/010-wilds-equipment/research.md) |
| `build_wilds_equipment.py` | Wilds weapons and armor → `assets/data/wilds/{weapons,armor}.json` (1.6 MB + 1.3 MB): weapon skills, sharpness with Handicraft, sets with set and group bonuses, skill and decoration kinds, talismans, piece ranks, materials matched to monsters. Keeps an existing `artian` section | [010 research R1](../../specs/010-wilds-equipment/research.md) |
| `build_wilds_artian.py` | The `artian` section of `wilds/weapons.json` (14 types: bases, elements by rarity, infusion, production and reinforcement rules) from the Monster Hunter Wiki; drops the 42 Artian that mhdb lists as plain weapons | [010 research R2](../../specs/010-wilds-equipment/research.md) |
| `fetch_part_icons.py` | Equipment part icons by rarity (helmet … talisman) → `assets/images/armor/parts/` from the Monster Hunter Fandom wiki | 008 equipment card |
| `kiranico_items.py` | Shared: slugs, name keys and material sources from the Kiranico item pages | [007 research R5](../../specs/007-rise-armor/research.md) |
| `common.py` | Paths (repo, cache), game selection, helpers | |

Each step rewrites the dataset file, so run them in the order `build.py` uses. Every value keeps
its source in the dataset's and monster's `sources`. Values the sources do not confirm are left
out, so the app shows "Desconhecido".
