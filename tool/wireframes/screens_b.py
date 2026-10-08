"""Detail pages (items, notifications, fonts, sound) and their dialogs."""
from screens_base import *

SCREENS = []


def screen(fn):
    SCREENS.append(fn)
    return fn


COMPONENTS = [("Material", "Custom", "minecraft:diamond_sword", False),
              ("Amount", "Custom", "1", True),
              ("Food", "Consumable · overrides the default", "Nutrition: 4, …", True),
              ("Max Damage", "Properties", "1561", True),
              ("Dyed Color", "Display", "#FF0000", True),
              ("Can Break", "Tool", "3 entries", True),
              ("Unbreakable", "Properties", "Set", True),
              ("Rarity", "Display", "Epic", True)]


def comp_card(s, x, y, w, name, cat, value, deletable):
    s.rect(x, y, w, 112, fill=SURFACE, stroke="none", r=12)
    s.text(x + 16, y + 28, name, 15, INK, 700)
    s.icon(x + w - (68 if deletable else 40), y + 12, 22, fill="none")
    if deletable:
        s.icon(x + w - 40, y + 12, 22, fill="#F9DEDC")
    s.text(x + 16, y + 50, cat, 12, ACCENT if cat == "Custom" else MUTED)
    s.text(x + 16, y + 96, value, 14, INK)


@screen
def s20_item_components():
    s = Svg("20 Item detail – Components tab")
    x, y, w = shell(s, "Items")
    y = detail_shell(s, x, y, w, "Ruby Sword", ["Components", "Enchantments", "Lore"], 0)
    page_header(s, x, y, w, "Components (8)", small=True,
                actions=(("All categories", "tonal"), ("Add", "filled")))
    grid(s, x, y + 60, w, COMPONENTS, comp_card, h=112)
    s.note(1120, 790, ["Material is required: no delete.", "Card tap / pencil → Edit component.",
                       "Dot after name = unsaved changes."])
    return s


@screen
def s21_component_picker():
    s = Svg("21 Dialog – Add component (picker)")
    x, y, w = s.dialog(560, 640, "Add component", actions=())
    s.search(x, y - 8, w, "Search components or categories")
    s.icon(x + w - 40, y + 6, 20, fill="none")
    yy = y + 60
    groups = [("Properties", [("Max Damage", "minecraft:max_damage", True),
                              ("Unbreakable", "minecraft:unbreakable", False),
                              ("Max Stack Size", "minecraft:max_stack_size", True)]),
              ("Display", [("Custom Name", "minecraft:custom_name", False),
                           ("Dyed Color", "minecraft:dyed_color", False),
                           ("Rarity", "minecraft:rarity", True)]),
              ("Consumable", [("Food", "minecraft:food", False)])]
    for g, rows in groups:
        s.text(x + 8, yy + 14, g, 13, ACCENT, 600)
        s.icon(x + 16 + len(g) * 8, yy + 2, 14, fill="none")
        yy += 26
        for n, k, d in rows:
            s.text(x + 16, yy + 18, n, 14, INK)
            s.text(x + 16, yy + 36, k, 12, MUTED)
            if d:
                s.text(x + w - 16, yy + 28, "Default", 12, MUTED, anchor="end")
            yy += 50
    s.note(1040, 200, ["Grouped by category; tapping a", "heading filters to it.",
                       "Row tap → Component edit dialog.", "No action buttons."])
    return s


@screen
def s22_component_edit():
    s = Svg("22 Dialog – Edit component (schema form)")
    x, y, w = s.dialog(600, 760, "Can Break", actions=("Cancel", "Save"))
    s.text(x, y, "Tool · minecraft:can_break", 13, MUTED)
    # list section
    s.rect(x, y + 20, w, 300, fill=BG, stroke=SURFACE_2, r=8)
    s.text(x + 16, y + 48, "Entries (2)", 14, INK, 600)
    s.icon(x + w - 40, y + 32, 22, fill="none")
    for i in range(2):
        sy = y + 70 + i * 120
        s.rect(x + 16, sy, w - 72, 104, fill=BG, stroke=SURFACE_2, r=8)
        s.text(x + 32, sy + 26, "Blocks", 13, INK, 600)
        # segmented Keys | Tag
        s.rect(x + w - 240, sy + 10, 160, 28, fill=BG, stroke=STROKE, r=14)
        s.rect(x + w - (160 if i else 240), sy + 10, 80, 28, fill=ACCENT_SOFT, stroke=STROKE, r=14)
        s.text(x + w - 200, sy + 29, "Keys", 12, INK, anchor="middle")
        s.text(x + w - 120, sy + 29, "Tag", 12, INK, anchor="middle")
        s.field(x + 32, sy + 48, w - 104, "Tag" if i else "Key",
                "#minecraft:logs" if i else "minecraft:stone", h=44)
        s.icon(x + w - 46, sy + 40, 22, fill="none")
    # optional object field + other types
    yy = y + 340
    s.checkbox(x + 4, yy, on=True)
    s.text(x + 34, yy + 14, "Show in tooltip (optional)", 14)
    s.text(x + 16, yy + 48, "Enabled", 14)
    s.switch(x + w - 60, yy + 28)
    s.field(x, yy + 84, w - 56, "Color", "#FF0000")
    s.rect(x + w - 44, yy + 92, 40, 40, fill="#FF0000", stroke=STROKE, r=6)
    s.field(x, yy + 162, w, "Max Damage", "1561", helper="Between 1 and 2147483647")
    s.note(1080, 120, ["Form is generated from schema:", "Int/Float → field + range helper",
                       "Bool → switch · Enum → dropdown", "Color → swatch + #RRGGBB",
                       "List → framed section, +/− rows", "RegistryTag → Keys | Tag toggle",
                       "Optional → checkbox reveals input", "Unit → \"no value\" text"], w=270)
    return s


@screen
def s23_item_enchantments():
    s = Svg("23 Item detail – Enchantments tab (+ group menu)")
    x, y, w = shell(s, "Items")
    y = detail_shell(s, x, y, w, "Ruby Sword", ["Components", "Enchantments", "Lore"], 1, dirty=False)
    page_header(s, x, y, w, "Enchantments (3)", small=True,
                actions=(("Weapon", "tonal"), ("Add", "filled")))
    for i, (n, l) in enumerate([("Sharpness", "Level: 5 / 5"), ("Fire Aspect", "Level: 2 / 2"),
                                ("Looting", "Level: 7")]):
        cy = y + 60 + i * 80
        s.rect(x, cy, w, 68, fill=SURFACE, stroke=STROKE, r=12)
        s.text(x + 20, cy + 28, n, 15, INK, 700)
        s.text(x + 20, cy + 50, l, 13, MUTED)
        s.icon(x + w - 96, cy + 22, 24, fill="#F9DEDC")
        s.icon(x + w - 52, cy + 22, 24, fill="none")
    mx = x + w - 260
    s.rect(mx, y + 48, 170, 184, fill=BG, stroke=STROKE, r=8)
    for i, g in enumerate(["Armor", "Weapon", "Tool", "Meta"]):
        if g == "Weapon":
            s.rect(mx + 1, y + 56 + i * 44, 168, 40, fill=ACCENT_SOFT, stroke="none")
            s.text(mx + 16, y + 82 + i * 44, "✓", 14, ACCENT)
        s.text(mx + 40, y + 82 + i * 44, g, 14, MUTED if g == "Weapon" else INK)
    s.note(1100, 700, ["Group change asks first:", "Group change – \"A change of the group",
                       "will reset each selected enchantment\"", "[Cancel] [Yes]",
                       "Rows < 650 px: actions in ⋯ menu."], w=290)
    return s


@screen
def s24_enchantment_dialogs():
    s = Svg("24 Dialogs – Add enchantment & Update level")
    s.scrim()
    x, y, w = s.dialog(520, 400, "Add a enchantment", actions=("Cancel", "Add"),
                       x=120, y=250, scrim=False)
    s.field(x, y, w, "Enchantment", "Sharpness", dropdown=True)
    s.checkbox(x + 4, y + 82)
    s.text(x + 34, y + 90, "Unsafe", 14)
    s.text(x + 34, y + 108, "Allows levels above the normal maximum of the enchantment", 12, MUTED)
    s.field(x, y + 136, w, "Level", "1")
    x, y, w = s.dialog(420, 260, "Update Level", actions=("Cancel", "Save"),
                       x=880, y=250, scrim=False)
    s.field(x, y, w, "Level", "5", helper="The maximum is 5")
    return s


@screen
def s25_item_lore():
    s = Svg("25 Item detail – Lore tab")
    x, y, w = shell(s, "Items")
    y = detail_shell(s, x, y, w, "Ruby Sword", ["Components", "Enchantments", "Lore"], 2, dirty=False)
    page_header(s, x, y, w, "Lore", small=True, actions=(("Add", "filled"),))
    s.rect(x + 70, y + 8, 76, 32, fill=BG, stroke=STROKE, r=8)
    s.text(x + 108, y + 29, "# 4 / 64", 13, INK, anchor="middle")
    lines = ["<gold>Forged in the nether", "<gray>Damage: +7", "", "<italic>Legendary"]
    for i, t in enumerate(lines):
        cy = y + 60 + i * 56
        drag = i == 1
        if drag:
            s.rect(x + 12, cy + 6, w - 24, 52, fill=BG, stroke=ACCENT, r=12)
        s.text(x + 24, cy + 34, str(i + 1), 14, MUTED)
        s.text(x + 64, cy + 34, t or "(empty line)", 15, INK if t else MUTED)
        s.icon(x + w - 140, cy + 18, 22, fill="#F9DEDC")
        s.icon(x + w - 100, cy + 18, 22, fill="none")
        s.text(x + w - 40, cy + 36, "≡", 20, MUTED, anchor="middle")
        s.line(x, cy + 56, x + w, cy + 56, stroke=SURFACE_2)
    s.note(1100, 560, ["Reorderable: drag handle ≡.", "Dragged row: card + accent border.",
                       "Add → \"Add new line\" dialog,", "Edit → \"Edit lore\" (button: Add)."])
    return s


@screen
def s26_entry_dialogs():
    s = Svg("26 Dialogs – Single-value entry, Add character, Simple delete")
    s.scrim()
    x, y, w = s.dialog(420, 260, "Add new line", actions=("Cancel", "Add"), x=40, y=300, scrim=False)
    s.field(x, y, w, "", "<gray>Damage: +7", trailing=True)
    x, y, w = s.dialog(420, 260, "Add character", actions=("Cancel", "Add"), x=510, y=300, scrim=False)
    s.field(x, y, w, "Char *", "", helper="Enter exactly 4 hex digits (e.g. E000)")
    s.text(x + 16, y + 33, "E000", 15, MUTED)
    x, y, w = s.dialog(420, 300, "Delete component", actions=("Cancel", "Delete"), danger=True,
                       x=980, y=280, scrim=False)
    s.text(x, y + 8, "Delete Food from the item?", 14)
    s.notice(x, y + 30, w, 48, [("This action cannot be undone.", 13, 700)], danger=True)
    s.note(40, 620, ["Same single-field dialog: Add new line / Edit lore / Edit char.",
                     "Simple delete variants: enchantment, lore, char, component."], w=440)
    return s


@screen
def s27_notification_detail():
    s = Svg("27 Notification detail")
    x, y, w = shell(s, "Notifications")
    y = detail_shell(s, x, y, w, "Welcome Toast", dirty=False)
    base_card(s, x, y + 8, "Material", "", hint="minecraft:dirt", counter="0/30")
    base_card(s, x + 366, y + 8, "Title", "Welcome!", counter="8/…")
    base_card(s, x + 732, y + 8, "FrameType", "Task", dropdown=True)
    s.note(1100, 700, ["Field cards wrap (spacing 16).", "FrameType: Task / Challenge / Goal.",
                       "Error: The material starts not", "with minecraft:"])
    return s


@screen
def s28_font_general():
    s = Svg("28 Font detail – General tab")
    x, y, w = shell(s, "Fonts")
    y = detail_shell(s, x, y, w, "Icons", ["General", "Characters"], 0)
    base_card(s, x, y + 8, "Provider", "bitmap")
    base_card(s, x + 366, y + 8, "Texture path", "minecraft:font/icons.png")
    base_card(s, x + 732, y + 8, "Ascent", "7")
    base_card(s, x, y + 224, "Height", "8")
    return s


@screen
def s29_font_chars():
    s = Svg("29 Font detail – Characters tab")
    x, y, w = shell(s, "Fonts")
    y = detail_shell(s, x, y, w, "Icons", ["General", "Characters"], 1, dirty=False)
    s.rect(x + w / 2 - 40, y + 20, 80, 32, fill=BG, stroke=STROKE, r=8)
    s.text(x + w / 2 + 8, y + 41, "+ Add", 13, INK, anchor="middle")
    for i, c in enumerate(["E000", "E001", "E002", "E010"]):
        cy = y + 76 + i * 72
        s.rect(x + 9, cy, w - 18, 60, fill=SURFACE, stroke=STROKE, r=12)
        s.text(x + 30, cy + 36, c, 15, INK)
        s.icon(x + w - 100, cy + 18, 24, fill="#F9DEDC")
        s.icon(x + w - 60, cy + 18, 24, fill="none")
    s.note(1100, 700, ["Legacy inline ActionChip \"Add\"", "(not in the page header)."])
    return s


@screen
def s30_sound_general():
    s = Svg("30 Sound detail – General tab")
    x, y, w = shell(s, "Sound")
    y = detail_shell(s, x, y, w, "UI Click", ["General", "Entries"], 0)
    base_card(s, x, y + 8, "Key", "custom:ui/click")
    base_card(s, x + 366, y + 8, "Subtitle", "Button clicked")
    return s


@screen
def s31_sound_entries():
    s = Svg("31 Sound detail – Entries tab")
    x, y, w = shell(s, "Sound")
    y = detail_shell(s, x, y, w, "UI Click", ["General", "Entries"], 1, dirty=False)
    cx = x + w / 2
    s.rect(cx - 130, y + 20, 80, 32, fill=BG, stroke=STROKE, r=8)
    s.text(cx - 90, y + 41, "+ Add", 13, INK, anchor="middle")
    s.button(cx + 0, y + 16, "Save", "filled", w=100, icon=True)
    for i, n in enumerate(["click_1", "click_2", "click_soft"]):
        cy = y + 80 + i * 92
        s.rect(x, cy, 400, 80, fill=SURFACE, stroke=STROKE, r=12)
        s.rect(x + 12, cy + 12, 56, 56, fill=SURFACE_2, stroke=STROKE, r=8)
        s.icon(x + 28, cy + 28, 24, fill="none")
        s.text(x + 82, cy + 34, n, 15, INK, 500)
        s.text(x + 82, cy + 54, n, 12, MUTED)
        s.button(x + 220, cy + 22, "View", "tonal", w=80, h=36)
        s.button(x + 308, cy + 22, "Delete", "outlined", w=80, h=36)
    s.note(1100, 680, ["Second save path: inline Save chip", "bypasses the header Save.",
                       "Delete → \"Delete file\" / Unlink this", "file from the sound event?",
                       "Card < 230 px: folder icon only."], w=280)
    return s


@screen
def s32_sound_modal():
    s = Svg("32 Dialog – Edit Sound (file modal)")
    x, y, w = s.dialog(560, 800, "Edit Sound", actions=("Cancel", "Save"))
    def sec(yy, h, title):
        s.rect(x, yy, w, h, fill=SURFACE_2, stroke="none", r=16)
        s.text(x + 20, yy + 30, title, 15, INK, 600)
    sec(y - 8, 116, "Name")
    s.field(x + 20, y + 40, w - 40, "", "click_1", trailing=True)
    sec(y + 120, 132, "Volume & Pitch")
    for i, (l, v) in enumerate([("Volume", 0.7), ("Pitch", 0.5)]):
        yy = y + 180 + i * 44
        s.text(x + 20, yy + 5, l, 14)
        s.line(x + 120, yy, x + w - 20, yy, stroke=SURFACE_2, sw=4)
        s.line(x + 120, yy, x + 120 + (w - 140) * v, yy, stroke=ACCENT, sw=4)
        s.circle(x + 120 + (w - 140) * v, yy, 9, fill=ACCENT, stroke="none")
    sec(y + 264, 116, "Weight & Attenuation")
    s.field(x + 20, y + 308, (w - 56) / 2, "Weight", "1")
    s.field(x + 36 + (w - 56) / 2, y + 308, (w - 56) / 2, "Attenuation Distance", "16")
    sec(y + 392, 176, "Options")
    s.text(x + 20, y + 456, "Stream", 14)
    s.switch(x + 90, y + 436, on=False)
    s.text(x + w / 2, y + 456, "Preload", 14)
    s.switch(x + w / 2 + 76, y + 436)
    s.line(x + 20, y + 486, x + w - 20, y + 486)
    s.field(x + 20, y + 500, w - 40, "Type", "File", dropdown=True, h=52)
    s.note(1060, 120, ["Create: title \"Create Sound\".", "Weight/Attenuation side by side",
                       "≥ 520 px; Stream/Preload ≥ 420 px."])
    return s


@screen
def s33_unsaved():
    s = Svg("33 Dialog – Unsaved changes guard")
    x, y, w = shell(s, "Items")
    detail_shell(s, x, y, w, "Ruby Sword", ["Components", "Enchantments", "Lore"], 0)
    s.scrim()
    dx, dy = 520, 330
    s.rect(dx, dy, 400, 220, fill="#FFFFFF", stroke=STROKE, r=28)
    s.text(dx + 24, dy + 48, "Unsaved changes", 22, INK, 500)
    s.text(dx + 24, dy + 86, "You have unsaved changes. Do you want to", 14, MUTED)
    s.text(dx + 24, dy + 106, "save them before leaving?", 14, MUTED)
    s.button(dx + 100, dy + 156, "Cancel", "text", w=80)
    s.button(dx + 184, dy + 156, "Discard", "text", w=90)
    s.button(dx + 284, dy + 156, "Save", "filled", w=92)
    return s
