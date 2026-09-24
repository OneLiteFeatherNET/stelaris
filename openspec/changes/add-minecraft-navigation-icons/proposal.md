# Proposal

## Why

The navigation rail's icons don't say what the sections are. A name badge stands for attributes, a
gamepad for items, a chat bubble for notifications (which are advancement toasts) and a volume knob
for sounds. Stelaris edits Minecraft content, and its users know Minecraft's own pictures. Icons
drawn from those pictures, but kept in Material's clean, single-colour style, make each section
recognisable at a glance and give the app its own look.

## What Changes

- **Five custom icons**, each in two forms: an outline for an inactive section and a filled one for
  the selected section. They are drawn on Material's 24×24 grid with 2px strokes and rounded ends.
  Minecraft shows in their silhouettes, not in pixel steps:
  - Attributes: heart with faceted lobes (the health bar)
  - Items: pickaxe (socket block, two curved blades, straight handle)
  - Notifications: advancement toast frame with a star
  - Fonts: the letters "Aa", with a blocky "a"
  - Sound: note block
- **The navigation rail and the Ctrl+K palette** both use the new icons. The palette's "go to"
  commands already take their icons from the navigation sections.
- **The icons follow the theme** like the Material icons do today: their colour, size, and light and
  dark mode.
- **SVG sources in the repo**: the drawings are kept as SVG so they can be changed later.
- No new runtime dependency. Other icons in the app (app bar, menus, projects) stay Material icons.

## Capabilities

### New Capabilities

- `navigation-icons`: which icon each navigation section shows, its outline and filled forms, and
  that the rail and the palette show the same icons in the theme's colours.

### Modified Capabilities

<!-- None. The command-palette spec does not name icons; the "go to" commands keep taking theirs
     from the navigation section. -->

## Impact

- **Code**: `NavigationEntry` (`lib/api/util/navigation.dart`) points at the new icons. The rail
  and `commands.dart` need no change.
- **Assets**:
  - An icon font generated from the SVGs, declared in `pubspec.yaml`.
  - A generated Dart class that holds the icon constants.
  - The SVG sources.
- **Tooling**: a one-off script turns the SVGs into the font. Its output is committed, so the Docker
  and CI builds stay as they are.
- **Tests**: the existing palette test (marked entry uses the filled icon) keeps passing. A test
  checks that each section has distinct outline and filled icons.
