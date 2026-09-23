# Spec Delta

## MODIFIED Requirements

### Requirement: Palette opens with a keyboard shortcut

The system SHALL open the command palette when the user presses `Ctrl+K`, or `Cmd+K` on macOS,
anywhere inside the project workspace (the pages reached after a project is selected), including
while a text field on the page has keyboard focus. The palette is the app bar's search field: the
shortcut focuses that field (expanding it where it is collapsed) and opens its dropdown of
entries, with any text already in the field kept and selected. The shortcut SHALL NOT trigger the browser's
own `Ctrl+K` behavior while the palette handles it. Outside the project workspace (sign-in page,
project selection) and while a modal dialog is open, the shortcut SHALL do nothing.

#### Scenario: Open from a model page

- **WHEN** the user is on the Items page and presses `Ctrl+K`
- **THEN** the app bar search field is focused and its dropdown lists the commands

#### Scenario: Open while typing in the search bar

- **WHEN** the app bar search field holds `sword` and has focus, and the user presses `Ctrl+K`
- **THEN** the dropdown opens for `sword` and the field's text is unchanged

#### Scenario: Open on macOS

- **WHEN** the user is on macOS and presses `Cmd+K` inside the project workspace
- **THEN** the command palette opens

#### Scenario: Shortcut outside the workspace

- **WHEN** the user is on the project selection page and presses `Ctrl+K`
- **THEN** no command palette opens

#### Scenario: Pressing the shortcut while the palette is open

- **WHEN** the dropdown is open and the user presses `Ctrl+K` again
- **THEN** the dropdown closes

### Requirement: Palette closes without side effects

The system SHALL close the dropdown without running any command when the user presses `Esc` or
clicks outside the search field and the dropdown. `Esc` SHALL leave the focus and the text in the
field; a second `Esc` with the dropdown closed clears the field, as the search did before.

#### Scenario: Dismiss with Escape

- **WHEN** the palette is open and the user presses `Esc`
- **THEN** the dropdown closes, no command runs, and the search field keeps its focus and text

#### Scenario: Dismiss by clicking outside

- **WHEN** the dropdown is open and the user clicks outside the field and the dropdown
- **THEN** the dropdown closes and no command runs

### Requirement: Commands are selected and run by keyboard or mouse

The system SHALL keep exactly one listed command highlighted, starting with the first, move the
highlight with `Up` and `Down` (wrapping at the ends), and reset it to the first entry whenever the
query changes. `Enter` SHALL run the highlighted command; clicking a command SHALL run that
command. Running a command SHALL close the dropdown first, so that dialogs and navigation the
command triggers appear on the page rather than behind it.

#### Scenario: Run with Enter

- **WHEN** the user types `:items` and presses `Enter`
- **THEN** the dropdown closes and the Items page is shown

#### Scenario: Move the highlight

- **WHEN** the first entry is highlighted and the user presses `Down` twice and then `Enter`
- **THEN** the third listed command runs

#### Scenario: Highlight wraps

- **WHEN** the first entry is highlighted and the user presses `Up`
- **THEN** the last listed command is highlighted

#### Scenario: Run by click

- **WHEN** the user clicks "Open settings"
- **THEN** the dropdown closes and the settings dialog opens
