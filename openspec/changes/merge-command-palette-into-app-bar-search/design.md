# Design

## Context

- The palette is a `CommandPalette` dialog (`showCommandPalette`). It owns a `TextField`, its own
  `FocusNode` with `onKeyEvent`, and state for mode, kind, drill frame, results, row keys and
  highlight. It renders the search row, the notice, the list and the key hints.
- `AppBarSearch` (`lib/feature/base/search/app_bar_search.dart`):
  - It owns a `SearchBar` with its own controller and focus node, and writes the text to
    `modelSearch` after a 300 ms debounce.
  - On a detail page it leaves for the list on the first keystroke, through `confirmLeaveIfDirty`.
  - `Esc` clears the field. Below 600 px it collapses into an icon.
  - `BasePage` keys it by section, so a new section gets a fresh field.
- `CommandPaletteShortcuts` in `BasePage` handles `Ctrl+K`/`Cmd+K` and opens the dialog.

## Goals / Non-Goals

**Goals:**

- One field, one set of palette logic. The dialog widget's state machine moves, it is not copied.
- Existing search behavior stays: debounce, sort and filter menu, clear button, compact mode.

**Non-Goals:**

- Server-side search. The list filter stays client-side as before.
- Changing what the palette offers. Syntax, drill-down, create and delete are carried over as they
  are.

## Decisions

### Split the dialog into a controller and a panel

```
CommandPaletteController extends ChangeNotifier
  registry, commandContext (updated when the dropdown opens)
  mode, kind, drill, results, rows, rowIds, rowKeys, highlight (ValueNotifier)
  onTextChanged(text) -> ParsedQuery      moves a prefix into the chip, re-searches
  handleKey(event) -> KeyEventResult      arrows, Enter, Backspace, step in/out
  leaveMode(), run(command)
  topEntries: List<StelarisCommand> Function(ParsedQuery)?   injected by the host

CommandPanel(controller)                  notice + lazy list + key hints (from the dialog)
```

- `run` calls back into the host: `onRun(command)` closes the dropdown and then runs the command
  with the host's context. That context is the app bar, below the router, the store and the
  navigator.
- Entries with `switchTo` and inert entries stay inside the controller, as before.
- The rebuild guarantees of the dialog carry over unchanged: stable row keys, a highlight notifier
  with per-row listeners, a lazy list, and re-searching only on a locale change.

### `AppBarSearch` hosts it

- **Field:**
  - The `SearchBar`'s leading slot shows the chip while a mode, kind or drill frame is active, and
    the search icon otherwise.
  - The hint comes from the controller. The default hint names the section and mentions `?`.
  - `_focusNode.onKeyEvent` delegates to `controller.handleKey`. That handler first handles `Esc`
    while the dropdown is open.
- **Dropdown:** an `OverlayPortal`, placed with `CompositedTransformTarget`/`Follower` under the
  field and matching its width. It shows while `_open` is true. A `TapRegion` around the field and
  the dropdown closes it on an outside click.
- **Filtering:**
  - `onChanged` forwards to the controller.
  - Only when the parsed query is plain (no mode, no drill) and the page is a list does the
    debounced `UpdateSearchQueryAction` run, as before.
  - A prefix never reaches `modelSearch`.
- **Filter entry:** the host injects it as `topEntries` for plain, non-empty text.
  - On a list, it closes the dropdown and flushes the debounce, so the filter applies immediately.
  - On a detail page, it runs the existing `_leaveDetail`, which checks for unsaved changes, sets
    the query and goes to the list.
  - The old leave-on-keystroke is removed.

### The list filter's debounce is a Redux action

`DebouncedSearchQueryAction(query) with Debounce` (300 ms) replaces the field's `Timer`. It is
dispatched on every plain keystroke, and only the last one within the pause reaches the store.
`DebouncedSearchQueryAction.cancel()` shares the debounce lock and does nothing itself, so
dispatching it drops a pending query. That is needed when the query is applied at once (the filter
entry, leaving a detail page), when it is cleared, when a prefix is typed, and when the field goes
away because the section changed.

### `Ctrl+K` asks the field to open

`CommandPaletteShortcuts` provides a `CommandPaletteHost` (an `InheritedWidget` holding the registry
and a `ChangeNotifier` of open requests). The shortcut calls `host.toggle()`. `AppBarSearch` listens:

- If the dropdown is closed, it expands from compact mode, focuses the field, selects its text and
  opens the dropdown.
- If the dropdown is open, it closes it.

`CommandPaletteShortcuts` keeps its fixed maps from the rebuild work. The dialog, `showCommandPalette`
and `CommandPalette` are removed.

## Risks / Trade-offs

- [Every keystroke now also runs the palette search] → Registry search and entity ranking are
  cheap. The expensive part, the list, is lazy and keyed as before.
- [The dropdown covers the top of the list being filtered] → It closes on `Enter` for the filter
  entry and on `Esc`. The list stays filtered underneath.
- [Tests move from the dialog to the app bar] → Same scenarios, a different harness: a shell with
  `AppBarSearch` in an `AppBar`. Expectations change only where the filter entry comes first.
- [Compact mode] → `Ctrl+K` expands the field first, and the dropdown follows its width, which is
  narrower on small screens.

## Migration Plan

UI only. The dialog is gone in the same release that brings the dropdown. Rollback means reverting
the change.
