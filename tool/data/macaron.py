"""HP of Wilds tempered and arch-tempered monsters from the macarongamemo table
(feature 004, research R4). Kiranico does not list tempered free hunts or the
arch-tempered event quests.

The table "歴戦・狂竜化個体の体力一覧" has one row per kind (歴戦 tempered,
歴戦王 arch-tempered, 狂竜化 frenzied), quest stars and Japanese monster name,
with the HP of strength levels ♦3–♦5 (middle of the 5 size variations; "–" or
empty when that level does not exist). Japanese names are matched to slugs
through the Kiranico Japanese monster pages.
"""
import html
import json
import re

from common import clean, fetch, roster

URL = 'https://macarongamemo.com/entry/mhwilds-monster-hp'
KIRANICO = 'https://mhwilds.kiranico.com'
TABLE = '歴戦・狂竜化個体の体力一覧'
KINDS = {'歴戦': 'tempered', '歴戦王': 'archTempered'}


def _table(first_header):
    """Rows (cell texts) of the page table whose first header cell is [first_header]."""
    page = re.sub(r'<script.*?</script>|<style.*?</style>', '', fetch(URL, 'macaron_hp.html'), flags=re.S)
    table = next(t for t in re.findall(r'<table.*?</table>', page, re.S)
                 if re.search(rf'<tr[^>]*>\s*<th[^>]*>\s*{first_header}\s*</th>', t))
    for tr in re.findall(r'<tr.*?</tr>', table, re.S):
        yield [clean(c) for c in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', tr, re.S)]


def _rows():
    """(kind, stars, name, [hp]) of the tempered / arch-tempered table (TABLE)."""
    for cells in _table('区分'):
        if len(cells) == 6 and cells[1].isdigit():
            yield cells[0], int(cells[1]), cells[2], [int(v) for v in cells[3:] if v.isdigit()]


def _normal_rows():
    """(stars, name, hp) of the normal table ("通常個体の体力一覧") at strength ♦3, the level
    of every assignment and optional quest target. Non-numeric cells, such as Gogmazios'
    "(410000)", which the page does not explain, are skipped."""
    for cells in _table('モンスター'):
        if len(cells) == 7 and cells[1].isdigit() and cells[4].isdigit():
            yield int(cells[1]), cells[0], int(cells[4])


def _ja_names():
    """{Japanese name: slug} of the Wilds monsters with a Kiranico page (bases, guardians)."""
    names = {}
    for slug, entry in roster('wilds').items():
        if entry.get('dataFrom'):
            continue
        en = fetch(f'{KIRANICO}/data/monsters/{slug}', f'cache_wilds_{slug}_en.html')
        path = re.search(r'\\?"version\\?":\\?"ja\\?",\\?"url\\?":\\?"(/ja/data/monsters/[^"\\]+)', en).group(1)
        ja = fetch(KIRANICO + path, f'cache_wilds_{slug}_ja.html')
        title = re.search(r'<title>(.*?) \|', ja).group(1)
        names[html.unescape(title).strip()] = slug
    return names


def wilds_hp():
    """{(slug, 'base' | 'tempered' | 'archTempered'): [(stars, hp)]}, every listed value."""
    names = _ja_names()
    result = {}
    for kind, stars, name, values in _rows():
        if kind not in KINDS or not values:
            continue
        if name not in names:
            raise SystemExit(f'macarongamemo: unknown monster "{name}"')
        result.setdefault((names[name], KINDS[kind]), []).extend((stars, v) for v in values)
    for stars, name, hp in _normal_rows():
        if name not in names:  # e.g. Nerscylla Clone, a special-quest monster outside the roster
            print(f'macarongamemo: "{name}" is not in the roster, skipped')
            continue
        result[(names[name], 'base')] = [(stars, hp)]
    return result


if __name__ == '__main__':
    for key, values in sorted(wilds_hp().items()):
        print(key, values)
