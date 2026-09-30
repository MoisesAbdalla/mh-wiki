"""Extracts MH World: Iceborne monster data from Kiranico (en + pt-BR pages).

Output: world_raw/<slug>.json with habitats, parts and drops per rank, each
name paired en/ptBr. Weaknesses are NOT taken from here (Kiranico lists
hitzones, not the in-game star ratings).
"""
import html, json, os, re, sys, time, urllib.request
import common  # noqa: E402,F401  (sets cwd to the cache)

BASE = 'https://mhworld.kiranico.com'
UA = {'User-Agent': 'Mozilla/5.0 (mh-wiki data curation; personal study project)'}
OUT = 'world_raw'
os.makedirs(OUT, exist_ok=True)

ROSTER = {  # slug -> kiranico path id/slug
    'great-jagras': 'zJ1Sb/great-jagras',
    'anjanath': 'ZqptN/anjanath',
    'rathian': 'Rz9Tb/rathian',
    'pink-rathian': 'BnNTd/pink-rathian',
    'rathalos': 'BnetX/rathalos',
    'diablos': 'BYXHE/diablos',
    'nergigante': 'aYaUV/nergigante',
    'zinogre': 'Ak8TZ/zinogre',
    'velkhana': 'J1pFn/velkhana',
    'alatreon': 'ErdcV/alatreon',
}

RANKS = {'Low Rank': 'low', 'High Rank': 'high', 'Master Rank': 'master'}


def fetch(url, cache):
    if os.path.exists(cache):
        return open(cache, encoding='utf8').read()
    req = urllib.request.Request(url, headers=UA)
    data = urllib.request.urlopen(req, timeout=60).read().decode('utf8')
    open(cache, 'w', encoding='utf8').write(data)
    time.sleep(1.5)  # be polite
    return data


def clean(text):
    return html.unescape(re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', text))).strip()


def section(page, header):
    """HTML between <h6 class="element-header">header</h6> and the next one."""
    headers = list(re.finditer(r'<h6 class="element-header">(.*?)</h6>', page, re.S))
    for i, m in enumerate(headers):
        if clean(m.group(1)) == header:
            end = headers[i + 1].start() if i + 1 < len(headers) else len(page)
            return page[m.end():end]
    return ''


def rank_blocks(sec):
    """[(label, html)] for each rank column, in page order (label as shown)."""
    marks = [(m.start(), clean(m.group(1))) for m in re.finditer(r'<h6>(.*?)</h6>', sec, re.S)]
    blocks = []
    for i, (pos, label) in enumerate(marks):
        end = marks[i + 1][0] if i + 1 < len(marks) else len(sec)
        blocks.append((label, sec[pos:end]))
    return blocks


def tables(block):
    result = []
    for t in re.findall(r'<table.*?</table>', block, re.S):
        title = re.search(r'<td colspan="2">(.*?)</td>', t, re.S)
        rows = re.findall(
            r'/items/(\w+)/[^"]*"[^>]*>.*?<span>(.*?)</span></a>(.*?)</td>\s*<td class="text-right">\s*(\d+(?:\.\d+)?)%',
            t, re.S)
        result.append({
            'title': clean(title.group(1)) if title else '',
            'rows': [{'itemId': i, 'name': clean(n), 'qty': clean(q), 'rate': float(r)} for i, n, q, r in rows],
        })
    return result


def parse(page, lang):
    exp = section(page, 'Expeditions' if lang == 'en' else 'Expedições')
    locales = [re.sub(r'\s*\(\d+%\)$', '', clean(x)) for x in re.findall(r'<td>([^<]*\(\d+%\))</td>', exp)]
    guiding = bool(re.search(r'<h6 class="element-header">(The Guiding Lands|As Terras-Guias)</h6>', page))
    carve_sec = section(page, 'Carves' if lang == 'en' else 'Talha')
    reward_sec = section(page, 'Rewards' if lang == 'en' else 'Prêmios')
    return {
        'locales': list(dict.fromkeys(locales)),
        'guidingLands': guiding,
        'carves': [(r, tables(b)) for r, b in rank_blocks(carve_sec)],
        'rewards': [(r, tables(b)) for r, b in rank_blocks(reward_sec)],
        'title': clean(re.search(r'<title>(.*?) - MH', page).group(1)),
    }


def main():
    for slug, path in ROSTER.items():
        en = parse(fetch(f'{BASE}/en/monsters/{path}', f'cache_world_{slug}_en.html'), 'en')
        pt = parse(fetch(f'{BASE}/pt-BR/monsters/{path}', f'cache_world_{slug}_pt.html'), 'pt')
        json.dump({'slug': slug, 'url': f'{BASE}/en/monsters/{path}', 'en': en, 'pt': pt},
                  open(f'{OUT}/{slug}.json', 'w', encoding='utf8'), ensure_ascii=False, indent=1)
        print(slug, 'locales', en['locales'], 'GL', en['guidingLands'],
              'carve ranks', [r for r, _ in en['carves']], 'reward ranks', [r for r, _ in en['rewards']])


if __name__ == '__main__':
    main()
