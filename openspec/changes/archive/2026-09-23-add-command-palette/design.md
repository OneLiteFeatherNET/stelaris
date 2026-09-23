# Design

## Context

See proposal.md for motivation and specs/command-palette/spec.md for the required behavior.

Relevant current state:

- Stelaris UI is a web-only Flutter app. Routing is `go_router`: `/sign-in` and `/projects` are
  top-level, and every model page (`NavigationEntry.*.route`) plus its `detail` child lives under
  one `ShellRoute` whose builder is `BasePage` (`lib/util/routes.dart`).
- State is `async_redux`. Everything the POC commands do already exists as an action or a dialog:
  `Refresh{Attribute,Item,Notification,Font,Sound}Action`, `BranchFetchAction`,
  `ReleaseFetchAction`, `ToggleDarkModeAction`, `ToggleSystemThemeAction(systemIsDark)`,
  `SettingsDialog`, `BuildDialog`.
- The app has no keyboard shortcuts at all today. Nothing uses `Shortcuts`, `Actions` or
  `CallbackShortcuts`.
- Roles are checked through `AuthState.hasRole`, which already returns `true` for every role when
  no identity provider is configured.
- Error behavior of the reused actions is not uniform. `Refresh*Action` lets the exception
  propagate, so `dispatchAndWait` reports it as failed. `BranchFetchAction` catches everything and
  sets `branches` to `null`. `ReleaseFetchAction` catches everything and returns `null`, which
  leaves the state unchanged.
- `lib/feature/model/command_bar.dart` already defines `CommandBar`, the search/filter bar on model
  pages.

## Goals / Non-Goals

**Goals:**

- One place to declare a command. Adding a command means adding one entry to the registry and
  nothing else.
- Commands reuse the existing actions and dialogs, so the palette and the buttons can't drift
  apart.
- The registry is plain Dart, with no widgets, so availability and search can be unit-tested
  without pumping a UI.

**Non-Goals:**

- Parameter prompts inside the palette, such as a multi-step "build for branch X". Commands that
  need input open the existing dialog.
- Commands defined by the backend, or a new backend endpoint.
- Destructive commands (delete) and "create model". The create dialogs are built inside each page
  with page-local callbacks, and lifting them out is beyond a POC.
- User-configurable key bindings, recently used ordering, or showing shortcuts next to commands.
- Opening the palette on `/sign-in` or `/projects`.

## Decisions

### Install the shortcut in `BasePage`, not in `MaterialApp.builder`

`BasePage` wraps its subtree in `Shortcuts` + `Actions` (`SingleActivator(KeyK, control: true)`
and `SingleActivator(KeyK, meta: true)` mapped to an `OpenCommandPaletteIntent`) plus a `Focus`
with `autofocus`, so the shortcut also works before anything on the page has been clicked.

- The scope in the spec (workspace only, inert while a dialog is open) comes for free. Dialogs are
  pushed onto the root navigator, outside `BasePage`'s subtree, so key events from inside a dialog
  never reach this `Shortcuts`.
- Key events bubble up the focus tree. A focused `SearchBar` or `TextField` inside the page doesn't
  handle `Ctrl+K` (on web, text-editing shortcuts are left to the browser), so the event reaches
  the ancestor `Shortcuts`.
- `BasePage`'s context sits below the router's `Navigator`, `ScaffoldMessenger` and
  `StoreProvider`. That is everything `showDialog`, `context.go`, snackbars and `dispatch` need.
  `MaterialApp.builder` sits above the Navigator, so it would need a global navigator key.
- *Alternative:* `HardwareKeyboard.instance.addHandler` as a truly global listener. Rejected: it
  bypasses the focus system, fires inside dialogs and text fields alike, and has to reimplement
  the scoping above by hand.

On web, a key event the framework reports as handled is `preventDefault`ed by the engine, so the
browser's own `Ctrl+K` doesn't fire (see Risks).

### The palette is a `showDialog`, not an `OverlayEntry`

`CommandPalette` is shown with `showDialog`: a top-aligned `Dialog` about 600 px wide, holding a
`TextField` and a `ListView`. `Esc`, the barrier click, focus trapping and focus restoration then
come from the framework. `Up` and `Down` are handled by a `Focus.onKeyEvent` on the text field, so
the field keeps focus while the highlight moves. The highlight is an index into the filtered list
and is kept visible with `Scrollable.ensureVisible`.

Pressing the shortcut while the palette is open closes it. This falls out of the `BasePage`
decision: the dialog is outside `BasePage`'s subtree, so the palette handles `Ctrl+K` / `Cmd+K`
itself by popping.

- *Alternative:* `SearchAnchor` / `SearchBar.view`. Rejected: it is built around "search
  suggestions", gives little control over keyboard highlight and grouping, and its full-screen view
  on narrow layouts is a different interaction.
- *Alternative:* a pub package (`command_palette`). Rejected for the POC: the widget is small,
  and the package would add a dependency with its own theming for little gain.

### A registry of plain command objects

```
StelarisCommand
  id            stable string, e.g. 'nav.items', 'backend.reload-branches'
  title         (AppLocalizations) -> String
  keywords      (AppLocalizations) -> List<String>   extra search terms
  group         CommandGroup { navigation, interface, backend }
  icon          IconData
  requiredRole  String?                              one of Roles.*
  isAvailable   (CommandContext) -> bool             default: always
  run           (BuildContext) -> Future<void>

CommandContext  { AppState state, String location }

CommandRegistry
  all                     List<StelarisCommand>      the POC set, built once
  available(ctx)          role + isAvailable filter
  search(query, ctx)      available, then fuzzy-filtered and ranked
```

`location` is `GoRouterState.of(context).matchedLocation`, read when the palette opens. Navigation
commands are generated from `NavigationEntry.values` and hide themselves when `location` starts
with their route. "Reload current list" maps the current `NavigationEntry` to its `Refresh*Action`
and is unavailable on `detail` routes and anywhere else without a list.

`title` and `keywords` take `AppLocalizations`, so matching runs against the strings the user can
see. The registry stays free of widgets: it takes the localizations as an argument instead of
reading them from a context.

### Search: a small subsequence scorer, no dependency

The query and the candidate are lowercased. A candidate matches when every query character appears
in order. The score rewards a match at the start of the title, a match at a word start, and
consecutive matches. Titles are scored above keywords. Ties keep registry order, which is the
group order. With an empty query the matcher is bypassed and the list is grouped under headings.
With a query, the list is flat and ranked, and each row shows a small group label. For about 15
commands, performance doesn't matter.

### Running a command: pop first, then run with the page's context

On `Enter` or a click, the palette pops itself and then calls `command.run(pageContext)`. It uses
`BasePage`'s context, which is still mounted, and not the dialog's context, which is being
disposed. This ordering is what the spec's "closes first" requires: a command that opens
`SettingsDialog` or `BuildDialog` would otherwise stack it under a closing palette.

### Backend commands own their feedback

A small helper, `runBackendCommand(context, action, {success, failure, neutral,
BackendOutcome Function(AppState before, AppState after)? outcome})`, captures
`ScaffoldMessenger.of(context)` and the store before the `await`, calls `dispatchAndWait`, and
then picks the success, neutral info or error bar. A command fails when `dispatchAndWait` throws
(the store has no error observer, so an action's exception reaches the caller), when
`ActionStatus.isCompletedFailed` is true, or when its `outcome` function says so after comparing
the state before and after. Without an `outcome`, a completed action is a success. The `outcome`
function covers the two actions that swallow their errors:

- `BranchFetchAction`: failed when `state.branches == null`.
- `ReleaseFetchAction`: this action gives no signal at all. The POC compares the release model
  before and after. If it is unchanged, the command reports "no new release information" as
  neutral info instead of a success. Changing `ReleaseFetchAction` to surface errors is left out on
  purpose, because the build dialog depends on its current behavior.

The palette doesn't wait for any of this, because it has already closed. The previous list stays on
screen after a failure because `Refresh*Action` doesn't touch the state when it throws.

### Theme commands

"Toggle dark mode" dispatches `ToggleDarkModeAction`. It also switches off "follow system theme",
exactly like the settings toggle, which is what the spec means by the same effect as the existing
control. "Toggle system theme" dispatches
`ToggleSystemThemeAction(MediaQuery.platformBrightnessOf(context) == Brightness.dark)`, as the
settings row does.

## Risks / Trade-offs

- [The browser takes `Ctrl+K` before Flutter can] → Chrome and Firefox deliver `Ctrl+K` to the
  page, and GitHub and Slack rely on this. Verify it by hand in Chrome and Firefox as an explicit
  task. If a browser refuses, the fallback is an extra `Ctrl+Shift+P` activator, not a redesign.
- [`Ctrl+K` inside a text field on macOS desktop means "delete to end of line"] → The app only
  ships for web, where text editing shortcuts belong to the browser. On macOS the palette uses
  `Cmd+K`, which doesn't collide.
- [The shortcut is dead until something inside `BasePage` has focus] → An `autofocus` `Focus` in
  `BasePage` covers the first load. After a dialog closes, focus returns into the page by default.
  Worth checking by hand after the settings and build dialogs.
- [A command's `isAvailable` goes stale while the palette is open] → Availability is evaluated
  once, when the palette opens. Nothing in the POC changes route or role while the modal palette is
  up, so this is acceptable.
- [`ReleaseFetchAction` can't report a failure] → The feedback is weaker for this one command, as
  explained above. It is recorded so a follow-up can decide to fix the action.
- [Registry and buttons drift apart] → Commands call the same actions and dialogs as the buttons,
  so there is no duplicated logic to drift.

## Migration Plan

The change is purely additive and client-side. It ships with the normal image release. To roll it
back, revert the change or remove the `Shortcuts` wrapper from `BasePage`. No state, storage or
configuration is involved.
