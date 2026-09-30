"""Feature 003 T011: solo HP per rank + party HP factors into the datasets.

Rules (research R1/R2, refined during implementation):
- World: Kiranico "Expeditions" (lowest per rank, basis expedition); ranks
  without expeditions fall back to the "Quest" table (star prefix: 1-5 LR,
  6-9 HR, M MR; arena/challenge excluded), basis minQuest.
- Rise: Kiranico monster page quest table (players = 1 row): Village (LR),
  Gathering Hub 1-3 (LR) / 4-7 (HR), MR (MR); first (lowest) HP variant.
- Wilds: Kiranico /data/quests (Assignments/Optional): 1-3 LR, 4+ HR.
- minQuest = lowest HP after dropping values under 80% of the rank median
  (multi-monster/special quest variants).
"""
import html, json, os, re, statistics, sys

from common import REPO, selected_games


def clean(t):
    return html.unescape(re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', t))).strip()


def num(s):
    return int(s.replace(',', ''))


def section(page, header):
    heads = list(re.finditer(r'<h6 class="element-header">(.*?)</h6>', page, re.S))
    for i, m in enumerate(heads):
        if clean(m.group(1)) == header:
            end = heads[i + 1].start() if i + 1 < len(heads) else len(page)
            return page[m.end():end]
    return ''


def min_quest(values):
    if not values:
        return None
    med = statistics.median(values)
    return min(v for v in values if v >= 0.8 * med)


def world(slug):
    page = open(f'cache_world_{slug}_en.html', encoding='utf8').read()
    exp = {}
    for tr in re.findall(r'<tr.*?</tr>', section(page, 'Expeditions'), re.S):
        m = re.match(r'(Low|High|Master) Rank .*? (\d[\d,]*) x', clean(tr))
        if m:
            exp.setdefault(m.group(1).lower(), []).append(num(m.group(2)))
    quests = {}
    for tr in re.findall(r'<tr.*?</tr>', section(page, 'Quest'), re.S):
        m = re.match(r'(M?)★(\d+) (.*?) (\d[\d,]*) x', clean(tr))
        if not m or re.search(r'Arena|Challenge|Event', m.group(3)):
            continue
        stars = int(m.group(2))
        rank = 'master' if m.group(1) else ('low' if stars <= 5 else 'high')
        quests.setdefault(rank, []).append(num(m.group(4)))
    out = []
    for rank in ('low', 'high', 'master'):
        if rank in exp:
            out.append({'rank': rank, 'solo': min(exp[rank]), 'basis': 'expedition'})
        elif rank in quests:
            out.append({'rank': rank, 'solo': min_quest(quests[rank]), 'basis': 'minQuest'})
    return out


def rise(slug):
    page = open(f'cache_rise_{slug}_en.html', encoding='utf8').read()
    vals = {}
    for tr in re.findall(r'<tr>.*?</tr>', page, re.S):
        m = re.match(r'(Village|Gathering Hub|MR) (\d+)★ .*? 1 (\d[\d,]*) HP', clean(tr))
        if not m:
            continue
        cat, stars, hp = m.group(1), int(m.group(2)), num(m.group(3))
        if cat == 'Village':
            rank = 'low'
        elif cat == 'MR':
            rank = 'master'
        elif stars <= 3:
            rank = 'low'
        elif stars <= 7:
            rank = 'high'
        else:
            continue
        vals.setdefault(rank, []).append(hp)
    return [{'rank': r, 'solo': min_quest(vals[r]), 'basis': 'minQuest'}
            for r in ('low', 'high', 'master') if r in vals]


WILDS_ROWS = []
for tr in re.findall(r'<tr.*?</tr>', open('wl_quests_full.html', encoding='utf8').read(), re.S)[1:]:
    tds = re.findall(r'<td.*?</td>', tr, re.S)
    m = re.match(r'\[(Assignments|Optional Quests) (\d+)★\]', clean(tds[0]))
    if not m:
        continue
    mons = [clean(d) for d in re.findall(r'<div>(.*?)</div>', tds[2], re.S)]
    hps = [num(clean(d).replace('HP', '')) for d in re.findall(r'<div>(.*?)</div>', tds[3], re.S)]
    for name, hp in zip(mons, hps):
        WILDS_ROWS.append((name, int(m.group(2)), hp))


def wilds(slug):
    name = ' '.join(w.capitalize() for w in slug.split('-'))
    vals = {}
    for n, stars, hp in WILDS_ROWS:
        if n == name:
            vals.setdefault('low' if stars <= 3 else 'high', []).append(hp)
    return [{'rank': r, 'solo': min_quest(vals[r]), 'basis': 'minQuest'}
            for r in ('low', 'high') if r in vals]


FACTORS = {
    'world_iceborne': {
        '2': {'min': 1.5, 'max': 1.5},
        '3': {'min': 2.2, 'max': 2.6},
        '4': {'min': 2.2, 'max': 2.6},
        'source': {
            'name': 'Fextralife',
            'url': 'https://monsterhunterworld.wiki.fextralife.com/Multiplayer',
            'notes': 'Multiplayer HP scaling: about 150% for 2 hunters, about 220%-260% for 3-4. '
                     'Applied to the solo reference HP; shown as an approximation.',
        },
    },
    'rise_sunbreak': {
        '2': {'min': 1.35, 'max': 1.5},
        '3': {'min': 1.7, 'max': 2.0},
        '4': {'min': 2.0, 'max': 2.4},
        'source': {
            'name': 'Kiranico (MH Rise: Sunbreak)',
            'url': 'https://mhrise.kiranico.com/data/quests/564051736',
            'notes': 'Per-player HP of quest pages: High Rank Gathering Hub x1.5/x2.0/x2.4, '
                     'Master Rank x1.35/x1.7/x2.0, Low Rank hub about x1.4/x1.86/x2.2. '
                     'Village quests do not scale.',
        },
    },
    'wilds': {
        '2': {'min': 1.6, 'max': 1.6},
        '3': {'min': 2.0, 'max': 2.0},
        '4': {'min': 2.4, 'max': 2.4},
        'source': {
            'name': 'Kiranico (MH Wilds)',
            'url': 'https://mhwilds.kiranico.com/data/quests',
            'notes': 'Per-player HP of quest pages (game data): x1.6 / x2.0 / x2.4 for 2 / 3 / 4 hunters, '
                     'same in Low and High Rank.',
        },
    },
}

HP_NOTES = {
    'world_iceborne': 'HP: lowest solo expedition HP per rank; ranks without expeditions use the lowest regular quest HP.',
    'rise_sunbreak': 'HP: lowest solo HP of the regular quests per rank (Village and Gathering Hub 1-3 LR, Hub 4-7 HR, MR).',
}

EXTRACT = {'world_iceborne': world, 'rise_sunbreak': rise, 'wilds': wilds}

for game, fn in ((g, EXTRACT[g]) for g in selected_games()):
    path = os.path.join(REPO, 'assets', 'data', game, 'monsters.json')
    raw = open(path, encoding='utf8', newline='').read()
    data = json.loads(raw)

    def dump(d):
        return json.dumps(d, indent=2, ensure_ascii=False)

    assert dump(data) == raw.replace('\r\n', '\n'), f'{game}: formatting would change'

    ordered = {}
    for k, v in data.items():
        if k == 'monsters':
            ordered['partyHpFactors'] = FACTORS[game]
        if k != 'partyHpFactors':
            ordered[k] = v
    data = ordered

    for monster in data['monsters']:
        hp = fn(monster['slug'])
        assert hp, f'{game}/{monster["slug"]}: no HP found'
        monster['hp'] = hp
        if game == 'wilds':
            if not any(s['url'] == 'https://mhwilds.kiranico.com/data/quests' for s in monster['sources']):
                monster['sources'].append({
                    'name': 'Kiranico (MH Wilds) - quests',
                    'url': 'https://mhwilds.kiranico.com/data/quests',
                    'notes': 'HP: lowest solo HP of the Assignments/Optional quests per rank (1-3 stars LR, 4+ HR).',
                })
        else:
            src = next(s for s in monster['sources'] if s['name'].startswith('Kiranico'))
            if HP_NOTES[game] not in src.get('notes', ''):
                src['notes'] = (src.get('notes', '') + ' ' + HP_NOTES[game]).strip()
        print(game, monster['slug'], [(h['rank'], h['solo'], h['basis']) for h in hp])

    open(path, 'w', encoding='utf8', newline='\n').write(dump(data))
print('ok')
