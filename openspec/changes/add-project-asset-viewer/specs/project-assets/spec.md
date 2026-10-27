# Spec Delta

## Purpose

Lets an author upload model and texture files for an item where its look is edited, refer to them
from the item by key, and see them again as an interactive 3D preview.

## ADDED Requirements

### Requirement: Upload an asset from the item model component

The item model component's edit dialog SHALL offer to upload a file of type `.png`, `.json` or
`.bbmodel` under a key the user can edit. The key SHALL be suggested from the file name. A rejected
upload SHALL show the backend's reason at the field it names and keep the dialog open.

#### Scenario: Upload a Blockbench model

- **WHEN** the user picks `ruby.bbmodel` in the asset picker and confirms the suggested key
- **THEN** the asset is stored in the project and offered in the picker

#### Scenario: Key already taken

- **WHEN** the user uploads a file under a key the project already uses
- **THEN** the dialog stays open and says that the key is taken

### Requirement: Choose a model for the item

The asset picker SHALL list the project's models (Minecraft model JSON and Blockbench models).
Choosing one SHALL set the item model component to the asset key. The item SHALL refer to the model
only through that value.

#### Scenario: Choose a model

- **WHEN** the user chooses the model `vulpes:item/ruby` and saves the component
- **THEN** the component value is `vulpes:item/ruby`

#### Scenario: Upload and choose

- **WHEN** the user uploads a model in the picker
- **THEN** the new model is chosen and its key is put into the component value

### Requirement: Show the referenced model again

The components tab SHALL offer a preview, like the lore preview: shown next to the cards where there is
room and toggled from the tab header, otherwise opened as a bottom sheet. It SHALL show in 3D the
project model whose key equals the item model value. A texture with the same key SHALL NOT count.
The item model card SHALL keep the size of the other cards and show its value as text.

#### Scenario: Reopen the item

- **WHEN** the user opens a wide components tab of an item whose item model value is the key of a project model
- **THEN** the model is shown in 3D next to the cards

#### Scenario: Hide the preview

- **WHEN** the user toggles the preview in the tab header
- **THEN** the preview hides and the cards take the full width

#### Scenario: Narrow window

- **WHEN** the components tab is too narrow for the preview and the user presses the preview action
- **THEN** the preview opens as a bottom sheet

#### Scenario: Cards stay aligned

- **WHEN** the components tab shows the item model card next to other components
- **THEN** all cards have the same size

#### Scenario: No such model

- **WHEN** the item model value names no model of the project
- **THEN** the card shows the value as text and the preview action is disabled

### Requirement: Browse assets from the sidebar

The sidebar SHALL show, separated from the existing sections, a group headed "Assets" with the
entries Models and Textures. The heading SHALL stay visible when the sidebar is collapsed and SHALL
NOT be selectable. Each entry SHALL open a page listing the project's assets of that kind (Models:
Minecraft model JSON and Blockbench models; Textures: PNG textures), offering an upload and a
preview of the selected asset.

#### Scenario: Open the models page

- **WHEN** the user selects Models in the Assets group
- **THEN** the project's models are listed and the Models entry is highlighted

#### Scenario: Preview a texture

- **WHEN** the user selects a texture on the textures page
- **THEN** the texture is shown pixel-sharp in the preview

#### Scenario: Upload from the page

- **WHEN** the user uploads a file on the models page
- **THEN** the new model appears in the list and is selected

#### Scenario: Collapsed sidebar

- **WHEN** the sidebar is collapsed
- **THEN** the "Assets" heading is still shown above the asset entries

### Requirement: Rotate and zoom the preview

The 3D preview SHALL let the user rotate the model by dragging, zoom with the wheel, reset the view,
and switch an automatic rotation on and off. Textures SHALL be drawn pixel-sharp.

#### Scenario: Rotate

- **WHEN** the user drags across the preview
- **THEN** the model turns with the pointer and the page does not scroll

### Requirement: Detail levels

The preview SHALL hold three detail levels: full, reduced (without the smallest elements) and a
single box in the model's average colour. It SHALL pick the level by distance unless the user pins
one.

#### Scenario: Zoom out

- **WHEN** the user zooms far out on a model with many elements
- **THEN** the preview draws fewer elements

#### Scenario: Pin a level

- **WHEN** the user pins the reduced level and zooms in
- **THEN** the preview keeps the reduced level

### Requirement: Read Minecraft and Blockbench models

The preview SHALL draw cuboid elements of Minecraft model JSON and cubes of Blockbench models with
their rotation, UVs and textures. Textures of a Minecraft model SHALL be found among the project's
textures by key. A texture that cannot be found SHALL be drawn as a magenta-black checker. Parts the
preview cannot draw SHALL be named under the preview.

#### Scenario: Missing texture

- **WHEN** a model refers to a texture key the project does not have
- **THEN** the affected faces show the magenta-black checker

#### Scenario: Flat item model

- **WHEN** a model has the parent `item/generated` and a texture `layer0`
- **THEN** the preview shows that texture as a flat item

#### Scenario: Blockbench mesh

- **WHEN** a Blockbench model contains free-form mesh elements
- **THEN** the cubes are drawn and the preview says that meshes are not shown

### Requirement: Preview outside the web build

On platforms without the web viewer the preview SHALL show a placeholder naming the asset instead of
failing.

#### Scenario: Desktop build

- **WHEN** the item model preview is opened on a non-web platform
- **THEN** a placeholder with the asset key is shown
