# Tasks

## 1. Detail pages open on a tab

- [x] 1.1 Add `lib/feature/model/detail_tabs.dart` with `initialTabIndex` and `detailLocation`, and verify with unit and widget tests that a known tab (any case) gives its index, and a missing or unknown one gives 0
- [x] 1.2 Give `ItemDetailPage`, `FontDetailPage` and `SoundDetailPage` a public `tabs` list, build their `Tab`s from it, and start their keyed `DefaultTabController` at `initialTabIndex`. Verify with widget tests that `/fonts/detail?tab=chars` shows Chars, and that the existing detail page tests still pass without the parameter

## 2. Children and drill-down

- [x] 2.1 Add `children` to `StelarisCommand`, and give item, font and sound entries one tab child per page tab whose `run` selects the entity and goes to `detailLocation`. Verify with unit tests that an item has General, Meta, Enchantments and Lore children, a sound has General and Entries, and notifications and attributes have none
- [x] 2.2 Add the drill frame to `CommandPalette`: Arrow Right at the end of the text on an entry with children steps in (chip shows the entity, children filtered by the text), and Arrow Left at offset 0, Backspace in an empty field or the chip's delete action step out and restore mode, kind, text and highlight. Verify with widget tests for stepping in, filtering `ench`, stepping out both ways, Arrow Right inside the text moving the cursor, and Arrow Right on an attribute doing nothing
- [x] 2.3 Verify with a widget test that choosing Lore after stepping into "Diamond Sword" selects it and lands on `/items/detail?tab=lore`

## 3. Marker and help

- [x] 3.1 Show `›` on rows with children, add `→ Tabs` to the key hints while such a row is listed, and add `→`/`←` to the Keyboard help section. Verify with widget tests that an item row has the chevron and an attribute row does not, and that the hint appears only in lists with children

## 4. Validation

- [x] 4.1 Run `flutter analyze` and `flutter test` and verify both pass
- [ ] 4.2 Test by hand in Chrome and Firefox: `#` → `→` on an item, a font and a sound, choosing a tab, `←` and Backspace back, `→` in the middle of the text, and the detail page opening on the chosen tab. Record the results in the PR description
  - 2026-09-23, Chromium via Playwright against the local backend: `#rune` shows the `›` and the `→ Tabs` hint, `→` lists General, FontFace and Chars with the chip "Rune Script" and the `← Back` hint, `ch` + Enter lands on `/fonts/detail?tab=chars` with Chars selected. Still open: a check by hand in a real Chrome and a real Firefox.
