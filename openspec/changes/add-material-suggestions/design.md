# Design

## Context

See proposal.md for motivation and specs/material-suggestions/spec.md for the required behavior.

- `vulpes_data/material.dart` exports `MaterialSearch`, `MaterialSearchEntry` (display name, key,
  search key, terms, category bitmask) and `MaterialCategory`. `search` normalizes a `minecraft:`
  prefix and separators, ranks exact and prefix matches first, and returns the first entries for an
  empty query.
- `SchemaField` renders a `KeySchema` as a `TextFormField` with a `minecraft:…` hint and a key
  pattern validator. `KeySchema.registry` names the registry. List-of-keys and the key mode of
  `RegistryTagField` render through the same branch.
- `TextInputCard` owns a controller and focus node and submits its value on focus loss and on
  Enter.

## Goals / Non-Goals

**Goals:**

- One widget that adds suggestions to any text field without changing the field's decoration or
  validation.
- Free text stays valid; custom and non-vanilla ids keep working.

**Non-Goals:**

- Suggestions for other registries (sound events, entity types, ...); no index for them exists.
- Restricting input to known materials or changing validators.
- Item icons in the suggestion list.

## Decisions

### `RawAutocomplete` with a caller-built field

`MaterialAutocomplete` wraps `RawAutocomplete<MaterialSearchEntry>` and takes a `fieldBuilder`, so
callers keep their own `TextFormField` (decoration, helper text, validator, `Form` participation).
`Autocomplete` would build the field itself and could not carry those. Arrow keys, Enter and
Escape come from `RawAutocomplete`.

### Suggestions do not replace `onChanged`

Picking a suggestion changes the controller programmatically, which does not call the field's
`onChanged`. The widget therefore reports the key through its own `onSelected`; callers wire that
to the same handler as typing (`SchemaField.onChanged`, `TextInputCard`'s submit).

### Build the index once, cap at five

The `MaterialSearch` is a top-level `final`, built on first use, because indexing every material
per keystroke or per widget is wasteful. `limit: 5` bounds the overlay. An empty or blank query
suggests nothing, even though `search` would return the first entries.

### Registry decides the categories

`item` searches all materials, `block` passes `{MaterialCategory.block}`. Any other registry, or
none, builds the plain `TextFormField` as before.

### Opt-in on `TextInputCard`

`suggestsMaterials` defaults to `false`, so the other cards are untouched. When on, the card passes
its own controller and focus node to `MaterialAutocomplete`, so focus-loss submission stays as is.
Enter submits the typed text unless it took a suggestion (then `onSelected` submits the key).

## Risks / Trade-offs

- A suggestion list overlays content below the field; it is limited to five rows and the width of the field.
- Enter on a card submits once through `onSelected` and, because Enter drops focus, once more
  through the focus listener; the second call carries the same value and the pages already ignore
  unchanged values.

## Material 3 menu

The suggestions are drawn as a Material 3 menu, following the SDK's menu implementation
(`material_ui` 1.6.0 is the Material library split out of Flutter, with no separate autocomplete
component): `menu_anchor.dart` (`_MenuPanel`, `MenuItemButton`) and the generated
`generated/menu_defaults_m3.g.dart` (`_MenuDefaultsM3`), with `dropdown_menu.dart` as the model for
highlighting an item while focus stays in a text field.

- **Panel**: `surfaceContainer` background, elevation level 2 (3 dp), 4 dp corner radius,
  `shadow` shadow colour, transparent surface tint and 8 dp vertical padding, each read from the
  ambient `MenuTheme` first so an app-wide menu theme applies. Colours come from the colour scheme,
  so light and dark mode follow the theme.
- **Items**: `MenuItemButton` with the display name in the button label style and the key in
  `bodySmall` / `onSurfaceVariant`, as the two-line menu item (56 dp). The keyboard-highlighted item
  gets the 10% `onSurface` state layer of a focused item, like `DropdownMenu` does.
- **Size and scrolling**: `RawAutocomplete` gives the options view the field's width and the space
  left on screen, so the list is as wide as the field and scrolls when it does not fit (desktop and
  web add the scrollbar). The fixed item extent lets the list scroll the highlighted item into view
  without building it first.
- **Cost**: `ListView.builder` builds only visible rows; the list listens to the highlight without
  depending on it, so only the rows repaint when the highlight moves.

## Web semantics

With the web semantics tree on (screen readers, browser automation), showing the options overlay
makes the engine re-parent the semantic nodes of the dialog route, which blurs the DOM input: the
field loses focus after the first typed character. A plain field is unaffected, and so is the web
without semantics. `MaterialAutocomplete` therefore shows no suggestions on the web while
semantics are on; typing keeps working.
