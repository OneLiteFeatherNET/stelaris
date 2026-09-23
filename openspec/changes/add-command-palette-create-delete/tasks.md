# Tasks

## 1. Shared dialogs

- [x] 1.1 Add `openModelCreateDialog` in `lib/feature/model/model_create.dart`, make the five list pages' Add use it and drop their private copies, and verify with a widget test that each kind's dialog shows its title and that submitting dispatches that kind's add action, and that the existing list page tests still pass
- [x] 1.2 Move `ModelDetailActions._openDelete` into `confirmAndDeleteModel` in `lib/feature/model/model_delete.dart`, call it from `ModelDetailActions`, and verify that the existing `model_detail_actions_test.dart` still passes unchanged

## 2. Palette

- [x] 2.1 Add `CommandGroup.create` and the five "New …" commands (role-gating deferred until #178 lands), which go to the kind's list after a successful create unless already there. Verify with unit tests for availability and with a widget test that "New item" on `/fonts` opens the item dialog, and that submitting lands on `/items` while cancelling stays on `/fonts`
- [x] 2.2 Append a "Delete…" child to every entity (tabs first where there are any; attributes and notifications get only this child). Verify with unit tests that every one of the five kinds sees it, matching a session without an identity provider; and with a widget test that choosing it opens `ModelDeleteDialog` for that entity and cancelling deletes nothing
- [x] 2.3 Add the "Delete this …" commands for items, fonts, sounds and notifications (role-gating deferred until #178 lands), available only on that kind's detail page with a selection. Verify with unit tests for availability, and with a widget test that confirming by typing the name removes the item (fake HTTP) and returns to `/items`
- [x] 2.4 Rename the step-in footer hint from "Tabs" to "More" and add the strings, and verify that the drill-down tests are updated and pass
- [x] 2.5 Add a unit test that pins the palette's per-kind delete titles and warnings to the ones the detail pages pass to `ModelDetailActions`

## 3. Validation

- [x] 3.1 Run `flutter analyze` and `flutter test` and verify both pass
- [ ] 3.2 Test by hand in Chrome and Firefox: "New …" for two kinds (submit and cancel), "Delete…" from the drill-down with cancel and with confirmation, and "Delete this item…" on a detail page. Record the results in the PR description
