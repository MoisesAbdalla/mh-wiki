"""Caches the Monster Hunter World: Iceborne equipment sources (011 research R1–R5).

- the wiki data modules Module:MHWI/data/{Weapons,Armor,Decorations,Weapons/Ammo}.json
  → .cache/world_wiki_<name>.json
- mhw-db.com armor/sets, skills, decorations, charms → .cache/world_mhwdb_<endpoint>.json
- the Kiranico World lists in en and pt-BR (weapons per type, armor series,
  skill trees, decorations, items) → .cache/world_kiranico_<page>_<lang>.html
- every Kiranico armor series page (en and pt-BR), crawled through each page's
  previous/next links → .cache/world_kiranico_series_<id>_<lang>.html (the
  overview lists only part of the pieces)

Existing files are kept, so a second run only fetches what is missing.
"""
import json
import os
import re
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, '.cache')
UA = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126 Safari/537.36')
WIKI = 'https://monsterhunterwiki.org'
WIKI_MODULES = ['Weapons', 'Armor', 'Decorations', 'Weapons/Ammo']
MHWDB = 'https://mhw-db.com'
MHWDB_ENDPOINTS = ['armor/sets', 'skills', 'decorations', 'charms']
KIRANICO = 'https://mhworld.kiranico.com'
KIRANICO_PAGES = ([f'weapons?type={t}' for t in range(14)]
                  + ['armorseries', 'skilltrees', 'decorations', 'items'])
LANGS = ['en', 'pt-BR']


def get(url, path, check=None):
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return path
    for attempt in range(3):
        out = subprocess.run(['curl', '-sfL', '-m', '180', '-A', UA, url], capture_output=True)
        if out.returncode == 0 and out.stdout and (check is None or check(out.stdout)):
            with open(path, 'wb') as f:
                f.write(out.stdout)
            time.sleep(1)
            return path
        time.sleep(3 * (attempt + 1))
    sys.exit(f'failed: {url}')


def is_json(raw):
    try:
        return bool(json.loads(raw))
    except ValueError:
        return False


def main():
    os.makedirs(CACHE, exist_ok=True)
    for name in WIKI_MODULES:
        path = get(f'{WIKI}/index.php?title=Module:MHWI/data/{name}.json&action=raw',
                   os.path.join(CACHE, f'world_wiki_{name.split("/")[-1].lower()}.json'), is_json)
        with open(path, encoding='utf8') as f:
            print(f'wiki {name:12} {len(json.load(f)):5}')
    for endpoint in MHWDB_ENDPOINTS:
        path = get(f'{MHWDB}/{endpoint}',
                   os.path.join(CACHE, f'world_mhwdb_{endpoint.replace("/", "-")}.json'), is_json)
        with open(path, encoding='utf8') as f:
            print(f'mhw-db {endpoint:10} {len(json.load(f)):5}')
    for page in KIRANICO_PAGES:
        for lang in LANGS:
            slug = page.replace('?type=', '-')
            path = get(f'{KIRANICO}/{lang}/{page}',
                       os.path.join(CACHE, f'world_kiranico_{slug}_{lang}.html'))
            print(f'kiranico {page:16} {lang:6} {os.path.getsize(path) // 1024} KB')
    crawl_series()


def crawl_series():
    """Visits every armor series page, starting from the overview's links."""
    def page(sid, lang):
        return get(f'{KIRANICO}/{lang}/armorseries/{sid}/x',
                   os.path.join(CACHE, f'world_kiranico_series_{sid}_{lang}.html'))

    with open(os.path.join(CACHE, 'world_kiranico_armorseries_en.html'), encoding='utf8') as f:
        todo = set(re.findall(r'/armorseries/(\w+)/', f.read()))
    seen = set()
    with ThreadPoolExecutor(4) as pool:
        while todo:
            batch = sorted(todo - seen)
            seen |= set(batch)
            todo = set()
            for path in pool.map(lambda sid: page(sid, 'en'), batch):
                with open(path, encoding='utf8') as f:
                    todo |= set(re.findall(r'/armorseries/(\w+)/', f.read()))
            list(pool.map(lambda sid: page(sid, 'pt-BR'), batch))
    print(f'kiranico armor series {len(seen)}')


if __name__ == '__main__':
    main()
