"""Builds assets/data/wilds/weapons.json and armor.json (010 research R1–R4).

Reads the wilds.mhdb.io cache (fetch_wilds_equipment.py, en + pt-BR), the
image indexes from fetch_wilds_icons.py and the Wilds monster drops
(assets/data/wilds/monsters.json), and writes the 006/007 schemas plus the
Wilds additions in 010 data-model.md: weapon skills, set and group bonuses,
skill kind, decoration kind and colour, and talismans.

The Artian section is added by build_wilds_artian.py.
"""
import json
import os
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
CACHE = os.path.join(HERE, '.cache')
DATA = os.path.join(REPO, 'assets', 'data', 'wilds')
API = 'https://wilds.mhdb.io'

PARTS = ['head', 'chest', 'arms', 'waist', 'legs']
TYPES = {
    'great-sword': ('Great Sword', 'Espadão', False), 'long-sword': ('Long Sword', 'Espada Longa', False),
    'sword-shield': ('Sword & Shield', 'Espada e Escudo', False),
    'dual-blades': ('Dual Blades', 'Lâminas Duplas', False), 'hammer': ('Hammer', 'Martelo', False),
    'hunting-horn': ('Hunting Horn', 'Berrante de Caça', False), 'lance': ('Lance', 'Lança', False),
    'gunlance': ('Gunlance', 'Lançarma', False), 'switch-axe': ('Switch Axe', 'Machado Articulado', False),
    'charge-blade': ('Charge Blade', 'Lâmina Dínamo', False),
    'insect-glaive': ('Insect Glaive', 'Glaive Inseto', False), 'bow': ('Bow', 'Arco', True),
    'light-bowgun': ('Light Bowgun', 'Fuzil Leve', True), 'heavy-bowgun': ('Heavy Bowgun', 'Fuzil Pesado', True),
}
TYPE_ID = {'sword-shield': 'sword-and-shield'}
SPECIAL = {'blastblight': 'blast'}
METHODS = {
    'carve': ('Carve', 'Entalhe'), 'tailCarve': ('Tail Carve', 'Entalhe da cauda'),
    'breakPart': ('Break Part', 'Quebrar parte'), 'questReward': ('Quest Reward', 'Recompensa de missão'),
    'capture': ('Capture', 'Captura'), 'other': ('Other', 'Outros'),
}
PHIALS = {'impact': ('Impact', 'Impacto'), 'element': ('Element', 'Elemento'), 'power': ('Power', 'Poder'),
          'dragon': ('Dragon', 'Dragão'), 'exhaust': ('Exhaust', 'Exaustão'), 'poison': ('Poison', 'Veneno'),
          'paralysis': ('Paralysis', 'Paralisia'), 'paralyze': ('Paralysis', 'Paralisia')}
SHELLS = {'normal': ('Normal', 'Normal'), 'long': ('Long', 'Longo'), 'wide': ('Wide', 'Amplo')}
COATINGS = {'close-range': ('Close-range Coating', 'Revestimento de Curto Alcance'),
            'power': ('Power Coating', 'Revestimento de Força'), 'pierce': ('Pierce Coating', 'Revestimento Perfurante'),
            'paralysis': ('Paralysis Coating', 'Revestimento de Paralisia'),
            'poison': ('Poison Coating', 'Revestimento de Veneno'), 'sleep': ('Sleep Coating', 'Revestimento de Sono'),
            'blast': ('Blast Coating', 'Revestimento Explosivo'), 'exhaust': ('Exhaust Coating', 'Revestimento de Exaustão')}


def slug(text):
    t = text.lower().replace("'", '').replace('+', '-plus').replace('γ', '-gamma')
    t = t.replace('α', '-alpha').replace('β', '-beta')
    return re.sub(r'[^a-z0-9]+', '-', t).strip('-')


def load(endpoint, lang):
    with open(os.path.join(CACHE, f'wilds_mhdb_{endpoint.replace("/", "-")}_{lang}.json'), encoding='utf8') as f:
        return json.load(f)


def both(endpoint):
    en = load(endpoint, 'en')
    pt = {x['id']: x for x in load(endpoint, 'pt-BR')}
    return [(x, pt.get(x['id'], {})) for x in en]


def text(en, pt):
    out = {'en': en or ''}
    if pt:
        out['ptBr'] = pt
    return out


def source(path):
    return {'name': 'wilds.mhdb.io', 'url': f'{API}/en/{path}'}


class Materials:
    """Items used by the equipment, with the Wilds monsters that drop them."""

    def __init__(self):
        items_pt = {x['id']: x for x in load('items', 'pt-BR')}
        self.items = {x['id']: (x, items_pt.get(x['id'], {})) for x in load('items', 'en')}
        with open(os.path.join(DATA, 'monsters.json'), encoding='utf8') as f:
            monsters = json.load(f)
        self.drops = defaultdict(list)
        for m in monsters['monsters']:
            for d in m['drops']:
                self.drops[d['materialId']].append((m, d))
        self.used = {}

    def cost(self, entry):
        item = entry['item']
        en, pt = self.items.get(item['id'], (item, {}))
        mid = slug(en['name'])
        if mid not in self.used:
            mat = {'id': mid, 'name': text(en['name'], pt.get('name'))}
            sources = {}
            monsters = []
            best = {}
            for m, d in self.drops.get(mid, []):
                key = (m['slug'], d['rank'], d['method'])
                best[key] = max(best.get(key, 0), d.get('ratePercent') or 0)
            for (mslug, rank, method), rate in sorted(best.items(), key=lambda kv: -kv[1]):
                m = next(m for m, _ in self.drops[mid] if m['slug'] == mslug)
                men, mpt = METHODS.get(method, (method, method))
                monsters.append({'name': m['name'], 'rank': rank, 'method': text(men, mpt),
                                 'rate': round(rate), 'slug': mslug})
            if monsters:
                sources['monsters'] = monsters
            if en.get('description'):
                sources['description'] = text(en['description'], pt.get('description'))
            if sources:
                mat['sources'] = sources
            self.used[mid] = mat
        return {'material': mid, 'quantity': entry['quantity']}

    def costs(self, entries):
        merged = {}
        for e in entries or []:
            c = self.cost(e)
            merged[c['material']] = merged.get(c['material'], 0) + c['quantity']
        return [{'material': m, 'quantity': q} for m, q in merged.items()]

    def matched(self):
        return sum(1 for m in self.used.values() if m.get('sources', {}).get('monsters')), len(self.used)


def skill_ids():
    ids = {}
    for en, _ in both('skills'):
        ids[en['id']] = slug(en['name'])
    return ids


def build_skills():
    out = []
    for en, pt in both('skills'):
        pranks = {r['id']: r for r in pt.get('ranks', [])}
        levels = []
        for r in sorted(en['ranks'], key=lambda r: r['level']):
            p = pranks.get(r['id'], {})
            if en['kind'] in ('set', 'group'):
                e = f"{r.get('name') or ''}: {r.get('description') or ''}".strip(': ')
                ptx = f"{p.get('name') or ''}: {p.get('description') or ''}".strip(': ') if p else None
            else:
                e, ptx = r.get('description') or '', p.get('description')
            levels.append({'effect': text(e, ptx)})
        out.append({'id': slug(en['name']), 'name': text(en['name'], pt.get('name')),
                     'description': text(en.get('description') or '', pt.get('description')),
                     'kind': en['kind'], 'levels': levels})
    return out


def skill_refs(entries, ids):
    out = {}
    for s in entries or []:
        sid = ids[s['skill']['id']]
        out[sid] = max(out.get(sid, 0), s['level'])
    return [{'skill': k, 'level': v} for k, v in out.items()]


def sharpness(w):
    s = w.get('sharpness')
    if not s:
        return None
    base = [s[c] for c in ('red', 'orange', 'yellow', 'green', 'blue', 'white', 'purple')]
    hand = list(base)
    top = max((i for i, v in enumerate(base) if v > 0), default=0)
    for i, levels in enumerate(w.get('handicraft') or []):
        if top + i < 7:
            hand[top + i] += levels * 10
    return {'base': base, 'handicraft': hand}


def traits(en, pt, kind):
    t = {}
    ph = en.get('phial')
    if ph:
        k = ph if isinstance(ph, str) else ph['kind']
        e, p = PHIALS[k]
        dmg = (ph.get('damage') or {}).get('display') if isinstance(ph, dict) else None
        t['phial'] = text(f'{e} {dmg}' if dmg else e, f'{p} {dmg}' if dmg else p)
    if en.get('shell'):
        e, p = SHELLS[en['shell']]
        lv = en.get('shellLevel')
        t['shelling'] = text(f'{e} {lv}' if lv else e, f'{p} {lv}' if lv else p)
    if en.get('kinsectLevel') is not None:
        t['kinsectLevel'] = en['kinsectLevel']
    if en.get('melody'):
        psongs = {s['id']: s for s in (pt.get('melody') or {}).get('songs', [])}
        t['songs'] = [text(s['name'], psongs.get(s['id'], {}).get('name')) for s in en['melody']['songs']]
    if en.get('coatings'):
        t['coatings'] = [{'name': text(*COATINGS[c])} for c in en['coatings'] if c in COATINGS]
    if en.get('ammo'):
        t['ammo'] = [{'ammo': a['kind'], 'capacity': [0] * (a['level'] - 1) + [a['capacity']]}
                     for a in en['ammo']]
    return t


def build_weapons(mats, ids):
    with open(os.path.join(CACHE, 'wilds_weapon_renders.json'), encoding='utf8') as f:
        renders = json.load(f)
    pairs = both('weapons')
    names = Counter(en['name'] for en, _ in pairs)
    seen = Counter()
    slug_of = {}
    for en, _ in pairs:
        s = slug(en['name'])
        if names[en['name']] > 1:
            seen[en['name']] += 1
            s = f'{s}-{seen[en["name"]]}'
        slug_of[en['id']] = s
    children = defaultdict(list)
    for en, _ in pairs:
        prev = (en.get('crafting') or {}).get('previous')
        if prev:
            children[prev['id']].append(slug_of[en['id']])
    weapons = []
    for en, pt in pairs:
        kind = en['kind']
        c = en.get('crafting') or {}
        series = en.get('series') or {}
        pseries = pt.get('series') or {}
        special = [{'kind': SPECIAL.get(s.get('element') or s.get('status'), s.get('element') or s.get('status')),
                    'value': s['damage']['display']} for s in en.get('specials', []) if not s.get('hidden')]
        w = {
            'slug': slug_of[en['id']], 'type': TYPE_ID.get(kind, kind),
            'name': text(en['name'], pt.get('name')),
            'description': text(en.get('description') or '', pt.get('description')),
            'rarity': en['rarity'],
            'tree': slug(series.get('name') or en['name']),
            'treeName': text(series.get('name') or en['name'], pseries.get('name')),
            'attack': en['damage']['display'], 'affinity': en.get('affinity') or 0,
            'special': special, 'slots': [s for s in en.get('slots') or [] if s],
            'rampageSlot': 0,
            'previous': slug_of[c['previous']['id']] if c.get('previous') else None,
            'next': children.get(en['id'], []),
            'forge': mats.costs(c.get('craftingMaterials')),
            'upgrade': mats.costs(c.get('upgradeMaterials')),
            'stars': {'value': min(max(en['rarity'], 1), 7), 'estimated': True},
            'skills': skill_refs(en.get('skills'), ids),
            'sources': [source(f'weapons/{en["id"]}')],
        }
        sharp = sharpness(en)
        if sharp and not TYPES[kind][2]:
            w['sharpness'] = sharp
        if en['name'] in renders:
            w['image'] = renders[en['name']]
        t = traits(en, pt, kind)
        if t:
            w['traits'] = t
        weapons.append(w)
    types = [{'id': TYPE_ID.get(k, k), 'name': text(e, p), 'ranged': r} for k, (e, p, r) in TYPES.items()]
    return types, weapons


def build_armor(mats, ids):
    with open(os.path.join(CACHE, 'wilds_armor_renders.json'), encoding='utf8') as f:
        renders = json.load(f)
    sets, pieces = [], []
    piece_ids = Counter()
    for en, pt in both('armor/sets'):
        if not en['pieces']:
            print(f'  ! set without pieces skipped: {en["name"]}')
            continue
        set_id = slug(en['name'])
        ppieces = {p['id']: p for p in pt.get('pieces', [])}
        series = re.sub(r'\s+[αβγ]$', '', en['name'])
        members = []
        for p in sorted(en['pieces'], key=lambda p: PARTS.index(p['kind'])):
            pp = ppieces.get(p['id'], {})
            pid = slug(p['name'])
            piece_ids[pid] += 1
            if piece_ids[pid] > 1:
                pid = f'{pid}-{piece_ids[pid]}'
            piece = {
                'id': pid, 'set': set_id, 'part': p['kind'], 'name': text(p['name'], pp.get('name')),
                'description': text(p.get('description') or '', pp.get('description')),
                'rarity': p['rarity'], 'defense': p['defense']['base'], 'maxDefense': p['defense']['max'],
                'resistances': {k: p['resistances'][k] for k in ('fire', 'water', 'thunder', 'ice', 'dragon')},
                'slots': [s for s in p.get('slots') or [] if s],
                'skills': skill_refs(p.get('skills'), ids),
                'forge': mats.costs((p.get('crafting') or {}).get('materials')),
                'sources': [source(f'armor/sets/{en["id"]}')],
            }
            image = (renders.get(en['name'], {}).get(p['kind'])
                     or renders.get(series, {}).get(p['kind']))
            if image and os.path.exists(os.path.join(REPO, image)):
                piece['image'] = image
            pieces.append(piece)
            members.append(pid)
        s = {'id': set_id, 'name': text(en['name'], pt.get('name')),
             'rarity': max(p['rarity'] for p in en['pieces']),
             'rank': en['pieces'][0]['rank'], 'pieces': members}
        for key, out in (('bonus', 'bonus'), ('groupBonus', 'groupBonus')):
            b = en.get(key)
            if not b:
                continue
            pb = {r['id']: r for r in (pt.get(key) or {}).get('ranks', [])}
            s[out] = {'skill': ids[b['skill']['id']], 'steps': [
                {'pieces': r['pieces'],
                 'name': text(r['skill'].get('name') or '', pb.get(r['id'], {}).get('skill', {}).get('name')),
                 'description': text(r['skill'].get('description') or '',
                                     pb.get(r['id'], {}).get('skill', {}).get('description'))}
                for r in sorted(b['ranks'], key=lambda r: r['pieces'])]}
        sets.append(s)
    return sets, pieces


def build_decorations(ids):
    out = []
    for en, pt in both('decorations'):
        d = {'id': slug(en['name']), 'name': text(en['name'], pt.get('name')), 'slotLevel': en['slot'],
             'kind': en['kind'], 'skills': skill_refs(en.get('skills'), ids), 'forge': []}
        color = (en.get('icon') or {}).get('color')
        if color:
            d['icon'] = f'assets/images/wilds/decorations/{en["slot"]}-' \
                        f'{"sword" if en["kind"] == "weapon" else "armor"}-{slug(color)}.webp'
        out.append(d)
    return out


def build_talismans(mats, ids):
    out = []
    for en, pt in both('charms'):
        pranks = {r['level']: r for r in pt.get('ranks', [])}
        ranks = sorted(en['ranks'], key=lambda r: r['level'])
        base = re.sub(r'\s+[IVX]+$', '', ranks[0]['name'])
        out.append({'id': slug(base), 'ranks': [
            {'level': r['level'], 'name': text(r['name'], pranks.get(r['level'], {}).get('name')),
             'rarity': r['rarity'], 'skills': skill_refs(r.get('skills'), ids),
             'forge': mats.costs((r.get('crafting') or {}).get('materials'))}
            for r in ranks]})
    return out


def main():
    ids = skill_ids()
    mats = Materials()
    types, weapons = build_weapons(mats, ids)
    weapon_mats = dict(mats.used)
    mats.used = {}
    sets, pieces = build_armor(mats, ids)
    talismans = build_talismans(mats, ids)
    armor_mats = dict(mats.used)

    meta = {'schemaVersion': 1, 'game': 'wilds', 'generatedAt': '2026-10-05',
            'sources': [{'name': 'wilds.mhdb.io', 'url': API},
                        {'name': 'Monster Hunter Wiki (icons, renders)', 'url': 'https://monsterhunterwiki.org'},
                        {'name': 'Kiranico (Wilds armor renders)', 'url': 'https://mhwilds.kiranico.com'}]}
    skills_all = {sk['id']: sk for sk in build_skills()}
    used_skills = sorted({ref['skill'] for w in weapons for ref in w['skills']})
    weapon_skills = [{'id': i, 'name': skills_all[i]['name'], 'max': len(skills_all[i]['levels'])}
                     for i in used_skills]
    weapons_out = {**meta, 'starRule': 'rarity (estimated)', 'weaponTypes': types,
                   'skills': weapon_skills,
                   'materials': sorted(weapon_mats.values(), key=lambda m: m['id']), 'weapons': weapons}
    armor_out = {**meta, 'skills': build_skills(), 'decorations': build_decorations(ids),
                 'materials': sorted(armor_mats.values(), key=lambda m: m['id']),
                 'sets': sets, 'pieces': pieces, 'talismans': talismans}
    # Keep an existing Artian section (build_wilds_artian.py writes it).
    old = os.path.join(DATA, 'weapons.json')
    if os.path.exists(old):
        with open(old, encoding='utf8') as f:
            prev = json.load(f)
        if 'artian' in prev:
            weapons_out['artian'] = prev['artian']
    for name, data in (('weapons.json', weapons_out), ('armor.json', armor_out)):
        with open(os.path.join(DATA, name), 'w', encoding='utf8', newline='\n') as f:
            json.dump(data, f, ensure_ascii=False, separators=(',', ':'))

    def pt_missing(items, key='name'):
        return sum(1 for i in items if 'ptBr' not in i[key])
    wm, wt = 0, 0
    for m in weapon_mats.values():
        wt += 1
        wm += bool(m.get('sources', {}).get('monsters'))
    print(f'weapons {len(weapons)} (pt missing {pt_missing(weapons)}, images '
          f'{sum(1 for w in weapons if "image" in w)}), materials {wt} ({wm} with monsters)')
    am, at = 0, 0
    for m in armor_mats.values():
        at += 1
        am += bool(m.get('sources', {}).get('monsters'))
    print(f'sets {len(sets)}, pieces {len(pieces)} (pt missing {pt_missing(pieces)}, images '
          f'{sum(1 for p in pieces if "image" in p)}), skills {len(armor_out["skills"])}, '
          f'decorations {len(armor_out["decorations"])}, talismans {len(talismans)}, '
          f'materials {at} ({am} with monsters)')
    for name in ('weapons.json', 'armor.json'):
        print(name, os.path.getsize(os.path.join(DATA, name)) // 1024, 'KB')


if __name__ == '__main__':
    sys.exit(main())
