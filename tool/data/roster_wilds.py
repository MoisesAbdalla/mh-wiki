"""Writes tool/data/rosters/wilds.json: the Wilds large-monster roster with
its versions (feature 004, research R1/R2/R4).

- Roster: Kiranico monster list, large monsters only (the list ends at the
  first small monster, "Vespoid"); the arena object "High Purrformance
  Barrel Puncher" is excluded.
- Guardian X is a `guardian` version of X when X is in the roster; otherwise
  it keeps its own row.
- `tempered` version of every base whose Monster Hunter Wiki page lists
  tempered drop groups in High Rank (its own data).
- `archTempered` version of every base that is the arch-tempered target of a
  Monster Hunter Wiki quest page (event/challenge/10-star quests, target
  template with `Type=Arch Tempered`). Its own data: those quests and their
  rewards. Kiranico does not list these quests, so there is no HP.
- No frenzied versions: the sources give them no own HP, drops or quests.
"""
import json
import os
import re
import time
import urllib.parse
import urllib.request

from common import HERE, clean

KIRANICO = 'https://mhwilds.kiranico.com'
TEMPERED_GROUPS = ('Extra Rewards (Tempered)', 'Tempered Wound Destruction Rewards')
WIKI_API = 'https://monsterhunterwiki.org/api.php'
UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki data curation; personal study project)'}


def wiki_api(params, cache):
    if not os.path.exists(cache):
        url = WIKI_API + '?' + urllib.parse.urlencode({**params, 'format': 'json'})
        data = urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read()
        open(cache, 'wb').write(data)
        time.sleep(1.2)
    return json.load(open(cache, encoding='utf8'))


def arch_tempered_quests():
    """{monster name: [quest page titles]} of the wiki quests whose target is arch-tempered."""
    titles, cont, n = [], {}, 0
    while True:
        d = wiki_api({'action': 'query', 'list': 'categorymembers', 'cmlimit': 500,
                      'cmtitle': 'Category:MHWilds Quests', **cont}, f'wiki_wilds_quests_{n}.json')
        titles += [m['title'] for m in d['query']['categorymembers']]
        if 'continue' not in d:
            break
        cont, n = d['continue'], n + 1
    found = {}
    for i in range(0, len(titles), 40):
        d = wiki_api({'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
                      'titles': '|'.join(sorted(titles)[i:i + 40])}, f'wiki_wilds_quest_text_{i // 40}.json')
        for p in d['query']['pages'].values():
            text = p['revisions'][0]['slots']['main']['*']
            target = re.search(r'\|Target\s*=(.*)', text)
            for name in re.findall(r'\|MHWilds\|([^|}]+)\|[^}]*Type=Arch Tempered',
                                   target.group(1) if target else ''):
                found.setdefault(name.strip(), []).append(p['title'])
    return {k: sorted(v) for k, v in found.items()}


def main():
    page = open('wl_list_2026.html', encoding='utf8').read()
    large = []
    for slug, name in re.findall(r'href="/data/monsters/([^"]+)"[^>]*>(.*?)</a>', page, re.S):
        name = clean(name)
        if name == 'Vespoid':
            break
        if not name or 'Barrel Puncher' in name or slug in [m['slug'] for m in large]:
            continue
        large.append({'slug': slug, 'name': name, 'wiki': name.replace(' ', '_')})

    by_name = {m['name']: m for m in large}
    roster = []
    for m in large:
        entry = dict(m)
        g = re.match(r'Guardian (.+)$', m['name'])
        if g and g.group(1) in by_name:
            entry['versionOf'] = by_name[g.group(1)]['slug']
            entry['versionKind'] = 'guardian'
        roster.append(entry)

    for m in [e for e in roster if 'versionOf' not in e]:
        wiki = open(f'cache_mhwiki_wilds_{m["slug"]}.html', encoding='utf8').read()
        if any(f'>{g}<' in wiki or f'>{g}\n' in wiki for g in TEMPERED_GROUPS):
            roster.append({
                'slug': f'tempered-{m["slug"]}',
                'name': f'Tempered {m["name"]}',
                'wiki': m['wiki'],
                'versionOf': m['slug'],
                'versionKind': 'tempered',
                'dataFrom': 'baseWikiTemperedDrops',
                'icon': 'base',
            })

    for name, quests in sorted(arch_tempered_quests().items()):
        base = by_name.get(name)
        if base is None:
            print('arch-tempered target not in the roster:', name)
            continue
        roster.append({
            'slug': f'arch-tempered-{base["slug"]}',
            'name': f'Arch-Tempered {name}',
            'wiki': base['wiki'],
            'versionOf': base['slug'],
            'versionKind': 'archTempered',
            'dataFrom': 'wikiArchTemperedQuests',
            'quests': quests,
            'icon': 'base',
        })

    out = os.path.join(HERE, 'rosters', 'wilds.json')
    with open(out, 'w', encoding='utf8', newline='\n') as f:
        json.dump({
            'game': 'wilds',
            'source': f'{KIRANICO}/data/monsters (game version 1.040)',
            'monsters': roster,
        }, f, ensure_ascii=False, indent=2)
        f.write('\n')
    bases = [e for e in roster if 'versionOf' not in e]
    print(f'{len(bases)} base rows, {len(roster) - len(bases)} versions')
    for e in roster:
        if 'versionOf' in e:
            print('  ', e['slug'], '->', e['versionOf'], e['versionKind'])


if __name__ == '__main__':
    main()
