# Design

## Context

- `EntityProvider` builds one `StelarisCommand` per loaded model on every keystroke, then ranks them
  all with `scoreMatch`. With 5,000 loaded items that took about 13 ms per keystroke (measured in a
  test benchmark), and the list held 5,000 rows.
- `scoreMatch` computes the best placement with a DP that looks back over every earlier position:
  O(query × title²). It also runs in full for titles that do not match.
- `CommandPaletteController` is synchronous. Results come from `PaletteSearch.resolve`.

## Goals / Non-Goals

**Goals:**

- A small, backend-agnostic source API. No HTTP in the palette.
- Bounded work per keystroke regardless of how much is loaded.

**Non-Goals:**

- The backend endpoint and its client, which are a follow-up.
- Server-side ranking rules. The palette keeps its own order for loaded matches.

## Decisions

### The API

```dart
abstract interface class EntitySearchSource {
  Future<List<EntityHit>> search(EntitySearchRequest request);
}

class EntitySearchRequest { String query; EntityKind? kind; String? projectId; int limit; }
class EntityHit { EntityKind kind; DataModel model; }   // model's type must fit kind
```

A backend implementation could call, for example, `GET /search?q=&kind=&projectId=&limit=15`,
returning `[{kind, model}]`. That contract is a suggestion for the follow-up, not part of this
change. Hits whose model type doesn't fit their kind are dropped.

### Ranking before building, capped at 15

`EntityProvider` collects `(kind, model, name)` tuples, which are cheap, and ranks them by
`scoreMatch(name)`. It keeps the best 15 and builds commands only for those. With an empty query it
keeps the first 15 in kind order. It reports the total number of matches, so the notice can say
"15 of 200".

Service hits join the same ranking. Hits that `scoreMatch` does not match (a service may match on
key or fuzzily) sort after the ones it does, in the order the service returned them. Deduplication
uses `kind + id`.

### Faster `scoreMatch`

1. A greedy subsequence check rejects non-matches in O(title).
2. The DP keeps a running best for non-adjacent predecessors, which brings it to O(query × title).

The existing tests pin the scores' ordering.

### Redux actions with a debounce run the source

The source query is app state, like every other backend call here. It does not run on a timer
inside the palette.

- **State**: `AppState.entitySearch` holds the current request, its hits and the status. It is
  transient and excluded from JSON, like the other caches.
- **`EntitySearchStartedAction(request)`**: synchronous. It records the request, empties the hits
  and sets the status to pending. The notice shows "Searching…" at once.
- **`EntitySearchAction(source, request) with Debounce`** (250 ms, one lock for all entity
  searches): async `Debounce` drops every dispatch that a newer one supersedes within the pause.
  - Its reducer returns nothing if `state.entitySearch.request` is no longer its request, both
    before and after awaiting the source. That covers a newer query arriving while an older one is
    in flight.
  - On success it stores the hits as done. On a throw it stores failed.
- **`ClearEntitySearchAction`**: forgets everything when there is no question, for example when
  leaving entity mode or clearing the text.
- **Controller and host**:
  - The controller only reports the question it would ask, through `onEntityQuery(request?)`, and
    only when that question changes.
  - The app bar search dispatches the actions and follows the store's `entitySearch` through a
    distinct `onChange` subscription, so its field doesn't rebuild. It hands updates to
    `controller.applyEntitySearch`.
  - The controller re-resolves when the state belongs to its current question.

### Notices

The notice is one line. Its state comes from the controller: no source, pending, failed, or capped.
Capped combines with the others, for example "Searching… · 15 of 200 shown".

## Risks / Trade-offs

- [A slow source makes the list jump when hits arrive] → Loaded matches come first and stay in
  place, hits are appended, and the highlight stays on its entry.
- [Unmatched service hits have no palette score] → They follow the scored ones in the service's
  order, which is a reasonable default for a search service's own relevance.
- [No source by default] → Behavior without one stays as before, apart from the cap and the faster
  search.

## Migration Plan

Additive. Rollback means reverting the change.
