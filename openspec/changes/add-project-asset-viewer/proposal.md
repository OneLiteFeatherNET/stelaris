# Proposal

Ships as `feat(asset)` on the prototype branch `themeinerlp/poc/project-assets`.

## Why

An item can name its look through the data component `minecraft:item_model`, but in Stelaris that is
a bare text field: the author types a resource location and hopes a model with that name exists
somewhere. The model files themselves (Minecraft model JSON, Blockbench `.bbmodel`, PNG textures)
live outside the tool, on someone's disk, and nobody can see in Stelaris what an item will look like.

The backend prototype (Vulpes-Backend, branch `themeinerlp/poc/project-assets`) now stores such files
per project in its object store as resource pack content; an asset's key is its path in the pack.
Items keep referring to them through their own fields, here `minecraft:item_model`, without a
coupling in the database. Stelaris needs the other half: upload the file where the component is
edited, put its key into the component, and show the model again, as an interactive 3D model that
can be rotated and zoomed, every time the item is opened.

## What Changes

- **Asset API** in the frontend, bound to the backend contract: list, upload and download project
  assets. The contract's link endpoints are being removed and are not used.
- **Model reading**: Minecraft model JSON (cuboid elements, rotations, per-face UVs, texture
  variables) and Blockbench `.bbmodel` (cubes with embedded textures) are turned into one neutral
  description of boxes and faces. Textures referenced by key are resolved against the project's
  texture assets; missing ones show the familiar magenta-black placeholder.
- **Detail levels**: from that description the frontend derives three levels: full detail, a reduced
  level that drops the smallest elements, and a single box in the model's average colour. The viewer
  switches by camera distance; the user can pin a level.
- **3D viewer** on the web build: the model is drawn with three.js, shipped with the app, inside the
  Flutter page. The user rotates and zooms with the mouse, resets the camera and can let the model
  turn on its own. Other platforms show a placeholder.
- **Data component `minecraft:item_model`**: its edit dialog gets an asset button that opens a picker
  with the project's models and an upload. Choosing or uploading a model sets the component value to
  the asset key. The component's card on the Components tab keeps its size and offers a preview
  that opens the model whose key equals the value in 3D.

## Capabilities

### New Capabilities

- `project-assets`: uploading project assets from the item model component, referring to them by
  key, and showing the referenced model again as an interactive 3D preview with detail levels.

### Modified Capabilities

<!-- None. Item components have no main spec yet. -->

## Impact

- **stelaris** (this repository): asset models and API client, model reading and detail levels,
  the web viewer with a vendored three.js 0.186.1 under `web/`, the asset picker and upload, the item
  model component dialog and card, l10n, tests.
- **Vulpes-Backend**: none beyond the prototype branch. The planned removal of asset links (and
  that a texture and a model may share a key) is assumed; the frontend never calls the link
  endpoints.
- No new pub dependency: file picking and the viewer use `package:web` and `dart:js_interop`, which
  the app already has.

Out of scope for the prototype: a project-wide asset library page, Blockbench free-form meshes and
animations, Minecraft `parent` inheritance beyond `item/generated` and `item/handheld`, item model
definitions (`assets/<ns>/items/*.json`) as a separate layer, the resource pack build, and the
desktop renderer.
