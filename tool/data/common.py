"""Shared paths and helpers of the data pipeline (feature 004, research R8).

Every script runs with the page cache (`tool/data/.cache/`) as its working
directory, so cached pages are read and written by bare file names.
"""
import html
import json
import os
import re
import sys
import time
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
CACHE = os.path.join(HERE, '.cache')
GAMES = ('world_iceborne', 'rise_sunbreak', 'wilds')
UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki data curation; personal study project)'}

os.makedirs(CACHE, exist_ok=True)
os.chdir(CACHE)
sys.stdout.reconfigure(encoding='utf-8')


def dataset_path(game):
    return os.path.join(REPO, 'assets', 'data', game, 'monsters.json')


def selected_games(argv=None):
    """Games named on the command line (all when none)."""
    args = [a for a in (sys.argv[1:] if argv is None else argv) if not a.startswith('-')]
    for a in args:
        if a not in GAMES:
            sys.exit(f'unknown game "{a}"; expected one of {", ".join(GAMES)}')
    return args or list(GAMES)


def roster(game):
    """{slug: entry} of tool/data/rosters/<game>.json, or {} when absent."""
    path = os.path.join(HERE, 'rosters', f'{game}.json')
    if not os.path.exists(path):
        return {}
    return {m['slug']: m for m in json.load(open(path, encoding='utf8'))['monsters']}


def clean(text):
    return html.unescape(re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', text))).strip()


def fetch(url, cache):
    """The page at [url], read from / written to the cache file [cache]."""
    if os.path.exists(cache):
        return open(cache, encoding='utf8').read()
    req = urllib.request.Request(url, headers=UA)
    for attempt in range(3):  # the sites answer 5xx now and then under load
        try:
            data = urllib.request.urlopen(req, timeout=60).read().decode('utf8')
            break
        except urllib.error.HTTPError as e:
            if e.code < 500 or attempt == 2:
                raise
            time.sleep(10 * (attempt + 1))
    open(cache, 'w', encoding='utf8').write(data)
    time.sleep(1.2)
    return data


def load_dataset(game):
    return json.load(open(dataset_path(game), encoding='utf8'))


def save_dataset(game, data):
    with open(dataset_path(game), 'w', encoding='utf8', newline='\n') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
