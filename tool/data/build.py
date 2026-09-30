"""Rebuilds one game's dataset end to end (feature 004, research R8).

    python tool/data/build.py wilds            # or rise_sunbreak / world_iceborne
    python tool/data/build.py wilds --no-icons

Steps: base data (names, weaknesses, habitats, parts, drops) -> HP per rank and
party factors (003 R1/R2) -> hunting item reactions (003 R3) -> thumbnails
(002). Pages are cached in tool/data/.cache/; delete it to fetch fresh pages.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = {
    'wilds': ['build_wilds.py'],
    'rise_sunbreak': ['build_rise.py'],
    'world_iceborne': ['kiranico_world.py', 'build_world.py'],
}


def run(script, *args):
    print(f'== {script} {" ".join(args)}', flush=True)
    subprocess.run([sys.executable, os.path.join(HERE, script), *args], check=True)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('-')]
    if len(args) != 1 or args[0] not in BASE:
        sys.exit(f'usage: build.py <{"|".join(BASE)}> [--no-icons]')
    game = args[0]
    for script in BASE[game]:
        run(script)
    run('hp_extract.py', game)
    run('items_extract.py', game)
    if '--no-icons' not in sys.argv:
        run('fetch_icons.py', game)


if __name__ == '__main__':
    main()
