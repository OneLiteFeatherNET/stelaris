# Proposal

## Why

The entity mode of the command palette (`add-command-palette-syntax`) opens an item, font or sound
on its first tab. People who want the lore of an item or the chars of a font then still have to
reach for the mouse. Palettes such as Linear, kbar and cmdk solve this with nested pages: from an
entry you step into its sub-entries. Here those sub-entries are the detail page's tabs.

It builds on `add-command-palette-syntax` and requires it first.

## What Changes

- **Arrow Right** on an entity that has tabs (items, fonts, sounds) shows those tabs in the palette,
  with the entity named in the chip. This only happens with the cursor at the end of the search
  text; anywhere else, Arrow Right keeps moving the cursor.
- **Enter** on a tab opens the entity's detail page directly on that tab. Enter on the entity itself
  still opens the first tab.
- **Arrow Left** with the cursor at the start, or **Backspace** in an empty field, goes back to the
  list the user came from, with the query they had typed.
- Entries that have tabs show a `›`. The key hints and the Keyboard help section gain the arrows.
- **Detail pages open on a requested tab**: `/items/detail`, `/fonts/detail` and `/sound/detail`
  accept `?tab=<name>` and start on that tab. Without it, or with an unknown name, they start on the
  first tab as today.
- Not in this change: drilling into "Go to" pages (the page's entities), and tabs for notifications
  or attributes, which have none.

## Capabilities

### New Capabilities

- `command-palette-drilldown`: stepping into and out of an entry's sub-entries with the arrow keys,
  and opening a detail page on a given tab.

### Modified Capabilities

<!-- None. Everything added lives in the new capability, and the command-palette and
     command-palette-syntax behaviors stay as specified. -->

## Impact

- **Code**:
  - `lib/feature/command_palette/`: commands can carry children, and the palette keeps a
    drill-down frame and handles the arrows.
  - `ItemDetailPage`, `FontDetailPage` and `SoundDetailPage` read the `tab` query parameter.
    A shared helper maps it to the start index.
- **Routes**: unchanged. The query parameter passes through the existing detail routes and their
  redirects.
- **Localization**: key hint and help strings.
- **Dependencies / backend**: none.
