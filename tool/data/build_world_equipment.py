"""Builds assets/data/world_iceborne/weapons.json and armor.json (011 research R1–R7).

Reads the caches of fetch_world_equipment.py and fetch_world_icons.py:
- the wiki modules for weapons, armor and decoration colours;
- mhw-db.com for skills, set bonuses, decorations and charms;
- Kiranico (en and pt-BR, matched by ID or row order) for the pt-BR names.

It also reads the World monster dataset (assets/data/world_iceborne/monsters.json)
for the material names and drops. It writes the 006/007/010 schemas plus the World
additions in 011 data-model.md:
- hidden elements, Elderseal, defense bonus, `worldSpecial`;
- the traits `kinsectBonus`, `notes` and `specialAmmo`;
- skill kind `secret`.
"""
import glob
import html
import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
CACHE = os.path.join(HERE, '.cache')
DATA = os.path.join(REPO, 'assets', 'data', 'world_iceborne')
WIKI = 'https://monsterhunterwiki.org'

# wiki code → (id, en, pt-BR, display multiplier, ranged)
TYPES = {
    'GS': ('great-sword', 'Great Sword', 'Espadão', 4.8, False),
    'LS': ('long-sword', 'Long Sword', 'Espada Longa', 3.3, False),
    'SnS': ('sword-and-shield', 'Sword & Shield', 'Espada e Escudo', 1.4, False),
    'DB': ('dual-blades', 'Dual Blades', 'Duplas-Lâminas', 1.4, False),
    'Hm': ('hammer', 'Hammer', 'Martelo', 5.2, False),
    'HH': ('hunting-horn', 'Hunting Horn', 'Berrante de Caça', 4.2, False),
    'Ln': ('lance', 'Lance', 'Lança', 2.3, False),
    'GL': ('gunlance', 'Gunlance', 'Lançarma', 2.3, False),
    'SA': ('switch-axe', 'Switch Axe', 'Transmachado', 3.5, False),
    'CB': ('charge-blade', 'Charge Blade', 'Lâmina Dínamo', 3.6, False),
    'IG': ('insect-glaive', 'Insect Glaive', 'Glaive Inseto', 3.1, False),
    'Bo': ('bow', 'Bow', 'Arco', 1.2, True),
    'LBG': ('light-bowgun', 'Light Bowgun', 'Fuzilarco Leve', 1.3, True),
    'HBG': ('heavy-bowgun', 'Heavy Bowgun', 'Fuzilarco Pesado', 1.5, True),
}
ELEMENTS = {'fire': 'fire', 'water': 'water', 'thunder': 'thunder', 'ice': 'ice', 'dragon': 'dragon',
            'poison': 'poison', 'paralyze': 'paralysis', 'paralysis': 'paralysis', 'sleep': 'sleep',
            'explosion': 'blast', 'blast': 'blast'}
PHIALS = {'Impact Phial': ('Impact', 'Impacto'), 'Power Element Phial': ('Element', 'Elemento'),
          'Power': ('Power', 'Força'), 'Power Element': ('Element', 'Elemento'),
          'Poison': ('Poison', 'Veneno'), 'Exhaust': ('Exhaust', 'Exaustão'),
          'Dragon': ('Dragon', 'Dragão'), 'Paralysis': ('Paralysis', 'Paralisia')}
SHELLS = {'Normal': 'Normal', 'Wide': 'Amplo', 'Long': 'Longo'}
KINSECT = {'Sever Boost': 'Bônus de Corte', 'Blunt Boost': 'Bônus de Impacto',
           'Speed Boost': 'Bônus de Velocidade', 'Element Boost': 'Bônus Elemental',
           'Health Boost': 'Bônus de Vida', 'Stamina Boost': 'Bônus de Vigor',
           'Stamina Upgrade & Healing': 'Vigor e Cura', 'Spirit & Strength Boost': 'Espírito e Força'}
NOTES = {'White': 'Branco', 'Purple': 'Roxo', 'Red': 'Vermelho', 'Blue': 'Azul', 'Green': 'Verde',
         'Yellow': 'Amarelo', 'Light Blue': 'Azul-claro', 'Dark Blue': 'Azul-escuro', 'Orange': 'Laranja', 'Cyan': 'Ciano'}
COATINGS = {'Close Range': 'Curto Alcance', 'Power': 'Força', 'Poison': 'Veneno',
            'Paralysis': 'Paralisia', 'Sleep': 'Sono', 'Blast': 'Explosão'}
DEVIATION = {'None': 'Nenhum', 'Low': 'Baixo', 'Average': 'Médio', 'High': 'Alto',
             'Very High': 'Muito Alto'}
SPECIAL_AMMO = {'Wyvernblast': 'Explosão Wyvern', 'Wyvernheart': 'Coração Wyvern',
                'Wyvernsnipe': 'Mira Wyvern'}
AMMO = {'Normal': 'normal', 'Pierce': 'pierce', 'Spread': 'spread', 'Sticky': 'sticky',
        'Cluster': 'cluster', 'Recover': 'recover', 'Poison': 'poison', 'Paralysis': 'paralysis',
        'Sleep': 'sleep', 'Exhaust': 'exhaust', 'Flaming': 'flaming', 'Water': 'water',
        'Freeze': 'freeze', 'Thunder': 'thunder', 'Dragon': 'dragon', 'Slicing': 'slicing',
        'Wyvern': 'wyvern', 'Demon': 'demon', 'Armor': 'armor', 'Tranq': 'tranq'}
TREES = {'Ore Tree': 'Árvore Minério', 'Bone Tree': 'Árvore Osso', 'Dragonbone Tree': 'Árvore Dragosso',
         'Blacksteel Tree': 'Árvore Aço Negro', 'Defender Tree': 'Árvore Defensor',
         'Guild Palace Tree': 'Árvore Palácio da Guilda', 'Workshop Weapon Tree': 'Árvore da Oficina',
         'Ice Element Tree': 'Árvore Elemento Gelo', 'Thunder Element Tree': 'Árvore Elemento Raio',
         'Water Element Tree': 'Árvore Elemento Água'}
PARTS = {'Helmet': 'head', 'Chestplate': 'chest', 'Armguards': 'arms', 'Waist': 'waist',
         'Leggings': 'legs'}
ROMAN = {1: 'I', 2: 'II', 3: 'III', 4: 'IV', 5: 'V', 6: 'VI', 7: 'VII'}


def slug(t):
    t = t.lower().replace("'", '').replace('+', '-plus').replace('γ', '-gamma')
    t = t.replace('α', '-alpha').replace('β', '-beta').replace('"', '')
    t = unicodedata.normalize('NFKD', t).encode('ascii', 'ignore').decode()
    return re.sub(r'[^a-z0-9]+', '-', t).strip('-')


def norm(t):
    t = unicodedata.normalize('NFKD', t).encode('ascii', 'ignore').decode().lower()
    return re.sub(r'[^a-z0-9+]', '', t)


def text(en, pt=None):
    out = {'en': en or ''}
    if pt:
        out['ptBr'] = pt
    return out


def load(name):
    with open(os.path.join(CACHE, name), encoding='utf8') as f:
        return json.load(f)


def page(name):
    with open(os.path.join(CACHE, name), encoding='utf8') as f:
        return f.read()


def links(s, kind):
    return [(i, html.unescape(re.sub(r'<[^>]+>', '', n)).strip())
            for i, n in re.findall(r'href="https://mhworld\.kiranico\.com/(?:pt-BR|en)/' + kind
                                   + r'/(\w+)/[^"]*"[^>]*>(.*?)</a>', s, re.S)]


# ---------------------------------------------------------------- pt-BR names

def kiranico_weapons():
    en, pt = {}, {}
    for t in range(14):
        en.update(links(page(f'world_kiranico_weapons-{t}_en.html'), 'weapons'))
        pt.update(links(page(f'world_kiranico_weapons-{t}_pt-BR.html'), 'weapons'))
    out = {}
    for i, n in en.items():
        out.setdefault(norm(n), pt.get(i))
    return out


def kiranico_pieces():
    rx = r'justify-content-between">\s*<span>([^<]+)</span>'
    out = {}
    for f in glob.glob(os.path.join(CACHE, 'world_kiranico_series_*_en.html')):
        with open(f, encoding='utf8') as fe, open(f.replace('_en.html', '_pt-BR.html'), encoding='utf8') as fp:
            a = [html.unescape(x).strip() for x in re.findall(rx, fe.read())]
            b = [html.unescape(x).strip() for x in re.findall(rx, fp.read())]
        if len(a) == len(b):
            out.update(zip(a, b))
    return out


def kiranico_series_names():
    """Set names (α+, β…) from the series pages' <title>."""
    out = {}
    for f in glob.glob(os.path.join(CACHE, 'world_kiranico_series_*_en.html')):
        with open(f, encoding='utf8') as fe, open(f.replace('_en.html', '_pt-BR.html'), encoding='utf8') as fp:
            te = re.search(r'<title>([^<]+?) - MH:World', fe.read())
            tp = re.search(r'<title>([^<]+?) - MH:World', fp.read())
        if te and tp:
            out[html.unescape(te.group(1)).strip()] = html.unescape(tp.group(1)).strip()
    return out


def kiranico_charms():
    rx = r'<td class="w-25">([^<]+)</td>\s*<td class="w-25">(?:Rarity|Raridade) \d+</td>'
    e = [html.unescape(x).strip() for x in re.findall(rx, page('world_kiranico_armorseries_en.html'))]
    p = [html.unescape(x).strip() for x in re.findall(rx, page('world_kiranico_armorseries_pt-BR.html'))]
    return dict(zip(e, p)) if len(e) == len(p) else {}


def kiranico_skills():
    """Skill tree name → (pt name, {level: (en effect, pt effect)})."""
    def parse(s):
        out = {}
        for m in re.finditer(r'href="https://mhworld\.kiranico\.com/(?:pt-BR|en)/skilltrees/(\w+)/[^"]*">([^<]+)</a>'
                             r'(.*?)(?=href="https://mhworld\.kiranico\.com/(?:pt-BR|en)/skilltrees/|\Z)', s, re.S):
            levels = {int(lv): html.unescape(d).strip() for lv, d in
                      re.findall(r'<td class="nowrap">(?:Lv|Nv) (\d+)</td>\s*<td>(.*?)</td>', m.group(3), re.S)}
            out.setdefault(m.group(1), (html.unescape(m.group(2)).strip(), levels))
        return out
    en = parse(page('world_kiranico_skilltrees_en.html'))
    pt = parse(page('world_kiranico_skilltrees_pt-BR.html'))
    return {en[i][0]: (pt.get(i, (None, {}))[0],
                       {lv: (en[i][1].get(lv), pt.get(i, (None, {}))[1].get(lv)) for lv in en[i][1]})
            for i in en}


def kiranico_decorations():
    en = dict(links(page('world_kiranico_decorations_en.html'), 'items'))
    pt = dict(links(page('world_kiranico_decorations_pt-BR.html'), 'items'))
    return {n: pt.get(i) for i, n in en.items()}


# ------------------------------------------------------------------ materials

class Materials:
    """Items used by the equipment, with the World monsters that drop them."""

    METHODS = {'carve': ('Carve', 'Entalhe'), 'tailCarve': ('Tail Carve', 'Entalhe da cauda'),
               'breakPart': ('Break Part', 'Quebrar parte'), 'questReward': ('Quest Reward', 'Recompensa de missão'),
               'capture': ('Capture', 'Captura'), 'palico': ('Palico', 'Amigato'), 'other': ('Other', 'Outros')}

    def __init__(self):
        with open(os.path.join(DATA, 'monsters.json'), encoding='utf8') as f:
            monsters = json.load(f)
        self.names = {m['id']: m['name'] for m in monsters['materials']}
        self.drops = defaultdict(list)
        for m in monsters['monsters']:
            for d in m['drops']:
                self.drops[d['materialId']].append((m, d))
        self.used = {}

    def cost(self, name, quantity):
        mid = slug(name)
        if mid not in self.used:
            mat = {'id': mid, 'name': self.names.get(mid) or text(name)}
            best = {}
            for m, d in self.drops.get(mid, []):
                key = (m['slug'], d['rank'], d['method'])
                best[key] = max(best.get(key, 0), d.get('ratePercent') or 0)
            monsters = []
            for (mslug, rank, method), rate in sorted(best.items(), key=lambda kv: -kv[1]):
                m = next(m for m, _ in self.drops[mid] if m['slug'] == mslug)
                men, mpt = self.METHODS.get(method, (method, method))
                monsters.append({'name': m['name'], 'rank': rank, 'method': text(men, mpt),
                                 'rate': round(rate), 'slug': mslug})
            if monsters:
                mat['sources'] = {'monsters': monsters}
            self.used[mid] = mat
        return mid, int(quantity)

    def costs(self, entries):
        merged = {}
        for name, qty in entries:
            if not name or int(qty) <= 0:
                continue
            mid, q = self.cost(name, qty)
            merged[mid] = merged.get(mid, 0) + q
        return [{'material': m, 'quantity': q} for m, q in merged.items()]


def wiki_materials(raw):
    if not raw:
        return []
    return [(m['name'], m['quantity']) for m in json.loads(raw)]


# -------------------------------------------------------------------- weapons

def special_of(element, dmg):
    hidden = element.startswith('(')
    kind = ELEMENTS[element.strip('()').lower()]
    return {'kind': kind, 'value': int(dmg.strip('()')) * 10, **({'hidden': True} if hidden else {})}


def ammo_table(raw):
    out = {}
    for name, cap in re.findall(r'Ammo\|([^|]+)\|[^}]*}}</td>\s*<td>(\d+)</td>', raw or ''):
        m = re.match(r'(.+?)(?: (?:Ammo|Bomb))?(?: (\d))?$', name)
        base, level = m.group(1), int(m.group(2) or 1)
        kind = AMMO.get(base)
        if not kind:
            continue
        caps = out.setdefault(kind, [])
        while len(caps) < level:
            caps.append(0)
        caps[level - 1] = int(cap)
    return [{'ammo': k, 'capacity': v} for k, v in out.items()]


def traits(w, type_id, ammo):
    t = {}
    phial = w.get('CbPhialType') or w.get('SaPhialType')
    if phial and phial in PHIALS:
        t['phial'] = text(*PHIALS[phial])
    if w.get('GlShellingType'):
        lv = w.get('GlShellingLevel')
        e = w['GlShellingType']
        t['shelling'] = text(f'{e} Lv {lv}' if lv else e, f'{SHELLS[e]} Nv {lv}' if lv else SHELLS[e])
    if w.get('IgKinsectBonus'):
        k = w['IgKinsectBonus'].strip()
        t['kinsectBonus'] = text(k, KINSECT.get(k))
    notes = [w.get(f'HhNote{i}') for i in (1, 2, 3) if w.get(f'HhNote{i}')]
    if notes:
        t['notes'] = [text(n, NOTES.get(n)) for n in notes]
    if w.get('BoCoatings'):
        shots = []
        for c in w['BoCoatings'].split(','):
            c = c.strip()
            plus = c.endswith('+')
            base = c.rstrip('+')
            shots.append({'name': text(c, COATINGS.get(base, base) + ('+' if plus else ''))})
        t['coatings'] = shots
    dev = w.get('LbgDeviation') or w.get('HbgDeviation')
    if dev:
        t['deviation'] = text(dev, DEVIATION.get(dev))
    special = w.get('LbgSpecialAmmoType') or w.get('HbgSpecialAmmoType')
    if special:
        t['specialAmmo'] = text(special, SPECIAL_AMMO.get(special))
    if ammo:
        t['ammo'] = ammo
    return t


def world_special(name):
    if 'Kjárr' in name or 'Kjarr' in name:
        return 'kjarr'
    if name.startswith("Safi's"):
        return 'safi'
    return 'kulve'


def build_weapons(mats, pt_names, monster_pt):
    wiki = load('world_wiki_weapons.json')
    ammo = load('world_wiki_ammo.json') if os.path.exists(os.path.join(CACHE, 'world_wiki_ammo.json')) else {}
    renders = load('world_weapon_renders.json')
    slugs = {}
    for name in wiki:
        s = slug(name)
        while s in slugs.values():
            s += '-2'
        slugs[name] = s
    weapons = []
    for name, w in wiki.items():
        type_id, _, _, mult, ranged = TYPES[w['Type']]
        special = w['Tree'] == 'Unavailable'
        tree = w['Tree']
        mon = monster_pt.get(tree[:-5]) if tree.endswith(' Tree') else None
        tree_pt = TREES.get(tree) or (f'Árvore {mon}' if mon else None)
        rarity = int(w['Rarity'])
        slots = []
        for level in (4, 3, 2, 1):
            slots += [level] * int(w.get(f'Decos{level}') or 0)
        out = {
            'slug': slugs[name], 'type': type_id,
            'name': text(name, pt_names.get(norm(name))),
            'description': text(w.get('Description') or ''),
            'rarity': rarity,
            'tree': slugs[name] if special else slug(tree),
            'treeName': text(name, pt_names.get(norm(name))) if special else text(tree, tree_pt),
            'attack': round(int(w['Attack']) * mult),
            'affinity': int(w.get('Affinity') or 0),
            'special': [special_of(w[f'Element{i}'], w[f'ElementDmg{i}'])
                        for i in (1, 2) if w.get(f'Element{i}') and w.get(f'ElementDmg{i}')
                        and w[f'Element{i}'].strip('()').lower() in ELEMENTS],
            'slots': slots[:3],
            'rampageSlot': 0,
            'previous': None if special or w.get('PreviousName') not in wiki else slugs[w['PreviousName']],
            'next': [] if special else [slugs[w[f'Next{i}Name']] for i in (1, 2, 3)
                                        if w.get(f'Next{i}Name') in wiki],
            'forge': mats.costs(wiki_materials(w.get('ForgeMaterials'))),
            'upgrade': mats.costs(wiki_materials(w.get('UpgradeMaterials'))),
            'stars': {'value': min(max(rarity, 1), 7), 'estimated': True},
            'sources': [{'name': 'Monster Hunter Wiki', 'url': f'{WIKI}/wiki/{name.replace(" ", "_")}_(MHWI)'}],
        }
        if special:
            out['worldSpecial'] = world_special(name)
        es = (w.get('Elderseal') or 'None').lower()
        if es in ('low', 'average', 'high'):
            out['elderseal'] = es
        defense = int(w.get('Defense') or 0)
        if defense > 0:
            out['defenseBonus'] = defense
        if not ranged and w.get('Sharpness'):
            base, extra = json.loads(w['Sharpness'])
            out['sharpness'] = {'base': base, 'handicraft': [a + b for a, b in zip(base, extra)]}
        if name in renders:
            out['image'] = renders[name]
        t = traits(w, type_id, ammo_table((ammo.get(name) or {}).get('ShellTable')))
        if t:
            out['traits'] = t
        weapons.append(out)
    # previous/next must agree both ways (the DTO checks it).
    by = {w['slug']: w for w in weapons}
    for w in weapons:
        w['next'] = [n for n in w['next'] if by[n]['previous'] == w['slug']]
    for w in weapons:
        p = w['previous']
        if p and w['slug'] not in by[p]['next']:
            by[p]['next'].append(w['slug'])
    types = [{'id': i, 'name': text(e, p), 'ranged': r} for i, e, p, _, r in TYPES.values()]
    return types, weapons


# ---------------------------------------------------------------------- armor

def build_skills(kskills, sets_db):
    """Regular skills from mhw-db, and one `set`/`secret` skill per set bonus."""
    db = load('world_mhwdb_skills.json')
    step_only = {r['skill']['skillName'] for s in sets_db if s.get('bonus') for r in s['bonus']['ranks']}
    used = set()
    for p in load('world_mhwdb_decorations.json'):
        used |= {k['skillName'] for k in p['skills']}
    for c in load('world_mhwdb_charms.json'):
        for r in c['ranks']:
            used |= {k['skillName'] for k in r['skills']}
    for s in load('world_wiki_armor.json').values():
        for p in s['Pieces']:
            used |= {k['Name'] for k in p.get('Skills') or []}
    skills = {}
    for s in db:
        if s['name'] in step_only and s['name'] not in used:
            continue
        pt_name, levels = kskills.get(s['name'], (None, {}))
        skills[slug(s['name'])] = {
            'id': slug(s['name']), 'name': text(s['name'], pt_name),
            'description': text(''), 'kind': 'armor',
            'levels': [{'effect': text(r['description'], (levels.get(r['level']) or (None, None))[1])}
                       for r in sorted(s['ranks'], key=lambda r: r['level'])]}
    bonuses = {}
    for s in sets_db:
        b = s.get('bonus')
        if not b or b['name'] in bonuses:
            continue
        pt_name, levels = kskills.get(b['name'], (None, {}))
        steps = []
        for r in sorted(b['ranks'], key=lambda r: r['pieces']):
            pt_desc = (levels.get(r['pieces']) or (None, None))[1]
            steps.append({'pieces': r['pieces'], 'name': text(''),
                          'description': text(r['description'] or r['skill']['skillName'], pt_desc)})
        secret = any(r['skill']['skillName'].endswith('Secret') for r in b['ranks'])
        sid = slug(b['name'])
        bonuses[b['name']] = {'skill': sid, 'steps': steps}
        skills[sid] = {'id': sid, 'name': text(b['name'], pt_name), 'description': text(''),
                       'kind': 'secret' if secret else 'set',
                       'levels': [{'effect': st['description']} for st in steps]}
    return skills, bonuses


def ensure_skill(skills, name, level):
    sid = slug(name)
    if sid not in skills:
        skills[sid] = {'id': sid, 'name': text(name), 'description': text(''), 'kind': 'armor',
                       'levels': [{'effect': text('')} for _ in range(level)]}
    while len(skills[sid]['levels']) < level:
        skills[sid]['levels'].append({'effect': text('')})
    return sid


def refs(skills, entries):
    out = {}
    for name, level in entries:
        sid = ensure_skill(skills, name, int(level))
        out[sid] = max(out.get(sid, 0), int(level))
    return [{'skill': k, 'level': v} for k, v in out.items()]


def build_armor(mats, skills, bonuses, pt_pieces, pt_sets):
    wiki = load('world_wiki_armor.json')
    renders = load('world_set_renders.json')
    sets, pieces = [], []
    piece_ids, set_ids = Counter(), Counter()
    for s in wiki.values():
        name = s['SetName']
        sid = slug(name)
        set_ids[sid] += 1
        if set_ids[sid] > 1:
            sid = f'{sid}-{set_ids[sid]}'
        bonus_name = (s.get('SetSkill1') or {}).get('Name')
        members = []
        for p in s['Pieces']:
            part = PARTS.get(p.get('IconType'))
            if not part:
                continue
            pid = slug(p['Name'])
            piece_ids[pid] += 1
            if piece_ids[pid] > 1:
                pid = f'{pid}-{piece_ids[pid]}'
            rarity = int(p['Rarity'])
            slots = []
            for level in (4, 3, 2, 1):
                slots += [level] * int(p.get(f'Decos{level}') or 0)
            entries = [(k['Name'], k['Level']) for k in p.get('Skills') or []]
            if bonus_name in bonuses:
                entries.append((bonus_name, 1))
            piece = {
                'id': pid, 'set': sid, 'part': part,
                'name': text(p['Name'], pt_pieces.get(p['Name'])),
                'description': text(p.get('Description') or ''),
                'rarity': rarity, 'rank': 'low' if rarity <= 4 else 'high' if rarity <= 8 else 'master',
                'defense': int(p['Defense']), 'maxDefense': int(p.get('MaxDefense') or p['Defense']),
                'resistances': {'fire': int(p['FireRes']), 'water': int(p['WaterRes']),
                                'thunder': int(p['ThunderRes']), 'ice': int(p['IceRes']),
                                'dragon': int(p['DragonRes'])},
                'slots': slots[:3],
                'skills': refs(skills, entries),
                'forge': mats.costs([(m['Name'], m['Quantity']) for m in p.get('Materials') or []]),
                'sources': [{'name': 'Monster Hunter Wiki', 'url': f'{WIKI}/wiki/{name.replace(" ", "_")}_(MHWI)'}],
            }
            pieces.append(piece)
            members.append(pid)
        if not members:
            continue
        rarity = max(int(p['Rarity']) for p in s['Pieces'])
        out = {'id': sid, 'name': text(name, pt_sets.get(name)), 'rarity': rarity,
               'rank': 'low' if rarity <= 4 else 'high' if rarity <= 8 else 'master', 'pieces': members}
        if bonus_name in bonuses:
            out['bonus'] = bonuses[bonus_name]
        if name in renders:
            out['image'] = renders[name]
        sets.append(out)
    return sets, pieces


def build_decorations(skills, pt_names):
    colors = {norm(re.sub(r'\[(\d)\]', r'\1', d['Name'])): d['IconColor'] for d in load('world_wiki_decorations.json').values()}
    by_skill = {}
    out = []
    db = load('world_mhwdb_decorations.json')
    for d in db:
        c = colors.get(norm(d['name']))
        if c and len(d['skills']) == 1:
            by_skill.setdefault(d['skills'][0]['skillName'], c)
    for d in db:
        color = colors.get(norm(d['name'])) or by_skill.get(d['skills'][0]['skillName']) or 'White'
        icon = f'assets/images/world/decorations/{d["slot"]}-{slug(color)}.webp'
        deco = {'id': slug(d['name']), 'name': text(d['name'], pt_names.get(d['name'])),
                'slotLevel': d['slot'], 'skills': refs(skills, [(k['skillName'], k['level']) for k in d['skills']]),
                'forge': []}
        if os.path.exists(os.path.join(REPO, icon)):
            deco['icon'] = icon
        out.append(deco)
    return out


def build_talismans(mats, skills, pt_charms):
    out = []
    for c in load('world_mhwdb_charms.json'):
        ranks = sorted(c['ranks'], key=lambda r: r['level'])
        base = re.sub(r'\s+\d+$', '', ranks[0]['name'])
        rows = []
        for r in ranks:
            en = f'{base} {ROMAN[r["level"]]}' if len(ranks) > 1 else base
            pt = pt_charms.get(en) or pt_charms.get(f'{base} I' if len(ranks) == 1 else en)
            mats_in = [(m['item']['name'], m['quantity']) for m in (r.get('crafting') or {}).get('materials') or []]
            rows.append({'level': r['level'], 'name': text(en, pt), 'rarity': r['rarity'],
                         'skills': refs(skills, [(k['skillName'], k['level']) for k in r['skills']]),
                         'forge': mats.costs(mats_in)})
        out.append({'id': slug(base), 'ranks': rows})
    return out


def main():
    with open(os.path.join(DATA, 'monsters.json'), encoding='utf8') as f:
        monster_pt = {m['name']['en']: m['name'].get('ptBr') for m in json.load(f)['monsters']}
    mats = Materials()
    types, weapons = build_weapons(mats, kiranico_weapons(), monster_pt)
    weapon_mats = dict(mats.used)
    mats.used = {}
    sets_db = load('world_mhwdb_armor-sets.json')
    skills, bonuses = build_skills(kiranico_skills(), sets_db)
    sets, pieces = build_armor(mats, skills, bonuses, kiranico_pieces(), kiranico_series_names())
    decorations = build_decorations(skills, kiranico_decorations())
    talismans = build_talismans(mats, skills, kiranico_charms())
    armor_mats = dict(mats.used)

    meta = {'schemaVersion': 1, 'game': 'world_iceborne', 'generatedAt': '2026-10-05',
            'sources': [{'name': 'Monster Hunter Wiki (Module:MHWI/data)', 'url': WIKI},
                        {'name': 'mhw-db.com', 'url': 'https://mhw-db.com'},
                        {'name': 'Kiranico (pt-BR names)', 'url': 'https://mhworld.kiranico.com'}]}
    weapons_out = {**meta, 'starRule': 'rarity (estimated)', 'weaponTypes': types,
                   'materials': sorted(weapon_mats.values(), key=lambda m: m['id']), 'weapons': weapons}
    armor_out = {**meta, 'skills': sorted(skills.values(), key=lambda s: s['id']),
                 'decorations': decorations,
                 'materials': sorted(armor_mats.values(), key=lambda m: m['id']),
                 'sets': sets, 'pieces': pieces, 'talismans': talismans}
    for name, data in (('weapons.json', weapons_out), ('armor.json', armor_out)):
        with open(os.path.join(DATA, name), 'w', encoding='utf8', newline='\n') as f:
            json.dump(data, f, ensure_ascii=False, separators=(',', ':'))

    def missing(items, key='name'):
        return sum(1 for i in items if 'ptBr' not in i[key])
    wm = sum(1 for m in weapon_mats.values() if m.get('sources'))
    am = sum(1 for m in armor_mats.values() if m.get('sources'))
    print(f'weapons {len(weapons)} (pt missing {missing(weapons)}, renders '
          f'{sum(1 for w in weapons if "image" in w)}, specials '
          f'{sum(1 for w in weapons if "worldSpecial" in w)}), materials {len(weapon_mats)} ({wm} with monsters)')
    ranks = [r for t in talismans for r in t['ranks']]
    print(f'sets {len(sets)} (pt missing {missing(sets)}, bonus {sum(1 for s in sets if "bonus" in s)}), '
          f'pieces {len(pieces)} (pt missing {missing(pieces)}), skills {len(skills)} '
          f'(pt missing {missing(skills.values())}), decorations {len(decorations)} '
          f'(pt missing {missing(decorations)}, icons {sum(1 for d in decorations if "icon" in d)}), '
          f'talismans {len(talismans)} (rank pt missing {missing(ranks)}), materials {len(armor_mats)} ({am} with monsters)')
    for name in ('weapons.json', 'armor.json'):
        print(name, os.path.getsize(os.path.join(DATA, name)) // 1024, 'KB')


if __name__ == '__main__':
    sys.exit(main())
