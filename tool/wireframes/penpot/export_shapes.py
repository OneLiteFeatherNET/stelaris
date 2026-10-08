"""Turn the wireframe screens into a JSON shape list for build.mjs.

Reads the same Svg objects build.py renders and maps every rect, line,
circle and text to a Penpot shape (absolute coordinates per board).
"""
import json
import pathlib
import sys
import xml.etree.ElementTree as ET

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import build  # noqa: E402

NS = "{http://www.w3.org/2000/svg}"


def f(el, k, d=0.0):
    return float(el.get(k, d))


def paint(color, opacity="1"):
    if not color or color == "none":
        return []
    return [{"fillColor": color, "fillOpacity": float(opacity)}]


def stroke(el, align="inner"):
    c = el.get("stroke")
    if not c or c == "none":
        return []
    return [{"strokeColor": c, "strokeOpacity": 1, "strokeWidth": f(el, "stroke-width", 1),
             "strokeAlignment": align,
             "strokeStyle": "dashed" if el.get("stroke-dasharray") else "solid"}]


def text_shape(el):
    s = el.text or ""
    size = f(el, "font-size", 14)
    weight = el.get("font-weight", "400")
    italic = el.get("font-style") == "italic"
    mono = "monospace" in el.get("font-family", "")
    anchor = el.get("text-anchor", "start")
    w = max(8, len(s) * size * 0.58 + 6)
    h = size * 1.25
    x = f(el, "x")
    if anchor == "middle":
        x -= w / 2
    elif anchor == "end":
        x -= w
    variant = ("regular" if weight == "400" else weight) if not italic else \
        ("italic" if weight == "400" else f"{weight}italic")
    leaf = {"text": s, "fontSize": str(int(size)), "fontWeight": weight,
            "fontStyle": "italic" if italic else "normal", "fontVariantId": variant,
            "fontId": "gfont-roboto-mono" if mono else "gfont-work-sans",
            "fontFamily": "Roboto Mono" if mono else "Work Sans",
            "fills": paint(el.get("fill", "#000000"))}
    align = {"start": "left", "middle": "center", "end": "right"}[anchor]
    return {"kind": "text", "name": s[:40] or "text", "x": x, "y": f(el, "y") - size * 0.95,
            "width": w, "height": h,
            "growType": "auto-width" if anchor == "start" else "fixed",
            "content": {"type": "root", "children": [{"type": "paragraph-set", "children": [
                {"type": "paragraph", "textAlign": align, "children": [leaf]}]}]}}


def shapes_of(svg_text):
    root = ET.fromstring(svg_text)
    out, bg = [], "#FFFFFF"
    for i, el in enumerate(root):
        tag = el.tag.replace(NS, "")
        if tag == "rect":
            x, y, w, h = f(el, "x"), f(el, "y"), f(el, "width"), f(el, "height")
            if i == 1 and (x, y) == (0, 0):  # page background -> board fill
                bg = el.get("fill")
                continue
            r = min(f(el, "rx"), w / 2, h / 2)
            out.append({"kind": "rect", "name": "rect", "x": x, "y": y, "width": w, "height": h,
                        "r1": r, "r2": r, "r3": r, "r4": r,
                        "fills": paint(el.get("fill"), el.get("fill-opacity", "1")),
                        "strokes": stroke(el)})
        elif tag == "circle":
            cx, cy, r = f(el, "cx"), f(el, "cy"), f(el, "r")
            out.append({"kind": "circle", "name": "circle", "x": cx - r, "y": cy - r,
                        "width": 2 * r, "height": 2 * r, "fills": paint(el.get("fill")),
                        "strokes": stroke(el)})
        elif tag == "line":
            x1, y1, x2, y2 = f(el, "x1"), f(el, "y1"), f(el, "x2"), f(el, "y2")
            out.append({"kind": "path", "name": "line", "x": min(x1, x2), "y": min(y1, y2),
                        "width": max(abs(x2 - x1), 0.01), "height": max(abs(y2 - y1), 0.01),
                        "content": [{"command": "move-to", "params": {"x": x1, "y": y1}},
                                    {"command": "line-to", "params": {"x": x2, "y": y2}}],
                        "fills": [], "strokes": stroke(el, "center")})
        elif tag == "text":
            out.append(text_shape(el))
    return bg, out


def main(dest):
    boards = []
    for s in build.load_screens():
        bg, shapes = shapes_of(s.svg())
        boards.append({"name": s.title, "key": s.title.split()[0], "width": s.w,
                       "height": s.h, "fill": bg, "shapes": shapes,
                       "links": [dict(zip("xywh", l[:4]), target=l[4]) for l in s.links]})
    from wf import M3
    pathlib.Path(dest).write_text(json.dumps({"colors": M3, "boards": boards}))
    print(f"{len(boards)} boards -> {dest}")


if __name__ == "__main__":
    main(sys.argv[1])
