# Proposal

Ships as `feat(asset)` on the prototype branch `poc/project-models`, which carries over the
foundation of `themeinerlp/poc/project-assets` (asset API, model reading, 3D preview, upload form,
item model picker) and replaces its asset pages.

## Why

The first prototype added two sidebar pages, Models and Textures, each with its own upload. Walking
through it as a user showed that the split is not the real problem. The hard part is that the user has
to know which files belong together and what their keys must be. A Minecraft model JSON names its
textures by key under `textures`, but a PNG uploaded on the Textures page gets a key suggested from
its file name, which matches only by chance. A wrong key shows up later as a magenta-black face
without saying why, and a PNG dropped on the Models page leads to a dead end.

Users think of "my ruby model" as one thing, and the PNGs belong to it. The rest of the app already
works as a list with a detail page. The link from a model to its textures is already in the data:
`referencedTextureKeys` reads it from a model JSON, and a `.bbmodel` brings its textures along, listed
in the asset's `derivedAssetIds`. The backend needs no grouping for this.

## What Changes

- **One Models page** replaces the Models and Textures pages. The sidebar keeps the "Assets" heading
  with a single entry, Models.
- **List and detail.** The page lists the project's models (Minecraft JSON and Blockbench). Selecting
  one shows its detail: the 3D preview, a general info card and the model's textures.
- **General info** is derived from what the backend already returns: kind, file name, size, last
  change and which items use the model through `minecraft:item_model`. No editable metadata.
- **Textures of a model.** A Minecraft model lists every texture key it refers to, each marked as
  present or missing. A missing texture has an upload right next to it whose key is fixed to the
  referenced key. A texture used by other models names them ("also in: …"). A `.bbmodel` lists its
  embedded textures read-only.
- **Create a model from a texture.** For flat items the user often has only a PNG. The page offers to
  upload a PNG and creates the model JSON (`parent: minecraft:item/generated`, `layer0` = the texture
  key) under the same key, so no hand-written JSON is needed.
- **Upload on the page** takes a `.json` or `.bbmodel` as before. After a model JSON upload, the
  missing textures are visible at once in its detail.

## Capabilities

### New Capabilities

- `project-models`: a Models page that treats a model and its textures as one thing, shows which
  textures are missing and lets the user upload them under the right key, and creates flat item models
  from a texture.

### Modified Capabilities

<!-- None. `project-assets` from the first prototype was never archived into a main spec; the
     sidebar requirement of that change is replaced here. -->

## Impact

- **stelaris** (this repository): the Models page with list and detail, the texture status of a
  model, the generated flat item model, the sidebar entry and route, l10n, tests.
- **Vulpes-Backend**: none. Upload, list and content of the prototype contract are enough. A
  generated model JSON is uploaded like any other file.
- No new pub dependency.

Out of scope for the prototype: editable metadata (display name, description, tags), replacing,
renaming or deleting assets, a place for textures no model refers to, multi-file drops that sort
PNGs to a model by name, and `parent` inheritance beyond `item/generated` and `item/handheld`.
