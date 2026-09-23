# Spec Delta

## Purpose

Makes the app bar's search field the single place to filter the current list and to reach every
command, entity and project, so the list filter and the command palette no longer compete for the
same keystrokes.

## ADDED Requirements

### Requirement: The search field opens a dropdown of entries

The system SHALL show the command palette's entries in a dropdown below the app bar search field
while the field has focus and the dropdown is open. The dropdown SHALL open when the field gains
focus by `Ctrl+K`/`Cmd+K` or by clicking it, and when the user types. It SHALL offer everything the
palette offered: commands, the query syntax with its chip, the entity drill-down, creating and
deleting, help, and the key hints.

#### Scenario: Click into the field

- **WHEN** the user clicks the empty app bar search field
- **THEN** the dropdown lists the commands grouped by section

#### Scenario: Syntax in the app bar

- **WHEN** the user types `#item ` into the app bar search field
- **THEN** the field shows an "Items" chip and the dropdown lists loaded items

### Requirement: Plain text filters the list, and filtering is the default

The system SHALL keep filtering the current list by plain text typed into the field, as the search
did before. While the text is plain and not empty, the first dropdown entry SHALL be "Filter
<section> by '<text>'", and it SHALL be highlighted, so `Enter` keeps the filter and closes the
dropdown. Commands and entities follow below it and are reached with `Down`.

#### Scenario: Enter keeps the filter

- **WHEN** the user is on the Items page, types `sword` and presses `Enter`
- **THEN** the dropdown closes, the Items list stays filtered by `sword`, and nothing else runs

#### Scenario: Down reaches the commands

- **WHEN** the user types `dark`, presses `Down` and then `Enter`
- **THEN** "Toggle dark mode" runs

### Requirement: Prefixed input does not filter the list

The system SHALL NOT filter the list by input that starts with a mode prefix or alias (`>`, `:`,
`#`, `@`, `/`, `?`, or an alias word with a space), and SHALL not offer the filter entry for it. The
list SHALL show the filter it had before the prefix was typed.

#### Scenario: Entity search leaves the list alone

- **WHEN** the Items list is unfiltered and the user types `#sword`
- **THEN** the dropdown lists "Diamond Sword" and the Items list stays unfiltered

### Requirement: Typing on a detail page does not leave it

The system SHALL NOT leave a detail page while the user types into the field. On a detail page the
filter entry SHALL read "Show <section> matching '<text>'". Choosing it SHALL go to the section's
list filtered by the text, asking about unsaved changes first as the search did before.

#### Scenario: Command on a detail page

- **WHEN** the user is on an item's detail page and types `delete this`
- **THEN** the page stays open and "Delete this item…" is listed

#### Scenario: Filter from a detail page

- **WHEN** the user is on an item's detail page, types `sword` and presses `Enter`
- **THEN** the Items list is shown, filtered by `sword`

### Requirement: The search field shows the palette's placeholder

The system SHALL show, in the empty field, the placeholder of the active palette mode. In the
default mode it SHALL name the current section and point to `?`.

#### Scenario: Default placeholder in the app bar

- **WHEN** the user is on the Items page and the field is empty
- **THEN** the placeholder names Items and mentions `?`
