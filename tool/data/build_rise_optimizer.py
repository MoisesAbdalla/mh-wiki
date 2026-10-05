"""Builds assets/data/rise_sunbreak/optimizer.json (feature 009, research R2).

A compact view of armor.json and weapons.json with only what the build
optimizer needs: skills with their max level, decorations with their slot
level and points, pieces with part, rarity, slots, defense and skills, and
weapons with type, rarity, slots and attack. Rampage data is left out.
"""
import json
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DATA = os.path.join(REPO, 'assets', 'data', 'rise_sunbreak')
PARTS = {'head', 'chest', 'arms', 'waist', 'legs'}


def load(name):
    with open(os.path.join(DATA, name), encoding='utf8') as f:
        return json.load(f)


def name(x):
    n = {'en': x['name']['en']}
    if x['name'].get('ptBr'):
        n['ptBr'] = x['name']['ptBr']
    return n


def slots(values):
    out = [s for s in values if s]
    assert len(out) <= 3 and all(1 <= s <= 4 for s in out), values
    return sorted(out, reverse=True)


def main():
    armor = load('armor.json')
    weapons = load('weapons.json')

    skills = [{'id': s['id'], 'name': name(s), 'max': len(s['levels'])} for s in armor['skills']]
    known = {s['id'] for s in skills}

    decorations = []
    for d in armor['decorations']:
        (sk,) = d['skills']
        assert sk['skill'] in known, d['id']
        decorations.append({'id': d['id'], 'name': name(d), 'slot': d['slotLevel'],
                            'skill': sk['skill'], 'points': sk['level']})

    pieces = []
    for p in armor['pieces']:
        assert p['part'] in PARTS, p['id']
        for s in p['skills']:
            assert s['skill'] in known, (p['id'], s)
        piece = {'id': p['id'], 'name': name(p), 'part': p['part'], 'rarity': p['rarity'],
                 'slots': slots(p['slots']), 'defense': p.get('maxDefense') or p.get('defense') or 0,
                 'skills': [{'skill': s['skill'], 'level': s['level']} for s in p['skills']]}
        pieces.append(piece)

    out_weapons = []
    for w in weapons['weapons']:
        weapon = {'id': w['slug'], 'name': name(w), 'type': w['type'], 'rarity': w['rarity'],
                  'slots': slots(w.get('slots') or []), 'attack': w.get('attack') or 0}
        if w.get('image'):
            weapon['image'] = w['image']
        # The weapon filter (009): the phial or shelling kind without its
        # level ("Exhaust 20" → exhaust), and the element / status kinds.
        traits = w.get('traits') or {}
        kind = traits.get('phial') or traits.get('shelling')
        if kind:
            en = kind['en'].split(' ')[0]
            weapon['trait'] = {'key': en.lower(), 'name': {
                'en': en, 'ptBr': (kind.get('ptBr') or en).split(' ')[0]}}
        elements = [e['kind'] for e in w.get('special') or []]
        if elements:
            weapon['elements'] = elements
        out_weapons.append(weapon)

    for kind, items in (('decorations', decorations), ('pieces', pieces), ('weapons', out_weapons)):
        ids = [i['id'] for i in items]
        assert len(ids) == len(set(ids)), f'duplicate ids in {kind}'

    dataset = {'schemaVersion': 1, 'game': 'rise_sunbreak', 'skills': skills,
               'decorations': decorations, 'pieces': pieces, 'weapons': out_weapons}
    path = os.path.join(DATA, 'optimizer.json')
    with open(path, 'w', encoding='utf8', newline='\n') as f:
        json.dump(dataset, f, ensure_ascii=False, separators=(',', ':'))
    print(f'skills {len(skills)}, decorations {len(decorations)}, pieces {len(pieces)}, '
          f'weapons {len(out_weapons)}; {os.path.getsize(path) / 1024:.0f} KB')


if __name__ == '__main__':
    sys.exit(main())
