# Proposal

## Why

The app now has two search fields: the app bar search, which filters the current list, and the
command palette dialog opened with `Ctrl+K`. They look alike, sit in different places and do
different things. People should have one field that filters the list and reaches every command,
entity and project.

## What Changes

- **The app bar search becomes the palette.** Its field shows the palette's entries in a dropdown
  below it, with everything the palette offers: syntax and chip, drill-down, create and delete,
  help, and key hints.
- **`Ctrl+K` / `Cmd+K`** focuses that field (expanding it on narrow screens) and opens the
  dropdown. The palette dialog is removed.
- **Plain text still filters the list**, and filtering is the default. The first entry, "Filter
  Items by 'sword'", is highlighted, so `Enter` just keeps the filter. `Down` reaches entities and
  commands.
- **Prefixed input doesn't filter the list.** `>`, `:`, `#`, `@`, `/`, `?` and alias words only
  drive the dropdown.
- **Detail pages are no longer left on the first keystroke.** On a detail page, "Show Items
  matching '…'" goes to the filtered list, with the unsaved-changes check as before. Typing a
  command there works.
- **`Esc`** first closes the dropdown. A second `Esc` clears the field, as before.
- The sort and filter menu, the clear button and compact mode stay.
- **BREAKING** for muscle memory only: there is no palette dialog anymore. `Ctrl+K` leads to the
  app bar field instead.

## Capabilities

### New Capabilities

- `app-bar-command-search`: the combined field. Covers the dropdown, the default filter entry,
  prefixes leaving the list alone, detail-page typing, and the placeholder.

### Modified Capabilities

- `command-palette`: the palette is the app bar field's dropdown instead of a dialog. This affects
  how it opens, how `Esc` and outside clicks dismiss it, and that plain text plus `Enter` now
  filters. The "Run with Enter" example uses `:items`.

## Impact

- **Code**:
  - The palette's state and list move from the dialog widget into a controller and a panel. The
    controller holds mode, kind, drill frame, results and highlight, and handles keys. The panel is
    the list, the notice and the key hints.
  - `AppBarSearch` owns the controller and shows the panel in an overlay under its field.
  - `CommandPaletteShortcuts` asks the field to open instead of showing a dialog.
- **Tests**: the palette tests move from the dialog to the app bar field. Expectations change where
  the filter entry now comes first.
- **Other open changes**: syntax, drill-down and create/delete keep their behavior, now in the
  dropdown. Their chip and placeholder requirements apply to the app bar field.
