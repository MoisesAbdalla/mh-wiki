"""Caches the Kiranico pages build_rise_armor.py needs (007 research R1, R4, R6).

The armor lists per rarity, every armor page (forge materials), the skills, decorations,
Rampage skills and Rampage decorations lists, and every decoration page, in English and
pt-BR where the builder needs both. Cached pages are skipped, so the script can be resumed.

    python tool/data/fetch_rise_armor_pages.py
"""
import os
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))  # before common changes the cwd
sys.path.insert(0, HERE)
from common import fetch  # noqa: E402

KIRANICO = 'https://mhrise.kiranico.com'
LISTS = ['skills', 'decorations', 'rampage-skills', 'rampage-decorations']


def list_path(name, lang):
    return f'rise_{name}{"_pt" if lang == "pt" else ""}.html'


def fetch_list(path, name, lang):
    prefix = '/pt-BR' if lang == 'pt' else ''
    return fetch(f'{KIRANICO}{prefix}{path}', list_path(name, lang))


def main():
    pages = []
    for lang in ('en', 'pt'):
        for view in range(10):
            pages.append(fetch_list(f'/data/armors?view={view}', f'armors_v{view}', lang))
        for name in LISTS:
            fetch_list(f'/data/{name}', name, lang)
    armor_ids = sorted({i for p in pages for i in re.findall(r'/data/armors/(\d+)"', p)})
    decorations = open(list_path('decorations', 'en'), encoding='utf8').read()
    deco_ids = sorted(set(re.findall(r'/data/decorations/(\d+)"', decorations)))
    todo = [(f'/data/armors/{i}', f'kiranico_armor_{i}.html') for i in armor_ids]
    todo += [(f'/data/decorations/{i}', f'kiranico_decoration_{i}.html') for i in deco_ids]
    todo = [job for job in todo if not os.path.exists(job[1])]

    def one(job):
        path, cache = job
        try:
            fetch(f'{KIRANICO}{path}', cache)
        except Exception as e:  # noqa: BLE001 - the builder reports what is missing
            print('page failed', path, e, flush=True)
        time.sleep(0.3)

    with ThreadPoolExecutor(max_workers=4) as pool:
        for n, _ in enumerate(pool.map(one, todo)):
            if n % 250 == 0:
                print('pages', n, 'of', len(todo), flush=True)
    print('done', len(armor_ids), 'armor', len(deco_ids), 'decorations', flush=True)


if __name__ == '__main__':
    main()
