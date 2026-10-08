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

- A suggestion list overlays content below the field; it is limited to five rows and 360 px width.
- Enter on a card submits once through `onSelected` and, because Enter drops focus, once more
  through the focus listener; the second call carries the same value and the pages already ignore
  unchanged values.
