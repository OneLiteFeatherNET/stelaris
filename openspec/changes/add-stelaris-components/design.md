# Design

## Context

See proposal.md and specs/stelaris-components/spec.md.

- `ItemComponentEntity` stores `componentKey` and a JSON `componentValue`, unique per item and key.
  `ItemComponentServiceImpl` doesn't check values with codecs; it only rejects the keys in
  `MANAGED_COMPONENTS`, which have dedicated fields on the item.
- `ItemComponentDTO` checks the key against a generic `namespace:path` pattern, so `stelaris:*`
  keys are accepted today.
- The schema is managed by Hibernate (`hbm2ddl.auto: update`), which never drops columns. There is
  no migration tool, and there is no production data.
- vulpes_data splits handwritten API (`lib/src/api/`) from the catalog the Stelaris CLI generates
  (`lib/src/generated/`). The generated catalog describes vanilla data only and stays UI neutral.
- `ItemModelCopier` copies lore, flags and enchantments, but no components.
- vulpes-generator reads `getMaterial()`, `getAmount()` and `getDisplayName()` and depends on
  vulpes-model 2.0.0, which has no components.
- Item flags (`ItemFlagEntity`) are HideFlags, which current Minecraft replaced with
  `minecraft:tooltip_display`. The frontend only has commented-out code for them.

## Goals / Non-Goals

**Goals:**

- Material, amount, display name and custom model data are stored and edited as components, with
  no field left on the item.
- Item flags are gone.
- The interface tells Stelaris' own components from the vanilla ones and knows which are required.

**Non-Goals:**

- vulpes-generator. It needs a hard update of its own that reads all components; until then it
  can't generate items from the new model.
- Lore and enchantments, which keep their tables and dedicated editors, and the item group.
- Checking component values in the backend. Vanilla components aren't checked either.
- A material picker with search. Material is edited through the key field.

## Decisions

### Specs live in the frontend, the category in vulpes_data

```dart
// lib/feature/item/components/stelaris_components.dart
const Set<String> requiredComponents = {'stelaris:material'};

const List<ComponentSpec> stelarisComponents = [
  ComponentSpec('stelaris:material', 'Material', ComponentCategory.custom, 'MATERIAL',
      KeySchema(registry: 'item')),
  ComponentSpec('stelaris:amount', 'Amount', ComponentCategory.custom, 'AMOUNT',
      IntSchema(min: 1, max: 99)),
];

extension StelarisComponentSpec on ComponentSpec {
  bool get isRequired => requiredComponents.contains(key);
}
```

`stelaris:material` and `stelaris:amount` are Stelaris terms, not Minecraft data, so vulpes_data
doesn't describe them. It only gets `ComponentCategory.custom` as its first entry (e414954): an enum
can't be extended from the frontend, and the frontend uses the category as a real enum value for its
sections, menus and sorting. `required` needs no field on `ComponentSpec`; the extension derives it
from the key. `requiredComponents` mirrors `vulpes.item-components.required` of the backend and has
to be kept in step with it.

Alternatives: specs and a `required` field in vulpes_data (puts Stelaris terms into the Minecraft
data package) or no change in vulpes_data at all (a "Custom" section outside the enum would need a
special case wherever the frontend handles categories).

### Keys and rules as configuration in the backend

```yaml
vulpes:
  item-components:
    managed:            # own storage and endpoints, rejected as components
      - minecraft:lore
      - minecraft:enchantments
    custom-namespace: stelaris
    custom:             # other keys in the namespace are rejected
      - stelaris:material
      - stelaris:amount
    required:           # created with every item, can't be removed or renamed
      - key: stelaris:material
        value: '"minecraft:dirt"'
```

`ItemComponentConfiguration` (`@ConfigurationProperties`) and `RequiredComponentConfiguration`
(`@EachProperty`, a list, because Micronaut normalizes map keys and `:` would not survive) read it.
`ItemComponentRules` is created at startup (`@Context`) and checks it: custom keys must be in the
namespace, nothing may be both custom and managed, a required key may not be managed, a required key
in the namespace must be custom, no key twice, and every value must be JSON. A broken configuration
stops the start with a message.

The backend only enforces which keys exist; what a key means lives in its spec in the frontend and,
later, in the generator. So a new Stelaris component needs no backend release, and item creation can
create every required component from its configured value instead of knowing the material.
vulpes-model only stores components and doesn't know any key.

Alternatives: constants in vulpes-model (puts backend rules into the persistence library) or
constants in the backend (every new key needs a backend release).

### Backend rules

- Creating an item adds every required component with its configured value in the same
  transaction.
- `deleteComponent` rejects required components; `deleteAllComponents` keeps them.
- Creating or updating a component with a key in the custom namespace that isn't custom is rejected.
- `updateComponent` rejects changing the key of a required component, which would remove it as well.
- Only `minecraft:lore` and `minecraft:enchantments` are managed; custom name, item name and custom
  model data are plain components now.
- The flag endpoints, DTOs and service methods are removed, and `ItemRelation.FLAGS` with them.
- `ItemRelation.COMPONENTS` copies all components. Required components are copied even without it,
  so a copy always has a material.

### Hard switch

No dual writes and no deprecation phase: without production data, the fields are removed in the
same release that adds the components. Local databases are recreated, or get
`ALTER TABLE ... DROP COLUMN` for the removed item columns and `DROP TABLE item_flags`.

### Frontend

- `componentCatalog = [...stelarisComponents, ...dataComponents]` backs the picker and the lookup by
  key. The picker already hides existing keys, so it offers the amount while it is missing and never
  the material.
- Cards in the `custom` category get a "Custom" badge like the "Default" one. A spec whose
  `isRequired` is true
  card has no remove button.
- The material that decides the default components comes from the loaded `stelaris:material`
  component, `defaultMaterial` while loading.
- `dedicatedComponents` shrinks to `minecraft:lore` and `minecraft:enchantments`, matching the
  backend.
- The General tab drops the Material, Amount, Display Name and Model Data cards and keeps the group.
- The commented-out `ItemFlagFetchAction` is removed.

## Risks / Trade-offs

- **Six repositories released together** → the order in the tasks keeps each step building; the
  frontend's `pubspec.lock` pins vulpes_data and stelaris-model until it upgrades on purpose.
- **vulpes-generator can't generate items** until its own update, since the columns it reads are
  dropped → accepted; the generator needs a hard update anyway.
- **A switch over `ComponentCategory` in the frontend** breaks with the new entry → found by the
  analyzer when vulpes_data is upgraded.
- **Amount max rises from 64 to 99** → matches vanilla and `max_stack_size`.
