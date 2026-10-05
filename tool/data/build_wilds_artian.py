"""Adds the Artian weapons section to assets/data/wilds/weapons.json (010 research R2).

Sources:
- Monster Hunter Wiki `Module:MHWilds/data/Weapons.json` (tree "Artian"): names,
  raw attack, affinity, sharpness with Handicraft, slots;
- Monster Hunter Wiki "Artian Weapons (MHWilds)": element values per rarity and
  the Element Infusion bonus per type;
- Game8 "Artian Weapons Guide" (503103): reinforcement rules (Element Boost per
  type, Sharpness +30 / +20 for Insect Glaive, Ammo +1 for bowguns, limits);
- Kiranico Wilds weapons list: the pt-BR names.

Displayed attack = raw × the type's multiplier, taken from wilds.mhdb.io
(display / raw), so the Artian numbers match the game's bloated values.
"""
import json
import os
import re
import subprocess
import sys
import urllib.parse
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
CACHE = os.path.join(HERE, '.cache')
OUT = os.path.join(REPO, 'assets', 'data', 'wilds', 'weapons.json')
WIKI = 'https://monsterhunterwiki.org'

ABBR = {'GS': 'great-sword', 'LS': 'long-sword', 'SnS': 'sword-and-shield', 'DB': 'dual-blades',
        'Hm': 'hammer', 'HH': 'hunting-horn', 'Ln': 'lance', 'GL': 'gunlance', 'SA': 'switch-axe',
        'CB': 'charge-blade', 'IG': 'insect-glaive', 'LBG': 'light-bowgun', 'HBG': 'heavy-bowgun',
        'Bo': 'bow'}
WIKI_SECTION = {'great-sword': 'Great Sword', 'long-sword': 'Long Sword', 'sword-and-shield': 'Sword and Shield',
                'dual-blades': 'Dual Blades', 'hammer': 'Hammer', 'hunting-horn': 'Hunting Horn',
                'lance': 'Lance', 'gunlance': 'Gunlance', 'switch-axe': 'Switch Axe',
                'charge-blade': 'Charge Blade', 'insect-glaive': 'Insect Glaive',
                'light-bowgun': 'Light Bowgun', 'heavy-bowgun': 'Heavy Bowgun', 'bow': 'Bow'}
# Game8 503103 › Reinforcement Bonuses: Element Boost per type.
ELEMENT_BOOST = {'great-sword': 80, 'long-sword': 50, 'hammer': 50, 'hunting-horn': 50, 'lance': 50,
                 'gunlance': 50, 'charge-blade': 50, 'sword-and-shield': 30, 'switch-axe': 30,
                 'insect-glaive': 30, 'bow': 30, 'dual-blades': 20}
ELEMENTS = ['fire', 'water', 'thunder', 'ice', 'dragon']
ROW_KINDS = {'FireblightWaterblightThunderblightIceblightDragonblight': ELEMENTS,
             'PoisonBlastblight': ['poison', 'blast'], 'ParalysisSleep': ['paralysis', 'sleep'],
             'Blastblight': ['blast'], 'Poison': ['poison']}


def get(url):
    out = subprocess.run(['curl', '-sfL', '-m', '120', '-A', 'Mozilla/5.0', url], capture_output=True)
    return out.stdout if out.returncode == 0 else None


def cached(name, url):
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        data = get(url)
        assert data, url
        open(path, 'wb').write(data)
    return open(path, encoding='utf8').read()


def wiki_weapons():
    raw = cached('wilds_wiki_weapons.json', f'{WIKI}/api.php?' + urllib.parse.urlencode(
        {'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
         'titles': 'Module:MHWilds/data/Weapons.json', 'format': 'json'}))
    page = next(iter(json.loads(raw)['query']['pages'].values()))
    return json.loads(page['revisions'][0]['slots']['main']['*'])


def wiki_artian_page():
    raw = cached('wiki_artian.json', f'{WIKI}/api.php?' + urllib.parse.urlencode(
        {'action': 'parse', 'page': 'Artian Weapons (MHWilds)', 'prop': 'wikitext', 'format': 'json'}))
    t = json.loads(raw)['parse']['wikitext']['*']
    t = re.sub(r'\{\{IconPickerUniversalAlt\|[^}]*?\|([^|}]*?)(?:\|[^}]*)?\}\}', r'\1', t)
    return re.sub(r'\{\{UI\|[^|]*\|([^|}]*)[^}]*\}\}', r'\1', t)


def element_tables(text):
    """Per type: {kind: (rarity 6/7 value, rarity 8 value)} and the infusion bonus."""
    out = {}
    for key, name in WIKI_SECTION.items():
        m = re.search(r'===' + re.escape(name) + re.escape(name) + r'===(.*?)(?====[A-Z]|\Z)', text, re.S)
        if not m:
            continue
        sec = m.group(1)
        values = {}
        for row, v67, v8 in re.findall(r'\|\s*([A-Za-z]+)\s*\n\|\s*(\d+)\s*\n\|\s*(\d+)', sec):
            for kind in ROW_KINDS.get(row, []):
                values[kind] = (int(v67), int(v8))
        inf = re.search(r'\+(\d+) Element', sec)
        out[key] = (values, int(inf.group(1)) if inf else 0)
    return out


def pt_names():
    html = cached('kiranico_wilds_weapons.html', 'https://mhwilds.kiranico.com/data/weapons')
    html = html.replace('\\"', '"')
    names = {}
    for m in re.finditer(r'\{"ja":"[^"]*","en":"([^"]+)"[^}]*?"pt-BR":"([^"]+)"', html):
        names[m.group(1)] = m.group(2)
    return names


def multipliers():
    with open(os.path.join(CACHE, 'wilds_mhdb_weapons_en.json'), encoding='utf8') as f:
        weapons = json.load(f)
    out = {}
    for w in weapons:
        kind = 'sword-and-shield' if w['kind'] == 'sword-shield' else w['kind']
        if w['damage']['raw']:
            out.setdefault(kind, w['damage']['display'] / w['damage']['raw'])
    return out


def main():
    weapons = wiki_weapons()
    tables = element_tables(wiki_artian_page())
    pt = pt_names()
    mult = multipliers()
    classic = defaultdict(dict)
    for w in weapons.values():
        if w.get('RootTree') != 'Artian':
            continue
        key, rarity = ABBR[w['Type']], int(w['Rarity'])
        # The first Artian of each rarity is the classic one; the second
        # rarity-8 entry is a Gogma Artian (listed with the normal weapons).
        if rarity not in classic[key] or w['Order'] < classic[key][rarity]['Order']:
            classic[key][rarity] = w
    artian = []
    for key in WIKI_SECTION:
        bases = classic.get(key, {})
        if sorted(bases) != [6, 7, 8]:
            print(f'  ! {key}: rarities {sorted(bases)}')
            continue
        m = mult[key]
        out_weapons = []
        for rarity in (6, 7, 8):
            w = bases[rarity]
            raw = int(w['Attack'])
            slots = [lv for lv in (4, 3, 2, 1) for _ in range(int(w.get(f'Decos{lv}') or 0))]
            entry = {'rarity': rarity, 'name': {'en': w['Name'], 'ptBr': pt.get(w['Name'], w['Name'])},
                     'attack': round(raw * m), 'raw': raw, 'affinity': int(w['Affinity']), 'slots': slots,
                     'image': f'assets/images/wilds/icons/{key}-{rarity}.webp'}
            if w.get('Sharpness'):
                base, extra = json.loads(w['Sharpness'])
                entry['sharpness'] = {'base': base, 'handicraft': [b + e for b, e in zip(base, extra)]}
            out_weapons.append(entry)
        values, infusion = tables.get(key, ({}, 0))
        if key == 'bow':
            # The wiki's Bow table uses row spans the parser above does not
            # read: the five elements 180 / 210, Blast 30 / 60; Poison,
            # Paralysis and Sleep give coatings instead of an element.
            values = {**{k: (180, 210) for k in ELEMENTS}, 'blast': (30, 60)}
            infusion = 20
        elements = {}
        for rarity in (6, 7, 8):
            elements[str(rarity)] = {k: (v8 if rarity == 8 else v67) for k, (v67, v8) in values.items()}
        ranged_gun = key in ('light-bowgun', 'heavy-bowgun')
        reinforcement = [{'kind': 'attack', 'value': 5, 'display': round(5 * m), 'max': 5},
                         {'kind': 'affinity', 'value': 5, 'max': 3}]
        if key in ELEMENT_BOOST:
            reinforcement.append({'kind': 'element', 'value': ELEMENT_BOOST[key], 'max': 4})
        if key not in ('bow', 'light-bowgun', 'heavy-bowgun'):
            reinforcement.append({'kind': 'sharpness', 'value': 20 if key == 'insect-glaive' else 30, 'max': 2})
        if ranged_gun:
            reinforcement.append({'kind': 'ammo', 'value': 1, 'max': 2})
        artian.append({'type': key, 'weapons': out_weapons, 'elementsByRarity': elements,
                       'infusion': infusion,
                       'production': {'attack': 5, 'attackDisplay': round(5 * m), 'affinity': 5},
                       'reinforcement': reinforcement, 'rolls': 5,
                       'sources': [{'name': 'Monster Hunter Wiki', 'url': f'{WIKI}/wiki/Artian_Weapons_(MHWilds)'},
                                   {'name': 'Game8', 'url': 'https://game8.co/games/Monster-Hunter-Wilds/archives/503103'}]})
        print(f'{key:17} {[w["attack"] for w in out_weapons]} elements r8 '
              f'{elements["8"].get("fire", "-")} infusion {infusion} '
              f'pt {[w["name"]["ptBr"] for w in out_weapons]}')
    with open(OUT, encoding='utf8') as f:
        data = json.load(f)
    data['artian'] = artian
    with open(OUT, 'w', encoding='utf8', newline='\n') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    print('artian types', len(artian))


if __name__ == '__main__':
    sys.exit(main())
