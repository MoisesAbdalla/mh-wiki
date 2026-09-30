"""Extracts MH World: Iceborne monster data from Kiranico (en + pt-BR pages).

Output: world_raw/<slug>.json with habitats, parts and drops per rank, each
name paired en/ptBr. Weaknesses are NOT taken from here (Kiranico lists
hitzones, not the in-game star ratings).
"""
import html, json, os, re
import common  # noqa: E402,F401  (sets cwd to the cache)

BASE = 'https://mhworld.kiranico.com'
OUT = 'world_raw'
os.makedirs(OUT, exist_ok=True)

ROSTER = {e['slug']: e['kiranicoPath'] for e in common.roster('world_iceborne').values()
          if 'versionOf' not in e}  # slug -> kiranico path id/slug (tool/data/rosters)

RANKS = {'Low Rank': 'low', 'High Rank': 'high', 'Master Rank': 'master'}


fetch = common.fetch


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


def quest_pages(entry):
    """[(quest, kiranico path, en page, pt page, stars label)] of a version's quests, linked from the base page."""
    base = fetch(f'{BASE}/en/monsters/{entry["kiranicoPath"]}', f'cache_world_{entry["versionOf"]}_en.html')
    links = {}
    for path, text in re.findall(r'href="https://mhworld\.kiranico\.com/en/quests/(\w+/[^"]+)"[^>]*>(.*?)</a>', base, re.S):
        m = re.match(r'(M?★\d+) (.*)$', clean(text))
        if m:
            links.setdefault(m.group(2), (path, m.group(1)))
    pages = []
    for q in entry['quests']:
        if q['name'] not in links:
            print('  quest not on the Kiranico base page:', entry['slug'], q['name'])
            continue
        path, stars = links[q['name']]
        file = path.replace('/', '_')
        en = fetch(f'{BASE}/en/quests/{path}', f'cache_world_quest_{file}_en.html')
        pt = fetch(f'{BASE}/pt-BR/quests/{path}', f'cache_world_quest_{file}_pt.html')
        pages.append((q, path, en, pt, stars))
    return pages


def rank_of(stars):
    return 'master' if stars.startswith('M') else ('low' if int(stars.lstrip('★')) <= 5 else 'high')


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
