# Proposal

Ships as `refactor(model)` on `refactor/model-grid`, branched from `develop`.

## Why

The list pages (items, attributes, advancements, fonts, sounds) share `ModelPage` and
`ModelGridCard`. Both are bound to `DataModel` and bring delete, copy, notes, the section header and
the AppBar search with them. A list of things that are not a `DataModel`, such as the project models
of the asset prototype, can't use them and has to copy the grid's columns, spacing and card layout.
Two copies drift apart as soon as one of them changes.

## What Changes

- **`ModelGrid<T>`**: the responsive grid of `ModelPage` without any model binding. It holds the
  column count (cards up to 320 px, at most four columns), the card height, the spacing and the
  load-more footer with the infinite scroll. The cards come from an `itemBuilder`.
- **`ModelCardFrame`**: the look of a model card without its actions. It is a filled card with ink,
  a header row of content plus an optional trailing widget, an optional summary line, and a footer
  with an icon and a text below a divider.
- `ModelPage` builds on `ModelGrid` and keeps the header, the search, the filters, the sorting and
  the empty states. `ModelGridCard` builds on `ModelCardFrame` and keeps the actions menu, delete,
  copy, notes and the "edited/created" footer.

## Capabilities

### New Capabilities

- `model-grid`: a grid and a card frame for lists of any kind of item, which the model list pages
  are built on.

### Modified Capabilities

<!-- None. The list pages behave as before. -->

## Impact

- **stelaris**: `lib/feature/model/` gets two widgets, and `model_page.dart` and
  `model_grid_card.dart` shrink. The existing tests of both must pass unchanged.
- No new dependency, no l10n change, no backend change.

Out of scope: moving the search out of `ModelPage`, and the asset models page itself (it moves
onto the new widgets on its own branch).
