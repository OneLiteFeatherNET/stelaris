# command-palette Specification

## Purpose

Lets people run navigation, interface and backend actions from the keyboard through a single
searchable palette, instead of locating the matching button on the matching page.

## Requirements

### Requirement: Palette opens with a keyboard shortcut

The system SHALL open the command palette when the user presses `Ctrl+K`, or `Cmd+K` on macOS,
anywhere inside the project workspace (the pages reached after a project is selected), including
while a text field on the page has keyboard focus. The shortcut SHALL NOT trigger the browser's
own `Ctrl+K` behavior while the palette handles it. Outside the project workspace (sign-in page,
project selection) and while a modal dialog is open, the shortcut SHALL do nothing.

#### Scenario: Open from a model page

- **WHEN** the user is on the Items page and presses `Ctrl+K`
- **THEN** the command palette opens with an empty, focused search field

#### Scenario: Open while typing in the search bar

- **WHEN** the model search bar has focus and the user presses `Ctrl+K`
- **THEN** the command palette opens and the search bar's text is unchanged

#### Scenario: Open on macOS

- **WHEN** the user is on macOS and presses `Cmd+K` inside the project workspace
- **THEN** the command palette opens

#### Scenario: Shortcut outside the workspace

- **WHEN** the user is on the project selection page and presses `Ctrl+K`
- **THEN** no command palette opens

#### Scenario: Pressing the shortcut while the palette is open

- **WHEN** the command palette is open and the user presses `Ctrl+K` again
- **THEN** the palette closes

### Requirement: Palette closes without side effects

The system SHALL close the palette without running any command when the user presses `Esc` or
clicks outside it, and SHALL return keyboard focus to where it was before the palette opened.

#### Scenario: Dismiss with Escape

- **WHEN** the palette is open and the user presses `Esc`
- **THEN** the palette closes, no command runs, and the previously focused element regains focus

#### Scenario: Dismiss by clicking outside

- **WHEN** the palette is open and the user clicks outside it
- **THEN** the palette closes and no command runs

### Requirement: Commands are searched as the user types

The system SHALL list all available commands grouped by category (Navigation, Interface, Backend)
while the search field is empty, and SHALL narrow the list as the user types to the commands whose
title or keywords match the query, case-insensitively and allowing non-adjacent characters in
order. Closer matches SHALL be listed first. When nothing matches, the palette SHALL show an
empty-result message instead of an empty list.

#### Scenario: Empty query lists everything available

- **WHEN** the palette opens
- **THEN** every available command is listed under its group heading

#### Scenario: Query narrows the list

- **WHEN** the user types `dark`
- **THEN** the list contains "Toggle dark mode" and no command whose title and keywords do not match

#### Scenario: Non-adjacent characters match

- **WHEN** the user types `gtit`
- **THEN** "Go to Items" is listed

#### Scenario: No match

- **WHEN** the user types a query no available command matches
- **THEN** the palette shows a "no matching commands" message

### Requirement: Commands are selected and run by keyboard or mouse

The system SHALL keep exactly one listed command highlighted, starting with the first, move the
highlight with `Up` and `Down` (wrapping at the ends), and reset it to the first entry whenever the
query changes. `Enter` SHALL run the highlighted command; clicking a command SHALL run that
command. Running a command SHALL close the palette first, so that dialogs and navigation the
command triggers appear on the page rather than behind the palette.

#### Scenario: Run with Enter

- **WHEN** the user types `items` and presses `Enter`
- **THEN** the palette closes and the Items page is shown

#### Scenario: Move the highlight

- **WHEN** the first entry is highlighted and the user presses `Down` twice and then `Enter`
- **THEN** the third listed command runs

#### Scenario: Highlight wraps

- **WHEN** the first entry is highlighted and the user presses `Up`
- **THEN** the last listed command is highlighted

#### Scenario: Run by click

- **WHEN** the user clicks "Open settings"
- **THEN** the palette closes and the settings dialog opens

### Requirement: Only available commands are offered

The system SHALL list a command only when it can run in the current context: its required role,
if it declares one, is granted to the current session, and its availability condition on the
current page and application state holds. A deployment without an identity provider grants every
role, consistent with the rest of the interface. A command for the page the user is already on
SHALL NOT be listed.

#### Scenario: Role not granted

- **WHEN** a command requires a role the signed-in user does not have
- **THEN** that command is not listed and cannot be found by searching

#### Scenario: No identity provider configured

- **WHEN** the deployment has no identity provider and a command requires a role
- **THEN** that command is listed

#### Scenario: Context-dependent command on an unrelated page

- **WHEN** the user opens the palette on a page without a model list
- **THEN** "Reload current list" is not listed

#### Scenario: Current page is not offered

- **WHEN** the user opens the palette on the Fonts page
- **THEN** "Go to Fonts" is not listed, and "Go to Items" is

### Requirement: POC command set

The system SHALL offer the following commands, all without further input in the palette:

- Navigation: go to Attributes, Items, Notifications, Fonts, Sound, and go to the project list.
- Interface: toggle dark mode, toggle following the system theme, open settings, open the build
  dialog.
- Backend: reload the current model list (only on the Attributes, Items, Notifications, Fonts and
  Sound list pages, reloading that page's list from the backend), reload git branches, reload
  release information.

Every command SHALL have the same effect as the existing control it mirrors.

#### Scenario: Toggle dark mode

- **WHEN** the user runs "Toggle dark mode" while the light theme is shown
- **THEN** the app switches to the dark theme, exactly as the settings toggle would

#### Scenario: Open the build dialog

- **WHEN** the user runs "Open build dialog"
- **THEN** the same build dialog opens as from the app bar's build button

#### Scenario: Reload the current list

- **WHEN** the user runs "Reload current list" on the Sound page
- **THEN** the sound list is refetched from the backend and replaces the displayed list

#### Scenario: Go to the project list

- **WHEN** the user runs "Go to project list"
- **THEN** the project selection page is shown

### Requirement: Backend commands report their outcome

The system SHALL show a success message once a backend command's request completes and an error
message when it fails. A failed backend command SHALL leave the app usable and the previously shown
data in place. The palette SHALL NOT wait for the request before closing.

#### Scenario: Successful reload

- **WHEN** the user runs "Reload git branches" and the backend responds successfully
- **THEN** a success message is shown and the branch list is updated

#### Scenario: Backend unreachable

- **WHEN** the user runs "Reload current list" and the request fails
- **THEN** an error message is shown and the previously displayed list remains
