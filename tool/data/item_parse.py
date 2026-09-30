import html, re

def clean(t):
    return html.unescape(re.sub(r'\s+', ' ', re.sub(r'<[^>]+>', ' ', t))).strip()

def item_table(page):
    """[(item name, [cell texts])] of the 'Trap & Flash ... Effectiveness' table."""
    i = page.find('Trap &amp; Flash')
    if i < 0:
        return None
    start = page.rfind('<table', 0, i)
    end = page.find('</table>', i)
    rows = []
    for tr in re.findall(r'<tr>(.*?)</tr>', page[start:end], re.S):
        name = re.search(r'<div style="margin: 0px;">(.*?)</div>', tr, re.S)
        if not name:
            continue
        cells = [clean(td) for td in re.findall(r'<td[^>]*>(.*?)</td>', tr, re.S)]
        rows.append((clean(name.group(1)), cells))
    return rows

def infobox(page):
    """{'Dung Pods': text, 'Flash Pods': text, ...} from the infobox row, if any."""
    i = page.find('<small>Dung Pods</small>')
    if i < 0:
        return {}
    start = page.rfind('<tr', 0, i)
    head_end = page.find('</tr>', i)
    heads = [clean(h) for h in re.findall(r'<small>(.*?)</small>', page[start:head_end], re.S)]
    row_end = page.find('</tr>', head_end + 5)
    vals = [clean(td) for td in re.findall(r'<td[^>]*>(.*?)</td>', page[head_end:row_end], re.S)]
    return dict(zip(heads, vals))
