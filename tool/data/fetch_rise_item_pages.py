"""Caches the Kiranico item page (English and pt-BR) of every material a Rise weapon uses.

The pages say where a material comes from: gathering by map and rank, monsters (large and
small) and quest rewards (006 research R13). The item ids come from the cached weapon pages
(fetch_rise_weapon_pages.py), so run that first. Cached pages are skipped.

    python tool/data/fetch_rise_item_pages.py
"""
import glob
import html
import json
import os
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))  # before common changes the cwd
sys.path.insert(0, HERE)
from common import CACHE, fetch  # noqa: E402

KIRANICO = 'https://mhrise.kiranico.com'


def item_ids():
    """{English item name: Kiranico item id} from the cached weapon pages."""
    ids = {}
    for path in glob.glob(os.path.join(CACHE, 'kiranico_weapon_*.html')):
        page = open(path, encoding='utf8').read()
        for item_id, name in re.findall(r'/data/items/(\d+)">(.*?)</a>', page):
            ids.setdefault(html.unescape(name.strip()), item_id)
    return ids


def page_path(item_id, lang):
    return os.path.join(CACHE, f'kiranico_item_{item_id}_{lang}.html')


def main():
    ids = item_ids()
    json.dump(ids, open(os.path.join(CACHE, 'kiranico_item_ids.json'), 'w', encoding='utf8'),
              ensure_ascii=False, indent=1)
    todo = [(i, lang) for i in sorted(set(ids.values())) for lang in ('en', 'pt')
            if not os.path.exists(page_path(i, lang))]

    def one(job):
        item_id, lang = job
        prefix = '/pt-BR' if lang == 'pt' else ''
        try:
            fetch(f'{KIRANICO}{prefix}/data/items/{item_id}', page_path(item_id, lang))
        except Exception as e:  # noqa: BLE001 - a material without a page has no sources
            print('page failed', item_id, lang, e, flush=True)
        time.sleep(0.3)

    with ThreadPoolExecutor(max_workers=4) as pool:
        for n, _ in enumerate(pool.map(one, todo)):
            if n % 250 == 0:
                print('pages', n, 'of', len(todo), flush=True)
    print('done', len(ids), 'items', flush=True)


if __name__ == '__main__':
    main()
