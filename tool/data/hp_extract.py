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
import glob, html, json, os, re, statistics, sys

import kiranico_world
import macaron
from common import REPO, roster, selected_games, wiki_api


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


def tiered_min(tiers, rank):
    """min_quest of the first tier that has [rank] (004 T039 follow-up). A tier
    may hold {scale: [hp]} instead of [hp] when a rank mixes HP scales (Rise
    Village and Gathering Hub quests); then each scale is filtered on its own
    and the lowest result wins."""
    for tier in tiers:
        if rank in tier:
            values = tier[rank]
            if isinstance(values, dict):
                return min(min_quest(v) for v in values.values())
            return min_quest(values)
    return None


def min_quest(values):
    if not values:
        return None
    med = statistics.median(values)
    return min(v for v in values if v >= 0.8 * med)


_WIKI_QUESTS = {}
WIKI_QUEST_PAGES = {  # game -> [(wiki category, cache prefix)], first wins on duplicates
    'world_iceborne': [('Category:MHWI Quest Pages', 'mhwi')],
    'rise_sunbreak': [('Category:MHRS Quest Pages', 'mhrs'), ('Category:MHRise Quest Pages', 'mhrise')],
}


def wiki_quests(game):
    """{normalized quest name: (target names, categories)} from the Monster
    Hunter Wiki quest pages of [game] ("Goal Icons" are the targets; they may
    span several lines). Pages are cached like the other wiki queries."""
    if game not in _WIKI_QUESTS:
        found = {}
        for category, prefix in WIKI_QUEST_PAGES[game]:
            titles, cont, n = [], {}, 0
            while True:
                d = wiki_api({'action': 'query', 'list': 'categorymembers', 'cmlimit': 500,
                              'cmtitle': category, **cont}, f'wiki_{prefix}_quests_{n}.json')
                titles += [m['title'] for m in d['query']['categorymembers']]
                if 'continue' not in d:
                    break
                cont, n = d['continue'], n + 1
            titles = sorted(titles)
            for i in range(0, len(titles), 40):
                d = wiki_api({'action': 'query', 'prop': 'revisions', 'rvprop': 'content',
                              'rvslots': 'main', 'titles': '|'.join(titles[i:i + 40])},
                             f'wiki_{prefix}_quest_text_{i // 40}.json')
                for page in d['query']['pages'].values():
                    text = page['revisions'][0]['slots']['main']['*']
                    goals = re.search(r'\|Goal Icons\s*=(.*?)(?=\n\|)', text, re.S)
                    targets = re.findall(
                        r'\{\{(?:IconPickerUniversal|IPUClassic\w*)\|(?:MHWI|MHRS|MHRise)\|([^|}]+)',
                        goals.group(1)) if goals else []
                    cats = set(re.findall(r'\[\[Category:(?:MHWI|MHRS|MHRise) ([^\]]+?) Quests\]\]', text))
                    name = re.sub(r' \((?:MHWI|MHRS|MHRise) Quest\)$', '', page['title'])
                    found.setdefault(quest_key(name), ([t.strip() for t in targets], cats))
        _WIKI_QUESTS[game] = found
    return _WIKI_QUESTS[game]


def quest_tier(game, quest, name):
    """0 = [name] is the only target, 1 = another regular quest, 2 = a special
    assignment (used only when nothing else exists), None = left out (arena,
    challenge). Quests missing on the wiki count as regular."""
    info = wiki_quests(game).get(quest_key(quest))
    if info is None:
        return 1
    targets, cats = info
    if cats & EXCLUDED:
        return None
    if cats & SPECIAL:
        return 2
    return 0 if targets == [name] else 1


def quest_key(name):
    return re.sub(r'[^a-z0-9]', '', html.unescape(name).lower())


# Arena-like quests with fixed, unusual HP; event quests are normal hunts.
# Special assignments (sieges, story set pieces) count only when a rank has
# no other quest, e.g. Zorah Magdaros.
EXCLUDED = {'Arena', 'Challenge'}
SPECIAL = {'Special'}


def world_version(entry):
    """Tempered / arch-tempered HP (004 R4): solo HP of the monster in its own quests
    (Kiranico quest pages), arena and challenge quests excluded. Quests where it is the
    only large monster come first, because World lowers each monster's HP in
    multi-monster quests."""
    base = next(e for e in roster('world_iceborne').values() if e['slug'] == entry['versionOf'])['name']
    single, multi = {}, {}
    for q, _path, en, _pt, stars in kiranico_world.quest_pages(entry):
        if q['arena']:
            continue
        rows = [[clean(c) for c in re.findall(r'<td[^>]*>(.*?)</td>', tr, re.S)]
                for tr in re.findall(r'<tr[^>]*>(.*?)</tr>', kiranico_world.section(en, 'Monsters'), re.S)]
        names = [r[0] for r in rows if len(r) == 1]
        current, hp = None, None
        for r in rows:
            if len(r) == 1:
                current = r[0]
            elif current == base and r and r[0] == '1':
                hp = num(r[1])
        if hp:
            (single if len(names) == 1 else multi).setdefault(kiranico_world.rank_of(stars), []).append(hp)
    vals = single or multi
    return [{'rank': r, 'solo': min_quest(vals[r]), 'basis': 'minQuest'}
            for r in ('low', 'high', 'master') if r in vals]


def world(slug, name=None):
    entry = roster('world_iceborne').get(slug, {})
    if entry.get('dataFrom') == 'wikiTemperedQuests':
        return world_version(entry)
    page = open(f'cache_world_{slug}_en.html', encoding='utf8').read()
    exp = {}
    for tr in re.findall(r'<tr.*?</tr>', section(page, 'Expeditions'), re.S):
        m = re.match(r'(Low|High|Master) Rank .*? (\d[\d,]*) x', clean(tr))
        if m:
            exp.setdefault(m.group(1).lower(), []).append(num(m.group(2)))
    # Regular quests per rank, single-target ones apart: World lowers each
    # monster's HP in multi-target quests (004 T039 follow-up). Targets and
    # quest types come from the wiki quest pages; quests missing there fall
    # back to the name filter of 003.
    tiers = ({}, {}, {})  # this monster as the only target / other regular / special
    for tr in re.findall(r'<tr.*?</tr>', section(page, 'Quest'), re.S):
        m = re.match(r'(M?)★(\d+) (.*?) (\d[\d,]*) x', clean(tr))
        if not m:
            continue
        if quest_key(m.group(3)) not in wiki_quests('world_iceborne') and re.search(
                r'Arena|Challenge|Event', m.group(3)):
            continue  # not on the wiki: the name filter of 003
        tier = quest_tier('world_iceborne', m.group(3), name)
        if tier is None:
            continue
        stars = int(m.group(2))
        rank = 'master' if m.group(1) else ('low' if stars <= 5 else 'high')
        tiers[tier].setdefault(rank, []).append(num(m.group(4)))
    out = []
    for rank in ('low', 'high', 'master'):
        if rank in exp:
            out.append({'rank': rank, 'solo': min(exp[rank]), 'basis': 'expedition'})
        elif solo := tiered_min(tiers, rank):
            out.append({'rank': rank, 'solo': solo, 'basis': 'minQuest'})
    return out


def rise(slug, name=None):
    entry = roster('rise_sunbreak').get(slug, {})
    if entry.get('versionKind') == 'afflicted':
        # Afflicted: the base page's "Anomaly Research: <base>" quest (Master Rank),
        # 004 research R4. Other Anomaly rows are research quests of other targets
        # where this monster is only an extra.
        base = roster('rise_sunbreak')[entry['versionOf']]['name']
        page = open(f'cache_rise_{entry["versionOf"]}_en.html', encoding='utf8').read()
        hps = [num(m.group(1)) for tr in re.findall(r'<tr>.*?</tr>', page, re.S)
               if (m := re.match(rf'Anomaly \d+★ Anomaly Research: {re.escape(base)} .*? 1 (\d[\d,]*) HP',
                                 clean(tr)))]
        return [{'rank': 'master', 'solo': min_quest(hps), 'basis': 'minQuest'}] if hps else []
    page = open(f'cache_rise_{slug}_en.html', encoding='utf8').read()
    target = entry.get('name', name)
    tiers = ({}, {}, {})  # only target / other regular / special (see quest_tier)
    for tr in re.findall(r'<tr>.*?</tr>', page, re.S):
        m = re.match(r'(Village|Gathering Hub|MR) (\d+)★ (.*?) 1 (\d[\d,]*) HP', clean(tr))
        if not m or (entry.get('versionKind') == 'apex' and m.group(3).startswith('Advanced:')):
            continue  # "Advanced:" 8★ quests are arena-style multi-Apex fights
        cat, stars, hp = m.group(1), int(m.group(2)), num(m.group(4))
        if cat == 'Village':
            rank = 'low'
        elif cat == 'MR':
            rank = 'master'
        elif stars <= 3:
            rank = 'low'
        elif stars <= 7 or entry.get('versionKind') == 'apex':
            rank = 'high'  # Apex hunts are Gathering Hub 8★ High Rank quests (004 R4)
        else:
            continue
        quest = re.split(r' Area \d', m.group(3))[0]
        tier = quest_tier('rise_sunbreak', quest, target)
        if tier is None:
            continue
        tiers[tier].setdefault(rank, {}).setdefault(cat, []).append(hp)
    out = []
    for rank in ('low', 'high', 'master'):
        if solo := tiered_min(tiers, rank):
            out.append({'rank': rank, 'solo': solo, 'basis': 'minQuest'})
    return out


WILDS_ROWS = []
for tr in re.findall(r'<tr.*?</tr>', open('wl_quests_full.html', encoding='utf8').read(), re.S)[1:]:
    tds = re.findall(r'<td.*?</td>', tr, re.S)
    m = re.match(r'\[(Assignments|Optional Quests) (\d+)★\]', clean(tds[0]))
    if not m:
        continue
    mons = [clean(d) for d in re.findall(r'<div>(.*?)</div>', tds[2], re.S)]
    hps = [num(clean(d).replace('HP', '')) for d in re.findall(r'<div>(.*?)</div>', tds[3], re.S)]
    for name, hp in zip(mons, hps):
        WILDS_ROWS.append((name, int(m.group(2)), hp, len(mons)))


# Tempered hunts, arch-tempered quests and the free title update / collab
# monsters are not on Kiranico (004 research R4): their HP comes from the
# macarongamemo table. 12 of 13 normal High Rank values checked there match
# Kiranico, so Kiranico stays first and the table only fills what it lacks.
_BLOG_HP = None
FROM_BLOG = {}  # slug -> [(stars, hp)] of the entries whose HP came from the table


def blog_hp():
    """{slug: (kind, [(stars, hp)])}: versions by (base, kind), bases by 'base'."""
    global _BLOG_HP
    if _BLOG_HP is None:
        table = macaron.wilds_hp()
        _BLOG_HP = {}
        for slug, e in roster('wilds').items():
            key = (e['versionOf'], e['versionKind']) if 'versionOf' in e else (slug, 'base')
            if key in table:
                _BLOG_HP[slug] = (key[1], table[key])
    return _BLOG_HP


def wilds(slug, name):
    # Quests where the monster is alone first: multi-monster quests lower
    # each one's HP (004 T039 follow-up).
    tiers = ({}, {})  # the monster alone / with others
    for n, stars, hp, count in WILDS_ROWS:
        if n == name:
            rank = 'low' if stars <= 3 else 'high'
            tiers[0 if count == 1 else 1].setdefault(rank, []).append(hp)
    if not any(tiers) and slug in blog_hp():
        FROM_BLOG[slug] = blog_hp()[slug]
        return [{'rank': 'high', 'solo': min(hp for _, hp in FROM_BLOG[slug][1]),
                 'basis': 'minQuest'}]
    return [{'rank': r, 'solo': solo, 'basis': 'minQuest'}
            for r in ('low', 'high') if (solo := tiered_min(tiers, r))]


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

WORLD_VERSION_HP_NOTE = ('HP: lowest solo HP of this monster in its own quests (arena and challenge '
                         'quests excluded; single-monster quests first).')
AFFLICTED_HP_NOTE = 'HP: solo HP of the "Anomaly Research: <monster>" quest on this page (Master Rank).'

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
        hp = fn(monster['slug'], monster['name']['en'])
        if not hp:
            monster.pop('hp', None)
            print(game, monster['slug'], 'no HP in the sources')
            continue
        monster['hp'] = hp
        if game == 'wilds' and monster['slug'] in FROM_BLOG:
            kind, rows = FROM_BLOG[monster['slug']]
            values = ', '.join(f'★{s} {hp:,}' for s, hp in rows)
            if kind == 'base':
                note = (f'HP: normal-individual row at strength ♦3, the level of quest targets, '
                        f'middle of the 5 size variations ({values}).')
            else:
                row = '歴戦王 (arch-tempered)' if kind == 'archTempered' else '歴戦 (tempered)'
                note = (f'HP: {row} rows, strength levels ♦3-♦5, middle of the 5 size variations '
                        f'({values}); the lowest is shown.')
            monster['sources'] = [s for s in monster['sources'] if s['url'] != macaron.URL] + [{
                'name': 'まかろんのゲームメモ (MHWilds monster HP)',
                'url': macaron.URL,
                'notes': note + ' Kiranico does not list these hunts.',
            }]
        elif game == 'wilds':
            if not any(s['url'] == 'https://mhwilds.kiranico.com/data/quests' for s in monster['sources']):
                monster['sources'].append({
                    'name': 'Kiranico (MH Wilds) - quests',
                    'url': 'https://mhwilds.kiranico.com/data/quests',
                    'notes': 'HP: lowest solo HP of the Assignments/Optional quests per rank (1-3 stars LR, 4+ HR).',
                })
        else:
            src = next(s for s in monster['sources'] if s['name'].startswith('Kiranico'))
            note = (AFFLICTED_HP_NOTE if monster.get('versionKind') == 'afflicted'
                    else WORLD_VERSION_HP_NOTE if game == 'world_iceborne' and 'versionOf' in monster
                    else HP_NOTES[game])
            if note not in src.get('notes', ''):
                src['notes'] = (src.get('notes', '') + ' ' + note).strip()
        print(game, monster['slug'], [(h['rank'], h['solo'], h['basis']) for h in hp])

    open(path, 'w', encoding='utf8', newline='\n').write(dump(data))
print('ok')
