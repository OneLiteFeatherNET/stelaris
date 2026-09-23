# Spec Delta

## Purpose

Lets people step from a palette entry into its sub-entries with the arrow keys, so an item, font or
sound can be opened directly on the tab they want.

## ADDED Requirements

### Requirement: Arrow Right steps into an entry's tabs

The system SHALL show, when the user presses Arrow Right on a highlighted entity that has tabs
(items, fonts and sounds), that entity's tabs in the palette instead of the previous list. The chip
SHALL name the entity. This SHALL only happen while the cursor is at the end of the search text.
Anywhere else, Arrow Right SHALL move the cursor as usual. On entries without tabs, Arrow Right SHALL
do nothing beyond moving the cursor.

#### Scenario: Step into an item

- **WHEN** "Diamond Sword" is highlighted in entity mode and the user presses Arrow Right
- **THEN** the palette lists General, Meta, Enchantments and Lore, and the chip says "Diamond Sword"

#### Scenario: Cursor inside the text

- **WHEN** the query is `sword`, the cursor is after `sw`, and the user presses Arrow Right
- **THEN** the cursor moves one character and the palette still lists the entities

#### Scenario: Entry without tabs

- **WHEN** an attribute is highlighted and the user presses Arrow Right
- **THEN** the list stays as it was

### Requirement: Choosing a tab opens the detail page on it

The system SHALL, when the user chooses a tab in the drill-down, select the entity and open its
detail page on that tab. The tabs SHALL be filterable by typing. Choosing the entity itself instead
of stepping in SHALL still open the first tab.

#### Scenario: Open an item on its Lore tab

- **WHEN** the user has stepped into "Diamond Sword" and chooses Lore
- **THEN** the palette closes and the Items detail page shows "Diamond Sword" on the Lore tab

#### Scenario: Filter the tabs

- **WHEN** the user has stepped into an item and types `ench`
- **THEN** only Enchantments is listed

### Requirement: Arrow Left and Backspace step back out

The system SHALL return to the list the user stepped in from, with the query they had typed and
with the entry they stepped in from highlighted, when the user presses Arrow Left with the cursor at
the start of the field, or Backspace in an empty field.

#### Scenario: Step back with Arrow Left

- **WHEN** the user typed `#sword`, stepped into "Diamond Sword", and presses Arrow Left
- **THEN** the palette is in entity mode with the query `sword` and "Diamond Sword" highlighted

#### Scenario: Step back with Backspace

- **WHEN** the user has stepped into an entity and presses Backspace in the empty field
- **THEN** the palette is back in the list the user came from

### Requirement: Entries with tabs are marked and the keys are shown

The system SHALL mark entries that can be stepped into with a trailing `›`. The key hints under the
list SHALL mention Arrow Right while the list contains such an entry. The Keyboard help section
SHALL list Arrow Right and Arrow Left.

#### Scenario: Marker on items, not on attributes

- **WHEN** the entity list shows an item and an attribute
- **THEN** the item row shows `›` and the attribute row does not

### Requirement: Detail pages open on a requested tab

The system SHALL open the item, font and sound detail pages on the tab named by a `tab` query
parameter (for example `/items/detail?tab=lore`), matched case-insensitively against the tab
names. Without the parameter, or with a name that is not one of the page's tabs, the page SHALL
open on its first tab as before.

#### Scenario: Font on Chars

- **WHEN** the selected font's detail page is opened at `/fonts/detail?tab=chars`
- **THEN** the Chars tab is shown

#### Scenario: Unknown tab

- **WHEN** a detail page is opened with `?tab=nonsense`
- **THEN** the first tab is shown
