"""Shared layout pieces: app shell (BasePage), page headers, model cards."""
from wf import *

NAV = ["Attributes", "Items", "Notifications", "Fonts", "Sound"]
BAR = 64


def shell(s: Svg, section: str, extended=True, query="", focused=False, chip=None):
    """BasePage: chrome-toned app bar + NavigationRail, rounded content panel.
    Returns (x, y, w) of the content area (16 px padding applied)."""
    rail = 180 if extended else 80
    s.rect(0, 0, s.w, s.h, fill=CHROME, stroke="none")
    # app bar leading menu toggle, aligned with the collapsed rail
    s.icon_button(20, 12)
    # search / command palette field (max 640, centered)
    sw = 640
    sx = (s.w - sw) / 2
    s.rect(sx, 12, sw, 40, fill=BG, stroke=ACCENT if focused else STROKE,
           r=20, sw=2 if focused else 1)
    tx = sx + 46
    if chip:  # active palette mode: InputChip replaces the leading icon
        cw = len(chip) * 7 + 36
        s.rect(sx + 8, 18, cw, 28, fill=ACCENT_SOFT, stroke=STROKE, r=14)
        s.text(sx + 20, 37, chip + "  ×", 12, INK)
        tx = sx + cw + 18
    else:
        s.icon(sx + 14, 22, 20, fill="none")
    if chip and not query:
        s.text(tx, 37, f"{chip}: pick a tab or an action", 15, MUTED)
    elif query:
        s.text(tx, 37, query, 15, INK)
        s.text(sx + sw - 58, 38, "×", 18, MUTED, anchor="middle")
    else:
        s.text(sx + 46, 37, f"Search {section}, or ? for more", 15, MUTED)
    s.icon(sx + sw - 34, 22, 20, fill="none")  # filter_list
    # actions: project badge, build, settings, session
    ax = s.w - 380
    s.rect(ax, 14, 196, 36, fill=BG, stroke=STROKE, r=18)
    s.icon(ax + 12, 23, 18, fill="none")
    s.text(ax + 38, 37, "Demo Project", 14, INK, 500)
    s.rect(ax + 142, 23, 42, 18, fill="#F2DAFF", stroke="none", r=9)
    s.text(ax + 163, 36, "Labor", 9, INK, 700, "middle")
    s.icon_button(ax + 206, 12)   # build
    s.icon_button(ax + 254, 12)   # settings
    s.icon_button(ax + 302, 12)   # account
    # rail
    for i, n in enumerate(NAV):
        y = BAR + 12 + i * 64 if extended else BAR + 12 + i * 64
        sel = n == section
        if extended:
            if sel:
                s.rect(12, y, 156, 52, fill=ACCENT_SOFT, stroke="none", r=26)
            s.icon(28, y + 14, 24, fill=ACCENT if sel else SURFACE_2)
            s.text(66, y + 31, n, 16, INK, 600 if sel else 400)
        else:
            if sel:
                s.rect(12, y + 10, 56, 32, fill=ACCENT_SOFT, stroke="none", r=16)
            s.icon(28, y + 14, 24, fill=ACCENT if sel else SURFACE_2)
    # content panel (only top-left corner rounded)
    s.rect(rail, BAR, s.w - rail + 20, s.h - BAR + 20, fill=BG, stroke="none", r=16)
    return rail + 16, BAR + 8, s.w - rail - 32


def page_header(s, x, y, w, title, actions=(("Refresh", "tonal"), ("Add", "filled")),
                small=False, back=False, dirty=False):
    tx = x
    if back:
        s.icon_button(x, y + 4)
        tx = x + 52
    s.text(tx, y + 31, title, 18 if small else 22, INK, 500)
    if dirty:
        s.circle(tx + len(title) * (9 if small else 11.5) + 12, y + 24, 4,
                 fill=ACCENT, stroke="none")
    bx = x + w
    for label, kind in reversed(actions):
        bw = len(label) * 8 + 56
        bx -= bw
        s.button(bx, y + 4, label, kind, w=bw, icon=True)
        bx -= 8


def model_card(s, x, y, w, name, key, note=None, edited="Edited 5 min ago", h=148):
    s.rect(x, y, w, h, fill=SURFACE, stroke="none", r=12)
    s.text(x + 16, y + 30, name, 16, INK, 700)
    s.info_chip(x + 16, y + 42, f"demo:{key}")
    s.text(x + w - 60, y + 32, "⋮", 20, MUTED, anchor="middle")
    s.icon(x + w - 40, y + 16, 22, fill="#F9DEDC")
    if note:
        s.text(x + 16, y + 92, note, 12, MUTED)
    s.line(x + 16, y + 106, x + w - 16, y + 106, stroke=SURFACE_2)
    s.icon(x + 16, y + 118, 16, fill="none")
    s.text(x + 40, y + 131, edited, 12, MUTED)


def grid(s, x, y, w, entries, kind, h=148, rows=None):
    cols = max(1, min(4, int((w + 12) // 332)))
    cw = (w - 12 * (cols - 1)) / cols
    for i, e in enumerate(entries):
        r, c = divmod(i, cols)
        if rows is not None and r >= rows:
            break
        kind(s, x + c * (cw + 12), y + r * (h + 12), cw, *e)
    return cols, cw


def detail_shell(s, x, y, w, name, tabs=None, active=0, dirty=True, notes=True):
    page_header(s, x, y, w, name, back=True, dirty=dirty, actions=(
        ("Notes", "tonal"), ("Info", "tonal"), ("Delete", "danger_tonal"), ("Save", "filled")))
    if tabs:
        s.tabs(x, y + 56, min(w, 160 * len(tabs)), tabs, active)
        s.line(x, y + 104, x + w, y + 104)
        return y + 120
    return y + 64


def base_card(s, x, y, label, value, hint=None, counter=None, dropdown=False, info=True):
    """BaseCard: 350x200, secondaryContainer header, centered input."""
    s.rect(x, y, 350, 200, fill=BG, stroke=STROKE, r=12)
    s.rect(x, y, 350, 44, fill=SECONDARY, stroke=STROKE, r=12)
    s.rect(x + 1, y + 30, 348, 14, fill=SECONDARY, stroke="none")
    s.text(x + 16, y + 28, label, 15, INK, 600)
    if info:
        s.icon(x + 318, y + 12, 18, fill="none")
    s.field(x + 25, y + 88, 300, label, value or "", dropdown=dropdown)
    if hint and not value:
        s.text(x + 41, y + 121, hint, 15, MUTED)
    if counter:
        s.text(x + 325, y + 162, counter, 11, MUTED, anchor="end")
