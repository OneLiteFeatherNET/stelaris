# Spec Delta

## Purpose

Lets a search service contribute entities to the palette's entity mode beyond what the app has
loaded, while keeping the list short.

## ADDED Requirements

### Requirement: At most 15 entities are listed

The system SHALL list at most 15 entities in entity mode, loaded and service-provided together,
best matches first. When more entities matched than are listed, the palette SHALL say how many are
shown out of how many matched. Entries that are not entities (such as the "Go to" entries for kinds
with nothing loaded) SHALL NOT count against the limit.

#### Scenario: Many loaded matches

- **WHEN** 200 items are loaded that all match `sword` and the user types `#sword`
- **THEN** 15 items are listed and a notice says 15 of 200 are shown

#### Scenario: Few matches

- **WHEN** 3 loaded entities match
- **THEN** all 3 are listed and no count notice is shown

### Requirement: A search service can contribute entities

The system SHALL accept an optional entity search source. In entity mode with a non-empty query, it
SHALL list the loaded matches at once, ask the source for up to 15 matches for the query, kind and
current project after a short pause in typing, and add the source's hits to the list. A hit that
is already listed SHALL NOT be listed twice. An answer for a query that is no longer the current one
SHALL be ignored. Choosing a hit SHALL behave like choosing a loaded entity of the same kind,
including its tabs and "Delete…".

#### Scenario: Hit that is not loaded

- **WHEN** the source knows the item "Obsidian Blade", which is not loaded, and the user types
  `#blade`
- **THEN** "Obsidian Blade" is listed once the source answers, and choosing it opens its detail page

#### Scenario: Duplicate hit

- **WHEN** the source returns an item that is also loaded and already listed
- **THEN** it is listed once

#### Scenario: Stale answer

- **WHEN** the user types `#bl`, then `#blade`, and the answer for `#bl` arrives last
- **THEN** the list shows the answer for `#blade`

### Requirement: The palette says what the entity search covers

The system SHALL show, in entity mode, "only loaded entries are searched" when no source is
configured, "Searching…" while a source query is pending, and a failure notice alongside the loaded
matches when the source fails.

#### Scenario: Source fails

- **WHEN** the source throws for `#blade`
- **THEN** the loaded matches stay listed and a notice says the search service is unavailable
