"""Writes tool/data/rosters/world_iceborne.json: the World: Iceborne
large-monster roster with its versions (feature 004, research R1/R2/R4).

- Roster: Kiranico large-monster list (the list ends at "Zorah Magdaros",
  before the small monsters). Subspecies and named variants (Ruiner
  Nergigante, Raging Brachydios, Savage Deviljho…) keep their own rows.
- `tempered` / `archTempered` version of every base that is the tempered /
  arch-tempered target of a Monster Hunter Wiki quest page ("MHWI Quest
  Pages", `Goal Icons` template with `Type=Tempered` / `Type=Arch Tempered`).
  Their own data: those quests (HP and rewards on Kiranico). Kiranico's own
  quest pages do not mark tempered targets.
"""
import json
import os
import re

from common import HERE, clean, fetch, wiki_api

KIRANICO = 'https://mhworld.kiranico.com'
KINDS = {'Tempered': 'tempered', 'Arch Tempered': 'archTempered'}
ARENA = ('[[Category:MHWI Arena Quests]]', '[[Category:MHWI Challenge Quests]]')


def slug(name):
    return re.sub(r'[^a-z0-9]+', '-', name.lower().replace("'", '')).strip('-')


def tempered_quests():
    """{(monster name, kind): [{'name', 'arena'}]} of the wiki quests with tempered targets."""
    titles, cont, n = [], {}, 0
    while True:
        d = wiki_api({'action': 'query', 'list': 'categorymembers', 'cmlimit': 500,
                      'cmtitle': 'Category:MHWI Quest Pages', **cont}, f'wiki_mhwi_quests_{n}.json')
        titles += [m['title'] for m in d['query']['categorymembers']]
        if 'continue' not in d:
            break
        cont, n = d['continue'], n + 1
    titles = sorted(titles)
    found = {}
    for i in range(0, len(titles), 40):
        d = wiki_api({'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
                      'titles': '|'.join(titles[i:i + 40])}, f'wiki_mhwi_quest_text_{i // 40}.json')
        for p in d['query']['pages'].values():
            text = p['revisions'][0]['slots']['main']['*']
            goals = re.search(r'\|Goal Icons\s*=(.*)', text)
            quest = {'name': p['title'].removesuffix(' (MHWI Quest)'),
                     'arena': any(c in text for c in ARENA)}
            for name, kind in re.findall(r'\|MHWI\|([^|}]+)\|[^}]*?Type=(Arch[ -]Tempered|Tempered)',
                                         goals.group(1) if goals else ''):
                found.setdefault((name.strip(), kind.replace('-', ' ')), []).append(quest)
    return found


def main():
    listing = fetch(f'{KIRANICO}/en/monsters', 'world_monster_list.html')
    roster = []
    for path, name in re.findall(r'href="https://mhworld\.kiranico\.com/en/monsters/(\w+/[\w-]+)"[^>]*>(.*?)</a>',
                                 listing, re.S):
        name = clean(name)
        if name and name not in [e['name'] for e in roster]:
            roster.append({'slug': slug(name), 'kiranicoPath': path, 'name': name,
                           'wiki': name.replace(' ', '_')})
        if name == 'Zorah Magdaros':  # last large monster; small monsters follow
            break

    by_name = {e['name']: e for e in roster}
    for (name, kind), quests in sorted(tempered_quests().items(), key=lambda kv: (KINDS[kv[0][1]], kv[0][0])):
        base = by_name.get(name)
        if base is None:
            print('tempered target not in the roster:', name, kind)
            continue
        prefix = 'arch-tempered' if kind == 'Arch Tempered' else 'tempered'
        roster.append({
            'slug': f'{prefix}-{base["slug"]}',
            'kiranicoPath': base['kiranicoPath'],
            'name': f'{"Arch-Tempered" if kind == "Arch Tempered" else "Tempered"} {name}',
            'wiki': base['wiki'],
            'versionOf': base['slug'],
            'versionKind': KINDS[kind],
            'dataFrom': 'wikiTemperedQuests',
            'quests': sorted(quests, key=lambda q: q['name']),
            'icon': 'base',
        })

    out = os.path.join(HERE, 'rosters', 'world_iceborne.json')
    with open(out, 'w', encoding='utf8', newline='\n') as f:
        json.dump({'game': 'world_iceborne', 'source': f'{KIRANICO}/en/monsters',
                   'monsters': roster}, f, ensure_ascii=False, indent=2)
        f.write('\n')
    bases = [e for e in roster if 'versionOf' not in e]
    print(f'{len(bases)} base rows, {len(roster) - len(bases)} versions')
    for e in roster:
        if 'versionOf' in e:
            print('  ', e['slug'], [(q['name'], q['arena']) for q in e['quests']])


if __name__ == '__main__':
    main()
