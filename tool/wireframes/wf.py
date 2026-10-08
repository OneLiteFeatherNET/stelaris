"""Tiny SVG wireframe kit.

Every screen is a plain SVG built from rect/line/circle/text so Penpot
imports it as editable shapes (drag the .svg onto the canvas).
"""
from __future__ import annotations

from html import escape

W, H = 1440, 900          # desktop frame
FONT = "Work Sans, Roboto, Arial, sans-serif"

# Grayscale palette + one accent for primary actions / selection.
BG = "#FFFFFF"
SURFACE = "#F4F4F5"
SURFACE_2 = "#E4E4E7"
STROKE = "#A1A1AA"
INK = "#18181B"
MUTED = "#71717A"
ACCENT = "#3F51B5"
ACCENT_SOFT = "#E3E6F5"
DANGER = "#B3261E"
NOTE = "#FFF4C2"


class Svg:
    def __init__(self, title: str, w: int = W, h: int = H):
        self.title, self.w, self.h = title, w, h
        self.parts: list[str] = []
        self.rect(0, 0, w, h, fill=BG, stroke="none")

    # -- primitives -----------------------------------------------------
    def add(self, s: str):
        self.parts.append(s)

    def rect(self, x, y, w, h, fill=SURFACE, stroke=STROKE, r=0, sw=1, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ""
        self.add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" '
                 f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')

    def line(self, x1, y1, x2, y2, stroke=STROKE, sw=1, dash=None):
        d = f' stroke-dasharray="{dash}"' if dash else ""
        self.add(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
                 f'stroke="{stroke}" stroke-width="{sw}"{d}/>')

    def circle(self, cx, cy, r, fill=SURFACE_2, stroke=STROKE):
        self.add(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" stroke="{stroke}"/>')

    def text(self, x, y, s, size=14, fill=INK, weight=400, anchor="start", italic=False):
        st = ' font-style="italic"' if italic else ""
        self.add(f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
                 f'font-weight="{weight}" fill="{fill}" text-anchor="{anchor}"{st}>'
                 f'{escape(s)}</text>')

    # -- components -----------------------------------------------------
    def icon(self, x, y, s=24, label=None, fill=SURFACE_2):
        """Placeholder icon: box with a cross."""
        self.rect(x, y, s, s, fill=fill, stroke=STROKE, r=4)
        self.line(x + 4, y + 4, x + s - 4, y + s - 4)
        self.line(x + s - 4, y + 4, x + 4, y + s - 4)
        if label:
            self.text(x + s / 2, y + s + 14, label, 11, MUTED, anchor="middle")

    def image(self, x, y, w, h, label="image"):
        self.rect(x, y, w, h, fill=SURFACE_2)
        self.line(x, y, x + w, y + h)
        self.line(x + w, y, x, y + h)
        self.text(x + w / 2, y + h / 2 + 4, label, 11, MUTED, anchor="middle")

    def button(self, x, y, label, kind="filled", w=None, h=40, icon=False):
        w = w or max(88, len(label) * 8 + (56 if icon else 40))
        if kind == "filled":
            self.rect(x, y, w, h, fill=ACCENT, stroke=ACCENT, r=h / 2)
            col = "#FFFFFF"
        elif kind == "tonal":
            self.rect(x, y, w, h, fill=ACCENT_SOFT, stroke=ACCENT_SOFT, r=h / 2)
            col = INK
        elif kind == "outlined":
            self.rect(x, y, w, h, fill=BG, stroke=STROKE, r=h / 2)
            col = ACCENT
        elif kind == "danger":
            self.rect(x, y, w, h, fill=DANGER, stroke=DANGER, r=h / 2)
            col = "#FFFFFF"
        else:  # text button
            col = ACCENT
        tx = x + w / 2
        if icon:
            self.icon(x + 14, y + h / 2 - 9, 18, fill="none")
            tx += 10
        self.text(tx, y + h / 2 + 5, label, 14, col, 500, "middle")
        return w

    def icon_button(self, x, y, s=40, filled=False):
        self.circle(x + s / 2, y + s / 2, s / 2,
                    fill=ACCENT_SOFT if filled else BG, stroke=STROKE)
        self.icon(x + s / 2 - 9, y + s / 2 - 9, 18, fill="none")

    def field(self, x, y, w, label, value="", h=56, trailing=False,
              multiline=False, helper=None, dropdown=False):
        """Outlined Material text field."""
        self.rect(x, y, w, h, fill=BG, stroke=STROKE, r=4)
        self.rect(x + 10, y - 7, len(label) * 6.6 + 8, 14, fill=BG, stroke="none")
        self.text(x + 14, y + 4, label, 12, MUTED)
        if value:
            self.text(x + 16, y + (28 if multiline else h / 2 + 5), value, 15, INK)
        if dropdown:
            self.text(x + w - 22, y + h / 2 + 5, "▾", 16, MUTED, anchor="middle")
        elif trailing:
            self.icon(x + w - 34, y + h / 2 - 10, 20, fill="none")
        if helper:
            self.text(x + 16, y + h + 16, helper, 12, MUTED)

    def search(self, x, y, w, hint="Search", h=48):
        self.rect(x, y, w, h, fill=SURFACE_2, stroke="none", r=h / 2)
        self.icon(x + 16, y + h / 2 - 10, 20, fill="none")
        self.text(x + 48, y + h / 2 + 5, hint, 15, MUTED)

    def chip(self, x, y, label, selected=False, close=False, h=32):
        w = len(label) * 7.5 + 28 + (20 if close or selected else 0)
        self.rect(x, y, w, h, fill=ACCENT_SOFT if selected else BG,
                  stroke=ACCENT if selected else STROKE, r=8)
        tx = x + 14
        if selected:
            self.text(tx, y + h / 2 + 5, "✓", 13, ACCENT)
            tx += 18
        self.text(tx, y + h / 2 + 5, label, 13, INK)
        if close:
            self.text(x + w - 16, y + h / 2 + 5, "×", 15, MUTED, anchor="middle")
        return w

    def switch(self, x, y, on=True):
        self.rect(x, y, 52, 32, fill=ACCENT if on else SURFACE_2,
                  stroke=ACCENT if on else STROKE, r=16)
        self.circle(x + (36 if on else 16), y + 16, 12 if on else 8,
                    fill="#FFFFFF" if on else STROKE, stroke="none")

    def checkbox(self, x, y, on=False):
        self.rect(x, y, 18, 18, fill=ACCENT if on else BG,
                  stroke=ACCENT if on else STROKE, r=2, sw=2)
        if on:
            self.text(x + 9, y + 14, "✓", 13, "#FFFFFF", 700, "middle")

    def radio(self, x, y, on=False):
        self.circle(x + 9, y + 9, 9, fill=BG, stroke=ACCENT if on else STROKE)
        if on:
            self.circle(x + 9, y + 9, 5, fill=ACCENT, stroke="none")

    def card(self, x, y, w, h, title=None, r=12, fill=SURFACE):
        self.rect(x, y, w, h, fill=fill, stroke=STROKE, r=r)
        if title:
            self.text(x + 16, y + 28, title, 16, INK, 600)

    def list_tile(self, x, y, w, title, subtitle=None, selected=False,
                  leading=True, trailing=False, h=None):
        h = h or (64 if subtitle else 48)
        if selected:
            self.rect(x, y, w, h, fill=ACCENT_SOFT, stroke="none", r=h / 2 if h < 60 else 12)
        tx = x + 16
        if leading:
            self.icon(x + 16, y + h / 2 - 12, 24)
            tx = x + 56
        if subtitle:
            self.text(tx, y + h / 2 - 3, title, 15, INK, 500)
            self.text(tx, y + h / 2 + 15, subtitle, 13, MUTED)
        else:
            self.text(tx, y + h / 2 + 5, title, 15, INK, 500 if selected else 400)
        if trailing:
            self.icon(x + w - 40, y + h / 2 - 10, 20, fill="none")

    def tabs(self, x, y, w, labels, active=0, h=48):
        tw = w / len(labels)
        self.line(x, y + h, x + w, y + h)
        for i, l in enumerate(labels):
            cx = x + tw * i + tw / 2
            self.text(cx, y + h / 2 + 5, l, 14, ACCENT if i == active else MUTED,
                      600 if i == active else 400, "middle")
            if i == active:
                self.rect(cx - len(l) * 4.5, y + h - 3, len(l) * 9, 3,
                          fill=ACCENT, stroke="none", r=1.5)

    def fab(self, x, y, label=None):
        if label:
            w = len(label) * 8 + 64
            self.rect(x, y, w, 56, fill=ACCENT_SOFT, stroke=STROKE, r=16)
            self.icon(x + 18, y + 16, 24, fill="none")
            self.text(x + 52, y + 33, label, 14, INK, 600)
        else:
            self.rect(x, y, 56, 56, fill=ACCENT_SOFT, stroke=STROKE, r=16)
            self.text(x + 28, y + 37, "+", 26, INK, 400, "middle")

    def snackbar(self, x, y, msg, action=None, w=480):
        self.rect(x, y, w, 48, fill="#313033", stroke="none", r=4)
        self.text(x + 16, y + 29, msg, 14, "#F4EFF4")
        if action:
            self.text(x + w - 16, y + 29, action, 14, "#C5CAE9", 600, "end")

    def scrim(self):
        self.rect(0, 0, self.w, self.h, fill="#000000", stroke="none")
        self.parts[-1] = self.parts[-1].replace('fill="#000000"', 'fill="#000000" fill-opacity="0.32"')

    def dialog(self, w, h, title, x=None, y=None, actions=("Cancel", "Save"),
               danger=False, icon=False):
        """Centered Material dialog; returns content origin (x, y)."""
        self.scrim()
        x = (self.w - w) / 2 if x is None else x
        y = (self.h - h) / 2 if y is None else y
        self.rect(x, y, w, h, fill="#FFFFFF", stroke=STROKE, r=28)
        ty = y + 44
        if icon:
            self.icon(x + w / 2 - 12, y + 24, 24)
            self.text(x + w / 2, y + 84, title, 22, INK, 500, "middle")
            ty = y + 108
        else:
            self.text(x + 24, ty, title, 22, INK, 500)
            ty += 28
        bx = x + w - 24
        for i, a in enumerate(reversed(actions)):
            primary = i == 0
            kind = ("danger" if danger else "filled") if primary else "text"
            bw = max(88, len(a) * 8 + 40)
            bx -= bw
            self.button(bx, y + h - 64, a, kind, w=bw)
            bx -= 8
        return x + 24, ty

    def note(self, x, y, lines, w=260):
        """Yellow annotation sticky – designer notes, not part of the UI."""
        h = 22 + 18 * len(lines)
        self.rect(x, y, w, h, fill=NOTE, stroke="#E0C200", r=4, dash="4 3")
        for i, l in enumerate(lines):
            self.text(x + 10, y + 20 + 18 * i, l, 12, "#5C4B00")

    def frame_label(self, s):
        self.text(16, self.h - 12, s, 11, MUTED)

    def svg(self) -> str:
        body = "\n  ".join(self.parts)
        return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}" '
                f'viewBox="0 0 {self.w} {self.h}">\n  <title>{escape(self.title)}</title>\n  '
                f'{body}\n</svg>\n')
