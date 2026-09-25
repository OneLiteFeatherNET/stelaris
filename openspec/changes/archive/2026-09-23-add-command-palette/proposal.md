# Proposal

## Why

Every action in Stelaris UI is reachable only by mouse: switching pages goes through the side bar,
the theme lives three clicks deep in the settings dialog, and reloading data or opening the build
dialog means finding the right button on the right page. A keyboard-driven command palette -
`Ctrl+K` / `Cmd+K`, type, `Enter` - is the established answer to that, and this change builds it as
a proof of concept to find out whether it fits the app before investing in a full command set.

The POC deliberately stays inside this repository: every command it offers either acts on the UI
or calls a backend endpoint the app already uses. No backend change is required.

## What Changes

- **A global command palette** opened with `Ctrl+K` (`Cmd+K` on macOS) from anywhere inside the
  signed-in, project-scoped part of the app - including while a text field has focus. It shows a
  search field and a filtered, grouped list of commands, operated entirely by keyboard
  (`Up`/`Down`, `Enter`, `Esc`) or mouse.
- **A command registry** that defines each command once: title, group, icon, optional required
  role, an availability check against the current app state and route, and what it does. The
  palette only ever shows commands that are available right now.
- **An initial POC command set**, all parameterless:
  - *Navigation*: go to Attributes, Items, Notifications, Fonts, Sound, and the project list.
  - *Interface*: toggle dark mode, toggle system theme, open settings, open the build dialog.
  - *Backend*: reload the current model list, reload git branches, reload release information.
- **Feedback for backend commands**: a success or failure snackbar once the request completes.
- Commands that need input (e.g. triggering a build for a branch) open the existing dialog instead
  of asking for parameters inside the palette. In-palette parameter prompts are out of scope for
  the POC.
- No **BREAKING** changes. Nothing existing is removed or rebound.

## Capabilities

### New Capabilities

- `command-palette`: the keyboard shortcut, the palette's search/selection/execution behavior,
  command availability (state, route and role), and feedback for commands that call the backend.

### Modified Capabilities

<!-- None: no existing spec covers navigation, theming or build triggering. -->

## Impact

- **Code**: new feature module for the palette and its command registry; the shell page
  (`BasePage` in `lib/feature/base/base_page.dart`) gains the shortcut. Existing Redux actions
  (`Refresh*Action`, `BranchFetchAction`, `ReleaseFetchAction`, `ToggleDarkModeAction`,
  `ToggleSystemThemeAction`) and dialogs (`SettingsDialog`, `BuildDialog`) are reused, not changed.
- **Localization**: new strings in `lib/l10n/stelaris_en.arb` for command titles, groups, the
  search hint and feedback messages.
- **Naming**: `CommandBar` (`lib/feature/model/command_bar.dart`) already names the search/filter
  bar on model pages; the new widget uses distinct names (`CommandPalette`, `StelarisCommand`) to
  avoid confusion.
- **Dependencies**: none added.
- **Backend / APIs**: none changed; only existing endpoints are called.
