# Tasks

The repositories build on each other in this order; vulpes-generator is out of scope. Each task
ends with its repository building and its tests passing. Commits are short conventional
one-liners without attribution.

## Review focus

Inputs the spec implies but doesn't spell out, each pinned by a test in the task that owns the code:

- Renaming `stelaris:material` through an update (changing its key) removes the material as surely
  as deleting it, so it is rejected (3.3).
- Updating another component to the key `stelaris:material` hits the duplicate check, the item
  already has one (3.3).
- A request that still sends `displayName`, `customModelData`, `material` or `amount` in the item
  body is answered without them and doesn't fail, so an old client degrades instead of breaking
  (3.1).
- `minecraft:custom_name`, `minecraft:item_name` and `minecraft:custom_model_data`, rejected until
  now, are accepted as components (3.3).
- An item whose components are still loading shows the default marks of `minecraft:dirt`, not
  those of the previous item (5.3).

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
  A switch over `ComponentCategory` that the analyzer reports is fixed in 5.1

## 2. vulpes-model

- [x] 2.1 ~~Add `StelarisComponents` to the model~~ (49f21aa), replaced by the backend
  configuration in 3.3 and removed from the model again (d45322a)
- [x] 2.2 Remove `material` and `amount` from `ItemEntity`: fields, constructor parameters,
  accessors and `toString`. Verified with `./gradlew build` (fcbeba6, `feat(item)!:`)
- [x] 2.3 Remove `displayName` and `customModelData` from `ItemEntity`. Verified with
  `./gradlew build` (03f72b4)
- [x] 2.4 Remove the item flags: `ItemEntity.flags`, `ItemFlagEntity`, `ItemFlagRepository` and the
  flag fetch in `ItemRepository.findAllWithFetches`. Verified with `./gradlew build` (526de0f)
- [ ] 2.5 Merge `feat/stelaris-components` into `next` and let release-please publish 3.0.0

## 3. Vulpes-Backend

- [ ] 3.1 Move to vulpes-model 3.0.0 in `settings.gradle.kts`. Remove `material`, `amount`,
  `displayName` and `customModelData` from `ItemModelDTO` (fields, `requiredProperties`,
  `toItemEntity`), from `ItemModelResponseDTO` and from `ItemModelCopier.copyRoot`. Update
  `ItemModelDTOValidationTest` and every test that builds an `ItemEntity` or posts those fields. Test
  that an item body which still contains them is accepted and answered without them. Verify with
  `./gradlew test`. Done except the test for a body with the old fields
- [x] 3.2 Remove the item flags: `ItemFlagController`, `ItemFlagDTO`, `ItemFlagResponseDTO`, the flag
  methods of `ItemService`/`ItemServiceImpl`, `ItemRelation.FLAGS` with its branch in
  `ItemModelCopier`, and their tests. Verify with `./gradlew test`. Controller, DTOs, service and
  their tests are done on Vulpes-Backend `refactor/item` (da1a7af … 6011dbb, tests in 1cb7f22).
  `./gradlew test`: 315 tests, 0 failures, 3 skipped (`@Disabled` sound tests from before)
- [x] 3.2a Update the development seed (`src/dev/.../seed`: `SeedWriter`, `SeedRepositories`,
  `SeedWiper`, `SeedValidator`, the fixtures): no flags (`hide(...)` writes
  `minecraft:tooltip_display`), and material, amount, display name and model data written as
  components; `SeedValidator` checks components against `ItemComponentDTO` and `ItemComponentRules`.
  Verified with `./gradlew compileDevJava` and a seed run against Postgres (142 items, each with
  `stelaris:material`) (0f1306c)
- [x] 3.3 Configure the component rules in `application.yml` (`vulpes.item-components`, as in
  design.md), read them with `ItemComponentConfiguration`, `RequiredComponentConfiguration` and
  `ItemComponentRules` (checked at startup, `ItemComponentRulesTest`), and apply them in
  `ItemComponentServiceImpl`, each with a case in `ItemComponentControllerIntegrationTest`:
  - `deleteComponent` rejects a required component with an invalid-request error ("can't be
    removed"); `deleteAllComponents` deletes everything else and keeps those.
  - `updateComponent` rejects changing the key of a required component.
  - `createComponent` and `updateComponent` reject a key in the custom namespace that isn't custom.
  - Only `minecraft:lore` and `minecraft:enchantments` are managed; `MANAGED_COMPONENTS` is gone.
  - Tests: delete material → 400 and still listed; delete all → only material left; rename material
    to `minecraft:food` → 400; add `stelaris:foo` → 400; add `stelaris:amount` with `5` → 200; update
    `minecraft:food` to key `stelaris:material` → 409 (duplicate); add `minecraft:custom_name` →
    200; add `minecraft:lore` → still 400.

  Verified with the two test classes (16 tests, none skipped) in a copy of the backend without the
  parts 3.1, 3.2 and 3.2a still have to fix (ccb97c1, 039f033)
- [x] 3.4 Creating an item adds every component of `ItemComponentRules.required()` with its value in
  the same transaction: override `create(UUID projectId, ItemModelDTO dto)` in `ItemServiceImpl`,
  call `super.create`, save the components through `ItemComponentRepository`, and return the
  reloaded item. Test: a new item lists exactly one component, `stelaris:material` =
  `minecraft:dirt`, and `create_keepsTheJsonValue` expects two components. Verify with
  `./gradlew test`. Done in 1a950e7; the rollback test now lets Hibernate create the schema like
  the other integration tests (ed6010e). 316 tests, 0 failures
- [ ] 3.5 Add `ItemRelation.COMPONENTS`. `ItemModelCopier` copies all components for it and copies
  the required components (`ItemComponentRules.isRequired`) in every case. Tests in `ItemModelCopierTest`: copy with
  `COMPONENTS` keeps food and material; copy without it keeps only the material; a changed material
  (`minecraft:stone`) is copied as changed. Verify with `./gradlew test`
- [ ] 3.6 Drop the old schema on local databases: `ALTER TABLE items DROP COLUMN material, DROP
  COLUMN amount, DROP COLUMN display_name, DROP COLUMN custom_model_data;` and
  `DROP TABLE item_flags;` (check the names with `\d items` first), or start with a fresh database.
  Verify that the backend starts and that creating an item through the API returns none of the
  removed fields

## 4. stelaris-model

- [ ] 4.1 Remove `material`, `amount`, `displayName`, `customModelData` and `flags` from `ItemModel`
  in `lib/src/model/item_model.dart`, run
  `dart run build_runner build --delete-conflicting-outputs`, and update tests that set them. Verify
  with `dart analyze` and `flutter test`, then push to `main`

## 5. stelaris (frontend)

- [ ] 5.1 Upgrade `vulpes_data` and `stelaris_models` (`flutter pub upgrade vulpes_data
  stelaris_models`). Shrink `dedicatedComponents` to `minecraft:lore` and `minecraft:enchantments`
  and adapt the test that pins it. Add `componentCatalog = [...stelarisComponents, ...dataComponents]` in
  `component_dialogs.dart` and build `offeredComponents` and the components page's `_specsByKey` from
  it. Fix every switch over `ComponentCategory` the analyzer reports, and give `custom` a label like
  the other categories. Tests in `component_dialogs_test.dart`: the picker lists Custom first;
  Amount is offered while missing; Material is never offered. Verify with `dart analyze` and
  `flutter test`
- [ ] 5.2 Components tab: cards of the `custom` category get a "Custom" badge next to the "Default"
  one (new string `component_custom_label`), and a card whose spec is `required` has no remove
  button. Tests in `item_components_page_test.dart`: the material card shows the badge and no
  remove button; an amount card can be removed. Verify with `flutter test`
- [ ] 5.3 Default marks: replace `state.selectedItem?.material` and `SelectedItemView.material` with
  `materialOf(List<ItemComponentDto> components)`, which returns the value of `stelaris:material`
  or `defaultMaterial`. Tests: changing the material component changes the default marks; while the
  components are loading, the marks are those of `defaultMaterial`. Verify with `flutter test`
- [ ] 5.4 General tab: remove the Material, Amount, Display Name and Model Data cards from
  `item_general_page.dart`, keep the group card, and drop the strings and tooltips only they used.
  Remove the commented-out `ItemFlagFetchAction` and the `flags` copy in `item_actions.dart`. Test
  that the tab shows only the group input.
  Verify with `dart analyze` and `flutter test`

## 6. Release

- [ ] 6.1 Release backend and frontend together on a database without the old schema. The
  generator can't generate items until its own update. Test by hand: create an item (material is
  dirt), change the material, add an amount and a custom name on the components tab, try to remove
  the material (no button), and copy the item with and without components. Record the results in
  the PR description
