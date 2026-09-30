"""Feature 003 T017: hunting items per dataset + item reactions per monster.

Source: Monster Hunter Wiki game pages (research R3).
- Traps (Pitfall/Shock): "Trap & Flash Pod Effectiveness" table duration.
- Flash / Sonic-Screamer / Dung: infobox row when present (World, Wilds),
  else the same table (Rise). The infobox wins on conflicts (it matches
  known game behaviour, e.g. World Rathalos ignores Screamer Pods while the
  table says ✓); conflicts are noted in the monster's wiki source.
Mapping: duration > 0 -> affects; 0s -> noEffect; '-' -> unknown;
✓ -> affects, ✓ (cond) -> conditional; ✗ -> noEffect; Dung N% > 0 -> affects.
"""
import json, os, re, time, urllib.parse, urllib.request

from item_parse import clean, infobox, item_table

from common import REPO, selected_games
UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki data curation; personal study project)'}
WIKI = 'https://monsterhunterwiki.org/wiki/'


def fetch(url, cache):
    if os.path.exists(cache):
        return open(cache, encoding='utf8').read()
    req = urllib.request.Request(url, headers=UA)
    data = urllib.request.urlopen(req, timeout=60).read().decode('utf8')
    open(cache, 'w', encoding='utf8').write(data)
    time.sleep(1.5)
    return data


def wiki_title(slug):
    return '_'.join(w.capitalize() for w in slug.split('-'))


GAMES = {
    'world_iceborne': {
        'suffix': 'MHWI',
        'cache': lambda s: f'cache_mhwiki_{s}_mhwi.html',
        'items': [
            ('flash', 'Flash Pod', 'Cápsula de Lampejo'),
            ('sonic', 'Screamer Pod', 'Cápsula de Grito'),
            ('dung', 'Dung Pod', 'Cápsula de Esterco'),
            ('pitfallTrap', 'Pitfall Trap', 'Armadilha de Poço'),
            ('shockTrap', 'Shock Trap', 'Armadilha de Choque'),
        ],
        'table': {'flash': 'Flash Pod', 'sonic': 'Sonic Pod', 'dung': 'Dung Pod'},
        'box': {'flash': 'Flash Pods', 'sonic': 'Sonic Pods', 'dung': 'Dung Pods'},
    },
    'rise_sunbreak': {
        'suffix': 'MHRS',
        'cache': lambda s: f'cache_mhwiki_{s}_mhrs.html',
        'items': [
            ('flash', 'Flash Bomb', 'Bomba de Luz'),
            ('sonic', 'Sonic Bomb', 'Bomba Sônica'),
            ('dung', 'Dung Bomb', 'Bomba de Esterco'),
            ('pitfallTrap', 'Pitfall Trap', 'Armad. de Poço'),
            ('shockTrap', 'Shock Trap', 'Armad. de Choque'),
        ],
        'table': {'flash': 'Flash Bomb', 'sonic': 'Sonic Bomb', 'dung': 'Dung Bomb'},
        'box': {},
    },
    'wilds': {
        'suffix': 'MHWilds',
        'cache': lambda s: f'cache_mhwiki_wilds_{s}.html',
        'items': [
            ('flash', 'Flash Pod', 'Cápsula de Lampejo'),
            ('sonic', 'Screamer Pod', 'Cápsula de Grito'),
            ('dung', 'Dung Pod', 'Cápsula de Esterco'),
            ('pitfallTrap', 'Pitfall Trap', 'Armadilha de Poço'),
            ('shockTrap', 'Shock Trap', 'Armadilha de Choque'),
        ],
        'table': {'flash': 'Flash Pod', 'sonic': 'Screamer Pod', 'dung': 'Dung Pod'},
        'box': {'flash': 'Flash Pods', 'sonic': 'Screamer Pods', 'dung': 'Dung Pods'},
    },
}

CONDITIONS = {}  # en condition -> pt-BR, filled after reviewing the output

# The page prose contradicts both the infobox and the table (scan of all 30
# pages for "Screamer Pod/Sonic Bomb at|on|while..." found only this one).
PROSE = {
    ('world_iceborne', 'diablos', 'sonic'): (
        {'item': 'sonic', 'effect': 'conditional',
         'detail': {'en': 'Only while burrowed: it is stunned as if in a Pitfall Trap',
                    'ptBr': 'Só quando está enterrado: fica preso como numa Armadilha de Poço'}},
        'Screamer Pod from the page text ("throwing a Screamer Pod at it while it is underground will '
        'startle it into a Pitfall Trap-like state"); the infobox says ✗.',
    ),
}


def lasts(seconds):
    return {'en': f'Lasts {seconds} s', 'ptBr': f'Dura {seconds} s'}


def from_duration(item, text):
    m = re.fullmatch(r'(\d+)s', text or '')
    if not m:
        return None  # '-' or missing -> unknown
    n = int(m.group(1))
    if n == 0:
        return {'item': item, 'effect': 'noEffect'}
    return {'item': item, 'effect': 'affects', 'detail': lasts(n)}


def from_mark(item, text, duration=None):
    if not text:
        return None
    if text.startswith('✓'):
        cond = re.search(r'\((.*)\)', text)
        if cond:
            en = cond.group(1).strip()
            return {'item': item, 'effect': 'conditional',
                    'detail': {'en': en, 'ptBr': CONDITIONS.get(en)} if CONDITIONS.get(en) else {'en': en}}
        r = {'item': item, 'effect': 'affects'}
        if duration and duration.get('effect') == 'affects':
            r['detail'] = duration['detail']
        return r
    if text.startswith('✗'):
        return {'item': item, 'effect': 'noEffect'}
    return None


def from_dung(text):
    m = re.fullmatch(r'(-?\d+)%', text or '')
    if not m or int(m.group(1)) <= 0:
        return None
    n = m.group(1)
    return {'item': 'dung', 'effect': 'affects',
            'detail': {'en': f'{n}% chance to leave', 'ptBr': f'{n}% de chance de fugir'}}


def reactions(page, cfg):
    table = {name: cells for name, cells in (item_table(page) or [])}
    box = infobox(page)
    out, conflicts = [], []

    def first(name):
        cells = table.get(name)
        return cells[0] if cells else None

    for item in ('pitfallTrap', 'shockTrap'):
        r = from_duration(item, first({'pitfallTrap': 'Pitfall Trap', 'shockTrap': 'Shock Trap'}[item]))
        if r:
            out.append(r)

    flash_t = from_duration('flash', first(cfg['table']['flash']))
    sonic_t = from_mark('sonic', first(cfg['table']['sonic']))
    dung_t = from_dung(first(cfg['table']['dung']))
    if box:
        flash = from_mark('flash', box.get(cfg['box']['flash']), flash_t)
        sonic = from_mark('sonic', box.get(cfg['box']['sonic']))
        dung = from_dung(box.get(cfg['box']['dung']))
        for label, a, b in (('Flash', flash, flash_t), ('Sonic', sonic, sonic_t), ('Dung', dung, dung_t)):
            ea, eb = (a or {}).get('effect'), (b or {}).get('effect')
            if a and b and ea != eb:
                conflicts.append(f'{label}: infobox {ea}, item table {eb}')
        flash, sonic, dung = flash or flash_t, sonic or sonic_t, dung or dung_t
    else:
        flash, sonic, dung = flash_t, sonic_t, dung_t
    out += [r for r in (flash, sonic, dung) if r]
    order = [i for i, _, _ in cfg['items']]
    out.sort(key=lambda r: order.index(r['item']))
    return out, conflicts


for game, cfg in ((g, GAMES[g]) for g in selected_games()):
    path = os.path.join(REPO, 'assets', 'data', game, 'monsters.json')
    raw = open(path, encoding='utf8', newline='').read()
    data = json.loads(raw)

    def dump(d):
        return json.dumps(d, indent=2, ensure_ascii=False)

    assert dump(data) == raw.replace('\r\n', '\n'), f'{game}: formatting would change'
    ordered = {}
    for k, v in data.items():
        if k == 'monsters':
            ordered['huntingItems'] = [
                {'id': i, 'name': {'en': en, 'ptBr': pt}} for i, en, pt in cfg['items']
            ]
        if k != 'huntingItems':
            ordered[k] = v
    data = ordered

    for monster in data['monsters']:
        slug = monster['slug']
        url = WIKI + urllib.parse.quote(f'{wiki_title(slug)}_({cfg["suffix"]})')
        page = fetch(url, cfg['cache'](slug))
        rs, conflicts = reactions(page, cfg)
        note = 'Hunting items: infobox (Flash, Sonic/Screamer, Dung) and "Trap & Flash Pod Effectiveness" table.'
        for (g, sl, item), (reaction, why) in PROSE.items():
            if (g, sl) == (game, slug):
                rs = [r for r in rs if r['item'] != item] + [reaction]
                rs.sort(key=lambda r: [i for i, _, _ in cfg['items']].index(r['item']))
                conflicts = [c for c in conflicts if not c.lower().startswith(item)]
                note += ' ' + why
        monster['itemReactions'] = rs
        if conflicts:
            note += ' Conflicts, infobox kept: ' + '; '.join(conflicts) + '.'
        src = next((s for s in monster['sources'] if s['url'] == url), None)
        if src is None:
            monster['sources'].append({'name': f'Monster Hunter Wiki ({cfg["suffix"]})', 'url': url, 'notes': note})
        else:
            base = re.sub(r'\s*Hunting items:.*$', '', src.get('notes', ''))
            src['notes'] = (base + ' ' + note).strip()
        summary = {r['item']: r['effect'] + (f" [{r['detail']['en']}]" if 'detail' in r else '') for r in rs}
        print(game, slug, summary, conflicts or '')

    open(path, 'w', encoding='utf8', newline='\n').write(dump(data))
print('ok')
