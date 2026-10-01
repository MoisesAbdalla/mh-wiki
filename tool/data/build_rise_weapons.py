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

            def costs(prefix):
                out = []
                for mat_name, qty, pts in materials(f, prefix):
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
                pts_name = re.match(r'(.+?)\+* Material\(s\) x\d+ pts\.', materials_out[mid]['name']['en'])
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
                **({'sharpness': sharpness(f)} if not ranged and sharpness(f) else {}),
                'previous': slug(f['Previous Name']) if f.get('Previous Name') else None,
                'next': [slug(f[f'Next {i} Name']) for i in range(1, 6) if f.get(f'Next {i} Name')],
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
        url = WIKI + 'Special:FilePath/' + f'MHRS-{stem} Icon.png'.replace(' ', '_')
        try:
            data = urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read()
            im = Image.open(io.BytesIO(data)).convert('RGBA')
            im.thumbnail((64, 64), Image.LANCZOS)
            im.save(out, 'WEBP', quality=90, method=6)
        except Exception as e:  # noqa: BLE001
            print('type icon failed', type_id, e)


if __name__ == '__main__':
    main()
