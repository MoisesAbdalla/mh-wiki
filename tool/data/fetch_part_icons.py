"""Downloads the Rise: Sunbreak equipment part icons (helmet, chest, arms, waist,
legs, talisman) in each rarity colour from the Monster Hunter Fandom wiki and
writes them as 64 px WebP to assets/images/armor/parts/<part>-<rarity>.webp.

The rarity colours follow the wiki's MHRise-Rarity and MHRS-Rarity templates.
"""
import io
import json
import os
import subprocess
import urllib.parse

from PIL import Image

UA = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126 Safari/537.36')
API = 'https://monsterhunter.fandom.com/api.php?'
OUT = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'images', 'armor', 'parts')

PARTS = {
    'head': 'Helmet',
    'chest': 'Chestplate',
    'arms': 'Armguard',
    'waist': 'Waist',
    'legs': 'Leggings',
    'talisman': 'Talisman',
}
COLOURS = {
    1: 'White', 2: 'Yellow', 3: 'Red', 4: 'Green', 5: 'Blue', 6: 'Dark Blue',
    7: 'Dark Red', 8: 'Light Blue', 9: 'Purple', 10: 'Orange',
}


def get(url):
    # The wiki refuses Python's TLS client; curl gets through.
    return subprocess.run(['curl', '-sfL', '-A', UA, '-e', 'https://monsterhunter.fandom.com/', url], check=True, capture_output=True).stdout


def thumb(title, width):
    """The PNG rendering of a wiki SVG, or None when the file does not exist."""
    q = urllib.parse.urlencode({
        'action': 'query', 'titles': f'File:{title}', 'prop': 'imageinfo',
        'iiprop': 'url', 'iiurlwidth': width, 'format': 'json',
    })
    page = next(iter(json.loads(get(API + q))['query']['pages'].values()))
    info = page.get('imageinfo')
    if not info:
        return None
    return info[0]['url'].split('?')[0] + f'/scale-to-width-down/{width}?format=png'


def tint(part, rarity):
    """The white icon of [part], recoloured with the main colour of the
    helmet of [rarity]; dark outlines stay dark."""
    white = Image.open(os.path.join(OUT, f'{part}-1.webp')).convert('RGBA')
    head = Image.open(os.path.join(OUT, f'head-{rarity}.webp')).convert('RGBA')
    colours = [c for n, c in sorted(head.getcolors(1 << 16), reverse=True)
               if c[3] > 200 and sum(c[:3]) > 300]
    target = colours[0][:3]
    out = white.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            k = (r + g + b) / (3 * 255)
            px[x, y] = tuple(round(t * k) for t in target) + (a,)
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    sources = []
    for part, name in PARTS.items():
        for rarity, colour in COLOURS.items():
            candidates = [f'{g} Item Icon-{name} Equipment {colour}.svg' for g in ('MHRS', 'MHRise')]
            for title in candidates:
                url = thumb(title, 128)
                if url:
                    break
            else:
                # The wiki has no Sunbreak waist icons: tint the white one with
                # the colour of the helmet of that rarity.
                tinted = tint(part, rarity)
                tinted.save(os.path.join(OUT, f'{part}-{rarity}.webp'), 'WEBP', lossless=True)
                sources.append(f'- `{part}-{rarity}.webp`: `{part}-1.webp` tinted like `head-{rarity}.webp`')
                print(part, rarity, 'tinted')
                continue
            im = Image.open(io.BytesIO(get(url))).convert('RGBA')
            im.thumbnail((64, 64), Image.LANCZOS)
            im.save(os.path.join(OUT, f'{part}-{rarity}.webp'), 'WEBP', lossless=True)
            sources.append(f'- `{part}-{rarity}.webp`: {title}')
            print(part, rarity, title)
    with open(os.path.join(OUT, 'SOURCES.md'), 'w', encoding='utf8') as f:
        f.write('# Equipment part icons\n\nFrom the Monster Hunter Fandom wiki (MHRise / MHRS item '
                'icons, colour by rarity as in its MHRise-Rarity and MHRS-Rarity templates). Capcom '
                'artwork, used locally like the other icons. Built by `tool/data/fetch_part_icons.py`.\n\n')
        f.write('\n'.join(sources) + '\n')


if __name__ == '__main__':
    main()
