# Design

## Context

- **Carried over.** The branch already has, from `themeinerlp/poc/project-assets`:
  - `AssetClientApi` with `getPage(kind, page)`, `upload(key, fileName, bytes)` and `content(id)`;
  - the scene readers (`readMinecraftModel`, `readBlockbenchModel`), `referencedTextureKeys` and the
    detail levels;
  - `AssetLibrary` with `findModelByKey` and `loadScene`, contents cached by sha1;
  - the 3D `AssetPreview` (three.js on the web, placeholder elsewhere);
  - `AssetUploadForm` with drop zone, key suggestion and key checks;
  - the asset picker in the `minecraft:item_model` dialog and the preview on the Components tab.

  Not carried over are `AssetLibraryPage`, `AssetNavigationEntry` and the `/assets/*` routes. They are
  rebuilt here around models.
- **Asset data.** `AssetModel` has `key`, `kind`, `fileName`, `size`, `sha1`, `width`/`height` for
  textures, `sourceAssetId` on textures extracted from a `.bbmodel` and `derivedAssetIds` on the
  `.bbmodel` itself.
- **Items.** Items are in the Redux store per project. Their `minecraft:item_model` value is the
  asset key, as decided in the first prototype.

## Goals / Non-Goals

**Goals:**
- A model and its textures appear as one thing.
- A missing texture is visible and can be uploaded under the right key in one step.
- A flat item model can be made from a PNG alone.
- Reuse the carried-over pieces and keep the diff small.

**Non-Goals:**
- Metadata the user edits, and any backend change.
- Replacing, renaming and deleting assets.
- Textures that no model refers to.
- Sorting several dropped files to their model.

## Decisions

### One page with a grid and a detail, not two pages
`ModelsPage` replaces `AssetLibraryPage(kinds)`. It shows MODEL and BBMODEL assets in `ModelGrid`
with `ModelCardFrame` cards (from `extract-model-grid`), so it reads like the other list pages with no
copied layout. The cards are 132 px high, as they have no notes line. A card shows the name, the key as an `InfoChip`, the missing badge and a
footer with kind and last change. Selecting a model shows its detail in place of the grid with a back
button. The detail uses edit cards under section headings like the other detail pages. The selected id is part of the route
(`/assets/models?id=…`), so a reload keeps the selection.

The sidebar keeps the "Assets" heading of the first prototype with one entry. `AssetNavigationEntry`
becomes `{ models }` so a later entry (e.g. sounds) has its place.

### Texture status is computed in Dart from data the page already has
`ModelTextures` is a pure value built by `modelTextures(model, json, textures)`:
- For MODEL: `referencedTextureKeys(json)` gives the keys. Each key becomes a `TextureSlot` with the
  matching TEXTURE asset or `null`. The slot also lists the other models that refer to the same key.
- For BBMODEL: the textures whose `sourceAssetId` is the model's id, all present, read-only.

The page loads the TEXTURE assets of the project once per open (and again after an upload or when
the tab regains focus, as `AssetLibrary` does for lookups). "Also in" needs the textures of the other
models, so the page reads the JSON of every MODEL in the list. Contents are cached by sha1 in
`AssetLibrary`, so this is one download per model and session. For the prototype's project sizes this
is fine; a backend endpoint for references would replace it later.

### Missing textures are never stored
Whether a texture is missing is not persisted anywhere. It is recomputed from the stored model JSON
and the current texture list whenever the page loads, after an upload and when the tab regains
focus. That way the state survives a restart and cannot go stale when a texture arrives from
elsewhere. The list shows a badge with the number of missing textures per model, from the same
`modelTextures` results the page already computes for "also in", so it costs no extra request.

### Upload of a missing texture uses the referenced key
The slot's upload button opens `AssetUploadForm` limited to `.png`, with the key prefilled and locked
to the slot's key. After the upload the texture index and the preview reload, and the slot turns
present. A rejected upload shows the backend's reason as before.

### Flat item model from a texture
"New from texture" in the page header opens the upload form for a `.png`. It uploads the texture under
the chosen key, then uploads a generated `<name>.json`:

```json
{ "parent": "minecraft:item/generated", "textures": { "layer0": "<key>" } }
```

under the same key. A texture and a model may share a key (prototype contract). If the model upload
fails, the texture stays and the error is shown; the user can retry from the slot.

### Used by
Item components are not in the store: `selectedItemComponents` holds only the open item's. The info
card therefore loads the project's items and their components through `ItemApi` when a model is
opened, one request per item, and `usedBy(key, components)` keeps the items whose
`minecraft:item_model` value equals the key (`itemModelKeyOf` already reads it). The result is
cached per page visit. The card lists the items as links to the item.

### Info card
Kind, file name, size (formatted like elsewhere in the app), last change, used by. The key is the
detail's title with a copy button.

## Risks / Trade-offs

- **Reading every model JSON for "also in".**
  - Risk: slow on projects with many models.
  - Mitigation: contents are cached by sha1; the list itself does not wait for it. Replace with a
    backend reference endpoint when it matters.
- **Two uploads for "new from texture" are not atomic.**
  - Mitigation: the texture alone is harmless, and the model can be created again.
- **Locked key on the slot upload.**
  - A user who wants a different key has to change the model JSON. That is intended: the model decides
    the key.

- **One request per item for "used by".**
  - Risk: slow on projects with many items.
  - Mitigation: loaded lazily in the info card, the rest of the detail does not wait. A backend query
    by component value would replace it.

## Open Questions

- Editable metadata needs fields on the asset in Vulpes. Left out until the user asks for it.
- Where textures without a model go (a filter "unused textures" on this page is the current idea).
