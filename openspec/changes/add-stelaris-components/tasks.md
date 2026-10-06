# Tasks

The repositories build on each other in this order. Each task ends with its repository building and
its tests passing. Commits are short conventional one-liners without attribution.

## Review focus

Inputs the spec implies but doesn't spell out, each pinned by a test in the task that owns the code:

- Renaming `stelaris:material` through an update (changing its key) removes the material as surely
  as deleting it, so it is rejected (3.2).
- Updating another component to the key `stelaris:material` hits the duplicate check, the item
  already has one (3.2).
- `stelaris:amount` stored as `1` generates no `.amount(...)` call, the same as a missing amount
  (4.1).
- A material value that isn't a JSON string, e.g. a number from a hand-made request, fails the
  generation with the item's key in the message instead of an unrelated parse error (4.1).
- An item whose components are still loading shows the default marks of `minecraft:dirt`, not
  those of the previous item (6.3).

## 1. vulpes-minecraft-dart (vulpes_data)

- [ ] 1.1 Add `final bool required` (default `false`) to `ComponentSpec` in
  `lib/src/api/component_schema.dart`, documented as "has to be present on every item, so it can't
  be removed", and add `custom('Custom', 'custom')` as the first entry of `ComponentCategory` in
  `lib/src/api/component_category.dart`. Extend the class comment: `custom` is assigned by the
  handwritten Stelaris specs, not by the CLI. Verify with `dart analyze` (exit code 0)
- [ ] 1.2 Add `lib/src/api/stelaris_components.dart` with
  `const List<ComponentSpec> stelarisComponents` holding
  `ComponentSpec('stelaris:material', 'Material', ComponentCategory.custom, 'MATERIAL', KeySchema(registry: 'item'), required: true)`
  and
  `ComponentSpec('stelaris:amount', 'Amount', ComponentCategory.custom, 'AMOUNT', IntSchema(min: 1, max: 99))`.
  Add `export 'src/api/stelaris_components.dart';` to `lib/vulpes_data.dart` in sorted position, the
  same line the CLI writes on its next run. Verify with `dart analyze` (exit code 0) and by running
  the CLI locally into a copy of the repository: `lib/vulpes_data.dart` keeps the export
- [ ] 1.3 Push to `master` and verify that the frontend still builds against it with its current
  code (`dart analyze` with a `pubspec_overrides.yaml` pointing at the clone, removed afterwards).
  A switch over `ComponentCategory` that the analyzer reports is fixed in 6.1

## 2. vulpes-model

- [x] 2.1 Add `StelarisComponents` in `net.onelitefeather.vulpes.api.model.item` with `MATERIAL`,
  `AMOUNT`, `REQUIRED`, `ALL`, `DEFAULT_MATERIAL` (`minecraft:dirt`) and `NAMESPACE` (`stelaris:`).
  Verified with `./gradlew build` (49f21aa)
- [x] 2.2 Remove `material` and `amount` from `ItemEntity`: fields, constructor parameters,
  accessors and `toString`. Verified with `./gradlew build` (fcbeba6, `feat(item)!:`)
- [ ] 2.3 Merge `feat/stelaris-components` into `next` and let release-please publish 3.0.0

## 3. Vulpes-Backend

- [ ] 3.1 Move to vulpes-model 3.0.0 in `settings.gradle.kts`. Remove `material` and `amount` from
  `ItemModelDTO` (fields, `requiredProperties`, `toItemEntity`), from `ItemModelResponseDTO` and from
  `ItemModelCopier.copyRoot`. Update `ItemModelDTOValidationTest` and every test that builds an
  `ItemEntity` or posts `material`/`amount`. Verify with `./gradlew test`
- [ ] 3.2 Component rules in `ItemComponentServiceImpl`, each with a case in
  `ItemComponentControllerIntegrationTest`:
  - `deleteComponent` rejects a key in `StelarisComponents.REQUIRED` with an invalid-request error
    ("can't be removed"); `deleteAllComponents` deletes everything else and keeps those.
  - `updateComponent` rejects changing the key of a required component.
  - `createComponent` and `updateComponent` reject a key that starts with
    `StelarisComponents.NAMESPACE` but isn't in `StelarisComponents.ALL`.
  - Tests: delete material → 400 and still listed; delete all → only material left; rename material
    to `minecraft:food` → 400; add `stelaris:foo` → 400; add `stelaris:amount` with `5` → 200; update
    `minecraft:food` to key `stelaris:material` → 409 (duplicate).

  Verify with `./gradlew test`
- [ ] 3.3 Creating an item adds `stelaris:material` with `"minecraft:dirt"` in the same transaction:
  override `create(UUID projectId, ItemModelDTO dto)` in `ItemServiceImpl`, call `super.create`, save
  the component through `ItemComponentRepository`, and return the reloaded item. Test in
  `ItemControllerTest` (or the component integration test): a new item lists exactly one component,
  `stelaris:material` = `minecraft:dirt`. Verify with `./gradlew test`
- [ ] 3.4 Add `ItemRelation.COMPONENTS`. `ItemModelCopier` copies all components for it and copies
  the keys in `StelarisComponents.REQUIRED` in every case. Tests in `ItemModelCopierTest`: copy with
  `COMPONENTS` keeps food and material; copy without it keeps only the material; a changed material
  (`minecraft:stone`) is copied as changed. Verify with `./gradlew test`
- [ ] 3.5 Drop the old columns on local databases: `ALTER TABLE items DROP COLUMN material, DROP
  COLUMN amount;` (check the column names with `\d items` first), or start with a fresh database.
  Verify that the backend starts and that creating an item through the API returns no `material`
  or `amount`

## 4. vulpes-generator

- [ ] 4.1 Move to vulpes-model 3.0.0 in `settings.gradle.kts` and fix what the jump from 2.0.0 brings.
  Add `ItemComponents` in the generator with `static String material(ItemEntity)` and
  `static int amount(ItemEntity)`, reading `getComponents()` and parsing `componentValue` with Gson.
  A missing amount is 1. A missing material, or one that isn't a JSON string, throws an
  `IllegalStateException` naming the item's key. Tests: material and amount are read; missing amount
  → 1; stored amount 1 → 1; missing material → exception with the key; material `5` → exception with
  the key. Verify with `./gradlew test`
- [ ] 4.2 `ItemGenerator` takes the material from `ItemComponents.material` and writes `.amount(n)`
  only for n ≠ 1. `ItemJsonGenerator` keeps the keys `material` and `amount` with the values from
  `ItemComponents`. Update `ItemJsonGeneratorTest` to build items with components, and add a case
  that the JSON of an item without amount has `"amount": 1`. Verify with `./gradlew test`

## 5. stelaris-model

- [ ] 5.1 Remove `material` and `amount` from `ItemModel` in `lib/src/model/item_model.dart`, run
  `dart run build_runner build --delete-conflicting-outputs`, and update tests that set them. Verify
  with `dart analyze` and `flutter test`, then push to `main`

## 6. stelaris (frontend)

- [ ] 6.1 Upgrade `vulpes_data` and `stelaris_models` (`flutter pub upgrade vulpes_data
  stelaris_models`). Add `componentCatalog = [...stelarisComponents, ...dataComponents]` in
  `component_dialogs.dart` and build `offeredComponents` and the components page's `_specsByKey` from
  it. Fix every switch over `ComponentCategory` the analyzer reports, and give `custom` a label like
  the other categories. Tests in `component_dialogs_test.dart`: the picker lists Custom first;
  Amount is offered while missing; Material is never offered. Verify with `dart analyze` and
  `flutter test`
- [ ] 6.2 Components tab: cards of the `custom` category get a "Custom" badge next to the "Default"
  one (new string `component_custom_label`), and a card whose spec is `required` has no remove
  button. Tests in `item_components_page_test.dart`: the material card shows the badge and no
  remove button; an amount card can be removed. Verify with `flutter test`
- [ ] 6.3 Default marks: replace `state.selectedItem?.material` and `SelectedItemView.material` with
  `materialOf(List<ItemComponentDto> components)`, which returns the value of `stelaris:material`
  or `defaultMaterial`. Tests: changing the material component changes the default marks; while the
  components are loading, the marks are those of `defaultMaterial`. Verify with `flutter test`
- [ ] 6.4 General tab: remove the Material and Amount cards from `item_general_page.dart` and fix
  the focus order of the remaining cards. Test that the tab shows no material or amount input.
  Verify with `dart analyze` and `flutter test`

## 7. Release

- [ ] 7.1 Release backend, generator and frontend together on a database without the old columns.
  Test by hand: create an item (material is dirt), change the material and add an amount on the
  components tab, try to remove the material (no button), copy the item with and without
  components, and generate the project (material and amount appear in the Java and JSON output).
  Record the results in the PR description
