# Proposal

## Why

An item's data is spread over two places. Material and amount are fields of the item and get their
own cards on the General tab, while everything else about the item stack is a data component on the
Components tab. Each field needs its own card, its own DTO field and its own column, and a new kind
of data needs all of that again.

The component storage is already generic: `item_components` holds a key and a JSON value, and the
backend accepts any `namespace:path` key. If Stelaris describes material and amount as components of
its own, `stelaris:material` and `stelaris:amount`, the item becomes one list of components and the
schema editor shows them like any other component. There is no production data yet, so the fields
can be replaced in one step.

## What Changes

- **Two Stelaris components**, described by hand in vulpes_data next to the generated vanilla
  catalog:
  - `stelaris:material`: the item key, e.g. `minecraft:stone`. Required: created with every item and
    can't be removed.
  - `stelaris:amount`: 1 to 99. Optional: a missing amount is 1.
- **`ComponentSpec.required`** and a **`custom` category** in vulpes_data, so any interface can tell
  required components and Stelaris' own components apart.
- **Backend**: material and amount leave the item entity and its DTOs. Creating an item adds
  `stelaris:material` with `minecraft:dirt`. The required component can't be deleted, unknown
  `stelaris:*` keys are rejected, and copying an item can copy its components.
- **Generator**: reads material and amount from the components. The JSON output keeps its format.
- **Frontend**: the Material and Amount cards leave the General tab. The components tab lists the
  Stelaris components first under "Custom", marks them, and offers no remove for the material.
- **BREAKING**: `material` and `amount` are removed from the item API, from `ItemEntity` (vulpes-model
  3.0.0) and from `ItemModel` in stelaris-model.

## Capabilities

### New Capabilities

- `stelaris-components`: the Stelaris components of an item, which of them are required, how they
  are created, edited, removed and copied, and how the interface shows them.

### Modified Capabilities

<!-- None. Item components have no spec yet. -->

## Impact

The change spans six repositories, released together:

- **vulpes-minecraft-dart** (vulpes_data): `ComponentSpec.required`, `ComponentCategory.custom`,
  `lib/src/api/stelaris_components.dart`. Additive.
- **vulpes-model**: `StelarisComponents` key constants, material and amount removed from
  `ItemEntity`. Breaking, released as 3.0.0.
- **Vulpes-Backend**: DTOs, item creation, component service rules, `ItemModelCopier` with a
  `COMPONENTS` relation. The `material` and `amount` columns are dropped by hand or with a fresh
  database.
- **vulpes-generator**: moves from vulpes-model 2.0.0 to 3.0.0 and reads the components.
- **stelaris-model**: `ItemModel` without material and amount.
- **stelaris** (this repository): component catalog, components tab, General tab, tests.

Display name and custom model data are out of scope. They move to the vanilla components
`minecraft:custom_name` and `minecraft:custom_model_data` in a later change. The item group stays a
field.
