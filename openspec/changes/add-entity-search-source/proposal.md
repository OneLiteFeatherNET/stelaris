# Proposal

## Why

Entity search in the palette only sees what the app has already loaded. An item that sits on the
second page of a list, or in a section nobody opened yet, can't be found. The backend has no search
endpoint today, but one is planned. The palette needs a place for such a service to plug in, and a
limit, so that neither thousands of loaded entities nor a generous service flood the list.

## What Changes

- **A search-source API** (`EntitySearchSource`): given a query, an optional kind, the project and a
  limit, it returns entity hits (kind and model). `CommandPaletteShortcuts` takes an optional
  source, and a backend implementation plugs in there without the palette changing.
- **Merging**: in entity mode, loaded matches show at once. The source's hits follow after a short
  debounce. Hits already listed are not repeated, and stale answers for an older query are ignored.
  Choosing a hit behaves like choosing a loaded entity: it opens it, has tabs and "Delete…".
- **At most 15 entities** in the list, loaded and remote together. A notice says when more matched
  than are shown.
- **Notices**:
  - Without a source, the palette keeps saying that only loaded entries are searched.
  - With a source, it says "Searching…" while the source works.
  - If the source fails, it says so and keeps showing the loaded matches.
- No backend endpoint in this change and no source configured by default. The design sketches the
  endpoint a backend could offer.

## Capabilities

### New Capabilities

- `entity-search-source`: the source API, merging its hits with loaded entities, the 15-entity
  limit, and the notices.

### Modified Capabilities

<!-- None in archived specs. The open add-command-palette-syntax change words its "honest about
     what is loaded" requirement for the case without a source (adjusted there). -->

## Impact

- **Code**:
  - `lib/feature/command_palette/entity_search_source.dart` holds the API.
  - `EntityProvider` ranks names before building commands and caps at 15.
  - The controller runs the debounced source query and merges its hits.
  - The host carries the source.
- **Performance**: ranking works on names, and commands are built only for the entities shown.
- **Backend**: none yet; a follow-up can implement the source against a search endpoint.
