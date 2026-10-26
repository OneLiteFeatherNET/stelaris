# Design

## Context

- **Backend contract.** The API is described in the Vulpes-Backend prototype contract and exposed under
  `project/{projectId}/asset`. It has these endpoints:
  - multipart upload with `file` and `key`, returning 201 `AssetResponseDTO`;
  - paged list with an optional `kind`;
  - `GET {id}/content` with an ETag;
  - `POST {id}/content` to replace the file;
  - delete, in the same forms as sound;
  - `POST {id}/link` with `{targetType, targetId, role}`;
  - `GET link?targetType=&targetId=`, returning links with the asset embedded;
  - `DELETE link/{linkId}`.

  The backend has announced that the link endpoints go away: assets are resource pack content,
  referenced by key from the models' own fields, and a texture and a model may share a key. The
  frontend does not use the link endpoints.

  Errors are ProblemDetail: 400 `VALIDATION_FAILED` with violations on `file`/`key`/`role`, plus 409 and 404.
  Kinds are `TEXTURE`, `MODEL` and `BBMODEL`. A `.bbmodel` upload also creates its embedded textures as `TEXTURE` assets.
- **Components dialog.** Item data components are edited through `showComponentEditDialog` (`component_dialogs.dart`).
  Books already get their own editor through `_isBook`. `minecraft:item_model` is a `KeySchema()` without a registry,
  shown by `_KeyField`, which already accepts a `suffix` widget.
- **API layer.** The API layer uses dio through `ApiClient`, the client pattern of `sound_client_api.dart`, and
  `ResponseType.bytes` as in `generate_api.dart`. There is no multipart and no file picker yet.
- **Web interop.** `package:web` is a dependency and is used through conditional imports (`download_helper*.dart`).
- **Tests.** Tests swap `dio.httpClientAdapter` with `FakeHttpClientAdapter` / `RecordingHttpClientAdapter` from `test/support/`.

## Goals / Non-Goals

**Goals:**
- Bind the contract.
- Upload and choose a model where `minecraft:item_model` is edited.
- Refer to the model by key, and show it again in 3D with rotation, zoom and three detail levels.
- Keep the diff small, and add no new pub dependency.

**Non-Goals:**
- An asset library page.
- Blockbench meshes and animations.
- General `parent` resolution.
- Item model definitions.
- The resource pack build.
- A desktop renderer.

## Decisions

### Renderer: three.js through a small JS bridge, not a Dart port
Three.js 0.186.1 (`three.module.min.js` plus `addons/controls/OrbitControls.js`) is vendored under
`web/vendor/three/` and imported through an import map in `web/index.html`.

`web/asset_viewer.js` is an ES module. It sets `window.stelarisAssetViewer` to
`{ mount(element, scene) -> handle }`, and the handle has `setDetail(level|null)`, `setAutoRotate(bool)`,
`resetView()` and `dispose()`.

Dart talks to it through `dart:js_interop` extension types and puts the viewer in an
`HtmlElementView.fromTagName('div')`.

Alternatives considered:
- `three_js` (Knightro63) and `flutter_scene` work on the web, but neither documents LOD, and both lag upstream.
- `model_viewer_plus` reads glTF only.
- `flutter_cube` and `flutter_gl` are unmaintained.

Vendoring instead of a CDN keeps the app working offline and pins the version.

### The model is read in Dart; JS only draws
`AssetScene` is a plain Dart value. It holds:
- texture slots as `{id, url-or-bytes as data URI, width, height}`;
- boxes as `{from, to, rotation {origin, axis, angle, rescale}, faces {dir: {uv, textureSlot | null}}}`, in Minecraft
  units (0..16);
- a list of unsupported parts.

Parsers are pure functions: `readMinecraftModel(json, textureLookup)` and `readBlockbenchModel(json)`. Reading in Dart
means the format logic is covered by fast unit tests, while the JS stays a thin, untested-by-unit drawing layer that the
browser check covers.

### Blockbench input
- Cubes use `from`, `to`, `origin` and `rotation` (Euler degrees, any axis), and `faces.{dir}.uv` / `texture` (an index
  into `textures`).
- The UV space is `resolution.width/height`; Minecraft JSON uses 0..16.
- Embedded `textures[].source` data URIs are used directly.
- Elements with `type: "mesh"` are skipped and reported.

### Minecraft model input
- `elements` and `textures` with `#var` references are resolved inside the model.
- Keys without a namespace get `minecraft:`.
- A key is looked up among the project's `TEXTURE` assets. Its content is downloaded once per sha1 and cached in memory
  for the session.
- `parent: item/generated|handheld` (with or without the `minecraft:` prefix) and no `elements` becomes one flat box
  0..16 × 0..16 × 7.5..8.5, textured with `layer0` on north and south.
- Other parents are reported as unsupported.
- A missing texture becomes slot `null`, which the bridge draws as a 2×2 magenta and black checker.

### Detail levels are computed in Dart
`detailLevels(scene)` returns three scenes:
- **Full.**
- **Reduced.** Boxes whose volume is below 2 % of the largest box are dropped. If that leaves no boxes, the largest one is
  kept.
- **Box.** One box over the bounds of all boxes. Its faces carry the average colour, which the bridge computes from the
  texture pixels. The Dart side marks the face as `averageColor: true`.

The bridge builds a `THREE.LOD` with the levels at distances 0, 48 and 96 units. When the user pins a level, the LOD is
replaced by that one level. Unit tests check the level selection.

### Drawing details (bridge)
- One `BoxGeometry`-like `BufferGeometry` per box, with UVs per face.
- Faces are grouped per texture into merged geometries per level, so there is one draw call per texture and level.
- `MeshLambertMaterial` with `NearestFilter`, `SRGBColorSpace`, `alphaTest 0.1` and `side: DoubleSide` for flat items.
- `OrbitControls` with damping and `autoRotate`.
- The camera frames the bounds.
- `ResizeObserver` keeps the renderer at the element size.
- The canvas has `touch-action: none` and stops wheel propagation, so the page does not scroll.
- `dispose()` frees geometries, textures, the renderer and the observer.
- Each preview has its own WebGL context. The dialog and the card are the only ones on screen, which stays well under the
  browser limit.

### File picking and upload
- A conditional import provides `pickAssetFile()`.
  - On the web: a hidden `<input type=file accept=".png,.json,.bbmodel">` returns `(name, bytes)`.
  - Elsewhere: `null`.
- Upload is `dio` `FormData` with `MultipartFile.fromBytes(bytes, filename)` and the field `key`.
- The key is suggested as `<project namespace or "minecraft">:item/<sanitised file name without extension>`.
  - Sanitising lowercases the name and replaces characters outside `[a-z0-9_.-]` with `_`.
  - The namespace comes from the project if it has one, otherwise `minecraft`. This is checked during apply.

### State and wiring
- No link state and no new global state.
  - The picker loads its asset list (kinds MODEL and BBMODEL) itself through the API and does not keep it in the store.
- Choosing or uploading a model returns the asset to the dialog.
  - The dialog puts its key into the value field. Saving is the existing component update.
- The card for `minecraft:item_model` on the Components tab resolves its value with `findModelByKey(projectId, key)`.
  - It pages through MODEL and BBMODEL assets and matches the key exactly. A TEXTURE with the same key is ignored.
  - When found it renders `AssetPreview`, otherwise it keeps today's text.
  - Lookups and downloaded contents are cached per session by key and sha1, so reopening an item does not refetch.
  - A key lookup endpoint in the backend would replace the paging later.
  - It reaches the card through the existing per-key special case point, next to `_isBook`, and does not touch the generic
    schema widgets.

## Risks / Trade-offs

- **Platform views and pointer events in Flutter web.**
  - Risk: a drag inside the canvas could leak to Flutter's scroll.
  - Mitigation: `touch-action: none`, `stopPropagation` on wheel, and a browser check in the final task.
- **WebGL context limit (about 16).**
  - Risk: many cards would open many contexts.
  - Mitigation: only the item model card and the picker preview draw. A list of thumbnails is out of scope.
- **Vendored JS is outside `flutter analyze` and the unit tests.**
  - Mitigation: keep the bridge under about 300 lines, and verify it in the browser.
- **`item_model` meaning.**
  - In Minecraft 1.21.4 and later, `item_model` names an item model definition, not a model file.
  - For the prototype, the value equals the asset key. A real resource pack build would add the definition file.
    This is noted for later.

## Open Questions

None that change what is built. The namespace default is checked during apply, as described under file picking.
