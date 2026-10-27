# Tasks

Prototype branch `poc/project-models` in stelaris, committed locally only. Commits are
conventional one-liners under `feat(asset)`, without attribution, with a minimal diff. Unit tests
follow F.I.R.S.T.: no real network and no wall-clock waits.

## Review focus

Inputs the spec implies but doesn't spell out, each pinned by a test in the task that owns the code:

- A model that refers to the same texture key twice (`#all` and `#side` → one key) lists it once (1.1).
- A texture key without a namespace is matched as `minecraft:` (1.1).
- A texture and a model with the same key: the texture counts as the model's texture, the model is not
  listed as a texture (1.1).
- "Also in" never names the selected model itself (1.1).

## 0. Carried over

- [x] 0.1 Asset API, scene reading, detail levels, loading, 3D preview, upload form and the item model
  picker from `themeinerlp/poc/project-assets`, one commit each, with only the l10n strings their
  code uses.

## 1. Texture status (pure Dart)

- [x] 1.1 Add `ModelTextures`/`TextureSlot` and `modelTextures(model, json, textures, otherModels)`.
  MODEL: one slot per referenced key with the TEXTURE asset or null, plus the other models using the
  key. BBMODEL: the textures whose `sourceAssetId` is the model, read-only. Verify with unit tests per
  case and the review focus above.
- [x] 1.2 Add `usedBy(key, components)` over the items' components, and a loader that reads all
  items of the project with their components through `ItemApi`. Verify with unit tests: match, no
  match, an item without the component.

## 2. Models page

- [x] 2.1 Add `ModelsPage` with the list of MODEL and BBMODEL assets and the selection in the route
  (`?id=`). Wide: list and detail side by side; narrow: detail as a full view with back. Upload of
  `.json`/`.bbmodel` in the header selects the new model. Models with missing textures carry a badge
  with their number, recomputed on load and when the tab regains focus. Verify with widget tests
  using the fake asset API: list, select, narrow back, upload selects, badge count, no badge when
  complete.
- [x] 2.2 Add the detail: title with key and copy, 3D preview, info card (kind, file, size, last
  change, used by with links) and the texture list from 1.1. Verify with widget tests: present and
  missing slots, "also in", `.bbmodel` read-only, used by.
- [x] 2.3 Slot upload: `.png` only, key locked to the slot. On success the slot turns present and the
  preview reloads. Verify with widget tests: key locked, success, rejected upload.
- [ ] 2.4 "New from texture": upload PNG, then the generated `item/generated` JSON under the same key;
  the new model is selected. Verify with tests: both uploads with the right key and JSON, model
  upload fails and the texture stays.

## 3. Sidebar and route

- [ ] 3.1 Add `AssetNavigationEntry { models }`, the "Assets" heading (disabled, visible collapsed and
  extended) and the route `/assets/models`. Verify with widget tests: heading not selectable, entry
  highlighted on its route, existing entries keep their indices.

## 4. Integration check

- [ ] 4.1 Against Vulpes-Backend `themeinerlp/poc/project-assets` with the release web build: upload a
  model JSON without textures, upload the missing ones from the slots, create a model from a PNG,
  open a `.bbmodel`, follow a "used by" link. Light and dark, wide and narrow. Record a screenshot.
- [ ] 4.2 Run `flutter analyze` and the full `flutter test`, and check that both pass.

## Workflow follow-up

- No push or pull request until the user asks.
