"""Builds assets/data/rise_sunbreak/weapons.json (feature 006, research R1-R6).

    python tool/data/build_rise_weapons.py           # data only
    python tool/data/build_rise_weapons.py --icons   # also weapon and type icons

Sources:
- Monster Hunter Wiki MHRS weapon pages ({{GenericWeapon}}): type, tree, rarity,
  description, attack, affinity, element/status, slots, Rampage slot, sharpness
  (+ Handicraft), previous/next weapons, forge/upgrade materials.
- Kiranico weapon lists (en + pt-BR): Kiranico id, pt-BR name, icon, attack
  (cross-check: every joined weapon must have the same attack).
- assets/data/rise_sunbreak/monsters.json + cached Kiranico monster pages:
  which monsters drop each material and their lowest quest star per rank
  (estimated stars, research R3).
"""
import datetime
import glob
import html
import io
import json
import os
import re
import sys
import time
import unicodedata
import urllib.request

from common import REPO, UA, clean, dataset_path, fetch, wiki_api  # noqa: F401 (sets cwd to the cache)

KIRANICO = 'https://mhrise.kiranico.com'
WIKI = 'https://monsterhunterwiki.org/wiki/'
OUT = os.path.join(REPO, 'assets', 'data', 'rise_sunbreak', 'weapons.json')
ICON_DIR = os.path.join(REPO, 'assets', 'images', 'weapons', 'rise_sunbreak')
TYPE_ICON_DIR = os.path.join(REPO, 'assets', 'images', 'weapons', 'types')
SLOT_ICON_DIR = os.path.join(REPO, 'assets', 'images', 'weapons', 'slots')
ICON_SIZE = 96

# id, Kiranico list view, wiki category, wiki icon file stem, ranged
TYPES = [
    ('great-sword', 0, 'Great Sword', 'Great Sword', False),
    ('sword-and-shield', 1, 'Sword and Shield', 'Sword and Shield', False),
    ('dual-blades', 2, 'Dual Blades', 'Dual Blades', False),
    ('long-sword', 3, 'Long Sword', 'Long Sword', False),
    ('hammer', 4, 'Hammer', 'Hammer', False),
    ('hunting-horn', 5, 'Hunting Horn', 'Hunting Horn', False),
    ('lance', 6, 'Lance', 'Lance', False),
    ('gunlance', 7, 'Gunlance', 'Gunlance', False),
    ('switch-axe', 8, 'Switch Axe', 'Switch Axe', False),
    ('charge-blade', 9, 'Charge Blade', 'Charge Blade', False),
    ('insect-glaive', 10, 'Insect Glaive', 'Insect Glaive', False),
    ('bow', 11, 'Bow', 'Bow', True),
    ('heavy-bowgun', 12, 'Heavy Bowgun', 'Heavy Bowgun', True),
    ('light-bowgun', 13, 'Light Bowgun', 'Light Bowgun', True),
]
FIRST_STAR = {'low': 1, 'high': 4, 'master': 1}  # first quest star of each rank
SPECIALS = {'Fire': 'fire', 'Water': 'water', 'Thunder': 'thunder', 'Ice': 'ice', 'Dragon': 'dragon',
            'Poison': 'poison', 'Sleep': 'sleep', 'Paralysis': 'paralysis', 'Blast': 'blast'}
STAR_RULE = ('Stars are estimated: each forge/upgrade material that the Rise monster dataset knows as a '
             'drop of the weapon\'s rank (or a "<monster> material(s) x pts." requirement) points to its '
             'monsters; each monster\'s lowest quest star of that rank comes from its Kiranico page '
             '(Village and Gathering Hub 1-3 = Low, Hub 4-7 = High, MR = Master); the weapon takes the '
             'highest of those, or the first star of the rank (Low 1, High 4, Master 1) when no monster is involved. Rank comes from rarity (1-3 Low, '
             '4-7 High, 8-10 Master).')


def slug(text):
    text = text.lower().replace("'", '').replace('+', '-plus')
    return re.sub(r'[^a-z0-9]+', '-', text).strip('-')


def key(name):
    """Join key for names across sources (case, accents and punctuation removed)."""
    text = unicodedata.normalize('NFKD', html.unescape(name)).encode('ascii', 'ignore').decode()
    return re.sub(r'[^a-z0-9+]', '', text.lower())


def rank_of(rarity):
    return 'low' if rarity <= 3 else 'high' if rarity <= 7 else 'master'


# ---------------------------------------------------------------- Kiranico lists

def kiranico_list(view, lang):
    prefix = '/pt-BR' if lang == 'pt' else ''
    page = fetch(f'{KIRANICO}{prefix}/data/weapons?view={view}',
                 f'rise_weapons_v{view}.html' if lang == 'en' else f'rise_weapons_pt_v{view}.html')
    rows = {}
    for tr in re.findall(r'<tr.*?</tr>', page, re.S):
        m = re.search(r'/data/weapons/(\d+)"[^>]*>(.*?)</a>', tr, re.S)
        attack = re.search(r'data-key="attack">(\d+)<', tr)
        if not m or not attack:
            continue
        icon = re.search(r'src="(https?://[^"]*avatar/weapons/\d+\.webp)"', tr)
        rows[m.group(1)] = {'name': clean(m.group(2)), 'attack': int(attack.group(1)),
                            'icon': icon.group(1) if icon else None}
    title = re.search(r'<title>(.*?) \|', page)
    return rows, clean(title.group(1)) if title else None


# ---------------------------------------------------------------- wiki pages

def wiki_pages(type_id, category):
    titles, cont, n = [], {}, 0
    while True:
        d = wiki_api({'action': 'query', 'list': 'categorymembers', 'cmlimit': 500,
                      'cmtitle': f'Category:MHRS {category}', **cont}, f'wiki_mhrs_weapons_{type_id}_{n}.json')
        titles += [m['title'] for m in d['query']['categorymembers'] if m['title'].endswith('(MHRS)')]
        if 'continue' not in d:
            break
        cont, n = d['continue'], n + 1
    titles = sorted(titles)
    pages = {}
    for i in range(0, len(titles), 40):
        d = wiki_api({'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
                      'titles': '|'.join(titles[i:i + 40])}, f'wiki_mhrs_weapon_text_{type_id}_{i // 40}.json')
        for p in d['query']['pages'].values():
            pages[p['title']] = p['revisions'][0]['slots']['main']['*']
    return pages


def fields_of(text):
    out = {}
    for name, value in re.findall(r'^\|\s*([A-Za-z][A-Za-z0-9 ]*?)\s*=(.*)$', text, re.M):
        out[name] = value.strip()
    return out


def materials(f, prefix):
    """[(name, quantity or None, points or None)] for 'Forge Material', 'Upgrade Material'
    or 'Next 1 Material' fields."""
    out = []
    for i in range(1, 9):
        name = f.get(f'{prefix} Item Name {i}')
        if not name:
            continue
        qty = f.get(f'{prefix} Quantity {i}')
        pts = f.get(f'{prefix} Points {i}')
        out.append((name, int(qty) if qty else None, int(pts) if pts else None))
    return out


def sharpness(f):
    m = re.search(r'\{\{SharpnessBar\|([^}]*)\}\}', f.get('Sharpness', ''))
    if not m:
        return None
    parts = m.group(1).split('|')
    base = [int(x) for x in parts[:7]]
    extra = dict(p.split('=', 1) for p in parts[7:] if '=' in p)
    plus = [int(extra.get(k, 0) or 0) for k in ('HR', 'HO', 'HY', 'HG', 'HB', 'HW', 'HP')]
    return {'base': base, 'handicraft': [b + p for b, p in zip(base, plus)]}


def kiranico_detail(kid):
    """Materials and both sharpness bars from the cached Kiranico weapon page, or None.

    The game data there is complete where the wiki sometimes is not (a missing material, no
    Handicraft values); fetch_rise_weapon_pages.py caches the pages (006 research R12).
    """
    path = f'kiranico_weapon_{kid}.html'
    if not os.path.exists(path):
        return None
    t = open(path, encoding='utf8').read()

    def items(start, end):
        i = t.find(start)
        j = t.find(end, i) if end else len(t)
        if i < 0:
            return []
        return [(clean(n), int(q)) for n, q in re.findall(
            r'/data/items/\d+">(.*?)</a></td>\s*<td[^>]*>x(\d+)</td>', t[i:j], re.S)]

    row = t[t.find('avatar/weapons/'):]
    row = row[:row.find('</tr>')]
    bars = [[int(w) * 5 for w in re.findall(r'<rect height="8" width="(\d+)"', b)]
            for b in re.findall(r'<svg width="96" height="8">(.*?)</svg>', row, re.S)]
    sharp = None
    if len(bars) >= 2:
        base, hc = [(b + [0] * 7)[:7] for b in bars[:2]]
        sharp = {'base': base, 'handicraft': hc}
    return {'forge': items('Forging Materials', 'Upgrade Materials'),
            'upgrade': items('Upgrade Materials', '</article>'),
            'sharpness': sharp}


# ---------------------------------------------------------------- type-specific traits

# Kiranico's bowgun ammo abbreviations (the same on the pt-BR pages) → ammo ids.
AMMO = {
    'Nrm': 'normal', 'Prc': 'pierce', 'Spr': 'spread', 'Shr': 'shrapnel', 'Sti': 'sticky',
    'Clu': 'cluster', 'Fir/P.': 'flaming', 'Wat/P.': 'water', 'Thn/P.': 'thunder',
    'Ice/P.': 'freeze', 'Dra/P.': 'dragon', 'Poi': 'poison', 'Par': 'paralysis', 'Sle': 'sleep',
    'Exh': 'exhaust', 'Rec': 'recover', 'Dem': 'demon', 'Amr': 'armor', 'Sli': 'slicing',
    'Wyv': 'wyvern', 'Tra': 'tranq',
}


def _text(fragment):
    return clean(re.sub(r'<[^>]+>', ' ', fragment))


def list_traits(view, lang):
    """{kiranico id: raw traits} from the type-specific cells of a cached weapon list.

    The rows nest tables (bowgun ammo), so each weapon is the page slice between two weapon
    icons rather than a regex over <tr> (006 research R13).
    """
    page = open(f'rise_weapons_v{view}.html' if lang == 'en' else f'rise_weapons_pt_v{view}.html',
                encoding='utf8').read()
    out = {}
    for part in page.split('avatar/weapons/')[1:]:
        kid = re.search(r'/data/weapons/(\d+)"', part)
        if not kid:
            continue
        rare = part.find('Rare ')
        body = part[:rare if rare > 0 else len(part)]
        after_sharp = body[body.rfind('</svg>') + 6:] if '</svg>' in body else ''
        raw = {}
        if view in (5,):  # hunting horn: three songs
            raw['songs'] = [_text(d) for d in re.findall(r'<div>([^<]+)</div>', after_sharp)]
        elif view in (7, 8, 9, 10):  # gunlance, switch axe, charge blade, insect glaive
            value = _text(after_sharp)
            if value:
                raw['value'] = value
        elif view == 11:  # bow
            arc = re.search(r'<div class="text-green-500">([^<]+)</div>', body)
            charge_cell = body[arc.end():body.find('columns-3')] if arc else ''
            raw['arcShot'] = _text(arc.group(1)) if arc else None
            raw['chargeShots'] = [
                {'name': _text(n), 'locked': 'gray' in (c or '')}
                for c, n in re.findall(r'<div(?: class="([^"]*)")?>([^<]+)</div>', charge_cell)]
            coat_cell = body[body.find('columns-3'):]
            raw['coatings'] = [
                {'name': _text(n), 'locked': 'gray' in (c or '')}
                for c, n in re.findall(r'<div class="([^"]*)">([^<]+)</div>', coat_cell)]
        elif view in (12, 13):  # bowguns
            stats = re.findall(r'<div>\s*([^<]+?)\s*</div>', body[body.find('<table>'):])[:3]
            raw['deviation'], raw['recoil'], raw['reload'] = [_text(x) for x in stats]
            ammo = []
            for name, cols in re.findall(r'<tr>\s*<td>([^<]+)</td>(.*?)</tr>', body, re.S):
                levels = [int(n) for n in re.findall(r'<td[^>]*>(\d+)</td>', cols)]
                if name.strip() in AMMO and any(levels):
                    ammo.append({'ammo': AMMO[name.strip()], 'capacity': levels})
            raw['ammo'] = ammo
        out[kid.group(1)] = raw
    return out


def traits_of(view, en, pt):
    """Joins the en and pt-BR raw traits of one weapon into the dataset's `traits`."""
    if not en:
        return None
    def loc(a, b):
        return {'en': a, **({'ptBr': b} if b else {})}
    pt = pt or {}
    if 'songs' in en:
        songs = en['songs']
        pts = pt.get('songs') or [None] * len(songs)
        return {'songs': [loc(a, b) for a, b in zip(songs, pts)]}
    if 'value' in en:
        field = {7: 'shelling', 8: 'phial', 9: 'phial'}.get(view)
        if view == 10:
            return {'kinsectLevel': int(re.search(r'(\d+)', en['value']).group(1))}
        if field == 'phial':
            # The grid labels it "Frasco": keep "Impacto", "Veneno 23"...
            short_en = re.sub(r' Phial', '', en['value'])
            short_pt = re.sub(r'^Frasco d[eo] ', '', pt['value']) if pt.get('value') else None
            return {field: loc(short_en, short_pt)}
        return {field: loc(en['value'], pt.get('value'))}
    if 'chargeShots' in en:
        def pair(key):
            a, b = en[key], pt.get(key) or [None] * len(en[key])
            return [{'name': loc(x['name'], y['name'] if y else None),
                     **({'locked': True} if x['locked'] else {})} for x, y in zip(a, b)]
        out = {'chargeShots': pair('chargeShots'), 'coatings': pair('coatings')}
        if en.get('arcShot'):
            out['arcShot'] = loc(en['arcShot'], pt.get('arcShot'))
        return out
    if 'ammo' in en:
        return {k: loc(en[k], pt.get(k)) for k in ('deviation', 'recoil', 'reload')} | {'ammo': en['ammo']}
    return None


# ---------------------------------------------------------------- material sources

RANKS = {'Low Rank': 'low', 'High Rank': 'high', 'Master Rank': 'master'}


def _item_rows(page, heading):
    """The table rows (list of cell texts) under one heading of a Kiranico item page."""
    page = re.sub(r'<script.*?</script>', '', page, flags=re.S)
    for part in re.split(r'<h[23][^>]*>', page)[1:]:
        if clean(re.sub(r'<[^>]+>', '', part[:part.find('</h')])) == heading:
            return [[clean(re.sub(r'<[^>]+>', ' ', c)) for c in re.findall(r'<td.*?</td>', row, re.S)]
                    for row in re.findall(r'<tr.*?</tr>', part, re.S)]
    return []


def _rate(text):
    m = re.match(r'(\d+)%', text or '')
    return int(m.group(1)) if m else None


def material_sources(item_id, large):
    """`sources` of one material from its cached Kiranico item pages (en + pt-BR), or None.

    Gathering keeps the best rate per map and rank; monsters the best row per monster and rank,
    with `slug` when it is a large monster of the app (else `small`); quests keep their category,
    stars and best rate. Rows pair by position between the en and pt-BR pages, which list them in
    the same order (006 research R13).
    """
    pages = {}
    for lang in ('en', 'pt'):
        path = f'kiranico_item_{item_id}_{lang}.html'
        if not os.path.exists(path):
            return None
        pages[lang] = open(path, encoding='utf8').read()
    heads = {'en': ('Locale', 'Monsters', 'Quests'), 'pt': ('Loc.', 'Monstros', 'Missões')}
    rows = {lang: [_item_rows(pages[lang], h) for h in heads[lang]] for lang in pages}

    def pt_cell(section, i, col):
        pt = rows['pt'][section]
        return pt[i][col] if i < len(pt) and col < len(pt[i]) else None

    def loc(en, pt):
        return {'en': en, **({'ptBr': pt} if pt else {})}

    gathering = {}
    for i, r in enumerate(rows['en'][0]):
        if len(r) < 4 or r[1] not in RANKS:
            continue
        k = (r[0], RANKS[r[1]])
        rate = _rate(r[3])
        if k not in gathering or (rate or 0) > (gathering[k]['rate'] or 0):
            gathering[k] = {'map': loc(r[0], pt_cell(0, i, 0)), 'rank': k[1], 'rate': rate}

    monsters = {}
    for i, r in enumerate(rows['en'][1]):
        if len(r) < 5 or r[1] not in RANKS:
            continue
        k = (r[0], RANKS[r[1]])
        rate = _rate(r[4])
        method_en = re.sub(r'\s*BodyPart \d+', '', r[2])
        method_pt = re.sub(r'\s*BodyPart \d+', '', pt_cell(1, i, 2) or '') or None
        if k not in monsters or (rate or 0) > (monsters[k]['rate'] or 0):
            entry = {'name': loc(r[0], pt_cell(1, i, 0)), 'rank': k[1],
                     'method': loc(method_en, method_pt), 'rate': rate}
            slug_of = large.get(key(r[0]))
            entry.update({'slug': slug_of} if slug_of else {'small': True})
            monsters[k] = entry

    quests = {}
    for i, r in enumerate(rows['en'][2]):
        m = re.match(r'(.*?)\s*(M?\d+)★\s*(.*)', r[0] if r else '')
        if not m:
            continue
        pm = re.match(r'(.*?)\s*(M?\d+)★\s*(.*)', pt_cell(2, i, 0) or '')
        k = (m.group(1), m.group(2), m.group(3))
        rate = _rate(r[3] if len(r) > 3 else None)
        if k not in quests or (rate or 0) > (quests[k]['rate'] or 0):
            quests[k] = {'name': loc(m.group(3), pm.group(3) if pm else None),
                         'category': loc(m.group(1) or 'Quest', (pm.group(1) if pm else None) or None),
                         'stars': m.group(2), 'rate': rate}

    def strip(xs):
        return [{k: v for k, v in x.items() if v is not None} for x in xs]
    out = {
        'gathering': strip(sorted(gathering.values(), key=lambda g: -(g['rate'] or 0))),
        'monsters': strip(sorted(monsters.values(), key=lambda m: -(m['rate'] or 0))),
        'quests': strip(sorted(quests.values(), key=lambda q: (len(q['stars']), q['stars']))),
    }
    return {k: v for k, v in out.items() if v}


def slots(f):
    out = []
    for level in (4, 3, 2, 1):
        out += [level] * int(f.get(f'Level {level} Decos', 0) or 0)
    return out


def specials(f):
    out = []
    for suffix in ('', ' 2'):
        kind = f.get(f'Elemental Damage Type{suffix}')
        value = f.get(f'Elemental Damage{suffix}')
        if kind and value and int(re.sub(r'\D', '', value) or 0) > 0:
            out.append({'kind': SPECIALS[kind], 'value': int(re.sub(r'\D', '', value))})
    return out


# ---------------------------------------------------------------- stars (R3)

def monster_star_table(monsters):
    """{monster slug: {rank: lowest quest star}} from the cached Kiranico monster pages."""
    table = {}
    for m in monsters:
        if m.get('versionOf'):
            continue
        cache = f'cache_rise_{m["slug"]}_en.html'
        if not os.path.exists(cache):
            continue
        stars = {}
        for tr in re.findall(r'<tr>.*?</tr>', open(cache, encoding='utf8').read(), re.S):
            row = re.match(r'(Village|Gathering Hub|MR) (\d+)★', clean(tr))
            if not row:
                continue
            cat, star = row.group(1), int(row.group(2))
            rank = ('low' if cat == 'Village' or star <= 3 else 'high' if star <= 7 else None) \
                if cat != 'MR' else 'master'
            if rank:
                stars[rank] = min(stars.get(rank, 99), star)
        table[m['slug']] = stars
    return table


def main():
    with_icons = '--icons' in sys.argv
    monsters_data = json.load(open(dataset_path('rise_sunbreak'), encoding='utf8'))
    monsters = monsters_data['monsters']
    star_table = monster_star_table(monsters)
    by_name = {key(m['name']['en']): m['slug'] for m in monsters if not m.get('versionOf')}
    drops = {}  # material id -> {rank: {monster slug}}
    for m in monsters:
        base = m.get('versionOf') or m['slug']
        for d in m.get('drops', []):
            drops.setdefault(d['materialId'], {}).setdefault(d['rank'], set()).add(base)
    pt_material = {mat['id']: mat['name'].get('ptBr') for mat in monsters_data['materials']}

    weapon_types, weapons, materials_out, report = [], [], {}, []
    for type_id, view, category, _icon, ranged in TYPES:
        en_rows, en_title = kiranico_list(view, 'en')
        pt_rows, pt_title = kiranico_list(view, 'pt')
        en_traits, pt_traits = list_traits(view, 'en'), list_traits(view, 'pt')
        weapon_types.append({'id': type_id, 'name': {'en': en_title or category, 'ptBr': pt_title or category},
                             'ranged': ranged})
        kir_by_key = {key(r['name']): (kid, r) for kid, r in en_rows.items() if r['attack'] > 0}
        pages = wiki_pages(type_id, category)
        seen = set()
        for title, text in sorted(pages.items()):
            f = fields_of(text)
            if 'Bucket' not in f or int(f.get('Attack', 0) or 0) == 0:
                continue  # cut items (research R2)
            name = f['Weapon Name']
            hit = kir_by_key.get(key(name))
            if hit is None:
                report.append(f'{type_id}: wiki only: {name}')
                continue
            kid, row = hit
            seen.add(kid)
            if row['attack'] != int(f['Attack']):
                report.append(f'{type_id}: attack differs for {name}: wiki {f["Attack"]} kiranico {row["attack"]}')
            rarity = int(f['Rarity'])
            rank = rank_of(rarity)

            detail = kiranico_detail(kid)

            def costs(prefix):
                listed = materials(f, prefix)
                if detail is not None:
                    # Kiranico has the game's materials; the wiki adds the
                    # points requirements, which Kiranico does not list.
                    kir = detail['forge' if prefix.startswith('Forge') else 'upgrade']
                    listed = [(n, q, None) for n, q in kir] + [m for m in listed if m[2]]
                out = []
                for mat_name, qty, pts in listed:
                    if pts:
                        # "Anjanath Material(s) x10 pts." is one material whose
                        # points go in the cost, not one material per amount.
                        mat_name = re.sub(r'\s*x\d+ pts\.?$', '', mat_name)
                    mid = slug(mat_name)
                    entry = materials_out.setdefault(mid, {'id': mid, 'name': {'en': mat_name}})
                    if pt_material.get(mid):
                        entry['name']['ptBr'] = pt_material[mid]
                    cost = {'material': mid}
                    if pts:
                        cost['points'] = pts
                    else:
                        cost['quantity'] = qty or 1
                    out.append(cost)
                return out

            forge = costs('Forge Material')
            upgrade = costs('Upgrade Material')
            star_values = []
            for cost in forge + upgrade:
                mid = cost['material']
                for mslug in drops.get(mid, {}).get(rank, ()):
                    if rank in star_table.get(mslug, {}):
                        star_values.append(star_table[mslug][rank])
                pts_name = re.match(r'(.+?)\+* Material\(s\)$', materials_out[mid]['name']['en'])
                if pts_name and key(pts_name.group(1)) in by_name:
                    mslug = by_name[key(pts_name.group(1))]
                    if rank in star_table.get(mslug, {}):
                        star_values.append(star_table[mslug][rank])
            weapon = {
                'slug': slug(name),
                'kiranicoId': kid,
                'type': type_id,
                'name': {'en': name, **({'ptBr': pt_rows[kid]['name']} if kid in pt_rows else {})},
                'description': {'en': html.unescape(f.get('Description', ''))},
                'rarity': rarity,
                'tree': slug(f.get('Tree', 'Other Tree')),
                'treeName': {'en': f.get('Tree', 'Other Tree')},
                'attack': int(f['Attack']),
                'affinity': int(f.get('Affinity', 0) or 0),
                'special': specials(f),
                'slots': slots(f),
                'rampageSlot': int((re.search(r'Rampage Deco\|(\d)', f.get('Rampage Decoration', '')) or [0, 0])[1]),
                **({'sharpness': (detail or {}).get('sharpness') or sharpness(f)}
                   if not ranged and ((detail or {}).get('sharpness') or sharpness(f)) else {}),
                'previous': slug(f['Previous Name']) if f.get('Previous Name') else None,
                'next': [slug(f[f'Next {i} Name']) for i in range(1, 6) if f.get(f'Next {i} Name')],
                **({'traits': t} if (t := traits_of(view, en_traits.get(kid), pt_traits.get(kid))) else {}),
                'forge': forge,
                'upgrade': upgrade,
                'stars': {'value': max(star_values) if star_values else FIRST_STAR[rank], 'estimated': True},
                'icon': row['icon'],
                'sources': [
                    {'name': 'Monster Hunter Wiki (MHRS)', 'url': WIKI + title.replace(' ', '_')},
                    {'name': 'Kiranico (MH Rise: Sunbreak)', 'url': f'{KIRANICO}/data/weapons/{kid}'},
                ],
            }
            weapons.append(weapon)
        for kid, row in en_rows.items():
            if row['attack'] > 0 and kid not in seen:
                report.append(f'{type_id}: kiranico only: {row["name"]}')
        print(type_id, en_title, '/', pt_title, '| weapons',
              sum(1 for w in weapons if w['type'] == type_id), flush=True)

    # Slugs: unique; on a clash, append the type.
    counts = {}
    for w in weapons:
        counts[w['slug']] = counts.get(w['slug'], 0) + 1
    rename = {}
    for w in weapons:
        if counts[w['slug']] > 1:
            rename[(w['type'], w['slug'])] = f'{w["slug"]}-{w["type"]}'
    for w in weapons:
        t = w['type']
        w['slug'] = rename.get((t, w['slug']), w['slug'])
        if w['previous']:
            w['previous'] = rename.get((t, w['previous']), w['previous'])
        w['next'] = [rename.get((t, n), n) for n in w['next']]

    # Links must resolve within the catalog (a tree may cross types, e.g. none in Rise).
    known = {w['slug'] for w in weapons}
    for w in weapons:
        if w['previous'] and w['previous'] not in known:
            report.append(f'unknown previous {w["previous"]} of {w["slug"]}')
            w['previous'] = None
        missing = [n for n in w['next'] if n not in known]
        if missing:
            report.append(f'unknown next {missing} of {w["slug"]}')
            w['next'] = [n for n in w['next'] if n in known]

    if with_icons:
        fetch_icons(weapons)
    for w in weapons:
        path = os.path.join(ICON_DIR, f'{w["slug"]}.webp')
        if os.path.exists(path):
            w['image'] = f'assets/images/weapons/rise_sunbreak/{w["slug"]}.webp'
        w.pop('icon')

    used = {c['material'] for w in weapons for c in w['forge'] + w['upgrade']}
    # Where each material comes from (006 US5), when its Kiranico item pages are cached.
    item_ids = {}
    if os.path.exists('kiranico_item_ids.json'):
        item_ids = {slug(n): i for n, i in json.load(open('kiranico_item_ids.json', encoding='utf8')).items()}
    large = {key(m['name']['en']): m['slug'] for m in monsters}
    for m in materials_out.values():
        if m['id'] in item_ids:
            src = material_sources(item_ids[m['id']], large)
            if src:
                m['sources'] = src
    dataset = {
        'schemaVersion': 1,
        'game': 'rise_sunbreak',
        'generatedAt': datetime.date.today().isoformat(),
        'sources': [
            {'name': 'Monster Hunter Wiki (MHRS weapon pages)', 'url': WIKI,
             'notes': 'GenericWeapon template: tree, rarity, attack, affinity, element/status, slots, '
                      'Rampage slot, sharpness (+Handicraft), previous/next, forge/upgrade materials.'},
            {'name': 'Kiranico (MH Rise: Sunbreak)', 'url': f'{KIRANICO}/data/weapons',
             'notes': 'pt-BR names and icons; attack cross-checked against the wiki.'},
        ],
        'starRule': STAR_RULE,
        'weaponTypes': weapon_types,
        'materials': sorted((m for m in materials_out.values() if m['id'] in used), key=lambda m: m['id']),
        'weapons': weapons,
    }
    with open(OUT, 'w', encoding='utf8', newline='\n') as fh:
        json.dump(dataset, fh, ensure_ascii=False, indent=1)
        fh.write('\n')
    print('weapons', len(weapons), 'materials', len(dataset['materials']),
          'with image', sum(1 for w in weapons if 'image' in w))
    print('report', len(report))
    for line in report[:60]:
        print('  ', line)
    if len(report) > len(weapons) * 0.01 + 10:
        sys.exit('too many unmatched weapons; check the report')


def fetch_icons(weapons):
    from PIL import Image
    os.makedirs(ICON_DIR, exist_ok=True)
    os.makedirs('weapon_icons', exist_ok=True)
    for i, w in enumerate(weapons):
        out = os.path.join(ICON_DIR, f'{w["slug"]}.webp')
        if os.path.exists(out) or not w['icon']:
            continue
        cache = os.path.join('weapon_icons', w['icon'].rsplit('/', 1)[1])
        if not os.path.exists(cache):
            try:
                req = urllib.request.Request(w['icon'].replace('http://', 'https://'), headers=UA)
                data = urllib.request.urlopen(req, timeout=60).read()
            except Exception as e:  # noqa: BLE001 - a missing icon falls back to the marker
                print('icon failed', w['slug'], e)
                continue
            open(cache, 'wb').write(data)
            time.sleep(0.3)
        im = Image.open(cache).convert('RGBA')
        im.thumbnail((ICON_SIZE, ICON_SIZE), Image.LANCZOS)
        canvas = Image.new('RGBA', (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
        canvas.paste(im, ((ICON_SIZE - im.width) // 2, (ICON_SIZE - im.height) // 2), im)
        canvas.save(out, 'WEBP', quality=82, method=6)
        if i % 250 == 0:
            print('icons', i, flush=True)
    os.makedirs(TYPE_ICON_DIR, exist_ok=True)
    for type_id, _v, _c, stem, _r in TYPES:
        out = os.path.join(TYPE_ICON_DIR, f'{type_id}.webp')
        if os.path.exists(out):
            continue
        url = WIKI + 'Special:FilePath/' + f'MHRS-{stem} Icon Rare 1.png'.replace(' ', '_')
        try:
            data = urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read()
            im = Image.open(io.BytesIO(data)).convert('RGBA')
            im.thumbnail((64, 64), Image.LANCZOS)
            im.save(out, 'WEBP', quality=90, method=6)
        except Exception as e:  # noqa: BLE001
            print('type icon failed', type_id, e)
    # The game's decoration slot icons, levels 1-4 (also used for the Rampage slot).
    os.makedirs(SLOT_ICON_DIR, exist_ok=True)
    for level in range(1, 5):
        out = os.path.join(SLOT_ICON_DIR, f'deco{level}.webp')
        if os.path.exists(out):
            continue
        url = f'https://cdn.kiranico.net/file/kiranico/mhrise-web/images/ui/deco{level}.png'
        data = urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read()
        im = Image.open(io.BytesIO(data)).convert('RGBA')
        im.thumbnail((48, 48), Image.LANCZOS)
        im.save(out, 'WEBP', lossless=True)


if __name__ == '__main__':
    main()
