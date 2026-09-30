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

ROSTER = json.load(open(os.path.join(REPO, 'tool', 'data', 'rosters', 'wilds.json'),
                       encoding='utf8'))['monsters']
TEMPERED_LABELS = {  # drop group -> method label (pt-BR from Kiranico when it exists)
    'Extra Rewards (Tempered)': {'en': 'Extra Reward (Tempered)'},
    'Tempered Wound Destruction Rewards': {'en': 'Tempered Wound Destroyed Reward',
                                           'ptBr': 'Prêmio de Ferimento Ag. Destr.'},
}
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
    t = t.lower().replace("'", '').replace('+', '-plus').replace('γ', '-gamma')
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


def combine(a, b):
    """Rate of a material listed twice in one group: the same table with other
    amounts adds up; when that would pass 100 % the rows are separate draws,
    combined as independent chances (feature 004)."""
    total = a + b
    if total <= 100:
        return round(total, 2)
    return round(100 * (1 - (1 - a / 100) * (1 - b / 100)), 2)


def material_of(item, en_items, materials):
    mid = slug(item)
    mat = materials.setdefault(mid, {'id': mid, 'name': {'en': item}})
    if 'ptBr' not in mat['name']:
        pt = pt_item_name(en_items.get(item) or slug(item))
        if pt:
            mat['name']['ptBr'] = pt
    return mid


def tempered_version(entry, materials):
    """A tempered version: only its own drops (the base page's tempered groups)."""
    base_slug, wname = entry['versionOf'], entry['wiki']
    wiki = fetch(f'{MHWIKI}{wname}_(MHWilds)', f'cache_mhwiki_wilds_{base_slug}.html')
    en_items, _ = kiranico_page(payload(fetch(f'{KIRANICO}/data/monsters/{base_slug}',
                                              f'cache_wilds_{base_slug}_en.html')))
    final = {}
    for rank, groups in wiki_drops(wiki).items():
        for title, rows in groups:
            label = TEMPERED_LABELS.get(title)
            if not label:
                continue
            for item, rate in rows:
                mid = material_of(item, en_items, materials)
                key = (mid, rank, label['en'])
                if key in final:
                    final[key]['ratePercent'] = combine(final[key]['ratePercent'], rate)
                else:
                    final[key] = {'materialId': mid, 'rank': rank, 'method': 'other',
                                  'methodLabel': label, 'ratePercent': rate}
    return {
        'slug': entry['slug'],
        'versionOf': base_slug,
        'versionKind': entry['versionKind'],
        'name': {'en': entry['name']},
        'drops': list(final.values()),
        'sources': [
            {'name': 'Monster Hunter Wiki (MHWilds)', 'url': f'{MHWIKI}{wname}_(MHWilds)',
             'notes': 'Tempered drop groups of the base page ("Extra Rewards (Tempered)", '
                      '"Tempered Wound Destruction Rewards"). Weaknesses, parts, habitats, item '
                      'reactions and classification are the base\'s (not listed separately).'},
        ],
    }


def quest_texts():
    """{quest page title: wikitext} from the pages cached by roster_wilds.py."""
    texts = {}
    for name in sorted(f for f in os.listdir('.') if f.startswith('wiki_wilds_quest_text_')):
        for p in json.load(open(name, encoding='utf8'))['query']['pages'].values():
            texts[p['title']] = p['revisions'][0]['slots']['main']['*']
    return texts


def arch_tempered_version(entry, materials, base, texts):
    """An arch-tempered version: the rewards of its quests that are the monster's own
    materials (named after it or among the base's drops). Quest pages give no rates."""
    base_slug = entry['versionOf']
    en_items, _ = kiranico_page(payload(fetch(f'{KIRANICO}/data/monsters/{base_slug}',
                                              f'cache_wilds_{base_slug}_en.html')))
    base_name = base['name']['en']
    base_mats = {d['materialId'] for d in base['drops']}
    drops, sources = {}, []
    for title in entry['quests']:
        text = texts[title]
        rank = re.search(r'\|Rank\s*=\s*(\w+)', text).group(1).lower()
        stars = re.search(r'\|Rank Level\s*=\s*(\d+)', text).group(1)
        rewards = re.search(r'==\s*Rewards\s*==(.*?)(?:\n==[^=]|$)', text, re.S)
        items = re.findall(r'\{\{#invoke:MHWildsItem\|iconSmall\|([^}|]+)\}\}', rewards.group(1) if rewards else '')
        own = [i.strip() for i in items if i.startswith(base_name + ' ') or slug(i) in base_mats]
        for item in own:
            mid = material_of(item, en_items, materials)
            drops.setdefault((mid, rank), {'materialId': mid, 'rank': rank, 'method': 'questReward'})
        name = title.removesuffix(' (MHWilds Quest)')
        sources.append({'name': f'Monster Hunter Wiki (MHWilds quest): {name}',
                        'url': MHWIKI + title.replace(' ', '_'),
                        'notes': f'★{stars} {rank.capitalize()} Rank quest with Arch-Tempered {base_name}. '
                                 f'Rewards that are {base_name} materials (the page has no rates).'})
    sources[0]['notes'] += (' Weaknesses, parts, habitats, item reactions and classification are '
                            'the base\'s.')
    return {
        'slug': entry['slug'],
        'versionOf': base_slug,
        'versionKind': entry['versionKind'],
        'name': {'en': entry['name']},
        'drops': list(drops.values()),
        'sources': sources,
    }


def build():
    habitats, materials, monsters = {}, {}, []
    texts = quest_texts()
    for entry in ROSTER:
        if entry.get('dataFrom') == 'wikiArchTemperedQuests':
            base = next(m for m in monsters if m['slug'] == entry['versionOf'])
            monsters.append(arch_tempered_version(entry, materials, base, texts))
            print(entry['slug'], '| drops', [d['materialId'] for d in monsters[-1]['drops']])
            continue
        if entry.get('dataFrom') == 'baseWikiTemperedDrops':
            monsters.append(tempered_version(entry, materials))
            print(entry['slug'], '| drops', len(monsters[-1]['drops']))
            continue
        s, wname = entry['slug'], entry['wiki']
        en_page = fetch(f'{KIRANICO}/data/monsters/{s}', f'cache_wilds_{s}_en.html')
        pt_url = re.search(r'"version":"pt-BR","url":"(/pt-BR/data/monsters/[^"]+)"', payload(en_page))
        pt_page = fetch(KIRANICO + (pt_url.group(1) if pt_url else f'/pt-BR/data/monsters/{s}'),
                        f'cache_wilds_{s}_pt.html')
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
                    mid = material_of(item, en_items, materials)
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
                final[key]['ratePercent'] = combine(final[key]['ratePercent'], d['ratePercent'])
            else:
                final[key] = dict(d)

        hab = []
        for loc in wiki_locales(wiki):
            hid = slug(loc)
            habitats.setdefault(hid, {'id': hid, 'name': {'en': loc}})
            hab.append(hid)

        version = ({'versionOf': entry['versionOf'], 'versionKind': entry['versionKind']}
                   if 'versionOf' in entry else {})
        monsters.append({
            'slug': s,
            **version,
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
