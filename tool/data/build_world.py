"""Builds assets/data/world_iceborne/monsters.json from:
- Kiranico (world_raw/*.json): names en/pt-BR, habitats, breakable parts, drops+rates
- mhw-db.com (mhw_monsters.json): in-game Hunter's Notes star ratings, species, locations
- Fextralife wiki: stars for Velkhana and Alatreon (absent from mhw-db)
"""
import json, re, datetime
from common import REPO, dataset_path  # noqa: E402,F401  (sets cwd to the cache)

OUT = dataset_path('world_iceborne')
ORDER = ['great-jagras', 'anjanath', 'rathian', 'pink-rathian', 'rathalos', 'diablos',
         'nergigante', 'zinogre', 'velkhana', 'alatreon']
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


def build():
    habitats, materials, monsters = {}, {}, []
    for s in ORDER:
        raw = json.load(open(f'world_raw/{s}.json', encoding='utf8'))
        en, pt = raw['en'], raw['pt']
        name_en, name_pt = en['title'], pt['title']
        db = MHWDB.get(name_en)
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
        else:
            stars = {x['element']: x['stars'] for x in db['weaknesses'] if x['condition'] is None}
            general = {e: STARS[stars.get(e, 0)] for e in ELEMENTS}
            states = []
            sources.append({'name': 'mhw-db.com', 'url': MHWDB_URL, 'notes': STAR_NOTE + ' Also species and locations.'})

        # Habitats: Kiranico expedition locales (+pt) U mhw-db locations U Guiding Lands
        hab = []
        pt_locale = dict(zip(en['locales'], pt['locales']))
        names = list(en['locales'])
        if db:
            names += [l['name'] for l in db['locations'] if l['name'] != 'Guiding Lands']
        for n in dict.fromkeys(names):
            hid = slug(n)
            habitats.setdefault(hid, {'id': hid, 'name': {'en': n}})
            if n in pt_locale or n in PT_HABITAT:
                habitats[hid]['name']['ptBr'] = pt_locale.get(n) or PT_HABITAT[n]
            hab.append(hid)
        if en['guidingLands'] or (db and any(l['name'] == 'Guiding Lands' for l in db['locations'])):
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

        species = SPECIES.get(s) or (db['species'].title() if db else None)
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

    used_h = {h for m in monsters for h in m['habitatIds']}
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
    for m in monsters:
        print(m['slug'], m['name']['ptBr'], '|', m['classification']['en'], '| hab', m['habitatIds'],
              '| parts', [(p['id'], p['name']['ptBr'], p['severable']) for p in m['parts']],
              '| drops', len(m['drops']), '| weak', m['weaknesses']['general'])
    print('materials', len(dataset['materials']), 'habitats', [(h['id'], h['name']) for h in dataset['habitats']])


build()
