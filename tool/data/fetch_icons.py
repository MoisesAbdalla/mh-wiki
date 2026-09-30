"""Downloads the hunter's-notes icons of the roster from the Monster Hunter Wiki,
converts them to 256x256 WebP (transparent) and records them in the datasets.
Research R1/R2 of specs/002-visual-identity.
"""
import io, json, os, sys, time, urllib.parse, urllib.request
from PIL import Image

from common import REPO as ROOT, selected_games  # noqa: E402
UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki personal study project)'}
GAMES = {  # dataset key -> (file prefix, extension)
    'world_iceborne': ('MHWI', 'png'),
    'rise_sunbreak': ('MHRS', 'png'),
    'wilds': ('MHWilds', 'webp'),
}
SIZE = 256
FILEPATH = 'https://monsterhunterwiki.org/wiki/Special:FilePath/'


def fetch(url):
    """Downloads an image once; later runs read it from the cache."""
    cache = os.path.join('icons', urllib.parse.unquote(url.rsplit('/', 1)[1]))
    if os.path.exists(cache):
        return open(cache, 'rb').read()
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=60) as r:
        if not r.headers.get('Content-Type', '').startswith('image/'):
            raise RuntimeError(f'not an image: {url}')
        data = r.read()
    os.makedirs('icons', exist_ok=True)
    open(cache, 'wb').write(data)
    time.sleep(1)
    return data


def to_webp(raw, out):
    im = Image.open(io.BytesIO(raw)).convert('RGBA')
    im.thumbnail((SIZE, SIZE), Image.LANCZOS)
    canvas = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    canvas.paste(im, ((SIZE - im.width) // 2, (SIZE - im.height) // 2), im)
    canvas.save(out, 'WEBP', quality=88, method=6)


failures = []
for game, (prefix, ext) in ((g, GAMES[g]) for g in selected_games()):
    path = os.path.join(ROOT, 'assets', 'data', game, 'monsters.json')
    data = json.load(open(path, encoding='utf8'))
    for m in data['monsters']:
        name = m['name']['en'].replace(' ', '_')
        file = f'{prefix}-{name}_Icon.{ext}'
        rel = f'assets/images/monsters/{game}/{m["slug"]}.webp'
        try:
            to_webp(fetch(FILEPATH + urllib.parse.quote(file)), os.path.join(ROOT, rel))
        except Exception as e:  # noqa: BLE001 - report every miss at the end
            failures.append((game, m['slug'], file, str(e)))
            continue
        m['image'] = rel
        print('ok', game, m['slug'], file, os.path.getsize(os.path.join(ROOT, rel)), 'bytes')
    data['sources'] = [s for s in data['sources'] if s['name'] != 'Monster Hunter Wiki (icons)']
    data['sources'].append({
        'name': 'Monster Hunter Wiki (icons)',
        'url': 'https://monsterhunterwiki.org/',
        'notes': f"Hunter's-notes icons: Special:FilePath/{prefix}-<Name>_Icon.{ext}, "
                 'converted to 256x256 WebP. Capcom artwork, used locally in a personal study project.',
    })
    json.dump(data, open(path, 'w', encoding='utf8', newline='\n'), ensure_ascii=False, indent=2)

if failures:
    print('FAILURES:')
    for f in failures:
        print(' ', f)
    sys.exit(1)
