# Design

## Context

See proposal.md for motivation and specs/command-palette-drilldown/spec.md for the behavior.

- Entity entries come from `EntityProvider`
  (`lib/feature/command_palette/palette_providers.dart`). Each is a `StelarisCommand` whose `run`
  dispatches the selection and calls `context.go('<route>/detail')`.
- The palette (`CommandPalette`) holds `_mode`, `_kind` and the text, handles keys in the text
  field's `FocusNode.onKeyEvent`, and switches its own state for entries with `switchTo`.
- `ItemDetailPage`, `FontDetailPage` and `SoundDetailPage` build a `DefaultTabController` without
  an initial index, from a private `_tabs` list of `Tab(text: …)`. Notifications and attributes
  have no tabs.
- The detail routes' redirects look only at `matchedLocation` and the Redux selection, so a query
  parameter passes through untouched.

## Goals / Non-Goals

**Goals:**

- Nested entries as data: a command may carry children. The palette doesn't need to know what an
  item's tabs are.
- One source for each page's tab names, used by both the page and the palette.

**Non-Goals:**

- Drilling into "Go to" pages or several levels deep. The frame design allows it, but this change
  only builds one level.
- Deep links to a specific entity. The detail route still depends on the Redux selection.

## Decisions

### Tabs are named once, on the page

Each detail page gets a public `static const List<String> tabs`, for example
`['General', 'Meta', 'Enchantments', 'Lore']`. Its private `_tabs` is built from it. The palette
reads the same list. A shared helper in `lib/feature/model/detail_tabs.dart` does the rest:

```
int initialTabIndex(BuildContext context, List<String> tabs)
    // GoRouterState.of(context).uri.queryParameters['tab'], matched case-insensitively,
    // or 0 when missing or unknown
String detailLocation(String listRoute, String? tab)
    // '<route>/detail' or '<route>/detail?tab=<lowercased tab>'
```

`DefaultTabController` gets `initialIndex: initialTabIndex(...)` and a `key` from the tab
parameter. Without the key, going from `?tab=meta` to `?tab=lore` on the same detail route would
keep the old controller and the old tab.

- *Alternative:* a path segment (`/items/detail/lore`). Rejected: it needs new routes and
  redirects for each page, while a query parameter needs none.

### Children on commands, one frame in the palette

`StelarisCommand` gains `List<StelarisCommand> Function()? children`. `EntityProvider` sets it for
items, fonts and sounds. Each child is a tab entry whose `run` dispatches the same selection and
goes to `detailLocation(route, tab)`.

The palette keeps an optional drill frame:

```
_DrillFrame { StelarisCommand parent; PaletteMode? mode; EntityKind? kind; String text; int highlight }
```

- Stepping in saves the current mode, kind, text and highlight in the frame, clears the text, and
  lists `parent.children()` filtered by `scoreMatch` on the typed text.
- The chip shows the parent's title while a frame is active.
- Stepping out restores everything from the frame. Backspace in an empty field and the chip's
  delete action step out before they leave a mode.

One nullable frame instead of a stack is enough for one level. It would become a list if deeper
nesting ever arrives.

### Arrow keys only act at the edges of the text

In `_onKey`:

- Arrow Right is handled, and so kept from the field, only if the selection is collapsed at the
  end of the text and the highlighted entry has children.
- Arrow Left is handled only inside a frame with the cursor at offset 0.

In every other case the event is ignored, so the text field moves the cursor as usual.

### Marker and hints

- A row with children gets a trailing `chevron_right` icon after its section label.
- The footer adds `→ Tabs` while any listed entry has children.
- The Keyboard help section gains `→` (step in) and `←` (step out) entries.

## Risks / Trade-offs

- [Arrow Right is a text-editing key] → It only acts at the end of the text. That is the position
  where the field would do nothing with it anyway.
- [The tab names are English literals] → They already are on the pages. Moving them into a shared
  list makes a later localization a single change.
- [Opening `?tab=` on the detail page the user is already on] → The keyed controller rebuilds, so
  the tab switches as expected.

## Migration Plan

Additive. Without `?tab=` every detail page behaves as before. Rollback means reverting the change.
