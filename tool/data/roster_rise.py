"""Writes tool/data/rosters/rise_sunbreak.json: the Rise: Sunbreak large-monster
roster with its versions (feature 004, research R1/R2/R4).

- Roster: Kiranico large-monster list (`?view=lg`).
- "Apex X" and "Risen X" are `apex` / `risen` versions of X (own Kiranico
  pages, own icons).
- Named variants with their own Hunter's Notes entry (Primordial Malzeno,
  Scorned Magnamalo, Furious Rajang…) and subspecies keep their own rows.
- `afflicted` version of every base whose Kiranico page lists "Afflicted"
  materials (its own data: afflicted drops; HP from Anomaly quests).
"""
import json
import os
import re

from common import HERE, clean, fetch

KIRANICO = 'https://mhrise.kiranico.com'


def slug(name):
    return re.sub(r'[^a-z0-9]+', '-', name.lower().replace("'", '')).strip('-')


def page(kid, s):
    return fetch(f'{KIRANICO}/data/monsters/{kid}', f'cache_rise_{s}_en.html')


def main():
    listing = fetch(f'{KIRANICO}/data/monsters?view=lg', 'rise_monster_list_lg.html')
    large = {}
    for kid, name in re.findall(r'href="https://mhrise\.kiranico\.com/data/monsters/(\d+)"[^>]*>(.*?)</a>',
                                listing, re.S):
        name = clean(name)
        if name and kid not in large:
            large[kid] = name

    by_name = {name: slug(name) for name in large.values()}
    roster = []
    for kid, name in sorted(large.items(), key=lambda kv: kv[1]):
        entry = {'slug': slug(name), 'kiranicoId': kid, 'name': name, 'wiki': name.replace(' ', '_')}
        m = re.match(r'(Apex|Risen) (.+)$', name)
        if m and m.group(2) in by_name:
            entry['versionOf'] = by_name[m.group(2)]
            entry['versionKind'] = m.group(1).lower()
        roster.append(entry)

    for entry in [e for e in roster if 'versionOf' not in e]:
        if re.search(r'>\s*Afflicted [^<]+</a>', page(entry['kiranicoId'], entry['slug'])):
            roster.append({
                'slug': f'afflicted-{entry["slug"]}',
                'kiranicoId': entry['kiranicoId'],
                'name': f'Afflicted {entry["name"]}',
                'wiki': entry['wiki'],
                'versionOf': entry['slug'],
                'versionKind': 'afflicted',
                'dataFrom': 'baseKiranicoAfflicted',
                'icon': 'base',
            })

    out = os.path.join(HERE, 'rosters', 'rise_sunbreak.json')
    with open(out, 'w', encoding='utf8', newline='\n') as f:
        json.dump({'game': 'rise_sunbreak', 'source': f'{KIRANICO}/data/monsters?view=lg',
                   'monsters': roster}, f, ensure_ascii=False, indent=2)
        f.write('\n')
    bases = [e for e in roster if 'versionOf' not in e]
    print(f'{len(bases)} base rows, {len(roster) - len(bases)} versions')
    for e in roster:
        if 'versionOf' in e:
            print('  ', e['slug'], '->', e['versionOf'], e['versionKind'])


if __name__ == '__main__':
    main()
