"""Auth, project selection, list pages and model dialogs."""
from screens_base import *

SCREENS = []


def screen(fn):
    SCREENS.append(fn)
    return fn


ITEMS = [("Ruby Sword", "ruby_sword", "Drops from the boss in the nether arena"),
         ("Healing Apple", "healing_apple", None, "Created 2 h ago"),
         ("Miner's Pick", "miners_pick", "Event reward"),
         ("Lucky Charm", "lucky_charm", None),
         ("Fire Staff", "fire_staff", None, "Edited 3 d ago"),
         ("Ice Boots", "ice_boots", "Winter season only"),
         ("Teleport Pearl", "teleport_pearl", None),
         ("Golden Crown", "golden_crown", None, "Edited 12.03.2026"),
         ("Bandage", "bandage", None), ("Lantern", "lantern", None),
         ("Rope", "rope", None), ("Map Fragment", "map_fragment", None)]


@screen
def s01_splash():
    s = Svg("01 Splash (web/index.html)")
    s.circle(720, 450, 24, fill="none", stroke=ACCENT)
    s.note(1120, 40, ["HTML splash before Flutter boots.", "48 px ring spinner in primary,",
                      "bg #fff / #121212 (dark). Fades out."])
    return s


@screen
def s02_sign_in():
    s = Svg("02 Sign in")
    s.icon(696, 300, 48, fill=ACCENT_SOFT)
    s.text(720, 390, "Stelaris", 24, INK, 500, "middle")
    s.text(720, 424, "Sign in to continue.", 15, MUTED, anchor="middle")
    s.button(658, 450, "Sign in", "filled", w=124, icon=True)
    s.note(1100, 40, ["Max width 420, centered.", "States of the message line:",
                      "• Signed out: Sign in to continue.",
                      "• Expired: Your session expired. Sign",
                      "  in again to continue.",
                      "• Unreachable: [cloud_off] icon, The",
                      "  identity provider could not be",
                      "  reached… + button Try again"], w=300)
    return s


@screen
def s03_project_select():
    s = Svg("03 Project selection – list")
    s.icon_button(1392, 8)
    s.image(680, 70, 80, 80, "logo")
    s.text(720, 196, "Welcome to Stelaris", 28, INK, 700, "middle")
    x, y = 460, 226
    s.rect(x, y, 520, 468, fill=BG, stroke=STROKE, r=20)
    s.text(720, y + 52, "Select Project", 22, INK, 700, "middle")
    s.line(x + 28, y + 76, x + 492, y + 76)
    s.rect(x + 28, y + 96, 464, 280, fill=BG, stroke=STROKE, r=12)
    projects = [("Demo Project", "demo", "Sandbox for the summer event", True, True),
                ("Survival", "survival", "Main survival server", False, False),
                ("Lobby", "lobby", None, False, False),
                ("Minigames", "minigames", "Bedwars, SkyWars", False, True),
                ("Creative", "creative", None, False, False)]
    yy = y + 97
    for name, key, desc, sel, labor in projects:
        h = 56 if desc else 44
        if sel:
            s.rect(x + 29, yy, 462, h, fill=ACCENT_SOFT, stroke="none")
        s.icon(x + 44, yy + h / 2 - 10, 20, fill=ACCENT if sel else "none")
        s.text(x + 78, yy + (24 if desc else 27), name, 14, INK, 700 if sel else 400)
        kx = x + 84 + len(name) * 7.6
        s.text(kx, yy + (24 if desc else 27), f"({key})", 11, MUTED)
        if labor:
            lx = kx + len(key) * 6.5 + 20
            s.rect(lx, yy + (12 if desc else 15), 34, 14, fill="#F2DAFF", stroke="none", r=7)
            s.text(lx + 17, yy + (22 if desc else 25), "Labor", 9, INK, 700, "middle")
        if desc:
            s.text(x + 78, yy + 43, desc, 12, MUTED)
        s.icon(x + 452, yy + h / 2 - 10, 20, fill="none")
        yy += h
        s.line(x + 29, yy, x + 491, yy, stroke=SURFACE_2)
    s.rect(x + 486, y + 104, 4, 120, fill=STROKE, stroke="none", r=2)
    s.button(x + 28, y + 400, "Create new project", "outlined", w=226, icon=True)
    s.button(x + 266, y + 400, "Open Project", "filled", w=226, icon=True)
    s.note(1040, 300, ["Project list: 80–280 px high,", "scrollbar always visible.",
                       "Open Project disabled until a", "row is selected → /attributes.",
                       "Pencil per row = Edit project.", "No delete-project UI exists."])
    return s


@screen
def s04_project_empty():
    s = Svg("04 Project selection – empty")
    s.icon_button(1392, 8)
    s.image(680, 120, 80, 80, "logo")
    s.text(720, 246, "Welcome to Stelaris", 28, INK, 700, "middle")
    x, y = 460, 280
    s.rect(x, y, 520, 330, fill=BG, stroke=STROKE, r=20)
    s.text(720, y + 52, "Select Project", 22, INK, 700, "middle")
    s.line(x + 28, y + 76, x + 492, y + 76)
    s.icon(692, y + 110, 56)
    s.text(720, y + 206, "No projects found", 18, INK, 600, "middle")
    s.text(720, y + 232, "Get started by creating your first project.", 14, MUTED, anchor="middle")
    s.button(668, y + 256, "Create", "filled", w=104, icon=True)
    return s


def _project_form(s, edit):
    x, y, w = s.dialog(550, 640, "Edit project" if edit else "Create new project",
                       actions=("Cancel", "Save" if edit else "Create"))
    s.field(x, y, w, "Display Name *", "Demo Project" if edit else "", trailing=True)
    if not edit:
        s.text(x + 16, y + 33, "e.g. My Awesome Project", 15, MUTED)
    if edit:
        s.rect(x, y + 76, w, 56, fill=SURFACE, stroke=SURFACE_2, r=4)
        s.text(x + 14, y + 80, "Key / Namespace", 12, MUTED)
        s.text(x + 16, y + 110, "demo", 15, MUTED)
        s.icon(x + w - 34, y + 94, 20, fill="none")
        s.text(x + 16, y + 150, "Project key cannot be changed after creation", 12, MUTED)
    else:
        s.field(x, y + 76, w, "Key / Namespace *", trailing=True)
        s.text(x + 16, y + 109, "e.g. my_project", 15, MUTED)
    s.field(x, y + 170, w, "Description", "Sandbox for the summer event" if edit else "", h=96,
            multiline=True)
    if not edit:
        s.text(x + 16, y + 198, "Brief description of the project", 15, MUTED)
    s.field(x, y + 286, w, "Project URL", "", trailing=True)
    s.text(x + 16, y + 319, "https://github.com/...", 15, MUTED)
    s.field(x, y + 362, w, "Documentation URL", "", trailing=True)
    s.text(x + 16, y + 395, "https://docs.example.com/...", 15, MUTED)
    s.text(x + 16, y + 456, "Labor / Experimental", 15, INK)
    s.text(x + 16, y + 476, "Mark as laboratory / experimental project", 12, MUTED)
    s.switch(x + w - 60, y + 446, on=edit)


@screen
def s05_project_create():
    s = Svg("05 Dialog – Create project")
    _project_form(s, False)
    return s


@screen
def s06_project_edit():
    s = Svg("06 Dialog – Edit project")
    _project_form(s, True)
    return s


@screen
def s07_switch_project():
    s = Svg("07 Dialog – Switch project")
    shell(s, "Items")
    x, y = 520, 290
    s.scrim()
    s.rect(x, y, 400, 300, fill="#FFFFFF", stroke=STROKE, r=28)
    s.text(720, y + 48, "Switch project?", 22, INK, 500, "middle")
    for i, (n, k) in enumerate([("Demo Project", "demo"), ("Survival", "survival")]):
        cx = x + 32 + i * 196
        s.rect(cx, y + 80, 140, 56, fill=SURFACE, stroke=STROKE, r=12)
        s.text(cx + 70, y + 104, n, 14, INK, 600, "middle")
        s.text(cx + 70, y + 124, k, 12, MUTED, anchor="middle")
    s.text(720, y + 114, "→", 20, MUTED, anchor="middle")
    s.icon(x + 32, y + 160, 18, fill="none")
    s.text(x + 58, y + 174, "Loaded items, fonts, notifications, attributes", 12, MUTED)
    s.text(x + 58, y + 192, "and sound events will be reset.", 12, MUTED)
    s.button(x + 160, y + 236, "Cancel", "text", w=88)
    s.button(x + 252, y + 236, "Switch project", "filled", w=128)
    return s


@screen
def s10_items_list():
    s = Svg("10 Items – list (rail extended)")
    x, y, w = shell(s, "Items")
    page_header(s, x, y, w, "Items (12)")
    grid(s, x, y + 64, w, ITEMS, lambda s, x, y, w, n, k, note=None, ed="Edited 5 min ago":
         model_card(s, x, y, w, n, k, note, ed))
    s.note(1180, 820, ["Grid: cols = (w+12)/332, 1–4.", "Card tap → /items/detail."], w=240)
    return s


@screen
def s11_attributes_filter():
    s = Svg("11 Attributes – list (rail collapsed) + Filter & Sort menu")
    x, y, w = shell(s, "Attributes", extended=False)
    page_header(s, x, y, w, "Attributes (6)")
    attrs = [("Max Health", "max_health"), ("Movement Speed", "movement_speed"),
             ("Attack Damage", "attack_damage"), ("Armor", "armor"),
             ("Luck", "luck"), ("Knockback", "knockback")]
    grid(s, x, y + 64, w, attrs, lambda s, x, y, w, n, k: model_card(s, x, y, w, n, k))
    mx, my = 760, 56
    s.rect(mx, my, 300, 300, fill=BG, stroke=STROKE, r=8)
    for i, t in enumerate(["Name (A–Z)", "Name (Z–A)", "Created (newest first)",
                           "Created (oldest first)"]):
        s.radio(mx + 16, my + 16 + i * 44, on=i == 0)
        s.text(mx + 48, my + 30 + i * 44, t, 14)
    s.line(mx, my + 192, mx + 300, my + 192)
    for i, t in enumerate(["Has default value", "Has maximum value"]):
        s.checkbox(mx + 16, my + 210 + i * 44, on=i == 0)
        s.text(mx + 48, my + 224 + i * 44, t, 14)
    s.circle(1056, 24, 8, fill=DANGER, stroke="none")
    s.text(1056, 28, "1", 10, "#FFFFFF", 700, "middle")
    s.note(1120, 120, ["Filter & Sort lives in the trailing", "icon of the app-bar search.",
                       "Checkbox filters: Attributes only.", "Rail < 1000 px: always collapsed."])
    return s


@screen
def s12_list_empty():
    s = Svg("12 List – empty / no matches")
    x, y, w = shell(s, "Fonts", query="zzz")
    page_header(s, x, y, w, "Fonts (0)")
    cx = x + w / 4
    s.icon(cx - 24, 330, 48, fill=ACCENT_SOFT)
    s.text(cx, 410, "No data selected", 18, INK, 500, "middle")
    s.text(cx, 436, "Please create or selected a model", 14, MUTED, anchor="middle")
    cx = x + 3 * w / 4
    s.icon(cx - 24, 330, 48, fill=ACCENT_SOFT)
    s.text(cx, 410, "No matches", 18, INK, 500, "middle")
    s.text(cx, 436, "Try another search or reset the filters.", 14, MUTED, anchor="middle")
    s.button(cx - 60, 456, "Reset search", "text", w=120)
    s.line(x + w / 2, 300, x + w / 2, 520, dash="6 4")
    s.text(x + 20, 560, "left: no models · right: search hides all", 12, MUTED, italic=True)
    return s


@screen
def s13_attribute_edit():
    s = Svg("13 Dialog – Edit attribute")
    x, y, w = s.dialog(420, 420, "Edit attribute")
    s.text(x, y + 6, "Max Health", 15, MUTED)
    s.info_chip(x, y + 16, "demo:max_health")
    s.line(x - 24, y + 56, x + w + 24, y + 56)
    s.field(x, y + 80, w, "Default value", "20")
    s.field(x, y + 156, w, "Maximum value", "1024")
    return s


@screen
def s14_model_create():
    s = Svg("14 Dialog – Create model")
    x, y, w = s.dialog(520, 420, "Create new item", actions=("Cancel", "Create"))
    s.field(x, y, w, "Name *", trailing=True)
    s.text(x + 16, y + 33, "e.g. My Entry", 15, MUTED)
    s.field(x, y + 76, w, "Key *", trailing=True)
    s.text(x + 16, y + 109, "e.g. my_entry", 15, MUTED)
    s.notice(x, y + 156, w, 64, [("NamespacedKey Preview", 13, 600),
                                 ("demo:<key>", 13, 400)])
    s.note(1010, 210, ["Title per section: Create new item /", "font / sound event / notification,",
                       "Create attribute. Key is lowercase."], w=270)
    return s


@screen
def s15_model_copy():
    s = Svg("15 Dialog – Copy model")
    x, y, w = s.dialog(520, 640, "Copy item", actions=("Cancel", "Copy"))
    s.field(x, y, w, "Target project", "Survival (survival)", dropdown=True)
    s.field(x, y + 76, w, "Name *", "Ruby Sword (Copy)")
    s.field(x, y + 152, w, "Key *", "ruby_sword-copy")
    s.notice(x, y + 228, w, 64, [("NamespacedKey Preview", 13, 600),
                                 ("survival:ruby_sword-copy", 13, 400)])
    s.text(x, y + 324, "Copy along", 14, INK, 600)
    for i, t in enumerate(["Lore", "Flags", "Enchantments"]):
        s.checkbox(x + 4, y + 340 + i * 36, on=True)
        s.text(x + 34, y + 354 + i * 36, t, 14)
    s.note(1010, 300, ["Copy-along options per type:", "Item: Lore/Flags/Enchantments",
                       "Sound: Sources · Font: Characters", "Notification/Attribute: none"])
    return s


@screen
def s16_model_delete():
    s = Svg("16 Dialog – Delete model (type name)")
    x, y, w = s.dialog(520, 500, "Delete item", actions=("Cancel", "Delete"), danger=True)
    s.text(x + w / 2, y + 8, "Ruby Sword", 18, INK, 600, "middle")
    s.info_chip(x + w / 2 - 80, y + 20, "demo:ruby_sword")
    s.line(x, y + 60, x + w, y + 60)
    s.notice(x, y + 76, w, 84, [("This action cannot be undone.", 14, 700),
                                ("All lore entries and enchantments that belong", 12, 400),
                                ("to this item will also be deleted.", 12, 400)], danger=True)
    s.text(x, y + 190, 'To confirm, type "Ruby Sword" in the box below', 13, INK)
    s.field(x, y + 206, w, "", "Ruby Sw")
    s.note(1010, 330, ["Delete stays disabled until the", "typed text matches the name."])
    return s


@screen
def s17_model_info():
    s = Svg("17 Dialog – Model info")
    x, y, w = s.dialog(520, 360, "Ruby Sword", actions=("Close",))
    s.notice(x, y, w, 48, [("demo:ruby_sword", 13, 400)])
    for i, (k, v) in enumerate([("ID", "6650f1c2a9e4b1"), ("Created", "3 d ago"),
                                ("Modified", "5 min ago")]):
        yy = y + 80 + i * 40
        s.text(x, yy, k, 13, MUTED)
        s.text(x + 90, yy, v, 14)
        s.icon(x + w - 24, yy - 15, 20, fill="none")
    return s


@screen
def s18_notes():
    s = Svg("18 Dialogs – Notes edit (card menu) & Notes view (detail header)")
    s.scrim()
    x, y, w = s.dialog(520, 460, "Notes for Ruby Sword", actions=("Cancel", "Save"),
                       x=120, y=220, scrim=False)
    s.field(x, y, w, "", h=240, multiline=True)
    s.text(x + 16, y + 28, "Internal notes for your team. The first line is", 14, MUTED)
    s.text(x + 16, y + 48, "shown in the overview.", 14, MUTED)
    x, y, w = s.dialog(520, 300, "Notes for Ruby Sword", actions=(), x=800, y=220, scrim=False)
    s.text(x, y + 8, "Drops from the boss in the nether arena.", 14)
    s.text(x, y + 30, "Balance pass pending (@design).", 14)
    s.icon(x, y + 150, 18, fill="none")
    s.text(x + 26, y + 164, "To edit the notes, use ⋯ → Edit notes on the overview card.", 12, MUTED)
    return s
