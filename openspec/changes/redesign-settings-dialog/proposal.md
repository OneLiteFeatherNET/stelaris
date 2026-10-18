# Proposal

## Why

The settings dialog still has the look of before the app moved to FormDialog and edit cards.

- It is its own shape. `SettingsDialog` wraps an `AnimatedDialog` around a custom
  `SettingsHeaderTile`, while every other dialog uses `FormDialog` with a title row and a close icon.
- Rows are a title and a subtitle with a control on the right (`SettingsBaseRow`, `SettingsItem`).
  There are no icons, and the section headings do not match the muted headings of `EditCardGrid`.
- Some of it is confusing. The dark-mode switch is disabled while "Use System Theme" is on, without
  saying why. The two switches are really one choice (system, light or dark).
- The font-size slider dispatches on every drag tick, so the whole app re-lays out while the thumb
  moves, and there is no way to see what a size looks like before it applies.
- The project row disappears when there are no projects, and it is a hand-styled `DropdownButton`.
- There is no way back to the defaults, and no way to pick a color, although the theme already
  keeps one (`ThemeSettings.primaryColor` and `UpdatePrimaryColorAction` have no caller in the UI).
- "Accessibility" holds only a wiki link, the font size sits under "Display", "Report" and
  "Suggest" open the same URL, and the footer hard-codes `@2025`.
- Who is signed in is only visible in the app-bar menu (`SessionIndicator`), not where users look
  for account matters.

## What Changes

- **Same chrome as the other dialogs.** The settings dialog is a `FormDialog` (title row, close
  icon, no action row because settings apply at once), at most about 560 px wide, a single column.
  Sections use the muted heading of `EditCardGrid`, the rows are outlined cards with a leading
  icon, spacing comes from the shared scale. It stays a dialog.
- **Sections** in this order: Account, Project, Appearance, Accessibility, About.
- **Theme mode is one choice**, System, Light or Dark, replacing the two dependent switches. It is
  stored in the existing `useSystemTheme` and `isDarkMode` fields.
- **A color choice.** A curated list of swatches sets the seed color (`primaryColor`), with the
  selected one marked.
- **Font size previews while dragging.** A sample text follows the slider during the drag and the
  setting is stored when the drag ends.
- **Reset to default** per section (Appearance, Accessibility), from `ThemeSettings.defaultSettings()`.
- **Account** shows the name, the roles and a sign-out button, from the existing session state.
  With no session it explains instead of vanishing, and without an identity provider it is not shown.
- **Project** is a choice card instead of a dropdown, still asking before it switches and before
  it drops unsaved edits. With no project it shows an empty state.
- **About** holds the version, the licences, one link to the issue tracker, the wiki link moved
  from "Accessibility", and a footer whose year comes from an injectable clock.

This ships as one Conventional Commit type, `feat`, with the pull request title
`feat(settings): redesign the settings dialog`.

## Capabilities

### New Capabilities

- `settings`: the structure and behaviour of the settings dialog, which sections it has, how each
  setting is changed and reset, and what the account section shows.

### Modified Capabilities

<!-- None. No spec for settings exists yet. -->

## Non-Goals

- A settings route or deep link. Settings stay a dialog opened from `SettingsButton` and the
  `ui.open-settings` command.
- A language switch.
- Searching within the settings.
- A second color (the accent) in the UI.
- Changing how the theme is persisted or how sign-in works.

## Impact

- **Code**
  - Rewritten in `lib/feature/settings/`: `settings_dialog.dart`, `settings_end_tile.dart` and the
    rows under `rows/`. New account row and a `SettingsCard` for the outlined row.
  - `settings_base_row.dart` and `settings_item.dart` are deleted. `settings_header_tile.dart`
    stays, `lib/feature/build/build_dialog.dart` still uses it.
  - `lib/feature/base/edit_card/edit_card_grid.dart` shares its section heading, so the settings
    use the same one.
  - `lib/api/state/actions/theme_actions.dart` gets `SetThemeModeAction`,
    `ResetAppearanceSettingsAction` and `ResetFontScaleAction`. `UpdateAccentColorAction` goes.
  - `ThemeSettings` gets a derived `themeMode`. `lib/app.dart` and `lib/util/app_theme.dart` read
    it, and `app_theme.dart` stops overriding the secondary color (see design.md).
  - `lib/feature/auth/session_indicator.dart` and the account row share the roles line.
  - `pubspec.yaml` lists `clock`, already in `pubspec.lock` through `flutter_test`.
  - `lib/l10n/stelaris_en.arb` gets the new strings, the ones only the old rows used go.
- **Tests**: new widget tests per section, new action tests. `project_settings_row_test.dart` and
  `misc_settings_row_test.dart` follow the new rows. `theme_actions_test.dart` and
  `app_theme_test.dart` follow the actions.
- **Depends on** `add-oidc-authentication` for the session state (`AuthState`) and sign-out
  (`AuthSession.signOut`, its task 2.7 is still open). The account section only reads and calls
  what that change provides.
- **No change** to the persisted shape of `ThemeSettings`, the API or the routes.
