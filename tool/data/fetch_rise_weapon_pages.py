"""Caches every Rise: Sunbreak weapon page of Kiranico for build_rise_weapons.py.

Each page has the game's own forge/upgrade materials and both sharpness bars, which the wiki
pages sometimes lack (006 research R12). Pages already cached are skipped, so the script can be
stopped and resumed.

    python tool/data/fetch_rise_weapon_pages.py
"""
import json
import os
import sys
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))  # before common changes the cwd
sys.path.insert(0, HERE)
from common import CACHE, fetch  # noqa: E402

KIRANICO = 'https://mhrise.kiranico.com'


def page_path(kid):
    return os.path.join(CACHE, f'kiranico_weapon_{kid}.html')


def main():
    repo = os.path.join(HERE, '..', '..')
    data = json.load(open(os.path.join(repo, 'assets/data/rise_sunbreak/weapons.json'), encoding='utf8'))
    ids = [w['kiranicoId'] for w in data['weapons']]
    todo = [kid for kid in ids if not os.path.exists(page_path(kid))]

    def one(kid):
        try:
            fetch(f'{KIRANICO}/data/weapons/{kid}', page_path(kid))
        except Exception as e:  # noqa: BLE001 - the builder falls back to the wiki
            print('page failed', kid, e, flush=True)
        time.sleep(0.3)

    # A few requests at a time: one page takes ~3 s to answer.
    with ThreadPoolExecutor(max_workers=4) as pool:
        for i, _ in enumerate(pool.map(one, todo)):
            if i % 250 == 0:
                print('pages', i, 'of', len(todo), flush=True)
    print('done', len(ids), flush=True)


if __name__ == '__main__':
    main()
