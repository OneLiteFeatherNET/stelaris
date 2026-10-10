# Proposal

Ships as `feat(input): suggest minecraft materials in id fields`.

## Why

Item components and notifications ask for a Minecraft material, item or block id as plain text.
Nothing tells the user which ids exist, so they type `minecraft:diamond_sword` from memory and
only learn about a typo when validation or the server rejects it. `vulpes_data` already ships a
searchable index of every vanilla material (`MaterialSearch`), so the app can offer the ids while
the user types.

## What Changes

- **A reusable `MaterialAutocomplete`** (`lib/feature/base/input/material_autocomplete.dart`),
  built on Flutter's `RawAutocomplete`, that shows at most five matching materials under a text
  field - display name plus key - and writes the key of the picked one into the field.
- **Item component key fields** (`KeySchema`) with registry `item` suggest every material; with
  registry `block` they suggest blocks only. This covers lists of keys and the key mode of
  registry-tag fields. Other registries keep the plain field.
- **The notification material card** (`TextInputCard`) gains an opt-in `suggestsMaterials`
  parameter and uses it.
- Suggestions are a shortcut, not a constraint: free text stays valid and all existing validators
  are unchanged.
- No **BREAKING** changes.

## Capabilities

### New Capabilities

- `material-suggestions`: autocomplete of Minecraft material keys in id fields - when it is
  offered, how many suggestions, how a suggestion is taken, and that free text stays allowed.

### Modified Capabilities

<!-- None: no existing spec covers these fields. -->

## Impact

- **Code**: new `lib/feature/base/input/material_autocomplete.dart`; `schema_field.dart` (key
  branch moves into a private `_KeyField`); `text_input_card.dart` (opt-in parameter);
  `notification_page_general.dart` (opts in).
- **Localization**: none.
- **Dependencies**: none added; `vulpes_data/material.dart` is already available.
- **Backend / APIs**: none.
