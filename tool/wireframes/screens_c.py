"""Settings, build dialog, command palette, menus, snackbars, compact layout."""
from screens_base import *

SCREENS = []


def screen(fn):
    SCREENS.append(fn)
    return fn


def _list_bg(s, section="Items"):
    x, y, w = shell(s, section)
    page_header(s, x, y, w, f"{section} (12)")
    return x, y, w


@screen
def s40_settings():
    s = Svg("40 Dialog – Settings")
    _list_bg(s)
    x, y = s.strip_dialog(1000, 820, "Settings", y=40)
    x += 24
    w = 952
    def section(yy, title):
        s.text(x, yy, title, 18, INK, 600)
        s.line(x, yy + 12, x + w, yy + 12)
        return yy + 28
    def row(yy, t, sub):
        s.text(x, yy + 20, t, 16, INK, 500)
        s.text(x, yy + 40, sub, 13, MUTED)
    yy = section(y + 10, "Project")
    row(yy, "Active Project", "Select or switch the active project workspace")
    s.field(x + w - 280, yy + 4, 280, "", "Demo Project (demo)  Labor", dropdown=True, h=44)
    yy = section(yy + 80, "Display settings")
    row(yy, "Use System Theme", "Automatically match your system's theme settings")
    s.switch(x + w - 52, yy + 10)
    row(yy + 60, "Dark Mode", "Update your preferred theme")
    s.switch(x + w - 52, yy + 70, on=False)
    row(yy + 120, "Font Size", "Adjust the text size throughout the app")
    s.line(x, yy + 196, x + w, yy + 196, stroke=SURFACE_2, sw=4)
    s.line(x, yy + 196, x + w * 0.33, yy + 196, stroke=ACCENT, sw=4)
    s.circle(x + w * 0.33, yy + 196, 9, fill=ACCENT, stroke="none")
    s.text(x + w * 0.33, yy + 176, "100%", 12, INK, 600, "middle")
    yy = section(yy + 236, "Accessibility")
    row(yy, "For assistance, feel free to explore our wiki", "Need some help?")
    s.button(x + w - 100, yy + 8, "Wiki", "outlined", w=100)
    yy = section(yy + 80, "Misc")
    rows = [("App Version", "Currently installed version of Stelaris", None),
            ("Found a bug?", "When you encounter a bug, please report it!", "Report"),
            ("Any Suggestion?", "Want to suggest a feature, create a ticket!", "Suggest"),
            ("Third-party software licenses",
             "This application uses the following open-source libraries.", "View")]
    for i, (t, sub, b) in enumerate(rows):
        row(yy + i * 56, t, sub)
        if b:
            s.button(x + w - 100, yy + i * 56 + 8, b, "outlined", w=100)
        else:
            s.rect(x + w - 80, yy + 12, 80, 30, fill=BG, stroke=STROKE, r=15)
            s.text(x + w - 40, yy + 32, "1.5.0", 13, INK, anchor="middle")
    s.text(720, 846, "@2025 Onelitefeather • Made with ❤ by the team", 12, MUTED, anchor="middle")
    return s


def _build_frame(s, tab):
    _list_bg(s)
    x, y = s.strip_dialog(1000, 640, "Build & Download Vulpes", y=130)
    # release status cards
    cw = (1000 - 100 - 24) / 2
    for i in range(2):
        cx = x + 50 + i * (cw + 24)
        s.rect(cx, y, cw, 70, fill=SURFACE, stroke=ACCENT_SOFT, r=12, sw=3)
    s.text(x + 70, y + 30, "Build: 1.5.0", 15, INK, 700)
    s.text(x + 70, y + 52, "Release: 2026-09-30 14:22:05", 13, MUTED)
    rx = x + 50 + cw + 24
    s.icon(rx + 20, y + 14, 20, fill=ACCENT_SOFT)
    s.text(rx + 50, y + 30, "Status: Stable", 15, ACCENT, 700)
    s.text(rx + 50, y + 52, "Commit: abc1234", 13, MUTED)
    s.line(x, y + 94, x + 1000, y + 94)
    s.tabs(x + 24, y + 98, 952, ["Download", "Build"], tab)
    s.line(x, y + 150, x + 1000, y + 150)
    return x + 50, y + 170, 900


@screen
def s41_build_download():
    s = Svg("41 Dialog – Build & Download: Download tab")
    x, y, w = _build_frame(s, 0)
    s.rect(x, y, w, 230, fill=SURFACE, stroke=STROKE, r=12)
    s.text(x + 24, y + 40, "Search by Commit", 15, INK)
    s.switch(x + w - 76, y + 18, on=False)
    s.field(x + 24, y + 72, w - 48, "", "main", dropdown=True)
    s.button(x + 24, y + 156, "Download", "filled", w=w - 48, icon=True)
    s.note(1160, 90, ["States of the Download tab:", "• Fetching branches… (spinner)",
                      "• No project selected!", "• Service unavailable",
                      "• No branches found! + refresh", "Switch on → \"Git commit\" field",
                      "(10 chars). Download closes the", "dialog: snackbar \"Generation",
                      "submitted to backend\"."], w=260)
    return s


@screen
def s42_build_build():
    s = Svg("42 Dialog – Build & Download: Build tab")
    x, y, w = _build_frame(s, 1)
    s.rect(x, y, w, 330, fill=SURFACE, stroke=STROKE, r=12)
    fw = (w - 48 - 60) / 2
    s.rect(x + 24, y + 24, fw, 56, fill=SURFACE_2, stroke=STROKE, r=4)
    s.text(x + 38, y + 20, "Current version", 12, MUTED)
    s.text(x + 40, y + 58, "1.5.0", 15, MUTED)
    s.text(x + 24 + fw + 30, y + 58, "→", 20, MUTED, anchor="middle")
    s.field(x + 84 + fw, y + 24, fw, "New Version", "1.6.0")
    s.text(x + 24, y + 112, "Select the part of the version to update:", 14)
    for i, t in enumerate(["Major", "Minor", "Patch"]):
        s.radio(x + 24, y + 126 + i * 30, on=i == 1)
        s.text(x + 54, y + 140 + i * 30, t, 14)
    s.line(x + 24, y + 222, x + w - 24, y + 222)
    s.rect(x + 24, y + 234, w - 48, 36, fill=BG, stroke=STROKE, r=18)
    s.rect(x + 24, y + 234, (w - 48) / 2, 36, fill=ACCENT_SOFT, stroke=STROKE, r=18)
    s.text(x + 24 + (w - 48) / 4, y + 257, "✓ Release", 14, INK, anchor="middle")
    s.text(x + 24 + 3 * (w - 48) / 4, y + 257, "Snapshot", 14, INK, anchor="middle")
    s.button(x + 24, y + 280, "Generate", "filled", w=w - 48, icon=True)
    return s


def _palette(s, x, y, w, rows, footer, notice=None, h=None):
    h = h or min(440, 70 + len(rows) * 40 + (28 if notice else 0))
    s.rect(x, y, w, h, fill=BG, stroke=STROKE, r=16)
    yy = y + 8
    if notice:
        s.text(x + 16, yy + 16, notice, 12, MUTED, italic=True)
        yy += 28
    for kind, *r in rows:
        if kind == "h":
            s.text(x + 16, yy + 22, r[0], 12, ACCENT, 600)
            yy += 30
            continue
        title, sub, trail, hl = (r + [None, None, False])[:4]
        rh = 48 if sub else 38
        if hl:
            s.rect(x + 6, yy, w - 12, rh, fill=SECONDARY, stroke="none", r=8)
        s.icon(x + 18, yy + rh / 2 - 10, 20, fill="none")
        s.text(x + 52, yy + (20 if sub else 24), title, 14, INK)
        if sub:
            s.text(x + 52, yy + 38, sub, 12, MUTED)
        if trail:
            s.text(x + w - 18, yy + rh / 2 + 5, trail, 12, ACCENT if trail == "Current page" else MUTED,
                   anchor="end")
        yy += rh
    s.line(x, y + h - 40, x + w, y + h - 40)
    fx = x + 16
    for key, label in footer:
        kw = len(key) * 7 + 12
        s.rect(fx, y + h - 30, kw, 20, fill=BG, stroke=STROKE, r=4)
        s.text(fx + kw / 2, y + h - 16, key, 11, INK, anchor="middle")
        s.text(fx + kw + 6, y + h - 16, label, 12, MUTED)
        fx += kw + len(label) * 6.5 + 22


FOOT = [("↑↓", "Navigate"), ("Enter", "Run"), ("→", "More"), ("Esc", "Close"), ("?", "Help")]


@screen
def s43_palette_default():
    s = Svg("43 Command palette – default (Ctrl+K)")
    x, y, w = shell(s, "Items", focused=True)
    page_header(s, x, y, w, "Items (12)")
    rows = [("h", "Navigation"), ("r", "Go to Attributes"), ("r", "Go to Items", None, "Current page"),
            ("r", "Go to Notifications"), ("r", "Go to Fonts"), ("r", "Go to Sound"),
            ("r", "Go to project list"),
            ("h", "Create"), ("r", "New attribute", None, None, True), ("r", "New item"),
            ("h", "Interface"), ("r", "Toggle dark mode"), ("r", "Open settings"),
            ("h", "Backend"), ("r", "Reload current list")]
    _palette(s, 400, 58, 640, rows, FOOT, h=600)
    s.note(1080, 120, ["Palette = the app-bar search field;", "dropdown opens below it",
                       "(max 440 high, radius 16).", "Prefixes: > commands, : go,",
                       "# entities, @ projects, / settings,", "? help. Plain text first row:",
                       "Filter Items by \"x\"."], w=260)
    return s


@screen
def s44_palette_entities():
    s = Svg("44 Command palette – entity mode, drilled into an item")
    x, y, w = shell(s, "Items", focused=True, chip="Ruby Sword")
    page_header(s, x, y, w, "Items (12)")
    rows = [("r", "Components", None, None, True), ("r", "Enchantments"), ("r", "Lore"),
            ("r", "Delete…")]
    _palette(s, 400, 58, 640, rows, [("↑↓", "Navigate"), ("Enter", "Run"), ("←", "Back"),
                                     ("Esc", "Close"), ("?", "Help")],
             notice="Ruby Sword: pick a tab or an action")
    rows2 = [("r", "Ruby Sword", "demo:ruby_sword", "Items ›", True),
             ("r", "Ruby Ore Sound", "demo:ruby_ore", "Sounds ›"),
             ("r", "Ruby", "demo:ruby", "Attributes")]
    s.text(400, 420, "Before drilling in (#ruby):", 13, MUTED, italic=True)
    _palette(s, 400, 432, 640, rows2, FOOT, notice="Only entries that are already loaded are searched")
    return s


@screen
def s45_palette_help():
    s = Svg("45 Command palette – Help mode (?)")
    x, y, w = shell(s, "Items", focused=True, query="?")
    rows = [("h", "Syntax"), ("r", ">  Commands", "Run a command"),
            ("r", ":  Navigation", "Go to a page · Also: go"),
            ("r", "#  Entities", "Open an item, font, sound, notification or attribute"),
            ("r", "@  Projects", "Switch to another project"),
            ("r", "/  Settings", "Change the theme or open the settings"),
            ("h", "Keyboard"), ("r", "↑ / ↓", "Move the highlight"),
            ("r", "Enter", "Run the highlighted entry"), ("r", "Esc", "Close the palette")]
    _palette(s, 400, 58, 640, rows, FOOT, h=560)
    return s


@screen
def s46_menus():
    s = Svg("46 Menus – card ⋯ menu & account menu")
    x, y, w = _list_bg(s)
    from screens_a import ITEMS
    grid(s, x, y + 64, w, ITEMS[:6], lambda s, x, y, w, n, k, note=None, ed="Edited 5 min ago":
         model_card(s, x, y, w, n, k, note, ed))
    mx, my = 470, 180
    s.rect(mx, my, 190, 140, fill=BG, stroke=STROKE, r=8)
    for i, t in enumerate(["Info", "Copy", "Edit notes"]):
        s.icon(mx + 16, my + 14 + i * 42, 20, fill="none")
        s.text(mx + 48, my + 30 + i * 42, t, 14)
    ax, ay = 1150, 56
    s.rect(ax, ay, 270, 140, fill=BG, stroke=STROKE, r=8)
    s.icon(ax + 16, ay + 18, 24, fill="none")
    s.text(ax + 52, ay + 30, "Jane Doe", 15, MUTED, 500)
    s.text(ax + 52, ay + 50, "admin, editor and 1 more", 12, MUTED)
    s.line(ax, ay + 76, ax + 270, ay + 76)
    s.icon(ax + 16, ay + 96, 20, fill="none")
    s.text(ax + 52, ay + 112, "Sign out", 14)
    return s


@screen
def s47_snackbars():
    s = Svg("47 Snackbars (floating, 550 wide)")
    for i, (bg, msg, act, label) in enumerate([
            ("#313033", "Copied to clipboard", None, "Info · 2 s"),
            ("#388E3C", "✓  Copied to Survival", "Switch project", "Success · 3 s (6 s with action)"),
            ("#FF6F00", "⚠  Validation failed  • key: must be lowercase", None, "Warning · 4 s"),
            ("#C62828", "⨯  Could not save (CONFLICT)", None, "Error · 4 s")]):
        y = 160 + i * 140
        s.text(445, y - 14, label, 13, MUTED)
        s.rect(445, y, 550, 52, fill=bg, stroke="none", r=4)
        s.text(461, y + 32, msg, 14, "#FFFFFF")
        if act:
            s.text(979, y + 32, act, 14, "#FFFFFF", 700, "end")
    return s


@screen
def s48_compact():
    s = Svg("48 Compact layout (< 600 px)", w=420, h=900)
    s.rect(0, 0, 420, 900, fill=CHROME, stroke="none")
    s.icon_button(20, 12)
    s.icon_button(76, 12)       # search collapsed
    s.rect(140, 14, 120, 36, fill=BG, stroke=STROKE, r=18)
    s.text(200, 37, "Demo Project", 12, INK, anchor="middle")
    s.icon_button(268, 12); s.icon_button(316, 12); s.icon_button(364, 12)
    for i in range(5):
        if i == 1:
            s.rect(12, 86 + i * 64, 56, 32, fill=ACCENT_SOFT, stroke="none", r=16)
        s.icon(28, 90 + i * 64, 24, fill=ACCENT if i == 1 else SURFACE_2)
    s.rect(80, 64, 360, 856, fill=BG, stroke="none", r=16)
    s.text(96, 103, "Items (12)", 20, INK, 500)
    s.icon_button(320, 76, filled=True); s.icon_button(366, 76, filled=True)
    for i, (n, k) in enumerate([("Ruby Sword", "ruby_sword"), ("Healing Apple", "healing_apple"),
                                ("Miner's Pick", "miners_pick"), ("Lucky Charm", "lucky_charm")]):
        model_card(s, 96, 136 + i * 160, 308, n, k)
    s.note(96, 790, ["Rail always collapsed (< 1000).", "Search → icon; header buttons",
                     "icon-only (< 480). 1 column."], w=230)
    return s


@screen
def s49_oidc_redirect():
    s = Svg("49 OIDC redirect page (web/redirect.html)")
    s.rect(520, 340, 400, 160, fill=BG, stroke=STROKE, r=12)
    s.text(544, 390, "All done.", 20, INK, 600)
    s.text(544, 424, "You can now close this tab and return", 14, MUTED)
    s.text(544, 444, "to the app.", 14, MUTED)
    s.note(1040, 340, ["Other texts: Completing your request…,", "Redirecting…, You have been signed out…,",
                       "Something went wrong (+ detail),", "No cross-tab messaging support."], w=300)
    return s
