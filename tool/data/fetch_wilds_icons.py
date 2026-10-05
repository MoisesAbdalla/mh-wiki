"""Downloads the Monster Hunter Wilds icons and images (010 research R3).

- Equipment icons by rarity from the Monster Hunter Wiki (MHWA-<Kind>_Icon_Rare_<N>):
  armor parts, talisman, the 14 weapon types and the Artian (Relic) parts
  → assets/images/wilds/icons/<kind>-<rarity>.webp
- Decoration icons (MHWilds-Decoration_Level_<slot>-Sword|Armor_Icon_<Color>)
  for every colour wilds.mhdb.io uses → assets/images/wilds/decorations/
- Slot icons (MHWilds-Decoration_Level_<N>_Icon_White, tinted gold)
  → assets/images/wilds/slots/slot<N>.webp
- Weapon renders listed in the wiki's Module:MHWilds/data/Weapons/RendersDict.json
  → assets/images/wilds/weapons/<file-slug>.webp, plus .cache/wilds_weapon_renders.json
- Armor piece renders from Kiranico Wilds (tex_thumbnail, male model)
  → assets/images/wilds/armor/<series>-<part>.webp, plus .cache/wilds_armor_renders.json

Needs fetch_wilds_equipment.py first (for decoration colours).
"""
import io
import json
import os
import re
import subprocess
import sys
import urllib.parse
from concurrent.futures import ThreadPoolExecutor

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
CACHE = os.path.join(HERE, '.cache')
OUT = os.path.join(REPO, 'assets', 'images', 'wilds')
UA = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126 Safari/537.36')
WIKI = 'https://monsterhunterwiki.org'

ICON_KINDS = {
    'head': 'Helmet', 'chest': 'Chestplate', 'arms': 'Armguards', 'waist': 'Waist',
    'legs': 'Leggings', 'talisman': 'Talisman',
    'great-sword': 'Great_Sword', 'long-sword': 'Long_Sword', 'sword-and-shield': 'Sword_and_Shield',
    'dual-blades': 'Dual_Blades', 'hammer': 'Hammer', 'hunting-horn': 'Hunting_Horn',
    'lance': 'Lance', 'gunlance': 'Gunlance', 'switch-axe': 'Switch_Axe',
    'charge-blade': 'Charge_Blade', 'insect-glaive': 'Insect_Glaive', 'bow': 'Bow',
    'light-bowgun': 'Light_Bowgun', 'heavy-bowgun': 'Heavy_Bowgun',
    'relic-blade': 'Relic_Blade', 'relic-device': 'Relic_Device', 'relic-disc': 'Relic_Disc',
    'relic-tube': 'Relic_Tube',
}
PARTS = ['head', 'chest', 'arms', 'waist', 'legs']
GOLD = (224, 189, 106)


def get(url):
    out = subprocess.run(['curl', '-sfL', '-m', '60', '-A', UA, '-e', WIKI + '/', url],
                         capture_output=True)
    return out.stdout if out.returncode == 0 else None


def wiki_file(name):
    return get(f'{WIKI}/wiki/Special:FilePath/{urllib.parse.quote(name)}')


def clear_background(im, tolerance=24):
    """Makes the flat dark background of a Kiranico render transparent by
    flooding from the edges, so dark parts inside the piece stay."""
    px = im.load()
    w, h = im.size
    seen = set()
    stack = [(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for x in (0, w - 1) for y in range(h)]
    while stack:
        x, y = stack.pop()
        if (x, y) in seen or not (0 <= x < w and 0 <= y < h):
            continue
        seen.add((x, y))
        r, g, b, a = px[x, y]
        if a == 0 or max(r, g, b) > tolerance:
            continue
        px[x, y] = (r, g, b, 0)
        stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return im


def save(data, path, size, tint=None):
    if not data:
        return False
    try:
        im = Image.open(io.BytesIO(data)).convert('RGBA')
    except Exception:
        return False
    if os.sep + 'armor' + os.sep in path or '/armor/' in path:
        im = clear_background(im)
    im.thumbnail((size, size), Image.LANCZOS)
    if tint:
        px = im.load()
        for y in range(im.height):
            for x in range(im.width):
                r, g, b, a = px[x, y]
                k = (r + g + b) / 765
                px[x, y] = (round(tint[0] * k), round(tint[1] * k), round(tint[2] * k), a)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path, 'WEBP', quality=90, method=6)
    return True


def slug(text):
    return re.sub(r'[^a-z0-9]+', '-', text.lower().replace("'", '')).strip('-')


def jobs_icons():
    for key, kind in ICON_KINDS.items():
        for r in range(1, 9):
            path = os.path.join(OUT, 'icons', f'{key}-{r}.webp')
            yield path, (lambda kind=kind, r=r: wiki_file(f'MHWA-{kind}_Icon_Rare_{r}.png')), 64, None


def jobs_decorations():
    with open(os.path.join(CACHE, 'wilds_mhdb_decorations_en.json'), encoding='utf8') as f:
        decos = json.load(f)
    seen = set()
    for d in decos:
        color = (d.get('icon') or {}).get('color')
        if not color:
            continue
        kind = 'Sword' if d['kind'] == 'weapon' else 'Armor'
        key = (d['slot'], kind, color)
        if key in seen:
            continue
        seen.add(key)
        path = os.path.join(OUT, 'decorations', f'{d["slot"]}-{kind.lower()}-{slug(color)}.webp')
        yield path, (lambda s=d['slot'], k=kind, c=color: deco_icon(s, k, c)), 48, None


# mhdb colour names the wiki spells differently, and a hex for tinting the
# white icon when the wiki has no file in that colour.
DECO_ALIASES = {'sky': 'Light_Blue', 'moss green': 'Moss', 'sage green': 'Light_Green',
                'ultramarine': 'Dark_Blue', 'ivory': 'White'}
DECO_HEX = {'sky': (111, 198, 232), 'moss green': (122, 142, 58), 'sage green': (156, 179, 138),
            'ultramarine': (63, 91, 216), 'ivory': (233, 227, 201), 'dark purple': (110, 74, 168)}


def deco_icon(slot, kind, color):
    color = color.replace('-', ' ')
    names = ['_'.join(w.capitalize() for w in color.split())]
    if color in DECO_ALIASES:
        names.insert(0, DECO_ALIASES[color])
    for n in names:
        data = wiki_file(f'MHWilds-Decoration_Level_{slot}-{kind}_Icon_{n}.png')
        if data:
            return data
    white = wiki_file(f'MHWilds-Decoration_Level_{slot}-{kind}_Icon_White.png')
    rgb = DECO_HEX.get(color)
    if not white or not rgb:
        return None
    im = Image.open(io.BytesIO(white)).convert('RGBA')
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            k = (r + g + b) / 765
            px[x, y] = (round(rgb[0] * k), round(rgb[1] * k), round(rgb[2] * k), a)
    buf = io.BytesIO()
    im.save(buf, 'PNG')
    return buf.getvalue()


def jobs_slots():
    for n in range(1, 5):
        path = os.path.join(OUT, 'slots', f'slot{n}.webp')
        yield path, (lambda n=n: wiki_file(f'MHWilds-Decoration_Level_{n}_Icon_White.png')), 48, GOLD


def renders_dict():
    q = {'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
         'titles': 'Module:MHWilds/data/Weapons/RendersDict.json', 'format': 'json'}
    data = json.loads(get(f'{WIKI}/api.php?' + urllib.parse.urlencode(q)))
    page = next(iter(data['query']['pages'].values()))
    return json.loads(page['revisions'][0]['slots']['main']['*'])


def jobs_weapons(index):
    files = sorted({f for per_type in renders_dict().values() for f in per_type.values()})
    for per_type in renders_dict().values():
        for name, f in per_type.items():
            index[name] = f'assets/images/wilds/weapons/{slug(f.rsplit(".", 1)[0])}.webp'
    for f in files:
        path = os.path.join(OUT, 'weapons', f'{slug(f.rsplit(".", 1)[0])}.webp')
        yield path, (lambda f=f: wiki_file(f)), 96, None


def kiranico_series():
    html = get('https://mhwilds.kiranico.com/data/armor-series').decode('utf8').replace('\\"', '"')
    marks = [(m.start(), 'name', m.group(1)) for m in re.finditer(r'"en":"([^"]+)"', html)]
    marks += [(m.start(), 'img', m.group(1)) for m in
              re.finditer(r'tex_thumbnail/(ch02_\d+_\d+_\d+_(\d))\.webp', html)]
    marks.sort()
    series, cur = {}, None
    for _, kind, value in marks:
        if kind == 'name':
            cur = value
        elif cur:
            series.setdefault(cur, {})[PARTS[int(value[-1])]] = value
    return series


def jobs_armor(index):
    for name, parts in kiranico_series().items():
        for part, tex in parts.items():
            rel = f'assets/images/wilds/armor/{slug(name)}-{part}.webp'
            index.setdefault(name, {})[part] = rel
            yield (os.path.join(REPO, rel),
                   (lambda tex=tex: get(f'https://mhwilds.kiranico.net/tex_thumbnail/{tex}.webp')), 96, None)


def run(jobs):
    def one(job):
        path, fetch, size, tint = job
        if os.path.exists(path):
            return True
        return save(fetch(), path, size, tint)
    with ThreadPoolExecutor(max_workers=6) as pool:
        results = list(pool.map(one, jobs))
    return sum(results), len(results)


def main():
    weapon_index, armor_index = {}, {}
    for label, jobs in [('icons', jobs_icons()), ('decorations', jobs_decorations()),
                        ('slots', jobs_slots()), ('weapon renders', jobs_weapons(weapon_index)),
                        ('armor renders', jobs_armor(armor_index))]:
        ok, total = run(list(jobs))
        print(f'{label:15} {ok}/{total}')
    with open(os.path.join(CACHE, 'wilds_weapon_renders.json'), 'w', encoding='utf8') as f:
        json.dump(weapon_index, f, ensure_ascii=False, indent=0)
    with open(os.path.join(CACHE, 'wilds_armor_renders.json'), 'w', encoding='utf8') as f:
        json.dump(armor_index, f, ensure_ascii=False, indent=0)
    with open(os.path.join(OUT, 'SOURCES.md'), 'w', encoding='utf8') as f:
        f.write('# Monster Hunter Wilds icons and images\n\n'
                '- `icons/`: equipment icons by rarity, Monster Hunter Wiki `MHWA-<Kind>_Icon_Rare_<N>`.\n'
                '- `decorations/`, `slots/`: Monster Hunter Wiki `MHWilds-Decoration_Level_*` (slots tinted gold).\n'
                '- `weapons/`: Monster Hunter Wiki weapon renders (Module:MHWilds/data/Weapons/RendersDict.json).\n'
                '- `armor/`: Kiranico Wilds armor thumbnails (male model).\n\n'
                'Capcom artwork, used locally like the other icons. Built by `tool/data/fetch_wilds_icons.py`.\n')
    total = sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(OUT) for f in fs)
    print(f'total {total / 1024 / 1024:.1f} MB')


if __name__ == '__main__':
    sys.exit(main())
