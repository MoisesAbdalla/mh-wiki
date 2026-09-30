"""Writes tool/data/rosters/wilds.json: the Wilds large-monster roster with
its versions (feature 004, research R1/R2/R4).

- Roster: Kiranico monster list, large monsters only (the list ends at the
  first small monster, "Vespoid"); the arena object "High Purrformance
  Barrel Puncher" is excluded.
- Guardian X is a `guardian` version of X when X is in the roster; otherwise
  it keeps its own row.
- `tempered` version of every base whose Monster Hunter Wiki page lists
  tempered drop groups in High Rank (its own data).
- No arch-tempered or frenzied versions: the sources give them no own HP,
  drops or quests (arch-tempered is only a moveset note on the wiki; event
  quests are not on Kiranico).
"""
import json
import os
import re

from common import HERE, clean

KIRANICO = 'https://mhwilds.kiranico.com'
TEMPERED_GROUPS = ('Extra Rewards (Tempered)', 'Tempered Wound Destruction Rewards')


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
