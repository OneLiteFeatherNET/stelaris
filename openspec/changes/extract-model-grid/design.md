# Design

## Context

- `ModelPage<E extends DataModel>` (`lib/feature/model/model_page.dart`) mixes three concerns.
  - It frames the page: the `PageHeader` with refresh and add, titled by a `NavigationEntry`.
  - It owns the search: it registers the filter options, reads `ModelSearchState`, and filters and
    sorts the models.
  - It lays out the grid: the columns, the `SliverGrid` and the load-more footer through
    `InfiniteScrollMixin`.
- `ModelGridCard<E extends DataModel>` draws a filled card. It shows the content of
  `mapToDataModelItem`, the `ModelCardActions` with the actions menu and delete, the first line of
  the notes, and a timestamp footer.
- The tests in `test/feature/model/` find the card through `Key('model_grid_card_inkwell')` and
  through its widgets.

## Goals / Non-Goals

**Goals:**
- The grid and the card look are usable without `DataModel`.
- The list pages look and behave exactly as before.

**Non-Goals:**
- Moving the search, filters or sorting out of `ModelPage`.
- Changing the card height, the columns or any style.

## Decisions

### `ModelGrid<T>` owns the scrolling, `ModelPage` the empty states
`ModelGrid` is a `StatefulWidget` with `InfiniteScrollMixin`. It takes `items`, `itemBuilder`,
`cardHeight` (default 148), `onLoadMore`, `hasMore` and `isLoadingMore`. It exposes the layout
values as constants (`maxCardExtent`, `spacing`, `maxColumns`) so that a page with its own layout
can line up with it.

The empty states stay in `ModelPage`. "No results" depends on the search, which only `ModelPage`
knows, so `ModelPage` decides before it builds the grid.

### `ModelCardFrame` takes slots, not a model
`ModelCardFrame` has these slots:
- `content` (required), the left part of the header;
- `trailing`, the right part of the header, e.g. `ModelCardActions` or a status badge;
- `summary`, one muted line below the header;
- `footerIcon` and `footerText`, shown below a divider when the text is set;
- `onTap`.

It keeps the `Key('model_grid_card_inkwell')` on its `InkWell`, so the existing tests and finders
keep working. `ModelGridCard` maps its model onto the slots.

## Risks / Trade-offs

- **Refactor of shared code.**
  - Mitigation: no test in `test/feature/model/` changes, and the full suite runs before the commit.
- **Default card height 148.** A list without a summary line could use a lower one. That is why
  `cardHeight` is a parameter.

## Open Questions

None.
