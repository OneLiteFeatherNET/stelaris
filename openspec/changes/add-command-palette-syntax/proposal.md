# Proposal

## Why

The command palette (change `add-command-palette`) runs a fixed set of commands, but people also
want to jump straight to a specific item, font or sound, switch project, or reach a setting without
scrolling through every command. Every established palette solves this with a small query syntax:
a leading character picks what kind of thing is searched (VS Code, GitHub, JetBrains), and a `?`
help mode lists the available modes so the syntax stays discoverable. This change adds the first
two stages of that syntax, the parts that need no backend change and no rework of existing pages.

It builds on the `command-palette` capability (archived change `add-command-palette`).

## What Changes

- **Mode prefixes** at the start of the query:
  - `>` searches commands only
  - `:` searches the pages to go to
  - `#` searches entities (items, fonts, sounds, notifications, attributes)
  - `@` searches projects to switch to
  - `/` searches settings
  - `?` lists the modes
  - Without a prefix, the palette behaves as it does today.
- **Word aliases** for the same modes, recognized when followed by a space: `item sword` is
  equivalent to `#item sword`, `project demo` to `@demo`, and `go items` to `:items`.
- **Entity kinds inside `#`**: `#item sword` narrows to items, and `#sword` searches every kind.
- **A mode chip**: once a prefix or alias is recognized, it turns into a chip in the search field
  (for example `[Items]`). Backspace on an empty field removes it, as GitHub does with its scope.
- **Entity jump**: choosing an entity opens it exactly as clicking its card does. Only entities
  already loaded in the app are searched, and the palette says so.
- **Project switch** through `@`, with the existing confirmation dialog.
- **A help mode in sections** (`?`): the syntax, the pages to go to, and the keys that operate the
  palette. Sections are registered, so later features add their own help without touching the
  existing ones.
- **The current page is marked** instead of hidden: its "Go to" entry shows the filled icon and a
  "Current page" label, in every mode that lists it.
- **A placeholder per mode** that says what the field searches, and in the default mode points
  to `?`.
- **A fallback in the default mode**: when no command matches, entries offer to search entities or
  projects for the same text instead.
- Not in this change: a second shortcut (`Ctrl+Shift+P` opens a private window in Firefox and cannot
  be taken over by a page, and `Ctrl+K` works in every browser tested), jumping into detail tabs (`#item sword > lore`), commands with typed
  arguments (`>build release minor`), and a backend search covering entities that are not loaded
  yet. Each of these needs changes outside the palette and follows as its own change.

## Capabilities

### New Capabilities

- `command-palette-syntax`: query modes and their prefixes and aliases, the mode chip, the
  sectioned help mode, the navigation mode, the placeholder per mode, entity jump, project switch
  and the default-mode fallback.

### Modified Capabilities

- `command-palette`: the "Go to" command for the current page is no longer hidden. It is listed and
  marked as the current page, as the side navigation does, and from a detail page it leads back
  to the list.

## Impact

- **Code**:
  - `lib/feature/command_palette/`: a query parser, per-mode providers, and the palette's search
    field, which gains the chip and the Backspace handling.
  - Commands gain a way to belong to the settings mode.
- **Reused as they are**:
  - Selection actions and routes: `SelectedItemAction`, `SelectFontAction`, `SelectSoundAction`,
    `SelectedNotificationAction`, and `/x/detail`.
  - `AttributeEditDialog`, `SwitchProjectDialog`, `SelectProjectAction`.
- **Localization**: mode names, help texts, alias words, and empty and fallback texts.
- **Dependencies**: none.
- **Backend / APIs**: none.
