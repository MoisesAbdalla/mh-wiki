"""Builds assets/data/world_iceborne/monsters.json from:
- Kiranico (world_raw/*.json): names en/pt-BR, habitats, breakable parts, drops+rates
- mhw-db.com (mhw_monsters.json): in-game Hunter's Notes star ratings, species, locations
- Fextralife wiki: stars of the monsters absent from mhw-db (Velkhana and Alatreon
  by hand; the others parsed from the page's "Weakness" box, feature 004)
- Kiranico hitzones: stars of elements Fextralife does not rate (hitzone rule)
- monsterhunterwiki.org: locales and classification of monsters absent from mhw-db
- Kiranico quest pages: HP targets and rewards of tempered / arch-tempered versions
"""
import json, re, datetime, urllib.error, urllib.parse
from common import REPO, clean, dataset_path, fetch, roster  # noqa: E402,F401  (sets cwd to the cache)
from kiranico_world import quest_pages, rank_of, section, tables

OUT = dataset_path('world_iceborne')
ENTRIES = list(roster('world_iceborne').values())
ORDER = [e['slug'] for e in ENTRIES if 'versionOf' not in e]
KIRANICO = 'https://mhworld.kiranico.com'
MHWIKI = 'https://monsterhunterwiki.org/wiki/'
ELEMENTS = ['fire', 'water', 'thunder', 'ice', 'dragon']
STARS = {0: 'none', 1: 'low', 2: 'medium', 3: 'high'}

MHWDB = {m['name']: m for m in json.load(open('mhw_monsters.json', encoding='utf8'))}
MHWDB_URL = 'https://mhw-db.com/monsters'
FEXTRA = 'https://monsterhunterworld.wiki.fextralife.com/'
STAR_NOTE = ("In-game Hunter's Notes star ratings; elements the notes mark with an X "
             "(no stars) are stored as 0 stars (none).")

# Fextralife (fetched 2026-09-29). "Immune" in the wiki = X in the notes -> none.
MANUAL_WEAKNESS = {
    'velkhana': {
        'general': {'fire': 3, 'water': 1, 'thunder': 2, 'ice': 0, 'dragon': 2},
        'states': [],
        'source': FEXTRA + 'Velkhana',
    },
    'alatreon': {
        # The fight starts in Dragon Active; the other two modes are states.
        'general': {'fire': 1, 'water': 1, 'thunder': 1, 'ice': 1, 'dragon': 2},
        'states': [
            ('fire-active', 'Fire Active', {'fire': 0, 'water': 2, 'thunder': 1, 'ice': 3, 'dragon': 1}),
            ('ice-active', 'Ice Active', {'fire': 3, 'water': 1, 'thunder': 2, 'ice': 0, 'dragon': 1}),
        ],
        'source': FEXTRA + 'Alatreon',
    },
}
MANUAL_HABITATS = {'alatreon': [('Secluded Valley', None, FEXTRA + 'Alatreon')]}
# pt-BR names confirmed on other Kiranico pages (Teostra expedition table).
PT_HABITAT = {"Elder's Recess": 'Fenda do Ancião'}
# Kiranico abbreviates some pt-BR part names; expanded to the full words.
PT_PART_EXPAND = {'Memb. diant': 'Membros dianteiros', 'Pernas tras': 'Pernas traseiras',
                  'Perna diant': 'Perna dianteira'}

SPECIES = {'velkhana': 'Elder Dragon', 'alatreon': 'Elder Dragon'}  # Fextralife infobox


FEXTRA_ELEMENTS = {'Fire': 'fire', 'Water': 'water', 'Thunder': 'thunder', 'Ice': 'ice', 'Dragon': 'dragon'}
HITZONE_RULE = ('Stars of elements the page does not rate: best elemental hitzone of the normal state on '
                'Kiranico, >=25 3 stars, 20-24 2, 10-19 1, <10 0.')


def fextra_stars(name):
    """{element: stars} from the Fextralife "Weakness" box; the first rating of each
    element is the normal state (later ones in parentheses are charged/crystallized
    states). Elements without a rating are missing."""
    url = FEXTRA + urllib.parse.quote(name.replace(' ', '+'))
    try:
        text = clean(fetch(url, f'fextra_{slug(name)}.html'))
    except urllib.error.HTTPError:
        return {}, url
    box = re.search(r'Weakness(.*?)Location', text)
    stars = {}
    for el, rating in re.findall(r'(Fire|Water|Thunder|Ice|Dragon)\s*(\(?\s*⭐+\s*\)?|\((?:immune|X)\))',
                                 box.group(1) if box else ''):
        stars.setdefault(FEXTRA_ELEMENTS[el], rating.count('⭐'))
    return stars, url


def hitzone_stars(page):
    """{element: stars} from the first (normal state) block of Kiranico's Physiology table."""
    best, seen = {e: 0 for e in ELEMENTS}, set()
    heads = list(re.finditer(r'<h6 class="element-header">(.*?)</h6>', page, re.S))
    i = [clean(h.group(1)) for h in heads].index('Physiology')
    for tr in re.findall(r'<tr[^>]*>(.*?)</tr>', page[heads[i].end():heads[i + 1].start()], re.S):
        cells = [clean(c) for c in re.findall(r'<td[^>]*>(.*?)</td>', tr, re.S)]
        if len(cells) < 9:
            continue
        if cells[0] in seen:
            break
        seen.add(cells[0])
        for e, v in zip(ELEMENTS, cells[4:9]):
            best[e] = max(best[e], int(v))
    return {e: 3 if v >= 25 else 2 if v >= 20 else 1 if v >= 10 else 0 for e, v in best.items()}


def wiki_page(title, cache):
    try:
        return fetch(MHWIKI + urllib.parse.quote(title), cache)
    except urllib.error.HTTPError:
        return ''


def wiki_locales(page):
    m = re.search(r'<th>Locales\s*</th></tr>\s*<tr>\s*<td[^>]*>(.*?)</td>', page, re.S)
    return [clean(a) for a in re.findall(r'<a [^>]*>(.*?)</a>', m.group(1))] if m else []


def wiki_class(page):
    m = re.search(r'Classification\s*</th>.*?<a [^>]*>(.*?)</a>', page, re.S)
    return clean(m.group(1)) if m else None


def slug(text):
    text = text.lower().replace("'", '').replace('+', '-plus')
    return re.sub(r'[^a-z0-9]+', '-', text).strip('-')


def first_tables(rank_tables):
    """Keep the first table for each title (later ones are Guiding Lands variants)."""
    seen, result = set(), []
    for t in rank_tables:
        if t['title'] in seen:
            continue
        seen.add(t['title'])
        result.append(t)
    return result


RANK = {'Low Rank': 'low', 'High Rank': 'high', 'Master Rank': 'master'}


def method_of(title, name):
    if title == 'Carves':
        return 'carve', None
    if title == 'Tail Carved':
        return 'tailCarve', None
    if title == 'Dropped Material':
        return 'droppedMaterial', None
    if title == f'Capture {name}':
        return 'capture', None
    if title == f'Hunt {name}':
        return 'questReward', None
    m = re.match(rf"Break {re.escape(name)}'s (.+)$", title)
    if m:
        return 'breakPart', m.group(1)
    return None, None  # Plunderblade, palico, tracks, Guiding Lands tiers: out of scope


def world_version(entry, materials):
    """A tempered / arch-tempered version: the rewards of its own quests, per quest."""
    drops, sources = {}, []
    for q, path, en, pt, stars in quest_pages(entry):
        rank = rank_of(stars)
        pt_name = re.sub(r'^M?★\d+ ', '', clean(re.search(r'<title>(.*?) - MH', pt).group(1)))
        label = {'en': f'Quest reward: {q["name"]}', 'ptBr': f'Prêmio da missão: {pt_name}'}
        pt_items = {r['itemId']: r['name'] for t in tables(section(pt, 'Prêmios da Missão')) for r in t['rows']}
        for t in tables(section(en, 'Quest Rewards')):
            for r in t['rows']:
                mid = slug(r['name'])
                mat = materials.setdefault(mid, {'id': mid, 'name': {'en': r['name']}})
                if r['itemId'] in pt_items:
                    mat['name']['ptBr'] = pt_items[r['itemId']]
                key = (mid, rank, label['en'])
                if key in drops:  # listed in two reward tables: independent draws
                    a, b = drops[key]['ratePercent'], r['rate']
                    drops[key]['ratePercent'] = round(100 * (1 - (1 - a / 100) * (1 - b / 100)), 2)
                else:
                    drops[key] = {'materialId': mid, 'rank': rank, 'method': 'other',
                                  'methodLabel': label, 'ratePercent': r['rate']}
        url = f'{KIRANICO}/en/quests/{path}'
        sources.append({'name': f'Kiranico (MH World: Iceborne) quest: {q["name"]}', 'url': url,
                        'notes': f'{stars} quest with {entry["name"]} (target marked on the Monster Hunter '
                                 f'Wiki quest page). Quest rewards and rates.'})
    return {
        'slug': entry['slug'],
        'versionOf': entry['versionOf'],
        'versionKind': entry['versionKind'],
        'name': {'en': entry['name']},
        'drops': list(drops.values()),
        'sources': sources,
    }


def build():
    habitats, materials, monsters = {}, {}, []
    for entry in ENTRIES:
        if entry.get('dataFrom') == 'wikiTemperedQuests':
            monsters.append(world_version(entry, materials))
            print(entry['slug'], '| drops', len(monsters[-1]['drops']))
    versions, monsters = monsters, []
    for s in ORDER:
        raw = json.load(open(f'world_raw/{s}.json', encoding='utf8'))
        raw_entry = next(e for e in ENTRIES if e['slug'] == s)
        en, pt = raw['en'], raw['pt']
        name_en, name_pt = en['title'], pt['title']
        db = MHWDB.get(name_en)
        wiki = '' if db else wiki_page(f'{raw_entry["wiki"]}_(MHWI)', f'cache_mhwiki_{s}_mhwi.html')
        sources = [{'name': 'Kiranico (MH World: Iceborne)', 'url': raw['url'],
                    'notes': 'Names (en/pt-BR), habitats (expedition locales, Guiding Lands), '
                             'breakable parts, carves, capture/break/hunt rewards and rates. '
                             'Reward quantities (e.g. x2) are not stored.'}]

        # Weaknesses
        if s in MANUAL_WEAKNESS:
            w = MANUAL_WEAKNESS[s]
            general = {e: STARS[w['general'][e]] for e in ELEMENTS}
            states = [{'id': sid, 'name': {'en': sen}, 'values': {e: STARS[v[e]] for e in ELEMENTS}}
                      for sid, sen, v in w['states']]
            sources.append({'name': 'Fextralife MHW wiki', 'url': w['source'], 'notes': STAR_NOTE})
        elif db:
            stars = {x['element']: x['stars'] for x in db['weaknesses'] if x['condition'] is None}
            general = {e: STARS[stars.get(e, 0)] for e in ELEMENTS}
            states = []
            sources.append({'name': 'mhw-db.com', 'url': MHWDB_URL, 'notes': STAR_NOTE + ' Also species and locations.'})
        else:  # not on mhw-db: Fextralife box, hitzone rule for elements it does not rate
            stars, url = fextra_stars(name_en)
            missing = [e for e in ELEMENTS if e not in stars]
            if missing:
                page = fetch(f'{KIRANICO}/en/monsters/{raw_entry["kiranicoPath"]}', f'cache_world_{s}_en.html')
                stars.update({e: v for e, v in hitzone_stars(page).items() if e in missing})
            general = {e: STARS[stars[e]] for e in ELEMENTS}
            states = []
            sources.append({'name': 'Fextralife MHW wiki', 'url': url,
                            'notes': STAR_NOTE + (f' {HITZONE_RULE} ({", ".join(missing)})' if missing else '')})

        # Habitats: Kiranico expedition locales (+pt) U mhw-db locations U Guiding Lands
        hab = []
        pt_locale = dict(zip(en['locales'], pt['locales']))
        names = list(en['locales'])
        if db:
            names += [l['name'] for l in db['locations'] if l['name'] != 'Guiding Lands']
        wiki_gl = False
        if not names and wiki:  # neither expeditions nor mhw-db: the wiki's locales
            names = [n for n in wiki_locales(wiki) if n != 'Guiding Lands']
            wiki_gl = 'Guiding Lands' in wiki_locales(wiki)
            sources.append({'name': 'Monster Hunter Wiki (MHWI)',
                            'url': MHWIKI + urllib.parse.quote(f'{raw_entry["wiki"]}_(MHWI)'),
                            'notes': 'Locales.'})
        for n in dict.fromkeys(names):
            hid = slug(n)
            habitats.setdefault(hid, {'id': hid, 'name': {'en': n}})
            if n in pt_locale or n in PT_HABITAT:
                habitats[hid]['name']['ptBr'] = pt_locale.get(n) or PT_HABITAT[n]
            hab.append(hid)
        if en['guidingLands'] or wiki_gl or (db and any(l['name'] == 'Guiding Lands' for l in db['locations'])):
            habitats.setdefault('guiding-lands', {'id': 'guiding-lands',
                                                  'name': {'en': 'The Guiding Lands', 'ptBr': 'As Terras-Guias'}})
            hab.append('guiding-lands')
        for n, npt, _src in MANUAL_HABITATS.get(s, []):
            hid = slug(n)
            habitats.setdefault(hid, {'id': hid, 'name': {'en': n, **({'ptBr': npt} if npt else {})}})
            hab.append(hid)

        # Drops + parts
        parts, drops = {}, []
        for kind in ('carves', 'rewards'):
            for (rank_label, tables_en), (_, tables_pt) in zip(en[kind], pt[kind]):
                rank = RANK[rank_label]
                # Kiranico fills ranks where the monster does not exist with a
                # dummy "Monster Bone L" table; skip them.
                if {x['name'] for t in tables_en for x in t['rows']} == {'Monster Bone L'}:
                    continue
                pt_by_title = {}
                # align pt tables by position among unique-title tables
                for t_en, t_pt in zip(tables_en, tables_pt):
                    pt_by_title.setdefault(t_en['title'], t_pt)
                for t in first_tables(tables_en):
                    method, part_en = method_of(t['title'], name_en)
                    if not method:
                        continue
                    t_pt = pt_by_title[t['title']]
                    part_id = None
                    if part_en:
                        part_id = slug(part_en)
                        part_pt = t_pt['title'].split(' - ')[0].strip()
                        part_pt = PT_PART_EXPAND.get(part_pt, part_pt)
                        parts.setdefault(part_id, {'id': part_id, 'name': {'en': part_en.capitalize(), 'ptBr': part_pt},
                                                   'severable': False})
                    if method == 'tailCarve':
                        parts.setdefault('tail', {'id': 'tail', 'name': {'en': 'Tail', 'ptBr': 'Cauda'}, 'severable': True})
                        parts['tail']['severable'] = True
                    pt_items = {r['itemId']: r['name'] for r in t_pt['rows']}
                    for r in t['rows']:
                        mid = slug(r['name'])
                        mat = materials.setdefault(mid, {'id': mid, 'name': {'en': r['name']}})
                        if r['itemId'] in pt_items:
                            mat['name']['ptBr'] = pt_items[r['itemId']]
                        d = {'materialId': mid, 'rank': rank, 'method': method}
                        if part_id:
                            d['partId'] = part_id
                        d['ratePercent'] = r['rate']
                        drops.append(d)

        # Merge duplicate rows (same material/rank/method/part appearing twice, e.g. x1 and x2 entries).
        merged = {}
        for d in drops:
            key = (d['materialId'], d['rank'], d['method'], d.get('partId'))
            if key in merged:
                merged[key]['ratePercent'] = round(merged[key]['ratePercent'] + d['ratePercent'], 2)
            else:
                merged[key] = dict(d)

        species = (SPECIES.get(s) or (db['species'].title() if db else None)
                   or wiki_class(wiki_page(raw_entry['wiki'], f'cache_mhwiki_{s}_base.html')))
        monsters.append({
            'slug': s,
            'name': {'en': name_en, 'ptBr': name_pt},
            'classification': {'en': species},
            'weaknesses': {'general': general, **({'states': states} if states else {})},
            'habitatIds': list(dict.fromkeys(hab)),
            'parts': list(parts.values()),
            'drops': list(merged.values()),
            'sources': sources,
        })

    monsters += versions
    used_h = {h for m in monsters for h in m.get('habitatIds', [])}
    used_m = {d['materialId'] for m in monsters for d in m['drops']}
    dataset = {
        'schemaVersion': 1,
        'game': 'world_iceborne',
        'generatedAt': datetime.date.today().isoformat(),
        'sources': [
            {'name': 'Kiranico (MH World: Iceborne)', 'url': 'https://mhworld.kiranico.com/',
             'notes': 'Game version shown by Kiranico: ver. 15.11. Scope: carves, tail carves, dropped '
                      'materials, capture/break/hunt rewards. Plunderblade, Bandit Mantle, palico, tracks, '
                      'investigations and Guiding Lands tier rewards are not included.'},
            {'name': 'mhw-db.com', 'url': MHWDB_URL, 'notes': STAR_NOTE},
        ],
        'habitats': [h for h in habitats.values() if h['id'] in used_h],
        'materials': sorted((m for m in materials.values() if m['id'] in used_m), key=lambda m: m['id']),
        'monsters': monsters,
    }
    json.dump(dataset, open(OUT, 'w', encoding='utf8', newline='\n'), ensure_ascii=False, indent=2)
    for m in (m for m in monsters if 'versionOf' not in m):
        print(m['slug'], m['name']['ptBr'], '|', m['classification']['en'], '| hab', m['habitatIds'],
              '| parts', [(p['id'], p['name']['ptBr'], p['severable']) for p in m['parts']],
              '| drops', len(m['drops']), '| weak', m['weaknesses']['general'])
    print('materials', len(dataset['materials']), 'habitats', [(h['id'], h['name']) for h in dataset['habitats']])


build()
