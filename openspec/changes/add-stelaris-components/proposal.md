# Proposal

## Why

An item's data is spread over two places. Material, amount, display name, custom model data and
flags are fields or tables of the item, and most of them get their own cards on the General tab,
while everything else about the item stack is a data component on the Components tab. Each field needs its own card, its own DTO field and its own column, and a new kind
of data needs all of that again.

The component storage is already generic: `item_components` holds a key and a JSON value, and the
backend accepts any `namespace:path` key. If Stelaris describes material and amount as components of
its own, `stelaris:material` and `stelaris:amount`, and the display name and model data become the
vanilla components they already are, the item becomes one list of components and the schema editor
shows them like any other component. Item flags are gone from current Minecraft; the
`minecraft:tooltip_display` component replaces them. There is no production data yet, so the fields
can be replaced in one step.

## What Changes

- **Two Stelaris components**, described by hand in vulpes_data next to the generated vanilla
  catalog:
  - `stelaris:material`: the item key, e.g. `minecraft:stone`. Required: created with every item and
    can't be removed.
  - `stelaris:amount`: 1 to 99. Optional: a missing amount is 1.
- **`ComponentSpec.required`** and a **`custom` category** in vulpes_data, so any interface can tell
  required components and Stelaris' own components apart.
- **Display name and custom model data** become the vanilla components `minecraft:custom_name` and
  `minecraft:custom_model_data`. Only lore and enchantments keep a dedicated editor and storage.
- **Item flags** are removed: entity, repository, endpoints and model. `minecraft:tooltip_display`
  covers them.
- **Backend**: material, amount, display name and custom model data leave the item entity and its
  DTOs, the flag endpoints go. Creating an item adds `stelaris:material` with `minecraft:dirt`. The
  required component can't be deleted or renamed, unknown `stelaris:*` keys are rejected, and
  copying an item can copy its components. Only lore and enchantments stay rejected as components.
- **Frontend**: the Material, Amount, Display Name and Model Data cards leave the General tab, which
  keeps the group. The components tab lists the Stelaris components first under "Custom", marks
  them, and offers no remove for the material. Custom name, item name and custom model data are
  offered like any other component.
- **BREAKING**: these fields and the flags are removed from the item API, from `ItemEntity`
  (vulpes-model 3.0.0) and from `ItemModel` in stelaris-model.

## Capabilities

### New Capabilities

- `stelaris-components`: the Stelaris components of an item, which of them are required, how they
  are created, edited, removed and copied, and how the interface shows them.

### Modified Capabilities

<!-- None. Item components have no spec yet. -->

## Impact

The change spans five repositories, released together:

- **vulpes-minecraft-dart** (vulpes_data): `ComponentSpec.required`, `ComponentCategory.custom`,
  `lib/src/api/stelaris_components.dart`. Additive.
- **vulpes-model**: `StelarisComponents` key constants; material, amount, display name, custom
  model data and flags removed from `ItemEntity`, `ItemFlagEntity` and its repository deleted.
  Breaking, released as 3.0.0.
- **Vulpes-Backend**: DTOs, flag endpoints removed, item creation, component service rules,
  `MANAGED_COMPONENTS` down to lore and enchantments, `ItemModelCopier` with a `COMPONENTS`
  relation. The old columns and the `item_flags` table are dropped by hand or with a fresh database.
- **stelaris-model**: `ItemModel` without material, amount, display name, custom model data and
  flags.
- **stelaris** (this repository): component catalog, components tab, General tab, tests.

Out of scope: **vulpes-generator**. It still reads the removed fields and needs a hard update of its
own, which then reads all components. Lore and enchantments keep their storage for now. The item
group stays a field.
