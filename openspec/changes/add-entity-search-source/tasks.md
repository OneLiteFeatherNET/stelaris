# Tasks

## 1. Faster matching and the cap

- [x] 1.1 Make `scoreMatch` O(query × title) with a greedy reject first, and verify the existing `command_search_test.dart` passes unchanged and a benchmark shows the gain
- [x] 1.2 Rank `(kind, model, name)` tuples in `EntityProvider`, build commands only for the best 15, and report the match total. Verify with unit tests that 200 matching items list 15 with the count in the notice, 3 list 3 without it, and "Go to" fallbacks don't count

## 2. Search source

- [x] 2.1 Add `EntitySearchSource`, `EntitySearchRequest` and `EntityHit`, and pass an optional source through `CommandPaletteShortcuts` and `CommandPaletteHost` to the controller
- [x] 2.2 Run the source from the controller (250 ms debounce, sequence token, re-resolve keeping the highlight) and merge hits into `EntityProvider` (dedupe by kind and id, unscored hits after scored ones, cap 15). Verify with widget tests: an unloaded hit appears and opens its detail page, a duplicate is listed once, a stale answer is ignored, and a failure keeps loaded matches with a failure notice
- [x] 2.3 Show "Searching…" while pending and adjust the "only loaded" notice to apply only without a source (also in the syntax change's spec), and verify with widget tests

- [x] 2.4 Move the source query into Redux: `AppState.entitySearch`, `EntitySearchStartedAction`, `EntitySearchAction with Debounce` (stale-checked before and after the await) and `ClearEntitySearchAction`; the controller reports its question and applies the state instead of running a timer. Verify with unit tests on a store (debounce keeps only the last dispatch, a stale answer is dropped, failure is recorded) and the existing widget tests

## 3. Validation

- [x] 3.1 Run `flutter analyze` and `flutter test` and verify both pass, and rerun the benchmark to record before and after
  - 2026-09-23, test benchmark, 5,000 loaded items, per keystroke: `#` 3.8 → 1.0 ms, `#sword` (all match) 12.9 → 3.5 ms, no match 11.4 → 0.9 ms; list rows 5,004 → 19 (15 entities + 4 Go-to)
