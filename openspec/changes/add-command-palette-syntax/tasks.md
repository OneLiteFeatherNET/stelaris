# Tasks

## 2. Parser and mode table

- [x] 2.1 Add `PaletteMode`, `EntityKind`, `ModeSpec` and the mode table (sigils, aliases, l10n labels and descriptions) and add the strings to `stelaris_en.arb`, and verify with `flutter gen-l10n` and `flutter analyze`
- [x] 2.2 Implement `parseQuery` and verify with unit tests: each sigil, each alias with and without a trailing space, case-insensitivity, `#item sword` setting kind and text, `#sword` with no kind, and a bare prefix
- [x] 2.3 Add a unit test asserting that no POC command title starts with an alias followed by a space, so aliases can never hide a command

## 3. Providers

- [x] 3.1 Add `PaletteProvider`, give `StelarisCommand` `modes` (default `{commands}`) and `switchTo`, tag the theme toggles and "Open settings" with the settings mode, and verify with unit tests that settings mode lists exactly those three commands
- [x] 3.2 Add `EntityProvider` (items, fonts, sounds, notifications, attributes from state; kind filter; `scoreMatch` on `uiName`; kind label; "Go to <kind>" for kinds with nothing loaded), and verify with unit tests for `#sword` across kinds, `#sound stone` restricting to sounds, and an empty font list yielding "Go to Fonts"
- [x] 3.3 Implement entity `run` mirroring each page's `onModelTap`, and verify with widget tests that an item result selects the item and lands on `/items/detail`, and that an attribute result opens `AttributeEditDialog`
- [x] 3.4 Add `ProjectProvider` (other projects by `displayName`, "Go to project list" when none), with `run` showing `SwitchProjectDialog` and dispatching `SelectProjectAction` only on confirm, and verify with widget tests for confirm, cancel, and the current project being excluded
- [x] 3.5 Add `HelpProvider` and the default-mode fallback entries (both use `switchTo`), and verify with unit tests that `?` lists four modes with their aliases and that an unmatched default query yields an entity and a project fallback carrying the text

## 4. Palette UI

- [x] 4.1 Hold `ParsedQuery` state in `CommandPalette`: move a recognized prefix or alias into the mode (and kind) and out of the text, and route search through the provider for that mode. Verify with widget tests that `#item ` shows an "Items" chip with an empty field, and that `item sword` lists the same results as `#item sword`
- [x] 4.2 Render the chip as the field's prefix with a delete action, and handle Backspace on an empty field (kind first, then mode). Verify with widget tests that Backspace returns to the default mode and that the chip's delete action does the same
- [x] 4.3 Handle `switchTo` entries by switching mode in place without popping, and show the "only loaded entries" notice in entity mode. Verify with widget tests that choosing the entities help entry shows its chip and an empty query, and that the entity fallback carries `sword` into entity mode

## 5. Placeholder, navigation mode and help sections

- [x] 5.1 Show a placeholder per mode and kind, pointing to `?` in the default mode, and verify with widget tests that the empty palette's hint mentions `?` and that `#item ` shows the loaded-items hint
- [x] 5.2 Add `PaletteMode.navigation` with sigil `:` and alias `go`, tag the "Go to" commands with it, change the alias collision test to "an alias may only prefix titles its own mode lists", and verify with unit tests that `:` on `/fonts` lists exactly the other four pages and the project list, and that `go to fonts` lists "Go to Fonts"
- [x] 5.3 Add `HelpSection` and `defaultHelpSections` (syntax, navigation, keyboard), make `HelpProvider` build from the sections with their titles as headings, add `inert` to `StelarisCommand` and ignore it in `_run`, and verify with unit tests that `?` lists all three sections, that the syntax section has five modes, and that a custom section passed to `PaletteSearch` appears without other changes
- [x] 5.4 Verify with widget tests that picking "Go to Items" in help navigates to `/items` and closes the palette, and that picking the `Esc` keyboard entry leaves the palette open in help mode

- [x] 5.5 Make the mouse move the one highlight instead of painting its own hover background, and verify with a widget test that hovering an entry highlights it and un-highlights the previous one
- [x] 5.6 Add a footer with the key hints (`↑↓`, `Enter`, `Esc`, `?`) below the list, and verify with a widget test that it is shown in every mode and that the last entry of a long list scrolls fully into view above it

- [x] 5.7 List the current page's "Go to" command instead of hiding it and mark it (filled icon, primary color, "Current page" label) in every mode, keep it out of the entity-mode "Go to" fallback, and verify with unit and widget tests that on `/fonts` and `/fonts/detail` "Go to Fonts" is listed and marked, other pages are not marked, choosing it on the detail page returns to `/fonts`, and `#font ` on `/fonts` offers no "Go to Fonts"

## 6. Validation

- [x] 6.1 Run `flutter analyze` and `flutter test` and verify both pass
- [ ] 6.2 Test by hand in Chrome and Firefox against a backend with at least two projects: `?`, `>`, `/`, `#item <name>`, `@<project>` with confirm and cancel, `:` and `go …`, the help sections (navigating from help, keyboard entries staying inert), the placeholder per mode, the current-page marker, the fallback entries, and the chip with Backspace. Record the results in the PR description
  - 2026-09-23, Chromium via Playwright against the local backend (four projects): `?`, `>`, `/`, `#`, `#attribute `, `@` with the switch dialog and cancel, the default-mode fallback into entity mode, Backspace on the chip, and opening a font detail page from `#rune` all behave as specified. Still open: a check by hand in a real Chrome and a real Firefox, including typing the sigils on a German keyboard layout (`@` is AltGr+Q).
