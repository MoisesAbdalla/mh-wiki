"""Downloads the Monster Hunter World: Iceborne icons and images (011 research R6).

- Equipment icons by rarity, Monster Hunter Wiki MHWI-<Kind>_Icon_Rare_<1..12>:
  the 14 weapon types, the 5 armor parts and the talisman
  → assets/images/world/icons/<kind>-<rarity>.webp
- Decoration icons by level and colour (MHWI-Decoration_Level_<1..4>_Icon_<Color>)
  → assets/images/world/decorations/<level>-<color>.webp
- Slot icons (MHWI-Decoration_Level_<N>_Icon_White, tinted gold)
  → assets/images/world/slots/slot<N>.webp
- Weapon renders (MHWI-<Name>_Render.png, the wiki has them for the last forms)
  → assets/images/world/weapons/<slug>.webp, index .cache/world_weapon_renders.json
- Armor set renders (MHWI-<Set>_Armor_Male_Render.png)
  → assets/images/world/sets/<slug>.webp, index .cache/world_set_renders.json

Needs fetch_world_equipment.py first; the image list comes from the wiki API.
"""
import json
import os
import re
import subprocess
import sys
import unicodedata
import urllib.parse

from fetch_wilds_icons import GOLD, run, save, wiki_file  # noqa: F401  (save is used by run)

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
CACHE = os.path.join(HERE, '.cache')
OUT = os.path.join(REPO, 'assets', 'images', 'world')
WIKI = 'https://monsterhunterwiki.org'

ICON_KINDS = {
    'head': 'Helmet', 'chest': 'Chestplate', 'arms': 'Armguards', 'waist': 'Waist',
    'legs': 'Leggings', 'talisman': 'Talisman',
    'great-sword': 'Great_Sword', 'long-sword': 'Long_Sword', 'sword-and-shield': 'Sword_and_Shield',
    'dual-blades': 'Dual_Blades', 'hammer': 'Hammer', 'hunting-horn': 'Hunting_Horn',
    'lance': 'Lance', 'gunlance': 'Gunlance', 'switch-axe': 'Switch_Axe',
    'charge-blade': 'Charge_Blade', 'insect-glaive': 'Insect_Glaive', 'bow': 'Bow',
    'light-bowgun': 'Light_Bowgun', 'heavy-bowgun': 'Heavy_Bowgun',
}
DECO_COLORS = ['White', 'Blue', 'Yellow', 'Purple', 'Red', 'Rose', 'Light_Blue', 'Gray',
               'Emerald', 'Brown', 'Dark_Blue', 'Lemon', 'Tan', 'Pink', 'Vermilion', 'Moss',
               'Green', 'Dark_Purple', 'Light_Green', 'Orange', 'Violet']


def slug(text):
    return re.sub(r'[^a-z0-9]+', '-', text.lower().replace("'", '')).strip('-')


def norm(text):
    text = unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode().lower()
    return re.sub(r'[^a-z0-9+]', '', text)


def wiki_images():
    path = os.path.join(CACHE, 'world_wiki_images.json')
    if os.path.exists(path):
        with open(path, encoding='utf8') as f:
            return json.load(f)
    names, cont = [], None
    while True:
        url = (f'{WIKI}/api.php?action=query&list=allimages&aiprefix=MHWI-&ailimit=500&format=json'
               + (f'&aicontinue={urllib.parse.quote(cont)}' if cont else ''))
        out = subprocess.run(['curl', '-s', '-A', 'Mozilla/5.0', url], capture_output=True)
        data = json.loads(out.stdout)
        names += [i['name'] for i in data['query']['allimages']]
        cont = data.get('continue', {}).get('aicontinue')
        if not cont:
            break
    with open(path, 'w', encoding='utf8') as f:
        json.dump(names, f)
    return names


def jobs_icons():
    for key, kind in ICON_KINDS.items():
        for r in range(1, 13):
            path = os.path.join(OUT, 'icons', f'{key}-{r}.webp')
            yield path, (lambda kind=kind, r=r: wiki_file(f'MHWI-{kind}_Icon_Rare_{r}.png')), 64, None


def jobs_decorations(have):
    for level in range(1, 5):
        for color in DECO_COLORS:
            name = f'MHWI-Decoration_Level_{level}_Icon_{color}.png'
            if name in have:
                path = os.path.join(OUT, 'decorations', f'{level}-{slug(color)}.webp')
                yield path, (lambda name=name: wiki_file(name)), 48, None


def jobs_slots():
    for n in range(1, 5):
        path = os.path.join(OUT, 'slots', f'slot{n}.webp')
        yield path, (lambda n=n: wiki_file(f'MHWI-Decoration_Level_{n}_Icon_White.png')), 48, GOLD


def jobs_weapons(have, index):
    with open(os.path.join(CACHE, 'world_wiki_weapons.json'), encoding='utf8') as f:
        weapons = json.load(f)
    renders = {norm(n[5:].rsplit('_Render', 1)[0]): n for n in have
               if '_Render.' in n and 'Armor' not in n}
    for name in weapons:
        file = renders.get(norm(name))
        if not file:
            continue
        rel = f'assets/images/world/weapons/{slug(name)}.webp'
        index[name] = rel
        yield os.path.join(REPO, rel), (lambda file=file: wiki_file(file)), 96, None


def jobs_sets(have, index):
    with open(os.path.join(CACHE, 'world_wiki_armor.json'), encoding='utf8') as f:
        sets = json.load(f)
    renders = {norm(n[5:].rsplit('_Armor_Male_Render', 1)[0]): n for n in have
               if '_Armor_Male_Render.' in n}
    for s in sets.values():
        name = s['SetName']
        key = norm(name.replace('α', 'Alpha').replace('β', 'Beta').replace('γ', 'Gamma'))
        file = renders.get(key)
        if not file:
            continue
        rel = f'assets/images/world/sets/{slug(key)}.webp'
        index[name] = rel
        yield os.path.join(REPO, rel), (lambda file=file: wiki_file(file)), 128, None


def main():
    have = set(wiki_images())
    weapon_index, set_index = {}, {}
    for label, jobs in [('icons', jobs_icons()), ('decorations', jobs_decorations(have)),
                        ('slots', jobs_slots()), ('weapon renders', jobs_weapons(have, weapon_index)),
                        ('set renders', jobs_sets(have, set_index))]:
        ok, total = run(list(jobs))
        print(f'{label:15} {ok}/{total}')
    with open(os.path.join(CACHE, 'world_weapon_renders.json'), 'w', encoding='utf8') as f:
        json.dump(weapon_index, f, ensure_ascii=False, indent=0)
    with open(os.path.join(CACHE, 'world_set_renders.json'), 'w', encoding='utf8') as f:
        json.dump(set_index, f, ensure_ascii=False, indent=0)
    with open(os.path.join(OUT, 'SOURCES.md'), 'w', encoding='utf8') as f:
        f.write('# Monster Hunter World: Iceborne icons and images\n\n'
                '- `icons/`: equipment icons by rarity, Monster Hunter Wiki `MHWI-<Kind>_Icon_Rare_<N>`.\n'
                '- `decorations/`, `slots/`: Monster Hunter Wiki `MHWI-Decoration_Level_*` (slots tinted gold).\n'
                '- `weapons/`: Monster Hunter Wiki weapon renders (`MHWI-<Name>_Render`).\n'
                '- `sets/`: Monster Hunter Wiki armor set renders (`MHWI-<Set>_Armor_Male_Render`).\n\n'
                'Capcom artwork, used locally like the other icons. Built by `tool/data/fetch_world_icons.py`.\n')
    total = sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(OUT) for f in fs)
    print(f'total {total / 1024 / 1024:.1f} MB')


if __name__ == '__main__':
    sys.exit(main())
