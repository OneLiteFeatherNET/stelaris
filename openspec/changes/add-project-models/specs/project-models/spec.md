# Spec Delta

## Purpose

Lets an author manage a model and its textures as one thing: see which textures a model needs, upload
missing ones under the right key, and create a flat item model from a texture alone.

## ADDED Requirements

### Requirement: Models page

The sidebar SHALL show, below the existing sections, the heading "Assets" with the entry Models. The
heading SHALL stay visible when the sidebar is collapsed and SHALL NOT be selectable. The Models page
SHALL show the project's Minecraft model JSON and Blockbench models as a grid of cards like the other
list pages. Selecting a model SHALL show its detail in place of the grid, with a way back.

#### Scenario: Open a model

- **WHEN** the user selects `vulpes:item/ruby` in the grid
- **THEN** its detail replaces the grid, a back action returns to it, and the selection survives a
  reload

#### Scenario: Narrow window

- **WHEN** the window is too narrow for two cards side by side
- **THEN** the grid shows the cards in one column

#### Scenario: Upload a model

- **WHEN** the user uploads a `.json` or `.bbmodel` file on the page
- **THEN** the new model appears in the list and is selected

### Requirement: Model detail

The detail SHALL show the model's key as its title, the 3D preview, and the kind, file name, size and
last change. It SHALL list the project's items whose item model value equals the key, each opening
that item.

#### Scenario: Used by an item

- **WHEN** the item `Ruby` has the item model value `vulpes:item/ruby` and the user opens that model
- **THEN** the detail lists `Ruby` under used by, and selecting it opens the item

### Requirement: Textures of a model

For a Minecraft model JSON, the detail SHALL list every texture key the model refers to, once each,
marked as present when the project has a texture with that key and as missing otherwise. A texture
also referred to by other models SHALL name them. For a Blockbench model, the detail SHALL list the
textures embedded in it, without upload.

#### Scenario: Missing texture

- **WHEN** a model refers to `vulpes:item/ruby_glow` and the project has no such texture
- **THEN** that texture is listed as missing with an upload action

#### Scenario: Shared texture

- **WHEN** the models `ruby` and `sword` both refer to `vulpes:block/gem`
- **THEN** the texture is listed in `ruby` with "also in: sword", and not with `ruby` itself

#### Scenario: Blockbench model

- **WHEN** the user opens a `.bbmodel`
- **THEN** its embedded textures are listed as present and offer no upload

### Requirement: Incomplete models in the list

The list SHALL mark every Minecraft model JSON that refers to missing textures with the number of
missing textures. The mark SHALL be computed from the stored model and the project's textures each
time the page loads, so it is shown again after a restart and disappears once the textures exist.

#### Scenario: After a restart

- **WHEN** the model `vulpes:item/ruby` refers to two textures the project lacks and the user opens
  the Models page in a new session
- **THEN** the list shows `vulpes:item/ruby` with the mark "2 missing"

#### Scenario: Texture added elsewhere

- **WHEN** a missing texture of a model is uploaded from another tab and the page regains focus
- **THEN** the mark counts one texture less, or disappears when none are missing

### Requirement: Upload a missing texture under the referenced key

The upload of a missing texture SHALL accept only `.png` files and SHALL use the referenced key, which
the user cannot change there. After a successful upload the texture SHALL be listed as present and the
preview SHALL show it. A rejected upload SHALL show the backend's reason and keep the form open.

#### Scenario: Fix a missing texture

- **WHEN** the user uploads `glow.png` at the missing texture `vulpes:item/ruby_glow`
- **THEN** it is stored under `vulpes:item/ruby_glow`, listed as present, and drawn in the preview

### Requirement: Create a flat item model from a texture

The page SHALL offer to create a model from a `.png`. It SHALL store the texture under the chosen key
and a model JSON with the parent `minecraft:item/generated` whose `layer0` is that key, under the same
key, and select the new model. If the model cannot be stored, the texture SHALL stay and the error
SHALL be shown.

#### Scenario: New from texture

- **WHEN** the user creates a model from `sapphire.png` with the key `vulpes:item/sapphire`
- **THEN** the model `vulpes:item/sapphire` is listed and selected, and the preview shows the texture as a flat item
