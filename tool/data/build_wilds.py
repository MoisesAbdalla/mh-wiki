"""Builds assets/data/wilds/monsters.json.

Sources:
- monsterhunterwiki.org <Name>_(MHWilds): drop tables per rank (carves, tail carves,
  hunt/capture rewards, named part breaks, wound destruction), locales;
  <Name> base page: classification.
- Kiranico MH Wilds: pt-BR names (monster, parts, items) and hitzones (stars rule).
"""
import datetime, html, json, os, re, time, urllib.request
from common import REPO, dataset_path  # noqa: E402,F401  (sets cwd to the cache)

UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki data curation; personal study project)'}
OUT = dataset_path('wilds')
KIRANICO = 'https://mhwilds.kiranico.com'
MHWIKI = 'https://monsterhunterwiki.org/wiki/'
ELEMENTS = ['fire', 'water', 'thunder', 'ice', 'dragon']  # also Kiranico's column order here

ROSTER = [  # slug (= Kiranico slug), wiki page name
    ('chatacabra', 'Chatacabra'),
    ('doshaguma', 'Doshaguma'),
    ('rey-dau', 'Rey_Dau'),
    ('uth-duna', 'Uth_Duna'),
    ('nu-udra', 'Nu_Udra'),
    ('jin-dahaad', 'Jin_Dahaad'),
    ('rathalos', 'Rathalos'),
    ('guardian-rathalos', 'Guardian_Rathalos'),
    ('gore-magala', 'Gore_Magala'),
    ('arkveld', 'Arkveld'),
]
PT_SLUG = {'guardian-rathalos': 'rathalos-guardiao'}  # Kiranico localizes this URL
STAR_RULE = ('Stars = best elemental hitzone over all parts, wounds excluded: >=25 3 stars, 20-24 2, '
             '10-19 1, <10 0 (same rule as the Rise dataset, calibrated on World Rathalos).')


def fetch(url, cache):
    if os.path.exists(cache):
        return open(cache, encoding='utf8').read()
    req = urllib.request.Request(url, headers=UA)
    try:
        data = urllib.request.urlopen(req, timeout=60).read().decode('utf8')
    except urllib.error.HTTPError as e:
        data = f'HTTP {e.code}'
    open(cache, 'w', encoding='utf8').write(data)
    time.sleep(1.2)
    return data


def clean(t):
    return html.unescape(re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', t))).strip()


def slug(t):
    t = t.lower().replace("'", '').replace('+', '-plus')
    return re.sub(r'[^a-z0-9]+', '-', t).strip('-')


def payload(page):
    chunks = re.findall(r'self\.__next_f\.push\(\[1,"(.*?)"\]\)', page, re.S)
    return ''.join(json.loads('"' + c + '"') for c in chunks)


def kiranico_page(p):
    """Returns (items en->(slug, name), physiology rows [(names dict, is_wound, 5 elems)])."""
    items = {name: href for href, name in re.findall(r'"hrefs":"/data/items/([^"]+)","children":"([^"]+)"', p)}
    phys = []
    for m in re.finditer(r'\{"type":"tr","props":\{"children":\[\{"type":"td","props":\{"children":\{"type":"tx",'
                         r'"props":\{"children":(\{[^{}]*\})\}\},"align":"left"\}\},\{"type":"td","props":\{"children":"(\w*)"'
                         r'(?:,"align":"left")?\}\},((?:\{"type":"td","props":\{"children":\{"type":"tx","props":\{"children":-?\d+\}\}\}\},?){9})', p):
        names = json.loads(m.group(1))
        nums = [int(x) for x in re.findall(r'"children":(-?\d+)', m.group(3))]
        phys.append((names, m.group(2) == 'Wounds', nums[3:8]))
    return items, phys


def wiki_drops(page):
    """{rank: [(group title, [(item, rate)])]} from the Drop Rates tabber."""
    start = page.find('id="Drop_Rates"')
    end = page.find('<h2', start + 10)
    section = page[start:end if end > 0 else len(page)]
    result = {}
    panels = list(re.finditer(r'<article class="tabber__panel"[^>]*id="tabber-(\w+?)_Rank"', section))
    for i, m in enumerate(panels):
        body = section[m.end(): panels[i + 1].start() if i + 1 < len(panels) else len(section)]
        groups = []
        for g in re.finditer(r'<th[^>]*>(.*?)</th>(.*?)(?=<th|$)', body, re.S):
            title = clean(g.group(1))
            rows = [(clean(n), float(r)) for n, r in re.findall(
                r'title="([^"]*?) \(MHWilds\)">[^<]*</a>[^<]*</td>\s*<td>\s*([\d.]+)%', g.group(2))]
            if rows:
                groups.append((title, rows))
        result[m.group(1).lower()] = groups
    return result


def wiki_locales(page):
    m = re.search(r'<th>Locales\s*</th></tr>\s*<tr>\s*<td[^>]*>(.*?)</td>', page, re.S)
    return [clean(a) for a in re.findall(r'<a [^>]*>(.*?)</a>', m.group(1))] if m else []


def wiki_class(page):
    m = re.search(r'Classification\s*</th>.*?<a [^>]*>(.*?)</a>', page, re.S)
    return clean(m.group(1)) if m else None


PT_ITEM_CACHE = {}


def pt_item_name(item_slug):
    """Follows the en item page's pt-BR alternate URL and reads its title."""
    if item_slug in PT_ITEM_CACHE:
        return PT_ITEM_CACHE[item_slug]
    name = None
    en = fetch(f'{KIRANICO}/data/items/{item_slug}', f'cache_wilds_item_{item_slug}_en.html')
    m = re.search(r'"version":"pt-BR","url":"(/pt-BR/data/items/[^"]+)"', payload(en))
    if m:
        pt = fetch(KIRANICO + m.group(1), f'cache_wilds_item_{item_slug}_pt.html')
        t = re.search(r'<title>(.*?) \| MHWilds', pt)
        if t:
            name = html.unescape(t.group(1)).strip()
    PT_ITEM_CACHE[item_slug] = name
    return name


def method_of(title):
    if title == 'Carves':
        return 'carve', None
    if title == 'Carve Tail':
        return 'tailCarve', None
    if title == 'Hunt Rewards':
        return 'questReward', None
    if title == 'Capture Rewards':
        return 'capture', None
    if title == 'Wound Destruction Rewards':
        return 'other', None
    m = re.match(r'Break (.+)$', title)
    if m:
        return 'breakPart', m.group(1)
    return None, None  # rotten carves, investigations, tempered extras


def build():
    habitats, materials, monsters = {}, {}, []
    for s, wname in ROSTER:
        en_page = fetch(f'{KIRANICO}/data/monsters/{s}', f'cache_wilds_{s}_en.html')
        pt_page = fetch(f'{KIRANICO}/pt-BR/data/monsters/{PT_SLUG.get(s, s)}', f'cache_wilds_{s}_pt.html')
        wiki = fetch(f'{MHWIKI}{wname}_(MHWilds)', f'cache_mhwiki_wilds_{s}.html')
        base = fetch(f'{MHWIKI}{wname}', f'cache_mhwiki_{s}_base.html')

        en_items, phys = kiranico_page(payload(en_page))
        pt_items, _ = kiranico_page(payload(pt_page))
        pt_by_slug = {v: k for k, v in pt_items.items()}
        name_en = clean(re.search(r'<title>(.*?)(?:\s*\||\s+-\s)', en_page).group(1))
        name_pt = clean(re.search(r'<title>(.*?)(?:\s*\||\s+-\s)', pt_page).group(1))
        part_pt = {n['en']: n.get('pt-BR') for n, _w, _e in phys}

        best = {e: 0 for e in ELEMENTS}
        for _n, wound, elems in phys:
            if not wound:
                for e, v in zip(ELEMENTS, elems):
                    best[e] = max(best[e], v)
        stars = lambda v: 'high' if v >= 25 else 'medium' if v >= 20 else 'low' if v >= 10 else 'none'
        general = {e: stars(best[e]) for e in ELEMENTS}

        parts, drops = {}, []
        for rank, groups in wiki_drops(wiki).items():
            seen = set()
            for title, rows in groups:
                if title in seen:
                    continue
                seen.add(title)
                method, part_en = method_of(title)
                if not method:
                    continue
                part_id = None
                if part_en:
                    part_id = slug(part_en)
                    parts.setdefault(part_id, {'id': part_id, 'name': {'en': part_en, **({'ptBr': part_pt[part_en]} if part_pt.get(part_en) else {})}, 'severable': False})
                if method == 'tailCarve':
                    parts.setdefault('tail', {'id': 'tail', 'name': {'en': 'Tail', **({'ptBr': part_pt['Tail']} if part_pt.get('Tail') else {})}, 'severable': True})
                    parts['tail']['severable'] = True
                for item, rate in rows:
                    mid = slug(item)
                    mat = materials.setdefault(mid, {'id': mid, 'name': {'en': item}})
                    if 'ptBr' not in mat['name']:
                        kslug = en_items.get(item) or slug(item)
                        pt = pt_item_name(kslug)
                        if pt:
                            mat['name']['ptBr'] = pt
                    d = {'materialId': mid, 'rank': rank, 'method': method}
                    if part_id:
                        d['partId'] = part_id
                    if method == 'other':
                        d['methodLabel'] = {'en': 'Wound Destroyed Reward',
                                            'ptBr': 'Prêmio de Ferimento Destruído'}
                    d['ratePercent'] = rate
                    drops.append(d)

        final = {}
        for d in drops:  # same material listed twice in one group (different amounts): sum
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
            'name': {'en': name_en, 'ptBr': name_pt},
            'classification': {'en': wiki_class(base) or 'Unknown'},
            'weaknesses': {'general': general},
            'habitatIds': hab,
            'parts': list(parts.values()),
            'drops': list(final.values()),
            'sources': [
                {'name': 'Monster Hunter Wiki (MHWilds)', 'url': f'{MHWIKI}{wname}_(MHWilds)',
                 'notes': 'Drop tables per rank (carves, tail carves, hunt/capture rewards, named part '
                          'breaks, wound destruction) and locales. Rotten carves, investigations and '
                          'tempered extras excluded.'},
                {'name': 'Kiranico (MH Wilds)', 'url': f'{KIRANICO}/data/monsters/{s}',
                 'notes': 'pt-BR names and hitzones. ' + STAR_RULE},
                {'name': 'Monster Hunter Wiki', 'url': f'{MHWIKI}{wname}', 'notes': 'Classification.'},
            ],
        })
        print(s, name_en, '/', name_pt, '|', monsters[-1]['classification']['en'], '| hab', hab,
              '| ranks', sorted({d['rank'] for d in final.values()}),
              '| parts', [(p['id'], p['name'].get('ptBr'), p['severable']) for p in parts.values()],
              '| drops', len(final), '| weak', general)

    used_m = {d['materialId'] for m in monsters for d in m['drops']}
    missing_pt = sorted(m['name']['en'] for m in materials.values() if m['id'] in used_m and 'ptBr' not in m['name'])
    dataset = {
        'schemaVersion': 1,
        'game': 'wilds',
        'generatedAt': datetime.date.today().isoformat(),
        'sources': [
            {'name': 'Monster Hunter Wiki', 'url': 'https://monsterhunterwiki.org/',
             'notes': 'Drop rates, named part breaks, locales, classification.'},
            {'name': 'Kiranico (MH Wilds)', 'url': KIRANICO + '/', 'notes': 'pt-BR names, hitzones. ' + STAR_RULE},
        ],
        'habitats': list(habitats.values()),
        'materials': sorted((m for m in materials.values() if m['id'] in used_m), key=lambda m: m['id']),
        'monsters': monsters,
    }
    json.dump(dataset, open(OUT, 'w', encoding='utf8', newline='\n'), ensure_ascii=False, indent=2)
    print('materials', len(dataset['materials']), 'missing pt', len(missing_pt), missing_pt[:15])
    print('habitats', [h['id'] for h in dataset['habitats']])


build()
