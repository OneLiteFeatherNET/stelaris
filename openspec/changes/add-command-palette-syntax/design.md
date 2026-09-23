# Design

## Context

See proposal.md for motivation and specs/command-palette-syntax/spec.md for the behavior.

The design starts from the palette built in `add-command-palette` (`lib/feature/command_palette/`):

- `StelarisCommand` holds plain data plus `run(BuildContext)`.
- `CommandRegistry.search(query, context, l10n)` filters by role and availability, then ranks
  with `scoreMatch`, the subsequence scorer.
- `CommandPalette` is a dialog holding a `TextField`, whose `FocusNode.onKeyEvent` handles
  Up/Down/Enter/Ctrl+K.
- `CommandPaletteShortcuts` in `BasePage` maps `Ctrl+K`/`Cmd+K` to `OpenCommandPaletteIntent`.

What the rest of the app offers:

- Every model has a `uiName`, and `Project` has `displayName`.
- Loaded entities are in `AppState` as paginated results: `items`, `fonts`, `soundEvents`,
  `notifications`, `attributes` (`PaginatedResult.items`). The known projects are in
  `state.projects`.
- Opening an entity already exists as a two-step flow in each page's `onModelTap`: dispatch
  `SelectedItemAction` / `SelectFontAction` / `SelectSoundAction` / `SelectedNotificationAction`,
  then `context.go('<route>/detail')`. Attributes have no detail route and open
  `AttributeEditDialog(model: …)` through `showDialog`.
- The settings row switches projects via `SwitchProjectDialog(currentProject, targetProject)`
  followed by `SelectProjectAction(p)` if confirmed.
- The backend has no search and no fetch-by-id (`BaseApi.getPage` only), so entity mode can only
  search what is loaded.

## Goals / Non-Goals

**Goals:**

- One parser that turns raw input into a mode, an optional kind and text. It is a pure function
  and unit-testable.
- Modes are data. The help list, the aliases, the chip labels and the parser all read from the same
  table, so the `?` help can't drift from what the parser accepts.
- Entity and project results are ordinary `StelarisCommand`s built on the fly, so highlight, Enter,
  click, "pop first, then run" and ranking all work unchanged.

**Non-Goals:**

- Detail-tab jumps, typed command arguments and a backend search (see proposal). The parser leaves
  room for a trailing ` > tab` and for arguments without implementing them.
- Scoping entity search to another project. Loaded entities always belong to the selected project,
  so a project scope would filter nothing.
- Persisted history, ranking by use, user-defined aliases.

## Decisions

### Modes as a table, parsed before the registry

```
PaletteMode { commands, navigation, entities, projects, settings, help }

ModeSpec
  mode       PaletteMode
  sigil      String            '>', ':', '#', '@', '/', '?'
  aliases    List<String>      'project', 'projects', ...
  label      (l10n) -> String  chip text, help title
  describe   (l10n) -> String  help line

EntityKind { item, font, sound, notification, attribute }
  aliases    'item', 'items', ...
  label      chip text for "#item": "Items"

ParsedQuery { PaletteMode? mode, EntityKind? kind, String text }

parseQuery(String raw) -> ParsedQuery
```

Parsing rules, applied in this order:

1. A leading sigil sets the mode.
2. Otherwise, a leading alias followed by a space sets the mode, and for entity aliases the kind
   as well.
3. In entity mode, a first word that is a kind alias followed by a space sets the kind (`#item
   sword`).
4. Whatever remains is `text`.

The palette does **not** reparse its whole input on every keystroke. Once a mode is recognized, it
is moved out of the text into state and shown as the chip, and later keystrokes only edit `text`.
This keeps `#item sword` stable while the user edits `sword`. It also makes Backspace on an empty
field the one way back out.

- *Alternative:* keep the prefix in the text and reparse on every keystroke (VS Code does this).
  Rejected: with a chip on screen the prefix would show twice, and editing near the start of the
  text could flip the mode unexpectedly.

### Providers per mode; `CommandRegistry` becomes the commands provider

```
abstract interface class PaletteProvider {
  List<StelarisCommand> resolve(ParsedQuery q, CommandContext c, AppLocalizations l10n);
}

commands  -> CommandRegistry (unchanged search)
settings  -> CommandRegistry filtered to commands whose modes contain settings
entities  -> EntityProvider   (reads state lists, builds one command per entity)
projects  -> ProjectProvider  (reads state.projects, builds one command per project)
navigation-> CommandRegistry filtered to commands whose modes contain navigation
help      -> HelpProvider     (sections: syntax, navigation, keyboard; see below)
default   -> commands; if empty and text non-empty -> two FallbackCommands
```

`StelarisCommand` gains `Set<PaletteMode> modes`, defaulting to `{commands}`. The theme toggles and
"Open settings" get `{commands, settings}`, and the "Go to" commands `{commands, navigation}`,
which is all the settings and navigation modes need. No second list has to be maintained.

The navigation alias `go` is the first word of every "Go to" title. That is safe, because
navigation mode lists exactly those commands: typing "go to fonts" lands in navigation mode with
the text "to fonts", which still ranks "Go to Fonts" first. The alias collision test encodes the
rule: an alias may only prefix titles of commands that its own mode lists.

`CommandContext` already carries `AppState`, so the providers need nothing new to read the loaded
lists.

### Entity commands mirror `onModelTap`

`EntityProvider` builds, for each loaded model of the selected kinds, a `StelarisCommand` with:

- `id: 'entity.<kind>.<model.id>'`
- `title: model.uiName`
- `group: CommandGroup.entity` (a new group) and a trailing kind label
- `run`:
  - Item, font, sound or notification: dispatch the matching select action, then
    `context.go('<route>/detail')`, the same two calls as the page's `onModelTap`.
  - Attribute: `showDialog(AttributeEditDialog(model: model))`.

The commands are ranked with `scoreMatch` on `uiName`. With an empty text they are listed in
kind order and then in list order. Kinds with nothing loaded contribute the "Go to <kind>" command
from the registry instead, and entity mode always shows a one-line notice that only loaded
entries are searched.

The `onModelTap` logic is duplicated here on purpose rather than extracted from the pages. It is two
lines per kind, and extracting it would touch five pages for no behavioral gain. A test pins the
palette's behavior to the same actions.

### Project commands reuse the confirmation dialog

`ProjectProvider` lists `state.projects` minus `selectedProject`, matched by `displayName`. `run`
shows `SwitchProjectDialog` and dispatches `SelectProjectAction(p)` only on `true`. That is the same
sequence as `ProjectSettingsRow`. `SelectProjectAction` already resets every list and selection,
and `BasePage` rekeys its child on the project id, so the current page reloads for the new project
with no extra work.

### Help and fallback entries switch mode instead of running something

Help entries and default-mode fallbacks have to change the palette's own state, not the app's.
They are `StelarisCommand`s whose `run` is never reached. Instead they carry a `PaletteMode`
target (and for fallbacks the text to carry over), and the palette checks for it before popping:
if a command has a target, the palette switches mode in place and stays open. This is one
additional nullable field (`switchTo`) and one branch in `_run`.

### Help as registered sections

```
HelpSection
  id        String
  title     (l10n) -> String                                  the heading
  entries   (CommandContext, CommandRegistry) -> List<StelarisCommand>

defaultHelpSections = [syntax, navigation, keyboard]
PaletteSearch(registry, {List<HelpSection> help = defaultHelpSections})
```

`HelpProvider` knows no content of its own any more. It asks each section for its entries, filters
all of them by the typed text, and sets `section` on each entry to the section's title so the list
groups under that heading. A later feature adds help by adding a `HelpSection` to the list; it
touches neither `HelpProvider` nor the other sections.

- **syntax**: one entry per `ModeSpec` except help, with `switchTo` its mode (as before).
- **navigation**: the registry's available navigation commands, unchanged. Choosing one runs it,
  so the palette closes and navigates exactly as the "Go to" command does.
- **keyboard**: one entry per key with the key as title and what it does as subtitle, marked
  `inert`. The palette ignores `Enter` or a click on an inert entry, so reading help never runs or
  closes anything.

`StelarisCommand` gains `bool inert = false`. `_run` checks it first.

### A placeholder per mode

The field's `hintText` comes from the active mode and kind. The default mode's hint mentions `?`,
because a syntax nobody knows about is not discoverable from an empty field otherwise.

### The current page is marked, not hidden

`StelarisCommand` gains `bool Function(CommandContext)? isCurrent` and `IconData? currentIcon`. The
"Go to" commands drop their "not on this page" availability check and set `isCurrent` instead,
using the same prefix rule, with `currentIcon` being the entry's filled `NavigationEntry.selected`.
The palette evaluates `isCurrent` against the `CommandContext` it opened with and then shows the
filled icon in the primary color and a "Current page" label. That marker is separate from the
keyboard highlight, which still starts on the first entry. `EntityProvider` skips the "Go to"
fallback for a kind whose list the user is already on.

### One highlight, and a footer

The mouse and the keyboard share a single highlight: entering a row with the mouse moves the
highlight there, and the rows paint no hover color of their own. Two highlighted rows, one from
each input, left it unclear what `Enter` would run.

A footer under the list shows the keys (`↑↓` navigate, `Enter` run, `Esc` close, `?` help). The
list then ends on a straight edge above it instead of being cut by the dialog's rounded corner,
and the most important help is visible without opening `?`.

### Rebuild only what changed

- Rows are keyed by entry id, and the keys survive searches, so a row that still matches after a
  keystroke keeps its element.
- The highlight is a `ValueNotifier`. Each row listens through a small widget that rebuilds only
  when that row gains or loses the highlight. Arrow keys and hovering rebuild two rows, not the
  palette.
- The list is a `ListView.builder` over headings and entries laid out once per search, so only
  visible rows are built however many entities are loaded.
- `didChangeDependencies` searches again only when the locale changes. Theme or media changes don't
  reset the results or the highlight.
- `CommandPaletteShortcuts` holds its shortcut and action maps in state and sits outside
  `BasePage`'s `StoreConnector`, so a project switch doesn't hand `Actions` a new map.

### Chip in the field, Backspace to leave

The `TextField`'s `prefixIcon` becomes an `InputChip` with the mode or kind label and a delete
action when a mode is active. `_onKey` gains one case: Backspace on a `KeyDownEvent` with empty
text and an active mode clears the mode (and first the kind, if both are set). Because the field
keeps focus, the rest of the keyboard handling is untouched.

## Risks / Trade-offs

- [An alias collides with a title word, e.g. "Items"] → Aliases only apply with a trailing space,
  and a command title never starts with an alias followed by a space ("Go to Items" starts with
  "Go"). A test covers every alias against every command title.
- [People expect `#sword` to find entries that aren't loaded yet] → A notice is always shown, and
  kinds with nothing loaded offer their "Go to" command. A backend search is the real fix, listed as
  a follow-up.
- [Large loaded lists make typing slow] → Lists hold what the user paged through, typically a few
  hundred at most. `scoreMatch` is quadratic only in title length. If it ever matters, results are
  capped at 50 before rendering.
- [Selecting the same entity type from another detail page] → `go('<route>/detail')` while already
  on that route replaces the selection in place. This is the same as clicking another card after
  going back, and the detail pages already rebuild from the selected model.
- [`?` and `/` clash with names starting with those characters] → Entity and project names are
  only searched inside `#` and `@`. A name starting with `/` would need `#/…`, which is acceptable.

## Migration Plan

Additive and client-side, on top of `add-command-palette`, which has to land first. Rollback means
reverting the change. The palette then behaves as the POC does.

## Open Questions

- Which aliases to add beyond the English ones is left open. The l10n files can gain translated
  aliases later without changing the parser, because aliases come from the mode table.
