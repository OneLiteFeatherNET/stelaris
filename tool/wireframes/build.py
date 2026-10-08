"""Render every wireframe to design/wireframes/.

    python3 tool/wireframes/build.py

Produces one SVG per screen plus all-screens.svg (every screen laid out
on one board). Import into Penpot by dragging the SVGs onto the canvas.
"""
from html import escape
import importlib
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from wf import W, H, FONT, MUTED, INK  # noqa: E402

OUT = pathlib.Path(__file__).resolve().parents[2] / "design" / "wireframes"
MODULES = ["screens_a", "screens_b", "screens_c"]
COLS, GAP, LABEL = 4, 160, 48


def slug(title):
    return re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")


def load_screens():
    screens = []
    for m in MODULES:
        screens += [f() for f in importlib.import_module(m).SCREENS]
    return screens


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("*.svg"):
        old.unlink()
    screens = load_screens()
    board = []
    for i, s in enumerate(screens):
        svg = s.svg()
        (OUT / f"{slug(s.title)}.svg").write_text(svg)
        r, c = divmod(i, COLS)
        x, y = c * (W + GAP), r * (H + GAP + LABEL)
        inner = svg.split(">", 1)[1].rsplit("</svg>", 1)[0]
        inner = re.sub(r"<title>.*?</title>", "", inner)
        board.append(f'<text x="{x}" y="{y + 32}" font-family="{FONT}" font-size="28" '
                     f'font-weight="600" fill="{INK}">{escape(s.title)}</text>'
                     f'<g id="{slug(s.title)}" transform="translate({x} {y + LABEL})">'
                     f'{inner}</g>')
    rows = -(-len(screens) // COLS)
    bw, bh = COLS * (W + GAP) - GAP, rows * (H + GAP + LABEL) - GAP
    (OUT / "all-screens.svg").write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{bw}" height="{bh}" '
        f'viewBox="0 0 {bw} {bh}">\n' + "\n".join(board) + "\n</svg>\n")
    print(f"{len(screens)} screens -> {OUT}")


if __name__ == "__main__":
    main()
