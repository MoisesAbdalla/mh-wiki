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
| `build_wilds.py`, `build_rise.py`, `build_world.py` (+ `kiranico_world.py`) | Names en/pt-BR, classification, weaknesses, habitats, parts, drops | [001 research](../../specs/001-monster-wiki/research.md) |
| `hp_extract.py [game…]` | Solo HP per rank, party HP factors | [003 research R1/R2](../../specs/003-hunting-info/research.md) |
| `items_extract.py [game…]` (+ `item_parse.py`) | Hunting items and reactions | [003 research R3](../../specs/003-hunting-info/research.md) |
| `fetch_icons.py [game…]` | Hunter's-notes icons → 256 px WebP | [002 research](../../specs/002-visual-identity/research.md) |
| `common.py` | Paths (repo, cache), game selection, helpers | |

Each step rewrites the dataset file, so run them in the order `build.py` uses. Every value keeps
its source in the dataset's and monster's `sources`. Values the sources do not confirm are left
out, so the app shows "Desconhecido".
