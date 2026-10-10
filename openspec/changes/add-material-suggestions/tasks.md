# Tasks

## 1. Suggestion widget

- [x] 1.1 Add `MaterialAutocomplete` in `lib/feature/base/input/material_autocomplete.dart` with a shared `MaterialSearch`, a cap of five and no suggestions for an empty query, and verify with widget tests that `diamond` yields at most five rows and an empty field none

## 2. Integration

- [x] 2.1 Use it for `KeySchema` fields of the `item` and `block` registries in `schema_field.dart` (blocks restricted to `MaterialCategory.block`), and verify with widget tests that `sword` yields nothing for blocks and that other registries show no suggestions
- [x] 2.2 Add the opt-in `suggestsMaterials` to `TextInputCard` and enable it for the notification material, and verify with widget tests that picking a suggestion saves its key and that free text is still saved on focus loss

## 3. Validation

- [x] 3.1 Run `flutter analyze` and `flutter test` and verify both pass (analyze keeps only the existing `backdoorInheritedWidget` warnings)
- [ ] 3.2 Open the pull request as `feat(input): suggest minecraft materials in id fields`
