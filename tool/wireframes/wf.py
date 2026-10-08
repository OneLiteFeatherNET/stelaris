"""Tiny SVG wireframe kit.

Every screen is a plain SVG built from rect/line/circle/text so Penpot
imports it as editable shapes (drag the .svg onto the canvas).
"""
from __future__ import annotations

from html import escape

W, H = 1440, 900          # desktop frame
FONT = "Work Sans, Roboto, Arial, sans-serif"

# Material 3 light scheme of the app: ColorScheme.fromSeed(seedColor:
# Colors.green[400], secondary: Colors.green[200]), tonal-spot variant,
# computed with material-color-utilities (see lib/util/app_theme.dart).
M3 = {
    "primary": "#39693B", "onPrimary": "#FFFFFF",
    "primaryContainer": "#BAF0B6", "onPrimaryContainer": "#215025",
    "secondary": "#A5D6A7",  # overridden by accentColor green[200]
    "secondaryContainer": "#D5E8CF", "onSecondaryContainer": "#3B4B39",
    "tertiaryContainer": "#BCEBF1", "onTertiaryContainer": "#1F4D53",
    "error": "#BA1A1A", "errorContainer": "#FFDAD6", "onErrorContainer": "#93000A",
    "surface": "#F7FBF1", "onSurface": "#181D17", "onSurfaceVariant": "#424940",
    "outline": "#72796F", "outlineVariant": "#C2C9BD",
    "surfaceContainerLow": "#F1F5EC", "surfaceContainer": "#EBEFE6",
    "surfaceContainerHigh": "#E6E9E0", "surfaceContainerHighest": "#E0E4DB",
    "inverseSurface": "#2D322C", "inverseOnSurface": "#EEF2E9", "inversePrimary": "#9FD49C",
    "scrim": "#000000",
}
BG = M3["surface"]
SURFACE = M3["surfaceContainerLow"]          # cards
SURFACE_2 = M3["surfaceContainerHighest"]    # chips, search, placeholders
DIALOG = M3["surfaceContainerHigh"]          # dialogs, menus
STROKE = M3["outlineVariant"]                # dividers, card borders
OUTLINE = M3["outline"]                      # text fields, outlined buttons
INK = M3["onSurface"]
MUTED = M3["onSurfaceVariant"]
ACCENT = M3["primary"]
ON_ACCENT = M3["onPrimary"]
ACCENT_SOFT = M3["secondaryContainer"]       # tonal buttons, nav indicator
ON_SOFT = M3["onSecondaryContainer"]
PRIMARY_CONTAINER = M3["primaryContainer"]   # dialog header strips
CHROME = M3["surfaceContainer"]              # app bar + rail (appChrome)
SECONDARY = M3["secondaryContainer"]         # BaseCard header
LABOR = M3["tertiaryContainer"]
DANGER = M3["error"]
DANGER_SOFT = M3["errorContainer"]
# Not part of the UI: designer notes.
NOTE = "#FFF4C2"


class Svg:
    def __init__(self, title: str, w: int = W, h: int = H):
        self.title, self.w, self.h = title, w, h
        self.parts: list[str] = []
        self.bg = BG  # surface under the next fields (label cut-out colour)
        # Click-dummy hotspots: (x, y, w, h, target). target is a screen
        # number ("10") or "back"; build.mjs turns them into interactions.
        self.links: list[tuple] = []
        self.rect(0, 0, w, h, fill=BG, stroke="none")

    def link(self, x, y, w, h, target):
        if target:
            self.links.append((x, y, w, h, target))

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
            col = ON_ACCENT
        elif kind == "tonal":
            self.rect(x, y, w, h, fill=ACCENT_SOFT, stroke=ACCENT_SOFT, r=h / 2)
            col = ON_SOFT
        elif kind == "outlined":
            self.rect(x, y, w, h, fill=BG, stroke=OUTLINE, r=h / 2)
            col = ACCENT
        elif kind == "danger_tonal":
            self.rect(x, y, w, h, fill=DANGER_SOFT, stroke=DANGER_SOFT, r=h / 2)
            col = DANGER
        elif kind == "danger":
            self.rect(x, y, w, h, fill=DANGER, stroke=DANGER, r=h / 2)
            col = ON_ACCENT
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
        self.rect(x, y, w, h, fill="none", stroke=OUTLINE, r=4)
        if label:
            self.rect(x + 10, y - 7, len(label) * 6.6 + 8, 14, fill=self.bg, stroke="none")
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
                  stroke=ACCENT if on else OUTLINE, r=16, sw=2)
        self.circle(x + (36 if on else 16), y + 16, 12 if on else 8,
                    fill=ON_ACCENT if on else OUTLINE, stroke="none")

    def checkbox(self, x, y, on=False):
        self.rect(x, y, 18, 18, fill=ACCENT if on else BG,
                  stroke=ACCENT if on else OUTLINE, r=2, sw=2)
        if on:
            self.text(x + 9, y + 14, "✓", 13, ON_ACCENT, 700, "middle")

    def radio(self, x, y, on=False):
        self.circle(x + 9, y + 9, 9, fill="none", stroke=ACCENT if on else OUTLINE)
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

    def tabs(self, x, y, w, labels, active=0, h=48, targets=None):
        tw = w / len(labels)
        for i, t in enumerate(targets or []):
            if i != active:
                self.link(x + tw * i, y, tw, h, t)
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
        self.rect(x, y, w, 48, fill=M3["inverseSurface"], stroke="none", r=4)
        self.text(x + 16, y + 29, msg, 14, M3["inverseOnSurface"])
        if action:
            self.text(x + w - 16, y + 29, action, 14, M3["inversePrimary"], 600, "end")

    def scrim(self):
        self.links.clear()  # nothing under a modal is clickable
        self.rect(0, 0, self.w, self.h, fill="#000000", stroke="none")
        self.parts[-1] = self.parts[-1].replace('fill="#000000"', 'fill="#000000" fill-opacity="0.32"')

    def dialog(self, w, h, title, actions=("Cancel", "Save"), danger=False,
               close=True, x=None, y=None, scrim=True, links=None):
        """FormDialog: radius 16, title + close, dividers, right-aligned
        actions (last one primary). Returns (x, y, w) of the content area."""
        if scrim:
            self.scrim()
        x = (self.w - w) / 2 if x is None else x
        y = (self.h - h) / 2 if y is None else y
        links = links or {}
        self.rect(x, y, w, h, fill=DIALOG, stroke="none", r=16)
        self.bg = DIALOG
        self.text(x + 24, y + 42, title, 20, INK, 600)
        if close:
            self.text(x + w - 32, y + 42, "×", 22, MUTED, anchor="middle")
            self.link(x + w - 52, y + 22, 40, 40, links.get("×", "back"))
        self.line(x, y + 64, x + w, y + 64)
        if actions:
            self.line(x, y + h - 72, x + w, y + h - 72)
            bx = x + w - 24
            for i, a in enumerate(reversed(actions)):
                kind = ("danger" if danger else "filled") if i == 0 else "text"
                bw = max(88, len(a) * 8 + 40)
                bx -= bw
                self.button(bx, y + h - 56, a, kind, w=bw)
                self.link(bx, y + h - 56, bw, 40, links.get(a, "back"))
                bx -= 8
        return x + 24, y + 88, w - 48

    def strip_dialog(self, w, h, title, x=None, y=None):
        """AnimatedDialog with primaryContainer header strip (Settings/Build)."""
        self.scrim()
        x = (self.w - w) / 2 if x is None else x
        y = (self.h - h) / 2 if y is None else y
        self.rect(x, y, w, h, fill=DIALOG, stroke="none", r=16)
        self.bg = DIALOG
        self.rect(x, y, w, 50, fill=PRIMARY_CONTAINER, stroke="none", r=16)
        self.rect(x, y + 30, w, 20, fill=PRIMARY_CONTAINER, stroke="none")
        self.text(x + 24, y + 32, title, 18, M3["onPrimaryContainer"], 700)
        self.text(x + w - 28, y + 33, "×", 22, M3["onPrimaryContainer"], anchor="middle")
        self.link(x + w - 48, y + 5, 40, 40, "back")
        return x, y + 75

    def notice(self, x, y, w, h, lines, danger=False):
        """NoticeBox: tinted callout with accent border and leading icon."""
        self.rect(x, y, w, h, fill=DANGER_SOFT if danger else ACCENT_SOFT,
                  stroke=DANGER if danger else ACCENT, r=10)
        self.icon(x + 14, y + 14, 20, fill="none")
        for i, (t, size, weight) in enumerate(lines):
            self.text(x + 46, y + 29 + 20 * i, t, size, DANGER if danger and i == 0 else INK, weight)

    def info_chip(self, x, y, text):
        w = len(text) * 7.4 + 40
        self.rect(x, y, w, 24, fill=SURFACE_2, stroke="none", r=6)
        self.icon(x + 6, y + 5, 14, fill="none")
        self.add(f'<text x="{x + 26}" y="{y + 16}" font-family="monospace" font-size="12" fill="{ACCENT}">{escape(text)}</text>')
        return w

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
