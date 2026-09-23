# Tasks

## 1. Command model and registry

- [x] 1.1 Add `lib/feature/command_palette/command.dart` with `StelarisCommand`, `CommandGroup` and `CommandContext` as described in design.md, and verify `flutter analyze` reports no issues for the new file
- [x] 1.2 Add the subsequence scorer (`command_search.dart`) and cover it in `test/feature/command_palette/command_search_test.dart`: in-order non-adjacent match (`gtit` → "Go to Items"), non-match, case-insensitivity, prefix and word-start ranking above scattered matches, title ranked above keyword
- [x] 1.3 Add `CommandRegistry` with `available(ctx)` (role via `AuthState.hasRole` plus `isAvailable`) and `search(query, ctx)`, and verify with unit tests that a command requiring an ungranted role is excluded, that the same command is included with auth disabled, and that an empty query returns every available command in group order

## 2. POC command set

- [x] 2.1 Add the command strings (titles, keywords, group headings, search hint, empty result, success and failure messages) to `lib/l10n/stelaris_en.arb`, regenerate localizations, and verify `flutter gen-l10n` succeeds
- [x] 2.2 Add the navigation commands generated from `NavigationEntry.values`, plus "Go to project list", and verify with unit tests that the current page's command is unavailable (for example `nav.font` on `/fonts` and on `/fonts/detail`) while the others are available
- [x] 2.3 Add the interface commands (toggle dark mode, toggle system theme, open settings, open build dialog), and verify with a unit test on a test store that "Toggle dark mode" flips `isDarkMode` and clears `useSystemTheme`
- [x] 2.4 Add `runBackendCommand` with success, neutral and failure snackbars and the `outcome` state check, and verify with a widget test that a throwing action shows the error bar and a completing action shows the success bar
- [x] 2.5 Add the backend commands ("Reload current list" mapped per `NavigationEntry` to its `Refresh*Action`, "Reload git branches", "Reload release information"), and verify with unit tests that "Reload current list" is available only on the five list routes, not on `detail` routes, and that the branch command reports failure when `branches` ends up `null`

## 3. Palette widget

- [x] 3.1 Build `CommandPalette` (top-aligned dialog, autofocused `TextField`, grouped list for an empty query, flat ranked list with group labels otherwise, and an empty-result message), and verify with a widget test that typing `dark` leaves only matching entries and that an unmatched query shows the empty-result text
- [x] 3.2 Add keyboard handling (`Up`/`Down` with wrap-around, highlight reset on query change, `Enter` runs, `Ctrl+K`/`Cmd+K` closes, highlight kept in view), and verify with widget tests for Down, Down, Enter running the third entry and for Up on the first entry highlighting the last
- [x] 3.3 Run commands by popping the palette first and then calling `run` with the page context, and verify with a widget test that "Open settings" leaves exactly one dialog on screen, `SettingsDialog`, and none of the palette

## 4. Shortcut integration

- [x] 4.1 Wrap `BasePage`'s body in `Shortcuts`/`Actions` (`Ctrl+K` and `Cmd+K` → `OpenCommandPaletteIntent`) with an autofocused `Focus`, and verify with a widget test in `test/feature/base/base_page_test.dart` that `Ctrl+K` opens the palette
- [x] 4.2 Verify with widget tests that `Ctrl+K` opens the palette while the model page's `SearchBar` has focus and leaves its text unchanged, and that `Esc` closes the palette and returns focus to the search bar
- [x] 4.3 Verify with a widget test that `Ctrl+K` does nothing on the project selection page or while `SettingsDialog` is open

## 5. Validation

- [x] 5.1 Run `flutter analyze` and `flutter test` and verify both pass
- [x] 5.2 Test by hand in a web build (`flutter run -d chrome`, and in Firefox): `Ctrl+K` opens the palette and not the browser's search, every POC command does what its button does, the reload commands show their snackbars (including with the backend stopped), and the shortcut still works after closing the settings and build dialogs. Record the results in the PR description
  - 2026-09-23, Chromium via Playwright against the local backend: all of the above pass, and the keydown for `Ctrl+K` arrives with `defaultPrevented` set. Found and fixed: after a wrap-around the highlight scrolled out of view (regression test added). Checked by hand in a real Chrome and a real Firefox by the user: `Ctrl+K` opens the palette.
