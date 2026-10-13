# Design

## Context

See proposal.md and specs/settings/spec.md.

- `SettingsDialog` is an `AnimatedDialog` with `SettingsHeaderTile`, then `ProjectSettingsRow`,
  `ThemeSettingsRow`, `AccessibilitySettingsRow`, `MiscSettingsRow` and `SettingsEndTile` in a
  scrolling column. Each row is a `SettingsBaseRow` of `SettingsItem`s (title, subtitle, trailing
  control).
- `ThemeSettingsRow` has a switch for `useSystemTheme`, a switch for `isDarkMode` (disabled while
  the first is on) and a slider from 0.8 to 1.4 that dispatches `UpdateFontScaleAction` on every
  `onChanged`.
- `ProjectSettingsRow` returns nothing for an empty project list. Otherwise a `DropdownButton`
  whose change opens `SwitchProjectDialog`, then `confirmLeaveIfDirty`, then dispatches
  `SelectProjectAction`.
- `ThemeSettings` has `isDarkMode`, `primaryColor`, `accentColor`, `fontScale` and
  `useSystemTheme`, with `defaultSettings()`. `lib/app.dart` turns `useSystemTheme` and `isDarkMode`
  into a `ThemeMode`. `AppTheme` builds `ColorScheme.fromSeed(seedColor: primaryColor, secondary:
  accentColor)`.
- `UpdatePrimaryColorAction` and `UpdateAccentColorAction` are only used by tests.
  `ToggleDarkModeAction` and `ToggleSystemThemeAction` are also used by the command palette
  (`commands.dart`).
- `FormDialog` has `showActions`, `maxWidth` and a close icon. `showChoiceEditDialog` already uses
  `showActions: false`. `EditCardGrid` draws section headings as `titleSmall` in `onSurfaceVariant`,
  24 above a section and 8 below the heading.
- Who is signed in is `AuthState` in `AppState.auth` (`status`, `displayName`, `roles`,
  `isEnabled`, `isSignedIn`), shown by `SessionIndicator` with `AuthSessions.current?.signOut()`.

## Goals / Non-Goals

**Goals**

- Look and behave like the other dialogs and edit cards.
- One way to choose the theme mode, a color, and a preview for the font size.
- Every setting can go back to its default.
- Show the account where users look for it, without a second sign-out path.

**Non-Goals**

- A settings route, a language switch, a settings search (see the proposal).
- Changing what is persisted.

## Decisions

### The dialog

`SettingsDialog` returns a `FormDialog` with the title "Settings", `showActions: false` and
`maxWidth: 560`. `onSubmit` is `null` and `actionLabel` is unused, as in `showChoiceEditDialog`.
The content is one column. A section is a heading, the same widget as in `EditCardGrid` (it is
extracted to a small public `EditSectionHeading` in `edit_card/`, with room for a trailing reset
button), 8 below it the cards, and 24 between sections. The footer sits under the last section.
`AnimatedDialog` is no longer used here.

### Settings cards

A `SettingsCard` is an outlined card in the shape and padding of `EditCard`, with a leading icon, a
title, an optional subtitle and a body or trailing widget for the control. It is not an `EditCard`,
because `EditCard` opens a dialog on a click and a segmented button or a slider must be operated in
place. The project choice does open a dialog and so uses an `EditCard`.

| Section | Card | Icon |
|---|---|---|
| Account | Name and roles, sign-out button | `account_circle_outlined` |
| Project | Active project | `folder_outlined` |
| Appearance | Theme mode | `brightness_6_outlined` |
| Appearance | Color | `palette_outlined` |
| Accessibility | Font size | `text_fields` |
| About | Version | `info_outline` |
| About | Licences | `description_outlined` |
| About | Issues | `bug_report_outlined` |
| About | Help (wiki) | `help_outline` |

### Theme mode

One `SegmentedButton<ThemeMode>` with System, Light and Dark, in a `SettingsCard`. A segmented
button shows all three options at once, which a choice dialog would hide behind a click.

It maps onto the stored fields, so nothing persisted changes.

| Choice | `useSystemTheme` | `isDarkMode` |
|---|---|---|
| System | `true` | unchanged |
| Light | `false` | `false` |
| Dark | `false` | `true` |

`ThemeSettings` gets `ThemeMode get themeMode` (system if `useSystemTheme`, else dark or light from
`isDarkMode`), and `lib/app.dart` reads it instead of its own ternary. A new
`SetThemeModeAction(ThemeMode)` writes the fields as the table says. Keeping `isDarkMode` for System
means the manual choice survives a round trip. `ToggleDarkModeAction` and `ToggleSystemThemeAction`
stay, the command palette uses them.

### Color

Only the seed color is exposed, as a row of about eight swatches (the Material primaries: blue,
indigo, teal, green, amber, orange, red, pink) built from a const list, each a round button with a
tooltip and a check on the selected one. A tap dispatches `UpdatePrimaryColorAction`. The default
(`Colors.blue`) is the first swatch. Reset returns to it. No free color picker and no hex entry:
a curated list cannot produce an unreadable scheme, and `fromSeed` keeps the contrast.

`accentColor` is not exposed. Today `AppTheme` passes it as `secondary`, so a new seed would leave
a blue-accent secondary beside a red seed. `AppTheme` stops passing `secondary` and lets
`fromSeed` derive the whole scheme. The `accentColor` field stays in `ThemeSettings`, so stored
settings still load, and is reset with the others. `UpdateAccentColorAction` has no caller and is
removed. This changes the secondary color of the default theme slightly, see Risks.

A stored color that is not in the list (older settings) shows no swatch as selected.

### Font size

A `Slider` from 0.8 to 1.4 with the divisions it has today, above a sample line of text. While
dragging, a local value drives the slider and the sample, which is scaled by the local value only
(`MediaQuery.withClampedTextScaling` or a `TextScaler.linear` on the sample). `onChangeEnd`
dispatches `UpdateFontScaleAction` once. The app text changes when the drag ends, not during. This
avoids a re-layout of the whole app, dialog included, on every tick, which also moves the slider
under the pointer. The local value follows the store when the store changes, so a reset moves the
slider.

### Reset

Two actions, both based on `ThemeSettings.defaultSettings()`.

- `ResetAppearanceSettingsAction` copies `useSystemTheme`, `isDarkMode`, `primaryColor` and
  `accentColor` from the defaults and keeps `fontScale`.
- `ResetFontScaleAction` copies `fontScale` from the defaults and keeps the rest.

Each of the two section headings has a "Reset" text button on its right, disabled when the section
already has its defaults. No confirmation, the change is visible at once and cheap to redo.

### Accessibility and About

Accessibility holds the font size, because that is what it is about. The theme items go to
"Appearance". The wiki link has nothing to do with accessibility and moves to About as a "Help"
card. "Report" and "Suggest" both opened `gitUrl`, the issue tracker, so they become one "Issues"
card ("Report a bug or suggest a feature"). The licences card keeps `showLicensePage`.

The footer reads "© {year} Onelitefeather • Made with ♥ by the team". The year is
`clock.now().year`, with `clock` a `Clock` from `package:clock` passed to `SettingsEndTile` (default
`const Clock()`) and from `SettingsDialog`. A test passes `Clock.fixed(...)`. `clock` is added to
`pubspec.yaml` as a direct dependency, it is already resolved in `pubspec.lock`.

### Account

The account section reads `AppState.auth` and builds on the status.

| `AuthState` | Shows |
|---|---|
| not `isEnabled` | nothing, not even the heading |
| `isSignedIn` | name (or "Signed in" without one), the roles line and a "Sign out" button |
| enabled, otherwise | one card saying that no one is signed in |

Sign-out calls `AuthSessions.current?.signOut()`, the same call as `SessionIndicator`. The roles
line (three names, then "+N more", "No roles" when empty) moves out of `SessionIndicator` into a
shared function that both use, so the two cannot drift apart. Nothing about tokens or sessions is
duplicated. `signOut` is task 2.7 of `add-oidc-authentication` and not done yet. Until it is, this
button does what the menu entry does. The section needs no change when it lands.

### Project

The Project section is an `EditCard` with the active project as its value, and the existing choice
dialog (`showChoiceEditDialog`) listing the projects with the current one marked and the labor badge
next to its name. Choosing another project keeps the flow of today: `SwitchProjectDialog`, then
`confirmLeaveIfDirty`, then `SelectProjectAction`. Picking the current project does nothing. With no
projects the section shows a card with an empty-state text ("No projects yet") instead of nothing.
With a `selectedProject` that is not in the list, the first project is shown, as today.

## Risks / Trade-offs

- **The app text changes on release, not during the drag.** Only the sample text previews live.
  That is the point, but a user may expect the whole app to follow.
- **The default theme's secondary color changes.** Dropping the `secondary` override gives a derived
  secondary instead of `blueAccent`. Buttons and chips that use it shift a little, and
  `app_theme_test` has to follow.
- **`accentColor` is left without a use.** The field is kept so stored settings load and a later
  change can use it, but nothing sets it.
- **Reset has no undo.** It touches a few values and is visible at once.
- **Account depends on an unfinished change.** Sign-out is only as good as task 2.7 of
  `add-oidc-authentication` makes it.
- **The segmented button is wide.** At 560 px it fits three short labels. Labels must stay short.

## Open Questions

- Should signing out also close the dialog? The sign-in page replaces the app when the session
  ends, so it probably does not matter.
- Is a curated list of eight colors enough, or do users expect a free picker? A picker can be added
  later on the same action.
- Is dropping the `secondary` override acceptable, or should `accentColor` stay as the secondary
  until a user changes the seed?
