# Tasks

## 1. Controller and panel

- [x] 1.1 Move the dialog's state and key handling into `CommandPaletteController` and its list, notice and key hints into `CommandPanel`, keeping the rebuild guarantees, and verify with `flutter analyze`
- [x] 1.2 Replace `showCommandPalette` with `CommandPaletteHost` (registry + open/close requests) provided by `CommandPaletteShortcuts`, and remove the dialog widget

## 2. App bar search

- [x] 2.1 Host the controller in `AppBarSearch`: chip and hint in the `SearchBar`, `onKeyEvent` delegation, the dropdown as an `OverlayPortal` under the field with a `TapRegion`, `Ctrl+K` toggling it (expanding compact mode), `Esc` closing it before clearing
- [x] 2.2 Filter only plain text; inject the highlighted filter entry for plain non-empty text (list: close and apply now; detail: leave through `_leaveDetail`); remove leaving on the first keystroke

## 3. Tests

- [x] 3.1 Move the palette widget tests (palette, syntax, drill-down, create/delete, base page) to an app bar harness and update the expectations the filter entry changes
- [x] 3.2 Add widget tests for: Enter keeps the filter, Down then Enter runs a command, `#sword` leaves the list unfiltered, typing on a detail page stays and "Show … matching" leaves filtered, Esc closes then clears, click outside closes, Ctrl+K toggles and expands compact mode
- [x] 3.3 Update the existing `AppBarSearch` tests that relied on leaving a detail page on the first keystroke

## 5. Build cycle

- [x] 5.1 Rebuild the search field only when the palette's mode, kind or drill-down changes, not on every keystroke, and verify with a widget test that a plain keystroke leaves the `SearchBar` widget untouched while a prefix rebuilds it

- [x] 5.2 Replace the field's debounce `Timer` with `DebouncedSearchQueryAction with Debounce` and its cancelling variant, and verify that the existing debounce, section-switch and clear tests pass unchanged plus a unit test that a cancel drops a pending query

## 4. Validation

- [x] 4.1 Run `flutter analyze` and `flutter test` and verify both pass
- [ ] 4.2 Test by hand in Chrome and Firefox, wide and narrow: Ctrl+K, filtering with Enter, commands with Down, syntax chip, drill-down, create/delete, detail-page typing, Esc twice, click outside. Record the results in the PR description
