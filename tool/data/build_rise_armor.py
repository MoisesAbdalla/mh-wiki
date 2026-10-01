"""Builds assets/data/rise_sunbreak/armor.json: Rise: Sunbreak armor, skills and decorations.

    python tool/data/fetch_rise_armor_pages.py      # Kiranico lists and pages (cached)
    python tool/data/fetch_rise_item_pages.py       # material item pages (sources)
    python tool/data/build_rise_armor.py [--icons]  # --icons also fetches the piece icons

Sources (007 research R1–R5, R7):
- Kiranico armor lists, en and pt-BR: names, defense, resistances (read per element icon), slots,
  skills by id, icons;
- Kiranico armor and decoration pages: forge materials;
- Monster Hunter Wiki MHRS set pages: set, body part and max defense of each piece;
- Kiranico skills and decorations lists, en and pt-BR;
- Kiranico item pages: material sources (shared with the weapons, kiranico_items.py).
"""
import datetime
import io
import json
import os
import re
import sys
import time
import urllib.request

from common import REPO, UA, clean, dataset_path, wiki_api  # sets cwd to the cache
from kiranico_items import enrich_sources, key, material_sources, slug, wiki_item_icons

KIRANICO = 'https://mhrise.kiranico.com'
WIKI = 'https://monsterhunterwiki.org/wiki/'
OUT = os.path.join(REPO, 'assets', 'data', 'rise_sunbreak', 'armor.json')
ICON_DIR = os.path.join(REPO, 'assets', 'images', 'armor', 'rise_sunbreak')
ICON_SIZE = 96

ELEMENTS = {'1': 'fire', '2': 'water', '3': 'thunder', '4': 'ice', '5': 'dragon'}
PARTS = {'Helmet': 'head', 'Chestplate': 'chest', 'Armguards': 'arms', 'Arms': 'arms',
         'Waist': 'waist', 'Leggings': 'legs', 'Legs': 'legs'}
PART_ORDER = ['head', 'chest', 'arms', 'waist', 'legs']


def page(name, lang='en'):
    return open(f'rise_{name}{"_pt" if lang == "pt" else ""}.html', encoding='utf8').read()


def text(fragment):
    return clean(re.sub(r'<[^>]+>', ' ', fragment))


def rank_of(rarity):
    return 'low' if rarity <= 3 else 'high' if rarity <= 7 else 'master'


def localized(en, pt):
    return {'en': en, **({'ptBr': pt} if pt and pt != '' else {})}


# ---------------------------------------------------------------- Kiranico lists

def armor_rows(view, lang):
    """{kiranico id: row} from one armor list (a rarity)."""
    out = {}
    html_page = page(f'armors_v{view}', lang)
    for part in html_page.split('<tr')[1:]:
        m = re.search(r'/data/armors/(\d+)">([^<]+)</a>', part)
        if not m:
            continue
        cells = re.findall(r'<td[^>]*>(.*?)</td>', part[:part.find('</tr>')], re.S)
        slots = sorted((int(n) for n in re.findall(r'deco(\d)\.png', cells[3] if len(cells) > 3 else '')),
                       reverse=True)
        defense = re.search(r'<div>\s*(-?\d+)\s*</div>', cells[4] if len(cells) > 4 else '')
        res = {e: 0 for e in ELEMENTS.values()}
        for el, value in re.findall(r'data-key="element" data-value="(\d)".*?data-key="elementAttack" '
                                    r'data-value="(-?\d+)"', part, re.S):
            res[ELEMENTS[el]] = int(value)
        skills = [(sid, int(lv)) for sid, lv in
                  re.findall(r'/data/skills/(\d+)">[^<]+</a>\s*(?:Lv|Nv\.)\s*(\d+)', part)]
        icon = re.search(r'src="(https?://[^"]*avatar/armors/\d+_m\.webp)"', part)
        out[m.group(1)] = {'name': clean(m.group(2)), 'rarity': view + 1,
                           'defense': int(defense.group(1)) if defense else 0,
                           'resistances': res, 'slots': slots, 'skills': skills,
                           'icon': icon.group(1) if icon else None}
    return out


def skill_table():
    """{kiranico skill id: skill} from the en and pt-BR skill lists."""
    def parse(lang):
        rows = {}
        for part in page('skills', lang).split('<tr')[1:]:
            m = re.search(r'/data/skills/(\d+)"', part)
            if not m:
                continue
            ps = [text(p) for p in re.findall(r'<p[^>]*>(.*?)</p>', part, re.S)]
            name = ps[0] if ps else ''
            levels = [re.sub(r'^(?:Lv|Nv\.)\s*\d+\s*', '', p) for p in ps if re.match(r'(Lv|Nv\.)\s*\d+', p)]
            desc = next((p for p in ps[1:] if p and not re.match(r'(Lv|Nv\.)\s*\d+', p)), '')
            rows[m.group(1)] = {'name': name, 'description': desc, 'levels': levels}
        return rows
    en, pt = parse('en'), parse('pt')
    wiki = wiki_skill_levels([s['name'] for s in en.values() if not s['levels']])
    for s in en.values():
        if not s['levels'] and s['name'] in wiki:
            s['levels'] = wiki[s['name']]
    out = {}
    for sid, s in en.items():
        p = pt.get(sid, {})
        pl = p.get('levels') or []
        out[sid] = {
            'id': slug(s['name']),
            'name': localized(s['name'], p.get('name')),
            'description': localized(s['description'], p.get('description')),
            'levels': [{'level': i + 1, 'effect': localized(e, pl[i] if i < len(pl) else None)}
                       for i, e in enumerate(s['levels'])],
        }
    return out


def wiki_skill_levels(names):
    """{skill en name: [level effect, ...]} from the MHRS skill pages of the wiki, for the skills
    whose Kiranico list has no level text (the Sunbreak additions, 007 research R4)."""
    titles = sorted({f'{n} (MHRS)' for n in names})
    out = {}
    for i in range(0, len(titles), 40):
        d = wiki_api({'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
                      'redirects': 1, 'titles': '|'.join(titles[i:i + 40])},
                     f'wiki_mhrs_skills_{i // 40}.json')
        for p in d['query']['pages'].values():
            if 'revisions' not in p:
                continue
            body = p['revisions'][0]['slots']['main']['*']
            table = body[body.find('Level Description'):]
            table = table[:table.find('|}')]
            levels = re.findall(r'^\|\s*(\d+)\s*\n\|\s*(.+)$', table, re.M)
            if levels:
                # [[Link|Text]] and [[Text]] keep only the shown text.
                out[p['title'].replace(' (MHRS)', '')] = [
                    clean(re.sub(r'\[\[(?:[^|\]]*\|)?([^\]]*)\]\]', r'\1', t)) for _, t in levels]
    return out


def decoration_table():
    """{kiranico decoration id: decoration} from the en and pt-BR lists."""
    def parse(lang):
        rows = {}
        for part in page('decorations', lang).split('<tr')[1:]:
            m = re.search(r'/data/decorations/(\d+)">([^<]+)</a>', part)
            if not m:
                continue
            skills = [(sid, int(lv)) for sid, lv in
                      re.findall(r'/data/skills/(\d+)">[^<]+</a>\s*(?:Lv|Nv\.)\s*(\d+)', part)]
            rows[m.group(1)] = {'name': clean(m.group(2)), 'skills': skills}
        return rows
    return parse('en'), parse('pt')


def forge_items(cache):
    """[(item id, en name, quantity)] from a cached Kiranico armor or decoration page."""
    if not os.path.exists(cache):
        return None
    t = open(cache, encoding='utf8').read()
    i = t.find('Forging Materials')
    j = t.find('</article>', i)
    if i < 0:
        return []
    return [(iid, clean(n), int(q)) for iid, n, q in re.findall(
        r'/data/items/(\d+)">(.*?)</a></td>\s*<td[^>]*>x(\d+)</td>', t[i:j], re.S)]


def item_pt_name(item_id):
    path = f'kiranico_item_{item_id}_pt.html'
    if not os.path.exists(path):
        return None
    m = re.search(r'<title>(.*?) \|', open(path, encoding='utf8').read(), re.S)
    return clean(m.group(1)) if m else None


# ---------------------------------------------------------------- wiki sets

def wiki_sets(piece_names):
    """{piece en name: (set name, part, max defense, set rarity)} from the MHRS set pages."""
    titles = sorted({f'{n} (MHRS)' for n in piece_names})
    redirects = {}
    for i in range(0, len(titles), 50):
        d = wiki_api({'action': 'query', 'titles': '|'.join(titles[i:i + 50]), 'redirects': 1},
                     f'wiki_mhrs_armor_redirects_{i // 50}.json')
        for r in d['query'].get('redirects', []):
            redirects[r['from']] = r['to']
    set_titles = sorted(set(redirects.values()))
    out = {}
    for i in range(0, len(set_titles), 40):
        d = wiki_api({'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
                      'titles': '|'.join(set_titles[i:i + 40])}, f'wiki_mhrs_armor_sets_{i // 40}.json')
        for p in d['query']['pages'].values():
            if 'revisions' not in p:
                continue
            body = p['revisions'][0]['slots']['main']['*']
            set_name = re.search(r'\|\s*Set Name\s*=\s*(.+)', body)
            set_rarity = re.search(r'\|\s*Set Rarity\s*=\s*(\d+)', body)
            for block in re.findall(r'\{\{GenericArmorSetPiece(.*?)\n\}\}', body, re.S):
                f = dict((k.strip(), v.strip()) for k, v in re.findall(r'^\|\s*([^=\n]+?)\s*=(.*)$', block, re.M))
                name = f.get('Piece Name')
                if not name:
                    continue
                max_def = re.search(r'→\s*(\d+)', f.get('Defense', ''))
                out[name] = (clean(set_name.group(1)) if set_name else p['title'].replace(' Set (MHRS)', ''),
                             PARTS.get(f.get('Item Icon Type', '')),
                             int(max_def.group(1)) if max_def else None,
                             int(set_rarity.group(1)) if set_rarity else None)
    return out


# Last word of a piece name → body part, for the few pieces without a wiki set page (R3).
NAME_PARTS = {'mask': 'head', 'cap': 'head', 'helm': 'head', 'suit': 'chest', 'jersey': 'chest',
              'mail': 'chest', 'braces': 'arms', 'gloves': 'arms', 'vambraces': 'arms', 'belt': 'waist',
              'tail': 'waist', 'coil': 'waist', 'boots': 'legs', 'shoes': 'legs', 'greaves': 'legs'}


def name_set(name):
    """(set name, part, None, None) from the piece name alone, or None."""
    words = name.split()
    part = NAME_PARTS.get(words[-1].lower()) if len(words) > 1 else None
    return (' '.join(words[:-1]), part, None, None) if part else None


def pt_set_name(pt_names, en_name):
    """Longest common word suffix of the pt-BR piece names, without a leading de/do/da (R3)."""
    names = [n.split() for n in pt_names if n]
    if len(names) == 1 and len(pt_names) == 1:
        return ' '.join(names[0])  # a one-piece set is named after its piece
    if len(names) < 2:
        return None
    suffix = []
    for words in zip(*(reversed(n) for n in names)):
        if len(set(words)) != 1:
            break
        suffix.insert(0, words[0])
    while suffix and suffix[0].lower() in ('de', 'do', 'da', 'dos', 'das'):
        suffix.pop(0)
    # Keep the rank letter of "Chaos S" / "Rathalos X" when the pt-BR names drop it.
    rank_mark = en_name.split()[-1] if en_name.split()[-1] in ('S', 'X') else None
    if suffix and rank_mark and suffix[-1] != rank_mark:
        suffix.append(rank_mark)
    return ' '.join(suffix) or None


# ---------------------------------------------------------------- build

def main():
    with_icons = '--icons' in sys.argv
    report = []
    monsters = json.load(open(dataset_path('rise_sunbreak'), encoding='utf8'))['monsters']
    large = {key(m['name']['en']): m['slug'] for m in monsters}

    rows, pt_rows = {}, {}
    for view in range(10):
        rows.update(armor_rows(view, 'en'))
        pt_rows.update(armor_rows(view, 'pt'))
    kept = {kid: r for kid, r in rows.items()
            if r['defense'] > 0 or r['skills'] or any(r['resistances'].values())}
    report += [f'dropped (cut): {r["name"]}' for kid, r in rows.items() if kid not in kept]

    sets_of = wiki_sets([r['name'] for r in kept.values()])
    skills = skill_table()
    deco_en, deco_pt = decoration_table()

    item_names = set()
    for kid in kept:
        item_names |= {n for _, n, _ in (forge_items(f'kiranico_armor_{kid}.html') or [])}
    for did in deco_en:
        item_names |= {n for _, n, _ in (forge_items(f'kiranico_decoration_{did}.html') or [])}
    icons = wiki_item_icons(item_names)
    materials = {}

    def costs(items):
        out = []
        for iid, name, qty in items:
            mid = slug(name)
            if mid not in materials:
                entry = {'id': mid, 'name': localized(name, item_pt_name(iid))}
                src = enrich_sources(material_sources(iid, large), iid, icons.get(name))
                if src:
                    entry['sources'] = src
                materials[mid] = entry
            out.append({'material': mid, 'quantity': qty})
        return out

    pieces, by_set = [], {}
    used_slugs = {}
    for kid, r in kept.items():
        info = sets_of.get(r['name']) or name_set(r['name'])
        if not info or not info[1]:
            report.append(f'no wiki set/part: {r["name"]}')
            continue
        if r['name'] not in sets_of:
            report.append(f'set by name (no wiki page): {r["name"]} -> {info[0]}')
        set_name, part, max_def, _ = info
        pid = slug(r['name'])
        if pid in used_slugs:
            pid = f'{pid}-{kid}'
        used_slugs[pid] = kid
        items = forge_items(f'kiranico_armor_{kid}.html')
        if items is None:
            report.append(f'no armor page: {r["name"]}')
            items = []
        piece = {
            'id': pid, 'kiranicoId': kid, 'set': slug(set_name), 'part': part,
            'name': localized(r['name'], pt_rows.get(kid, {}).get('name')),
            'rarity': r['rarity'], 'defense': r['defense'],
            **({'maxDefense': max_def} if max_def and max_def >= r['defense'] else {}),
            'resistances': r['resistances'], 'slots': r['slots'][:3],
            'skills': [{'skill': skills[sid]['id'], 'level': lv} for sid, lv in r['skills'] if sid in skills],
            'forge': costs(items),
            'sources': [
                {'name': 'Kiranico (MH Rise: Sunbreak)', 'url': f'{KIRANICO}/data/armors/{kid}'},
                {'name': 'Monster Hunter Wiki (MHRS)', 'url': WIKI + f'{set_name} Set (MHRS)'.replace(' ', '_')},
            ],
            '_icon': r['icon'],
        }
        missing = [sid for sid, _ in r['skills'] if sid not in skills]
        report += [f'unknown skill {sid} on {r["name"]}' for sid in missing]
        pieces.append(piece)
        by_set.setdefault(piece['set'], {'name': set_name, 'pieces': []})['pieces'].append(piece)

    sets = []
    for sid, s in sorted(by_set.items()):
        ps = sorted(s['pieces'], key=lambda p: (PART_ORDER.index(p['part']), p['rarity']))
        rarity = max(p['rarity'] for p in ps)
        sets.append({'id': sid,
                     'name': localized(s['name'], pt_set_name([p['name'].get('ptBr') for p in ps], s['name'])),
                     'rarity': rarity, 'rank': rank_of(rarity), 'pieces': [p['id'] for p in ps]})

    decorations = []
    for did, d in deco_en.items():
        name = d['name']
        level = re.search(r'(\d)\s*$', name)
        items = forge_items(f'kiranico_decoration_{did}.html') or []
        decorations.append({
            'id': slug(name), 'kiranicoId': did,
            'name': localized(name, deco_pt.get(did, {}).get('name')),
            'slotLevel': int(level.group(1)) if level else 1,
            'skills': [{'skill': skills[sid]['id'], 'level': lv} for sid, lv in d['skills'] if sid in skills],
            'forge': costs(items),
        })

    if with_icons:
        fetch_icons(pieces)
    for p in pieces:
        p.pop('_icon')
        path = os.path.join(ICON_DIR, f'{p["id"]}.webp')
        if os.path.exists(path):
            p['image'] = f'assets/images/armor/rise_sunbreak/{p["id"]}.webp'

    used = {c['material'] for x in pieces + decorations for c in x['forge']}
    dataset = {
        'schemaVersion': 1,
        'game': 'rise_sunbreak',
        'generatedAt': datetime.date.today().isoformat(),
        'sources': [
            {'name': 'Kiranico (MH Rise: Sunbreak)', 'url': f'{KIRANICO}/data/armors',
             'notes': 'Armor lists (en, pt-BR): defense, resistances, slots, skills, icons; armor and '
                      'decoration pages: forge materials; skills and decorations lists; item pages: '
                      'material sources.'},
            {'name': 'Monster Hunter Wiki (MHRS)', 'url': WIKI + 'MHRS/Armor',
             'notes': 'Set pages: set, body part and max defense of each piece.'},
        ],
        'skills': sorted(skills.values(), key=lambda s: s['id']),
        'decorations': sorted(decorations, key=lambda d: (d['slotLevel'], d['id'])),
        'materials': sorted((m for m in materials.values() if m['id'] in used), key=lambda m: m['id']),
        'sets': sets,
        'pieces': pieces,
    }
    with open(OUT, 'w', encoding='utf8', newline='\n') as fh:
        json.dump(dataset, fh, ensure_ascii=False, indent=1)
        fh.write('\n')
    by_rarity = {}
    for p in pieces:
        by_rarity[p['rarity']] = by_rarity.get(p['rarity'], 0) + 1
    print('pieces', len(pieces), 'sets', len(sets), 'skills', len(skills), 'decorations', len(decorations),
          'materials', len(dataset['materials']), 'with image', sum(1 for p in pieces if 'image' in p))
    print('by rarity', dict(sorted(by_rarity.items())))
    print('report', len(report))
    with open('rise_armor_report.txt', 'w', encoding='utf8') as fh:
        fh.write('\n'.join(report) + '\n')


def fetch_icons(pieces):
    from PIL import Image
    os.makedirs(ICON_DIR, exist_ok=True)
    os.makedirs('armor_icons', exist_ok=True)
    for i, p in enumerate(pieces):
        out = os.path.join(ICON_DIR, f'{p["id"]}.webp')
        if os.path.exists(out) or not p['_icon']:
            continue
        cache = os.path.join('armor_icons', p['_icon'].rsplit('/', 1)[1])
        if not os.path.exists(cache):
            try:
                req = urllib.request.Request(p['_icon'].replace('http://', 'https://'), headers=UA)
                open(cache, 'wb').write(urllib.request.urlopen(req, timeout=60).read())
            except Exception as e:  # noqa: BLE001 - a missing icon falls back to the part glyph
                print('icon failed', p['id'], e)
                continue
            time.sleep(0.3)
        im = Image.open(cache).convert('RGBA')
        im.thumbnail((ICON_SIZE, ICON_SIZE), Image.LANCZOS)
        canvas = Image.new('RGBA', (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
        canvas.paste(im, ((ICON_SIZE - im.width) // 2, (ICON_SIZE - im.height) // 2), im)
        canvas.save(out, 'WEBP', quality=82, method=6)
        if i % 250 == 0:
            print('icons', i, flush=True)


if __name__ == '__main__':
    main()
