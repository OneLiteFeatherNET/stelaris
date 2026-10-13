# Tasks

Each group starts with its failing test (red), then the code that makes it pass (green). Tests
follow F.I.R.S.T.: widget tests build a fresh `Store<AppState>` and fixture per test, drive frames
with `pump` and never sleep, take the year from an injected `Clock`, and assert one behaviour each.

## 1. Theme state

- [x] 1.1 Test first, in `test/api/state/actions/theme_actions_test.dart` and a new
      `test/api/model/theme/theme_settings_test.dart`: `themeMode` is system, light or dark from the
      fields; `SetThemeModeAction` writes the fields as the table in design.md says and keeps
      `isDarkMode` for System; `ResetAppearanceSettingsAction` restores mode, color and accent but
      keeps `fontScale`; `ResetFontScaleAction` restores only `fontScale`.
- [x] 1.2 Add `ThemeSettings.themeMode`, `SetThemeModeAction`, `ResetAppearanceSettingsAction` and
      `ResetFontScaleAction`. Remove `UpdateAccentColorAction` and its test group.
- [x] 1.3 Test first in `test/util/app_theme_test.dart`: the scheme is `fromSeed` of the primary
      color with no `secondary` override. Then `AppTheme` drops `secondary` and `lib/app.dart` reads
      `themeMode`.

## 2. Dialog chrome and cards

- [ ] 2.1 Test first, `test/feature/settings/settings_dialog_test.dart`: the dialog shows the title
      "Settings", a close icon and no Save or Cancel, the sections in order, and the close icon
      closes it.
- [ ] 2.2 Extract `EditSectionHeading` from `EditCardGrid`; `edit_card_test.dart` stays green.
- [ ] 2.3 `SettingsCard` and the new `SettingsDialog` on `FormDialog` (`showActions: false`,
      `maxWidth: 560`). Delete `settings_base_row.dart` and `settings_item.dart`; keep
      `settings_header_tile.dart`, `build_dialog.dart` uses it.
- [ ] 2.4 Check that `SettingsButton` and `ui.open-settings` still open the dialog.

## 3. Appearance

- [ ] 3.1 Test first, `test/feature/settings/rows/theme_settings_row_test.dart`: the three choices;
      tapping Dark sets `useSystemTheme` off and `isDarkMode` on; tapping System sets
      `useSystemTheme` on; the selected choice matches the store; tapping a swatch sets the primary
      color and marks it; Reset restores the defaults and is disabled at the defaults.
- [ ] 3.2 Rewrite `rows/theme_settings_row.dart` as the Appearance section with the segmented
      button, the swatches (a const list) and the reset.

## 4. Accessibility

- [ ] 4.1 Test first, `test/feature/settings/rows/accessibility_settings_row_test.dart`: dragging
      the slider (`tester.drag`, no release) changes the sample text scale and not the store;
      releasing stores the value once; Reset restores 1.0 and moves the slider; Reset is disabled
      at 1.0.
- [ ] 4.2 Rewrite `rows/accessibility_settings_row.dart` with the slider, the sample text,
      `onChangeEnd` and the reset.

## 5. Account

- [ ] 5.1 Test first, `test/feature/settings/rows/account_settings_row_test.dart`, with a fake
      session instead of a provider: signed in shows name and roles and "Sign out", tapping it calls
      sign-out once; enabled but signed out shows the explanation and no button; disabled shows
      nothing, not even the heading.
- [ ] 5.2 Move the roles line out of `SessionIndicator` into one shared function and use it from
      both; the existing `SessionIndicator` tests stay green.
- [ ] 5.3 `rows/account_settings_row.dart`, calling `AuthSessions.current?.signOut()`. It relies on
      `add-oidc-authentication`; its task 2.7 is still open and needs no change here when it lands.

## 6. Project

- [ ] 6.1 Test first, in `test/feature/settings/rows/project_settings_row_test.dart`: the active
      project is shown; choosing another and confirming selects it; cancelling keeps the selection;
      the dirty-leave prompt still appears; with no projects the empty state shows.
- [ ] 6.2 Rewrite `rows/project_settings_row.dart` as an edit card with the choice dialog and the
      empty state, keeping `SwitchProjectDialog` and `confirmLeaveIfDirty`.

## 7. About

- [ ] 7.1 Test first, in `test/feature/settings/rows/misc_settings_row_test.dart` and
      `test/feature/settings/settings_end_tile_test.dart`: version, licences, one issues card and
      one help card are shown; the footer shows the year of `Clock.fixed(DateTime(2031))`.
- [ ] 7.2 Rewrite `rows/misc_settings_row.dart` as About with the four cards, the wiki link moved
      here. Add `clock` to `pubspec.yaml`, give `SettingsEndTile` a `Clock` (default `const Clock()`)
      and pass it from `SettingsDialog`.

## 8. Strings and clean up

- [ ] 8.1 Add the new keys to `lib/l10n/stelaris_en.arb` (sections, theme modes, color tooltips,
      font preview, reset, account texts, empty state, about cards, footer with a year placeholder)
      and regenerate localizations.
- [ ] 8.2 Remove the keys only the old rows used (the two switches, the separate bug and suggestion
      texts, the accessibility wiki texts) and the `@2025` literal.
- [ ] 8.3 Run `flutter analyze` and `flutter test`; both clean.

## 9. Pull request

- [ ] 9.1 Open the pull request titled `feat(settings): redesign the settings dialog`.
