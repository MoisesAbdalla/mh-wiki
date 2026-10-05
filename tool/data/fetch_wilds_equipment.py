"""Caches the Monster Hunter Wilds equipment data from wilds.mhdb.io (010 research R1).

Each endpoint is fetched once per language (en, pt-BR) into
tool/data/.cache/wilds_mhdb_<endpoint>_<lang>.json. Existing files are kept,
so a second run only fetches what is missing.
"""
import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, '.cache')
API = 'https://wilds.mhdb.io'
ENDPOINTS = ['weapons', 'armor/sets', 'skills', 'decorations', 'charms', 'items']
LANGS = ['en', 'pt-BR']


def cache_path(endpoint, lang):
    return os.path.join(CACHE, f'wilds_mhdb_{endpoint.replace("/", "-")}_{lang}.json')


def fetch(endpoint, lang):
    path = cache_path(endpoint, lang)
    if os.path.exists(path) and os.path.getsize(path) > 0:
        return path
    url = f'{API}/{lang}/{endpoint}'
    for attempt in range(3):
        out = subprocess.run(['curl', '-sfL', '-m', '180', '-A', 'Mozilla/5.0', url],
                             capture_output=True)
        if out.returncode == 0:
            data = json.loads(out.stdout)
            assert isinstance(data, list) and data, url
            with open(path, 'w', encoding='utf8') as f:
                json.dump(data, f, ensure_ascii=False)
            time.sleep(1)
            return path
        time.sleep(3 * (attempt + 1))
    sys.exit(f'failed: {url}')


def main():
    os.makedirs(CACHE, exist_ok=True)
    for endpoint in ENDPOINTS:
        for lang in LANGS:
            path = fetch(endpoint, lang)
            with open(path, encoding='utf8') as f:
                n = len(json.load(f))
            print(f'{endpoint:12} {lang:6} {n:5}  {os.path.getsize(path) // 1024} KB')


if __name__ == '__main__':
    main()
