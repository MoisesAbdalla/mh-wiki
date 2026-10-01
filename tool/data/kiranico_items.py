"""Shared Kiranico item helpers: names to slugs and keys, and where a material comes from.

Used by build_rise_weapons.py (006) and build_rise_armor.py (007 research R5). The item pages
are cached by fetch_rise_item_pages.py.
"""
import html
import os
import re
import unicodedata

from common import clean


def slug(text):
    text = text.lower().replace("'", '').replace('+', '-plus')
    return re.sub(r'[^a-z0-9]+', '-', text).strip('-')


def key(name):
    """Join key for names across sources (case, accents and punctuation removed)."""
    text = unicodedata.normalize('NFKD', html.unescape(name)).encode('ascii', 'ignore').decode()
    return re.sub(r'[^a-z0-9+]', '', text.lower())


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
