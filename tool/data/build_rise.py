"""Builds assets/data/rise_sunbreak/monsters.json.

Sources:
- Kiranico MH Rise: Sunbreak (en + pt-BR): names, drops with rates, hitzones.
- monsterhunterwiki.org: MHRS pages give named "Broken Part (X)" reward tables
  (used to name Kiranico's "BodyPart N" groups by identical item/rate sets),
  locales; base pages give the classification.
"""
import collections, datetime, html, json, os, re, time, urllib.request
from common import REPO, dataset_path  # noqa: E402,F401  (sets cwd to the cache)

UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki data curation; personal study project)'}
OUT = dataset_path('rise_sunbreak')
KIRANICO = 'https://mhrise.kiranico.com'
MHWIKI = 'https://monsterhunterwiki.org/wiki/'

ROSTER = [  # slug, kiranico id, wiki page name
    ('great-izuchi', '1681174536', 'Great_Izuchi'),
    ('rathian', '366824395', 'Rathian'),
    ('rathalos', '381074408', 'Rathalos'),
    ('tigrex', '808327178', 'Tigrex'),
    ('zinogre', '1432800563', 'Zinogre'),
    ('mizutsune', '1251979832', 'Mizutsune'),
    ('violet-mizutsune', '1061157944', 'Violet_Mizutsune'),
    ('magnamalo', '1921564947', 'Magnamalo'),
    ('rajang', '243411229', 'Rajang'),
    ('malzeno', '50943022', 'Malzeno'),
]
ELEMENTS_KIRANICO_ORDER = ['fire', 'water', 'ice', 'thunder', 'dragon']
ELEMENTS = ['fire', 'water', 'thunder', 'ice', 'dragon']
RANK = {'Low Rank': 'low', 'High Rank': 'high', 'Master Rank': 'master'}
STAR_RULE = ('Rise lists hitzones, not stars. Stars = best elemental hitzone over all parts in the '
             'normal state: >=25 3 stars, 20-24 2, 10-19 1, <10 0 (calibrated on World Rathalos, '
             'whose official notes give dragon 30=3, thunder 20=2, water/ice 15=1, fire 0=X).')


def fetch(url, cache):
    if os.path.exists(cache):
        return open(cache, encoding='utf8').read()
    req = urllib.request.Request(url, headers=UA)
    data = urllib.request.urlopen(req, timeout=60).read().decode('utf8')
    open(cache, 'w', encoding='utf8').write(data)
    time.sleep(1.5)
    return data


def clean(t):
    return html.unescape(re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', t))).strip()


def slug(t):
    t = t.lower().replace("'", '').replace('+', '-plus')
    return re.sub(r'[^a-z0-9]+', '-', t).strip('-')


ITEM_ROW = re.compile(
    r'href="https://mhrise\.kiranico\.com/(?:pt-BR/)?data/items/(\d+)">(.*?)</a></td>\s*'
    r'<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>\s*<td[^>]*>(.*?)</td>', re.S)


def kiranico(page):
    title = clean(re.search(r'<title>(.*?)\|', page).group(1))
    items = [tuple(clean(x) for x in r) for r in ITEM_ROW.findall(page)]
    # Physiology rows: part, state, 3 physical, 5 elemental, stun.
    start = page.find('Physiology') if 'Physiology' in page else page.find('Fisiologia')
    phys_html = page[start:page.find('</table>', start)]
    phys = []
    for tr in re.findall(r'<tr[^>]*>(.*?)</tr>', phys_html, re.S):
        cells = [clean(c) for c in re.findall(r'<td[^>]*>(.*?)</td>', tr, re.S)]
        if len(cells) == 11 and all(re.fullmatch(r'-?\d+', c) for c in cells[1:]):
            phys.append((cells[0], int(cells[1]), [int(c) for c in cells[5:10]]))
    return title, items, phys


def wiki_breaks(page):
    groups = []
    for m in re.finditer(r'<th colspan="2">Broken Part \(([^)]*)\)</th></tr>(.*?)(?=<th|</table>)', page, re.S):
        rows = frozenset((clean(n), int(r)) for n, r in re.findall(
            r'title="[^"]*\(MHRS\)">([^<]*)</a>[^<]*</td><td>(\d+)%', m.group(2)))
        groups.append((m.group(1), rows))
    return groups


def wiki_locales(page):
    m = re.search(r'<th>Locales\s*</th></tr>\s*<tr>\s*<td[^>]*>(.*?)</td>', page, re.S)
    return [clean(a) for a in re.findall(r'<a [^>]*>(.*?)</a>', m.group(1))] if m else []


def wiki_class(page):
    m = re.search(r'Classification\s*</th>.*?<a [^>]*>(.*?)</a>', page, re.S)
    return clean(m.group(1)) if m else None


def global_part_names():
    """en -> pt-BR part names paired by position on every roster page."""
    names = {}
    for s, kid, _ in ROSTER:
        _, _, en_phys = kiranico(fetch(f'{KIRANICO}/data/monsters/{kid}', f'cache_rise_{s}_en.html'))
        _, _, pt_phys = kiranico(fetch(f'{KIRANICO}/pt-BR/data/monsters/{kid}', f'cache_rise_{s}_pt.html'))
        for e, p in zip(en_phys, pt_phys):
            names.setdefault(e[0], p[0])
    return names


def build():
    habitats, materials, monsters = {}, {}, []
    all_pt_parts = global_part_names()
    for s, kid, wname in ROSTER:
        en_title, en_items, en_phys = kiranico(fetch(f'{KIRANICO}/data/monsters/{kid}', f'cache_rise_{s}_en.html'))
        pt_title, pt_items, pt_phys = kiranico(fetch(f'{KIRANICO}/pt-BR/data/monsters/{kid}', f'cache_rise_{s}_pt.html'))
        wiki = fetch(f'{MHWIKI}{wname}_(MHRS)', f'cache_mhwiki_{s}_mhrs.html')
        base = fetch(f'{MHWIKI}{wname}', f'cache_mhwiki_{s}_base.html')
        assert len(en_items) == len(pt_items), s
        pt_part = {**all_pt_parts, **{e[0]: p[0] for e, p in zip(en_phys, pt_phys)}}

        # Weaknesses from normal-state hitzones
        best = {e: 0 for e in ELEMENTS}
        for _part, state, elem in en_phys:
            if state != 0:
                continue
            for e, v in zip(ELEMENTS_KIRANICO_ORDER, elem):
                best[e] = max(best[e], v)
        stars = lambda v: 'high' if v >= 25 else 'medium' if v >= 20 else 'low' if v >= 10 else 'none'
        general = {e: stars(best[e]) for e in ELEMENTS}

        # Name break groups by matching identical item/rate sets on the wiki
        wiki_groups = wiki_breaks(wiki)
        k_groups = collections.defaultdict(set)
        for (_iid, name, rank, method, sub, qty, rate) in en_items:
            if method == 'Broken Part Rewards':
                k_groups[(rank, sub)].add((name, int(rate.rstrip('%'))))
        votes = collections.defaultdict(collections.Counter)
        for (rank, sub), rows in k_groups.items():
            for part, wrows in wiki_groups:
                if wrows == frozenset(rows):
                    votes[sub][part] += 1
        part_of = {sub: c.most_common(1)[0][0] for sub, c in votes.items()}
        unnamed = sorted({sub for (_, sub) in k_groups} - set(part_of))

        parts, drops = {}, []
        for (iid, name, rank_l, method, sub, qty, rate), pt in zip(en_items, pt_items):
            if name.startswith('Afflicted'):
                continue  # rewards of the Afflicted variant, not the base monster
            rank = RANK[rank_l]
            part_id = None
            if method == 'Carves' and sub == 'Body':
                m = 'carve'
            elif method == 'Carves' and sub == 'Severing':
                m = 'tailCarve'
                parts.setdefault('tail', {'id': 'tail', 'name': {'en': 'Tail', **({'ptBr': pt_part['Tail']} if 'Tail' in pt_part else {})}, 'severable': True})
                parts['tail']['severable'] = True
            elif method == 'Dropped Materials' and sub == '':
                m = 'droppedMaterial'
            elif method == 'Capture Rewards':
                m = 'capture'
            elif method == 'Target Rewards':
                m = 'questReward'
            elif method == 'Broken Part Rewards' and sub in part_of:
                m = 'breakPart'
                pname = part_of[sub]
                part_id = slug(pname)
                parts.setdefault(part_id, {'id': part_id, 'name': {'en': pname, **({'ptBr': pt_part[pname]} if pname in pt_part else {})}, 'severable': False})
            else:
                continue  # palico, wyvern riding drops, unnamed break groups
            mid = slug(name)
            mat = materials.setdefault(mid, {'id': mid, 'name': {'en': name}})
            mat['name']['ptBr'] = pt[1]
            d = {'materialId': mid, 'rank': rank, 'method': m, **({'partId': part_id} if part_id else {}),
                 'ratePercent': float(rate.rstrip('%'))}
            drops.append(d)

        merged = {}
        for d in drops:  # identical rows repeat on Kiranico (one per quest type); keep one
            key = (d['materialId'], d['rank'], d['method'], d.get('partId'), d['ratePercent'])
            merged.setdefault(key, d)
        # same material+method listed with different amounts: sum their chances
        final = {}
        for d in merged.values():
            key = (d['materialId'], d['rank'], d['method'], d.get('partId'))
            if key in final:
                final[key]['ratePercent'] = round(final[key]['ratePercent'] + d['ratePercent'], 2)
            else:
                final[key] = dict(d)

        hab = []
        for loc in wiki_locales(wiki):
            hid = slug(loc)
            habitats.setdefault(hid, {'id': hid, 'name': {'en': loc}})
            hab.append(hid)

        monsters.append({
            'slug': s,
            'name': {'en': en_title, 'ptBr': pt_title},
            'classification': {'en': wiki_class(base) or 'Unknown'},
            'weaknesses': {'general': general},
            'habitatIds': hab,
            'parts': list(parts.values()),
            'drops': list(final.values()),
            'sources': [
                {'name': 'Kiranico (MH Rise: Sunbreak)', 'url': f'{KIRANICO}/data/monsters/{kid}',
                 'notes': 'Names (en/pt-BR), drops and rates, hitzones. ' + STAR_RULE
                          + ' Afflicted-variant, palico and wyvern-riding drops excluded.'},
                {'name': 'Monster Hunter Wiki (MHRS)', 'url': f'{MHWIKI}{wname}_(MHRS)',
                 'notes': 'Locales and named broken-part rewards, matched to Kiranico BodyPart groups by '
                          'identical item/rate sets.'
                          + (f' Unmatched groups not shown: {", ".join(unnamed)}.' if unnamed else '')},
                {'name': 'Monster Hunter Wiki', 'url': f'{MHWIKI}{wname}', 'notes': 'Classification.'},
            ],
        })
        print(s, en_title, '/', pt_title, '|', monsters[-1]['classification']['en'], '| hab', hab,
              '| parts', [(p['id'], p['name'].get('ptBr'), p['severable']) for p in parts.values()],
              '| unnamed', unnamed, '| drops', len(final), '| weak', general)

    used_m = {d['materialId'] for m in monsters for d in m['drops']}
    dataset = {
        'schemaVersion': 1,
        'game': 'rise_sunbreak',
        'generatedAt': datetime.date.today().isoformat(),
        'sources': [
            {'name': 'Kiranico (MH Rise: Sunbreak)', 'url': KIRANICO + '/',
             'notes': 'Database ver. 16.0.0. ' + STAR_RULE},
            {'name': 'Monster Hunter Wiki', 'url': 'https://monsterhunterwiki.org/',
             'notes': 'Locales, classification and broken-part names.'},
        ],
        'habitats': list(habitats.values()),
        'materials': sorted((m for m in materials.values() if m['id'] in used_m), key=lambda m: m['id']),
        'monsters': monsters,
    }
    json.dump(dataset, open(OUT, 'w', encoding='utf8', newline='\n'), ensure_ascii=False, indent=2)
    print('materials', len(dataset['materials']), 'habitats', [h['id'] for h in dataset['habitats']])


build()
