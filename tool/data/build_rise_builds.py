"""Builds assets/data/rise_sunbreak/builds.json: curated Rise: Sunbreak builds from Game8.

    python tool/data/build_rise_builds.py

Reads the Game8 build pages of the 14 weapon types (Master Rank, plus High and Low Rank of base
Rise), cached and fetched one at a time (008 research R1). Parses every build's tables (R2), maps
its stage to the app's progress scale (R3), and matches each item to our weapons and armor
datasets, taking their ids and en/pt-BR names (R4). Unmatched items are kept by name and written
to rise_builds_report.txt.
"""
import datetime
import html
import json
import os
import re
import time
import unicodedata

from common import REPO, fetch
from kiranico_items import slug

GAME8 = 'https://game8.co/games/Monster-Hunter-Rise/archives/'
OUT = os.path.join(REPO, 'assets', 'data', 'rise_sunbreak', 'builds.json')

MASTER = {'great-sword': 380791, 'long-sword': 380797, 'sword-and-shield': 380795, 'dual-blades': 380777,
          'hammer': 380793, 'hunting-horn': 380800, 'lance': 380801, 'gunlance': 380802,
          'switch-axe': 381141, 'charge-blade': 380792, 'insect-glaive': 380810, 'bow': 380805,
          'light-bowgun': 381282, 'heavy-bowgun': 381358}
# High/Low Rank pages of base Rise, classified by their <title> (R1).
BASE_PAGES = [339296, 341257, 341258, 341261, 341612, 341613, 341616, 341738, 341741, 341812, 341813,
              341918, 341921, 341922, 341931, 341932, 341977, 341978, 341982, 341983, 341984, 341985,
              341988, 341989, 341991, 341992, 341993, 341997]
TYPE_NAMES = {'Great Sword': 'great-sword', 'Long Sword': 'long-sword', 'Sword and Shield': 'sword-and-shield',
              'Dual Blades': 'dual-blades', 'Hammer': 'hammer', 'Hunting Horn': 'hunting-horn',
              'Lance': 'lance', 'Gunlance': 'gunlance', 'Switch Axe': 'switch-axe',
              'Charge Blade': 'charge-blade', 'Insect Glaive': 'insect-glaive', 'Bow': 'bow',
              'Light Bowgun': 'light-bowgun', 'Heavy Bowgun': 'heavy-bowgun'}
BANDS = [10, 50, 100, 140, 180]


def page(pid):
    path = f'game8_{pid}.html'
    fresh = not os.path.exists(path)
    text = fetch(GAME8 + str(pid), path)
    if fresh:
        time.sleep(1)  # one request at a time, gently
    return re.sub(r'<script.*?</script>', '', text, flags=re.S)


def cell_text(c):
    c = re.sub(r"<img[^>]+alt=['\"]([^'\"]*)['\"][^>]*>", lambda m: ' [' + m.group(1) + '] ', c)
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', c))).strip()


def rows(table):
    return [[cell_text(c) for c in re.findall(r'<t[dh][^>]*>(.*?)</t[dh]>', r, re.S)]
            for r in re.findall(r'<tr.*?</tr>', table, re.S)]


def plain(fragment):
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', fragment))).strip()


def key(name):
    """Join key: no accents, case, punctuation or possessive "'s" ("Channeler's" = "Channeler")."""
    text = unicodedata.normalize('NFKD', name.replace('’', "'")).encode('ascii', 'ignore').decode()
    text = re.sub(r"'s\b", '', text.lower().replace('lv.', 'lv'))
    return re.sub(r'[^a-z0-9+]', '', text)


# ---------------------------------------------------------------- stages (R3)

def stage_of(label):
    """(rank, step) for a stage label, or None."""
    m = re.search(r'MR ?(\d+)', label)
    if m:
        n = int(m.group(1))
        if n <= 6:
            return 'master', f'M{max(n, 1)}'
        return 'post', str(max(b for b in BANDS if b <= n))
    m = re.search(r'Hub HR (\d)', label)
    if m:
        return 'high', str(min(max(int(m.group(1)), 4), 7))
    m = re.search(r'HR ?(\d+)', label)
    if m:
        # HR levels above the story cap (HR 8+) come after the 7★ quests.
        return 'high', '7' if int(m.group(1)) >= 8 else '4'
    m = re.search(r'★ ?(\d)', label)
    if m and ('Village' in label or 'Low Rank' in label):
        village = int(m.group(1))
        return 'low', '1' if village <= 3 else '2' if village <= 5 else '3'
    if 'Low Rank' in label:
        return 'low', '1'
    return None


# ---------------------------------------------------------------- catalog

def load_catalog():
    w = json.load(open(os.path.join(REPO, 'assets/data/rise_sunbreak/weapons.json'), encoding='utf8'))
    a = json.load(open(os.path.join(REPO, 'assets/data/rise_sunbreak/armor.json'), encoding='utf8'))
    by = {'weapon': {}, 'piece': {}, 'decoration': {}, 'skill': {}, 'rampage': {}}
    for x in w['weapons']:
        by['weapon'][key(x['name']['en'])] = (x['slug'], x['name'])
    for x in a['pieces']:
        by['piece'][key(x['name']['en'])] = (x['id'], x['name'], x['part'])
    for x in a['decorations']:
        by['decoration'][key(x['name']['en'])] = (x['id'], x['name'], x['slotLevel'])
    for x in a['skills']:
        by['skill'][key(x['name']['en'])] = (x['id'], x['name'], len(x['levels']))
    for x in w.get('rampageSkills', []):
        by['rampage'][key(x['name']['en'])] = (x['id'], x['name'])
    for x in w.get('rampageDecorations', []):
        by['decoration'].setdefault(key(x['name']['en']), (x['id'], x['name'], x['slotLevel']))
    return by


class Matcher:
    def __init__(self, catalog):
        self.catalog = catalog
        self.missing = []

    def ref(self, kind, name, where):
        name = name.strip()
        k = ALIASES.get(key(name), key(name))
        hit = self.catalog[kind].get(k)
        if not hit and kind == 'weapon':
            # Game8 drops a trailing "+" now and then.
            hit = self.catalog[kind].get(k + '+')
        if not hit and kind == 'piece':
            # base-Rise guides name High Rank pieces without their "S".
            hit = self.catalog[kind].get(k + 's')
        if not hit:
            self.missing.append(f'{where}: {kind} "{name}"')
            return {'name': {'en': name}, 'kind': kind}
        return {'id': hit[0], 'name': hit[1], 'kind': kind}


# ---------------------------------------------------------------- parsing (R2)

def visible(cell):
    """The cell's own text, without the [image alt] parts (alts cut at apostrophes)."""
    return re.sub(r'\s+', ' ', re.sub(r'\[[^\]]*\]', ' ', cell)).strip()


# Game8 spellings → catalog spellings.
ALIASES = {'quicksheath': 'quicksheathe', 'masterstouch': 'mastertouch', 'spiribirdscall': 'spiribirdcall',
           'stunresist': 'stunresistance'}
NOT_PIECES = ('Alternative', 'Other Notes', 'Rampage Decoration', 'Decoration', 'Weapon Augment',
              'Armor Augment', 'Notes')


def decos(text):
    return [n.strip() for n in re.findall(r'\[MH Rise - ([^\]]+)\]', text)]


def parse_build(name, tables, ctx, m):
    """One build from its tables (a weapon table first), or None."""
    weapon = pieces = talisman = None
    skills, rampage, totals = [], [], []
    pieces = []
    for tb in tables:
        rs = [r for r in rows(tb) if r]
        if not rs:
            continue
        head = rs[0][0]
        if head == 'Weapon':
            wname = visible(rs[1][0]) if len(rs) > 1 else ''
            wname = re.sub(r'\s*(Great Sword|Long Sword|Sword and Shield|Dual Blades|Hammer|Hunting Horn|'
                           r'Lance|Gunlance|Switch Axe|Charge Blade|Insect Glaive|Bow|Light Bowgun|'
                           r'Heavy Bowgun)?\s*Sharpness$', '', wname).strip()
            if not wname:
                return None
            wdecos, wramp = [], []
            for r in rs:
                if r and decos(' '.join(r)) and len(r) <= 2 and 'MH Rise' in r[0] + (r[1] if len(r) > 1 else ''):
                    wdecos = decos(r[0])
                    wramp = decos(r[1]) if len(r) > 1 else []
            weapon = {'ref': m.ref('weapon', wname, ctx), 'decorations': [m.ref('decoration', d, ctx) for d in wdecos]}
            if wramp:
                weapon['rampageDecorations'] = [m.ref('decoration', d, ctx) for d in wramp]
        elif head == 'Armor':
            in_decos = False
            for r in rs[1:]:
                if not r:
                    continue
                first = r[0]
                if first.startswith('Decorations'):
                    in_decos = True
                    if len(r) > 1:
                        totals += re.findall(r'([A-Z][^\[\]]*?Jewel\+? ?\d) ?x ?(\d+)', ' '.join(r[1:]))
                    continue
                if in_decos:
                    totals += re.findall(r'([A-Z][^\[\]]*?Jewel\+? ?\d) ?x ?(\d+)', ' '.join(r))
                    continue
                if 'Talisman' in first:
                    req = r[-1]
                    sk = re.match(r"([A-Za-z'\- /()]+?)(?:\s+Lv\.?\s*\d|\s+\d|\s*・|\s+with\b|\s+and\b|$)", req)
                    level = re.search(r'Level (\d)|Lv\.? ?(\d)', req)
                    talisman = {
                        'skill': m.ref('skill', sk.group(1) if sk else req, ctx),
                        'level': int(next(g for g in level.groups() if g)) if level else 1,
                        'note': req,
                        'decorations': [m.ref('decoration', d, ctx) for d in decos(r[1])] if len(r) > 2 else [],
                    }
                    continue
                if not first.startswith('[') or visible(first).startswith(NOT_PIECES):
                    continue
                pname = visible(first)
                # A decoration list printed as a row ("Attack Jewel 2 x3 ...").
                if re.search(r'Jewel \d x\d', pname):
                    continue
                names = [n.strip() for n in pname.split('/') if n.strip()]
                # "Virtue / Prudence Coil": the last word belongs to every name.
                last = names[-1].split()
                if len(names) > 1 and len(last) > 1:
                    names = [n if len(n.split()) > 1 else f'{n} {last[-1]}' for n in names]
                refs = [m.ref('piece', n, ctx) for n in names]
                part = None
                for n in names:
                    hit = m.catalog['piece'].get(key(n))
                    if hit:
                        part = hit[2]
                        break
                if part and any(p['part'] == part for p in pieces):
                    print(f'  ! {ctx}: second {part} piece "{pname}" dropped')
                    continue
                pieces.append({'part': part, 'item': {'ref': refs[0],
                                                      'decorations': [m.ref('decoration', d, ctx) for d in decos(r[1])] if len(r) > 2 else []},
                               'alternatives': refs[1:]})
        elif head.startswith('Skills') or head == 'Skills':
            for r in rs:
                if not r:
                    continue
                if r[0].startswith('Rampage Skills') and len(r) > 1:
                    text = r[1].split('・')[0]
                    for rk, (rid, rname) in m.catalog['rampage'].items():
                        if rname['en'] in text:
                            rampage.append({'id': rid, 'name': rname, 'kind': 'rampage'})
                    continue
                text = ' '.join(r[1:] if r[0].startswith('Skills') and len(r) > 1 else r)
                for sname, lv in re.findall(r"([A-Z][A-Za-z'\-/ ]*?)\s+Lv\.?\s?(\d+)", text.replace('|', ' ')):
                    if sname.strip() in ('Decorations', 'Skills'):
                        continue
                    ref = m.ref('skill', sname.strip(), ctx)
                    hit = m.catalog['skill'].get(key(sname))
                    skills.append({'skill': ref, 'level': int(lv), 'maxLevel': hit[2] if hit else int(lv)})
        elif head == 'Decorations':
            for r in rs[1:]:
                totals += re.findall(r'([A-Z][^\[\]]*?Jewel\+? ?\d) ?x ?(\d+)', ' '.join(r))
    if not weapon or not pieces:
        return None

    # Decoration totals: from the slots when the guide gives them, else its own list.
    count = {}
    if any(p['item']['decorations'] for p in pieces) or weapon['decorations']:
        for item in [weapon] + [p['item'] for p in pieces] + ([talisman] if talisman else []):
            for d in item['decorations']:
                k = d['name']['en']
                count[k] = (d, count.get(k, (d, 0))[1] + 1)
    else:
        for n, c in totals:
            d = m.ref('decoration', n.strip(), ctx)
            count[d['name']['en']] = (d, count.get(d['name']['en'], (d, 0))[1] + int(c))
    return {'weapon': weapon, 'pieces': pieces, 'talisman': talisman, 'skills': skills,
            'rampage': rampage, 'decorations': [{'decoration': d, 'count': c} for d, c in count.values()]}


def builds_of(pid, type_id, m, report):
    t = page(pid)
    title = re.search(r'<title>(.*?)\s*\|', t, re.S)
    url = GAME8 + str(pid)
    # The progression table of Master Rank pages gives each build's own MR level.
    own = {}
    i = t.find('Builds List')
    if i > 0:
        tb = re.findall(r'<table.*?</table>', t[i:i + 30000], re.S)
        for r in rows(tb[0])[1:] if tb else []:
            if len(r) >= 3 and r[0].startswith('MR'):
                own[r[2]] = r[0]
    out = []
    sections = re.split(r'<h2[^>]*>', t)
    for sec in sections[1:]:
        head = plain(sec[:sec.find('</h2>')])
        if head.startswith(('Best Skills', 'Monster Hunter', 'Comment', 'Author')):
            break
        sec_stage = stage_of(head)
        if not sec_stage:
            continue
        parts = re.split(r'(<h3[^>]*>.*?</h3>)', sec, flags=re.S)
        for j in range(1, len(parts), 2):
            name = plain(parts[j])
            body = parts[j + 1] if j + 1 < len(parts) else ''
            tables = re.findall(r'<table.*?</table>', body, re.S)
            # A heading with several weapon tables holds variants (one per element).
            groups, cur = [], []
            for tb in tables:
                rs = rows(tb)
                if rs and rs[0] and rs[0][0] == 'Weapon' and cur:
                    groups.append(cur)
                    cur = []
                cur.append(tb)
            if cur:
                groups.append(cur)
            for g in groups:
                ctx = f'{type_id} / {name}'
                b = parse_build(name, g, ctx, m)
                if not b:
                    continue
                label, stage = head, sec_stage
                best = max(own, key=lambda o: overlap(o, name), default=None)
                if best and overlap(best, name) >= 0.5:
                    label = own[best]
                    stage = stage_of(label) or sec_stage
                bname = name if len(groups) == 1 else f'{name} ({b["weapon"]["ref"]["name"]["en"]})'
                out.append({'name': bname, 'weaponType': type_id,
                            'stage': {'label': re.sub(r'^.*?:\s*', '', label) if ':' in label else label,
                                      'rank': stage[0], 'step': stage[1]},
                            **b, 'source': {'name': 'Game8', 'url': url}})
    if not out:
        report.append(f'no builds parsed: {pid} {title.group(1) if title else ""}')
    return out


def overlap(a, b):
    wa, wb = set(re.findall(r'[a-z]+', a.lower())), set(re.findall(r'[a-z]+', b.lower()))
    wa -= {'build', 'gs', 'db', 'tu', 'bu'}
    wb -= {'build', 'gs', 'db', 'tu', 'bu'}
    return len(wa & wb) / max(1, min(len(wa), len(wb)))


def main():
    report = []
    m = Matcher(load_catalog())
    builds = []
    for type_id, pid in MASTER.items():
        builds += builds_of(pid, type_id, m, report)
    for pid in BASE_PAGES:
        t = page(pid)
        title = re.search(r'<title>(?:High|Low) Rank (.*?) Builds', t)
        type_id = TYPE_NAMES.get(title.group(1).strip()) if title else None
        if not type_id:
            report.append(f'unknown page {pid}')
            continue
        builds += builds_of(pid, type_id, m, report)

    ids = {}
    for b in builds:
        bid = slug(f'{b["weaponType"]} {b["name"]}')
        ids[bid] = ids.get(bid, 0) + 1
        b['id'] = bid if ids[bid] == 1 else f'{bid}-{ids[bid]}'
    dataset = {
        'schemaVersion': 1,
        'game': 'rise_sunbreak',
        'generatedAt': datetime.date.today().isoformat(),
        'sources': [{'name': 'Game8', 'url': GAME8 + '325380',
                     'notes': 'Build guides per weapon type (Master Rank, High Rank and Low Rank). '
                              'Only the build composition is kept, with a link to each page.'}],
        'builds': [{'id': b.pop('id'), **b} for b in builds],
    }
    with open(OUT, 'w', encoding='utf8', newline='\n') as fh:
        json.dump(dataset, fh, ensure_ascii=False, indent=1)
        fh.write('\n')
    refs = [r for b in dataset['builds'] for r in iter_refs(b)]
    known = sum(1 for r in refs if 'id' in r)
    per = {}
    for b in dataset['builds']:
        per.setdefault(b['weaponType'], {}).setdefault(b['stage']['rank'], 0)
        per[b['weaponType']][b['stage']['rank']] += 1
    print('builds', len(dataset['builds']), 'refs', len(refs), 'matched', f'{known / max(1, len(refs)):.1%}')
    for k, v in per.items():
        print(' ', k, v)
    with open('rise_builds_report.txt', 'w', encoding='utf8') as fh:
        fh.write('\n'.join(report + sorted(set(m.missing))) + '\n')
    print('report', len(report), 'missing', len(set(m.missing)))


def iter_refs(b):
    yield b['weapon']['ref']
    yield from b['weapon']['decorations']
    for p in b['pieces']:
        yield p['item']['ref']
        yield from p['item']['decorations']
        yield from p['alternatives']
    if b['talisman']:
        yield b['talisman']['skill']
        yield from b['talisman']['decorations']
    for s in b['skills']:
        yield s['skill']


if __name__ == '__main__':
    main()
