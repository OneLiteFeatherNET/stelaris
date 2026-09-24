# Design

## Context

`NavigationEntry` (`lib/api/util/navigation.dart`) is the only place that holds the section icons.
It has two `IconData` fields: `data` (outline) and `selected` (filled). Two places read them:

```
             NavigationEntry.data / .selected   (IconData)
                  |                     |
                  v                     v
   NavigationSideBar              commands.dart _goTo
   (NavigationRailDestination     (icon / currentIcon of the
    icon / selectedIcon)           "go to" palette commands)
```

The app has no custom fonts or icon assets yet. `pubspec.yaml` bundles only files directly in
`assets/`, not subfolders. The web image is built with `flutter build web --release --wasm` inside
the Dockerfile, and that build has no Node toolchain.

## Goals / Non-Goals

**Goals:**
- Replace the five section icons with custom drawings and keep the `IconData` type, so the rail and
  the palette stay untouched.
- Keep the SVG drawings as the editable source.

**Non-Goals:**
- Changing other icons: app bar, menus, the projects command, create/delete commands.
- Tooltips or labels for the collapsed rail.
- Coloured or multi-tone icons.

## Decisions

### An icon font rather than SVG widgets

We generate an icon font (`StelarisIcons.ttf`) from the SVGs. A generated `StelarisIcons` class
holds `static const IconData` constants. Each constant uses `fontFamily: 'StelarisIcons'`.

- **Why**:
  - `IconData` goes through `Icon`, so `IconTheme` colours and sizes it. Both the rail's
    selected/unselected colours and the palette work as they do today.
  - Only the enum values change.
  - Flutter's icon tree-shaking still applies, because the constants are `const`.
- **Rejected: `flutter_svg`**. It adds a runtime dependency. It would turn `IconData` into a widget
  throughout `NavigationEntry`, `StelarisCommand` and their tests. Theme colours would also have to
  be rebuilt with a `ColorFilter`.
- **Rejected: `CustomPainter`/`Path` in Dart**. There are no dependencies, but the SVG source is
  lost and the drawings are hard to adjust.

### Generated output is committed; generation is a manual script

The SVGs live in `design/icons/navigation/`, outside `assets/`, so they aren't bundled. A script
`tool/generate_icons.sh` runs `npx fantasticon` and writes two files, both committed:

- `assets/fonts/StelarisIcons.ttf`
- `lib/util/stelaris_icons.dart`

The Dart file has a fixed code point per icon, so regenerating keeps existing code points stable.

- **Why**: the Docker and CI builds don't need Node, and a normal `flutter build` sees just a font.
- **Rejected: generating the font in the Dockerfile**. It would add a Node stage for a file that
  rarely changes.
- If the generated Dart doesn't match the project's style, the script writes only the font. The
  Dart class is then kept by hand, with ten constants.

### Drawing rules

- 24×24 viewBox with Material's 2px padding, so the live area is 20×20.
- Material geometry: 2px strokes with round joins and caps, and real diagonals and curves. The
  Minecraft look comes from the silhouettes (the heart's faceted lobes, the advancement frame's cut
  corners, the blocky "a"), not from a pixel grid. A first pass on a 2px pixel grid read as too
  pixelated at rail size and was dropped in the motif review.
- The shapes are authored with strokes, then flattened to one filled path per icon (picosvg /
  skia-pathops), because the font takes fills only. The flattened SVGs are what the repo keeps.
- The filled form fills the outline's silhouette, and details (the star, the note) are cut out as
  counters. Letters have no inside to fill, so the filled "Aa" is a heavier stroke of the same
  letters.
- Recognisability beats Minecraft flavour. In the review a crescent pickaxe read as a sickle and a
  flat-topped "A" as an arch. The pickaxe now has a socket block with two blades, and Fonts shows
  "Aa", the common sign for type.
- Each glyph is named `<motif>_outlined` or `<motif>`, like Material:

```
heart / heart_outlined               attributes
pickaxe / pickaxe_outlined           items
advancement / advancement_outlined   notifications
letters / letters_outlined           fonts
note_block / note_block_outlined     sound
```

### Motif review before generation

The motifs were settled in discussion, but they have to hold up at 24px. The first task is an HTML
preview of the SVGs: outline and filled, light and dark, at 24px, next to the current icons. The
user approves it before the font is generated. A sword stays ready as a fallback for Attributes, in
case the heart reads as "favourite".

## Risks / Trade-offs

- [The heart reads as "favourites" without a label] → The motif review compares it with the sword.
  Tooltips for the collapsed rail are a possible follow-up.
- [Fine details (the star, the note flag) blur at small sizes] → Keep details at least 1.8px thick
  and check them at 18px and 24px in the preview.
- [The font file is out of date with the SVGs] → The script is the only way to update both. The
  tasks rerun it and check the font into the same commit as the SVG change.
- [Icon tree-shaking breaks the font] → `IconData` constants stay `const`. The wasm release build is
  checked in the tasks.

## Migration Plan

This is a UI-only change with no data or API impact. To roll back, point `NavigationEntry` back at
the Material icons.
