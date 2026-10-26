# Tasks

Prototype branch `themeinerlp/poc/project-assets` in stelaris, committed locally only. Commits are
conventional one-liners under `feat(asset)` (vendoring three.js under `build(web)`), without
attribution, with a minimal diff. Unit tests follow F.I.R.S.T.: no real network and no wall-clock waits.

## Review focus

Inputs the spec implies but doesn't spell out, each pinned by a test in the task that owns the code:

- A `.bbmodel` UV is in `resolution` pixels while Minecraft JSON uses 0..16 (2.2).
- `#var` texture chains (`#all` → `#side` → key) and keys without a namespace (2.1).
- A texture and a model with the same key: the preview shows the model, never the texture (4.2).
- The reduced level never ends up empty (2.3).

## 1. Contract

- [x] 1.1 Add `AssetModel` and `AssetKind` with JSON mapping per the contract (no link types; the
  links are being removed). Verify with a unit test that decodes a contract sample, including
  `derivedAssetIds` and nullable `width`/`height`.
- [x] 1.2 Add `AssetClientApi` with `getPage(kind, page)`, `upload(key, name, bytes)` as multipart
  and `content(id)` as bytes. A 400 or 409 surfaces as the existing `ProblemDetail`. Register it in
  `ApiService`. Verify with `RecordingHttpClientAdapter` tests for paths, multipart fields, the `kind`
  query parameter and error mapping.

## 2. Model reading and detail levels (pure Dart)

- [x] 2.1 Add `AssetScene` and `readMinecraftModel(json, textureLookup)`. It resolves `#var` chains
  and defaults the namespace, uses `item/generated|handheld` as a flat box with `layer0`, sets missing
  textures to `null` slots, and reports other parents. Verify with unit tests per case.
- [x] 2.2 Add `readBlockbenchModel(json)`. It handles cubes with origin/rotation, faces with UV
  scaled from `resolution` to 0..16, embedded texture data URIs, and skipped meshes that are
  reported. Verify with unit tests from a small hand-written `.bbmodel`.
- [x] 2.3 Add `detailLevels(scene)` with full, reduced (below 2 % of the largest volume dropped,
  never empty) and bounding box with `averageColor`. Verify with unit tests.

## 3. Web viewer

- [x] 3.1 Vendor three.js 0.186.1 (`three.module.min.js`, `OrbitControls.js`, license) under
  `web/vendor/three/`, and add an import map and the `asset_viewer.js` module script to
  `web/index.html`. Verify that `flutter build web --release` copies the files.
- [x] 3.2 Write `web/asset_viewer.js`:
  - `mount(element, scene)` builds merged geometry per texture and level, `THREE.LOD` at 0, 1.5 and 3 times the framing distance,
    `OrbitControls` with damping, a checker texture for `null` slots, the average colour for the box
    level, `NearestFilter`, a `ResizeObserver`, `touch-action: none` and wheel `stopPropagation`;
  - the handle exposes `setDetail`, `setAutoRotate`, `resetView` and `dispose`.

  Verify by hand in the browser in 5.1.
- [x] 3.3 Add the Dart `AssetPreview` widget. On the web it uses `HtmlElementView.fromTagName` with a
  `dart:js_interop` binding, mounts on creation and disposes with the widget. It has controls for
  reset, auto-rotate and pinning the level, and a line naming unsupported parts. Elsewhere a
  conditional import gives a placeholder with the asset key. Verify with a widget test of the
  placeholder and of the controls' state (the platform view itself is checked in 5.1).

## 4. Item model component

- [x] 4.1 Add `pickAssetFile()` (web: hidden file input; elsewhere `null`) and the asset picker
  dialog. The dialog lists MODEL and BBMODEL assets with a preview of the selection, and offers an
  upload with a suggested key that stays open on a rejected upload and shows the message at `key` or
  `file`. Add l10n keys. Verify with widget tests using `FakeHttpClientAdapter`: list, choose, upload
  success and key conflict.
- [x] 4.2 Add `findModelByKey(projectId, key)` with a per-session cache of lookups and contents
  (MODEL and BBMODEL only, exact key). Verify with tests against a fake adapter: found on a later
  page, not found, a texture with the same key ignored, and a second call served from the cache.
- [x] 4.3 Wire it into the components UI:
  - the `minecraft:item_model` edit dialog gets the asset button next to the key field, and the
    chosen key goes into the value;
  - its card shows `AssetPreview` when `findModelByKey` finds the value, and text otherwise.

  Verify with widget tests on `item_components_page`. Keep the generic schema widgets unchanged.
- [x] ~~4.4 Review feedback: the item model card keeps the size of the other cards (the grid as on
  develop) and shows its value as text; when `findModelByKey` finds the value, a preview button
  opens the model in a dialog. Verify with widget tests: same card height as other cards, button only
  for a found model (not for a texture with the same key), button opens the 3D preview.~~ replaced by 4.5
- [ ] 4.5 Review feedback: preview like the lore preview. Remove the card button and dialog of 4.4
  (cards as on develop). The components tab header gets a preview toggle; at >= 840 px the 3D preview
  of the item model slides in next to the grid with the lore preview's title row and surface, below
  that the toggle opens it as a bottom sheet; disabled while no model is found. Verify with widget
  tests: panel shown when wide and a model is found, toggle hides it, narrow opens a bottom sheet,
  toggle disabled without a model or with only a texture of that key, card heights unchanged.

## 5. Integration check

- [x] 5.1 Run Vulpes-Backend `themeinerlp/poc/project-assets` locally together with the release web build.
  - Upload a Minecraft model JSON plus its texture, and a `.bbmodel`.
  - Choose each one for an item and reopen the item.
  - Rotate, zoom, reset and auto-rotate, then pin each level.
  - Confirm the page does not scroll while dragging or zooming.
  - Record the result with a screenshot.
- [x] 5.2 Run `flutter analyze` and the full `flutter test`, and check that both pass.

## Workflow follow-up

- No push or pull request until the user asks; then open it under `feat(asset): upload project
  assets and preview item models in 3d`.
