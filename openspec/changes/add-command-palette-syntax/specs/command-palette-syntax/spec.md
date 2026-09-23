# Spec Delta

## Purpose

Gives the command palette a small query syntax, so people can say what kind of thing they are
looking for (commands, entities, projects or settings) and jump straight to it, and can discover
that syntax from inside the palette.

## ADDED Requirements

### Requirement: Query modes are chosen by a leading prefix

The system SHALL read a leading `>`, `:`, `#`, `@`, `/` or `?` in the palette's query as a mode:

- `>` means commands
- `:` means navigation
- `#` means entities
- `@` means projects
- `/` means settings
- `?` means help

The rest of the query SHALL be searched within that mode only. A query without such a prefix SHALL
behave as the palette did before this change: it searches commands.

#### Scenario: Command mode

- **WHEN** the user types `>dark`
- **THEN** only commands are listed, and "Toggle dark mode" is among them

#### Scenario: No prefix keeps today's behavior

- **WHEN** the user types `dark`
- **THEN** the same commands are listed as before this change

#### Scenario: Prefix alone

- **WHEN** the user types `#` and nothing else
- **THEN** every loaded entity is listed, grouped by kind

### Requirement: Word aliases select the same modes

The system SHALL treat a leading alias word followed by a space as the corresponding mode,
case-insensitively. At least these aliases SHALL exist:

- `item`, `items`, `font`, `fonts`, `sound`, `sounds`, `notification`, `notifications`,
  `attribute` and `attributes`: entities of that kind
- `project` and `projects`: projects
- `setting` and `settings`: settings
- `go`: navigation

An alias word without a following space SHALL NOT change the mode. An alias followed by a space
SHALL only ever select a mode that lists every command whose title starts with that alias and a
space, so an alias never hides a command.

#### Scenario: Alias with a space

- **WHEN** the user types `item sword`
- **THEN** the palette lists the same results as for `#item sword`

#### Scenario: Alias without a space

- **WHEN** the user types `items`
- **THEN** the palette is still in the default mode and lists "Go to Items"

#### Scenario: A title starting with an alias stays reachable

- **WHEN** the user types `go to fonts`
- **THEN** the palette is in navigation mode and lists "Go to Fonts"

### Requirement: The active mode is shown as a chip

The system SHALL replace a recognized prefix or alias with a chip at the start of the search field
naming the mode, including the entity kind if one was given (for example "Items" or "Projects").
The chip SHALL remain while the user types the rest of the query. Pressing Backspace in an empty
field SHALL remove the chip and return to the default mode. Clicking the chip's remove control
SHALL do the same.

#### Scenario: Chip appears

- **WHEN** the user types `#item ` (with the trailing space)
- **THEN** the field shows an "Items" chip and an empty text input

#### Scenario: Backspace removes the chip

- **WHEN** an "Items" chip is shown with no text after it and the user presses Backspace
- **THEN** the chip disappears and the palette lists commands again

### Requirement: Help mode explains the palette in sections

The system SHALL show, for `?`, the help in sections, each under its own heading, at least:

- **Syntax**: every mode with its prefix, its alias words and a one-line description. Choosing a
  mode SHALL switch the palette into it with an empty query.
- **Navigation**: every page the user can go to, with the current one marked. Choosing one SHALL
  navigate there, exactly as the matching "Go to" command does.
- **Keyboard**: how to operate the palette, at least `Up`/`Down`, `Enter`, `Esc`, `Backspace` on an
  empty field, and `Ctrl+K`/`Cmd+K`. Choosing one of these entries SHALL do nothing and leave the
  palette open.

Text typed in help mode SHALL filter the entries of all sections.

#### Scenario: Discover the modes

- **WHEN** the user types `?`
- **THEN** the Syntax section lists commands (`>`), navigation (`:`), entities (`#`), projects (`@`)
  and settings (`/`) with their aliases

#### Scenario: Choose a mode from help

- **WHEN** the user picks the entities entry in help mode
- **THEN** the field shows the entities chip and an empty query

#### Scenario: Navigate from help

- **WHEN** the user is on the Fonts page, types `?` and picks "Go to Items" from the Navigation
  section
- **THEN** the palette closes and the Items page is shown

#### Scenario: Keyboard entries are for reading

- **WHEN** the user picks the `Esc` entry of the Keyboard section
- **THEN** nothing runs and the palette stays open in help mode

### Requirement: Entities can be found and opened from the palette

In entity mode, the system SHALL search the items, fonts, sounds, notifications and attributes
already loaded in the current project by their display name, using the same matching and ranking
as for commands. An optional first word naming a kind SHALL restrict the search to that kind. Each
result SHALL show its kind. Choosing a result SHALL have the same effect as clicking that entity in
its list: items, fonts, sounds and notifications open their detail page, and attributes open their
edit dialog.

#### Scenario: Jump to an item

- **WHEN** the item "Diamond Sword" is loaded and the user types `#sword` and presses `Enter`
- **THEN** the Items detail page opens showing "Diamond Sword"

#### Scenario: Restrict to one kind

- **WHEN** an item and a sound both contain "stone" and the user types `#sound stone`
- **THEN** only the sound is listed

#### Scenario: Open an attribute

- **WHEN** the user chooses an attribute from the entity results
- **THEN** that attribute's edit dialog opens

### Requirement: Entity search is honest about what is loaded

The system SHALL tell the user in entity mode that only loaded entries are searched, as long as no
entity search source is configured. When a kind
has nothing loaded, the palette SHALL offer that kind's "Go to" command instead of an empty result,
so opening the list loads it, unless the user is already on that list.

#### Scenario: Kind not loaded yet

- **WHEN** no fonts are loaded and the user types `#font ` (with the trailing space)
- **THEN** the palette shows a notice that only loaded entries are searched, and offers "Go to Fonts"

### Requirement: Projects can be switched from the palette

In project mode, the system SHALL list the known projects other than the current one, matched by
their display name. Choosing one SHALL ask for confirmation with the same dialog as the settings
project switcher, and switch only if the user confirms. When no other project is known, the palette
SHALL offer "Go to project list".

#### Scenario: Switch project

- **WHEN** the user types `@demo`, chooses "Demo" and confirms the dialog
- **THEN** "Demo" becomes the selected project

#### Scenario: Switch cancelled

- **WHEN** the user chooses a project and cancels the confirmation dialog
- **THEN** the selected project is unchanged

#### Scenario: Current project not offered

- **WHEN** the user types `@`
- **THEN** the currently selected project is not listed

### Requirement: Navigation mode lists the pages to go to

In navigation mode, the system SHALL list only the navigation commands: every list page, with
the current one marked, and the project list.

#### Scenario: Navigation only

- **WHEN** the user is on the Fonts page and types `:`
- **THEN** "Go to Attributes", "Go to Items", "Go to Notifications", "Go to Fonts" (marked as the
  current page), "Go to Sound" and "Go to project list" are listed, and no interface or backend
  command is

### Requirement: The search field says what it searches

The system SHALL show a placeholder in the empty search field that names what the current mode
searches. In the default mode it SHALL also point to `?`.

#### Scenario: Default placeholder

- **WHEN** the palette opens
- **THEN** the empty field's placeholder mentions `?`

#### Scenario: Kind placeholder

- **WHEN** the user types `#item `
- **THEN** the empty field's placeholder says that loaded items are searched

### Requirement: One highlight and visible keys

The system SHALL keep exactly one highlighted entry whether the user moves with the keyboard or the
mouse: pointing at an entry SHALL highlight it. The palette SHALL show the keys that operate it
below the list in every mode.

#### Scenario: Mouse moves the highlight

- **WHEN** the first entry is highlighted and the user points at the third
- **THEN** the third entry is highlighted and the first is not

#### Scenario: Keys are shown

- **WHEN** the palette is open in any mode
- **THEN** the hints for moving, running, closing and help are shown below the list

### Requirement: Settings mode lists settings commands

In settings mode, the system SHALL list only commands that change or open settings: toggle dark
mode, toggle system theme, and open settings.

#### Scenario: Settings only

- **WHEN** the user types `/`
- **THEN** exactly the settings commands are listed and no navigation or backend command is

### Requirement: The default mode falls back to other modes

In the default mode, when the query is not empty and no command matches, the system SHALL show the
no-match message and offer entries that repeat the same text in entity mode and in project mode.

#### Scenario: Fallback to entities

- **WHEN** the user types `sword`, no command matches, and the user picks the entity fallback entry
- **THEN** the palette switches to entity mode with the query `sword`
