"""Downloads the official game logos used as the game tabs (feature 005,
research R5) from the Monster Hunter Wiki, trims them to their bounding box
and saves them as 138 px tall WebP with alpha (3x of the 46 dp tab height).

    python tool/data/fetch_game_logos.py
"""
import io
import os
import time
import urllib.request

from PIL import Image

from common import REPO, UA  # noqa: E402  (sets cwd to the cache)

FILEPATH = 'https://monsterhunterwiki.org/wiki/Special:FilePath/'
LOGOS = {  # asset name -> wiki file
    'world_iceborne': 'MHWI-Logo.png',
    'rise_sunbreak': 'MHRS-Logo.png',
    'wilds': 'MHWilds-Logo.png',
}
HEIGHT = 138
OUT = os.path.join(REPO, 'assets', 'images', 'games')


def fetch(name):
    cache = os.path.join('logos', name)
    if not os.path.exists(cache):
        req = urllib.request.Request(FILEPATH + name, headers=UA)
        with urllib.request.urlopen(req, timeout=60) as r:
            if not r.headers.get('Content-Type', '').startswith('image/'):
                raise RuntimeError(f'not an image: {name}')
            data = r.read()
        os.makedirs('logos', exist_ok=True)
        open(cache, 'wb').write(data)
        time.sleep(1)
    return open(cache, 'rb').read()


def main():
    os.makedirs(OUT, exist_ok=True)
    for asset, name in LOGOS.items():
        im = Image.open(io.BytesIO(fetch(name))).convert('RGBA')
        im = im.crop(im.getchannel('A').getbbox())
        im = im.resize((round(im.width * HEIGHT / im.height), HEIGHT), Image.LANCZOS)
        path = os.path.join(OUT, f'{asset}.webp')
        im.save(path, 'WEBP', lossless=True, method=6)
        print(asset, im.size, os.path.getsize(path), 'bytes')


if __name__ == '__main__':
    main()
