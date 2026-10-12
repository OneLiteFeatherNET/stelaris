# Proposal

## Why

Most detail pages already edit through "click a card, change it in a dialog". The item components,
enchantments, lore lines, attributes and projects work that way. Three pages still edit inline in
input cards, the General tabs of fonts and sounds and the advancement page. They are the last users
of `TextInputCard`, `DropdownCard`, `BaseCard` and the form registry behind the header's save.

A first attempt (`replace-input-cards-with-dialogs` on `feature/propertyDialogs`) turned every
field into a card shaped like a model card. It worked, but it looked off, for two reasons.

- A model card carries a lot (name, key, notes, a "last edited" footer and a menu). A field has a
  label and one short value. In the same frame and at a fixed minimum height, most of the card was
  empty.
- The label was the big, bold text and the value the small one, the reverse of what matters.

The cards also don't tell their roles apart today. The component card copies the model card on
purpose, so a card that opens a page and a card that opens a dialog look the same.

## What Changes

- **Two families of cards, by what a click does.**
  - *Navigation cards* open a page. That is the model card, which stays as it is.
  - *Edit cards* open a dialog that changes a value. That is the new field card and the component
    card, which follows it. They share one look that differs from the model card.
  - The lore line stays a reorderable list and is not part of either family.
- **A field card puts the value first.** The value is the large text and the label a small one
  above it. An icon shows the kind of field, and a footer shows its rule or hint. The card is as
  high as its content.
- **Text components show their formatting.** Title and description of an advancement span the
  full width and show the text the way it looks in game. Their dialog is the MiniMessage editor.
- **Fields are grouped** under section headings, so a page doesn't turn into a wall of equal cards.
- **A dialog only stages the change**, like on the first attempt. Saving in the dialog updates the
  model in the store and marks it unsaved. The header's save button persists it, and leaving with
  unsaved changes still asks first.
- **Every field keeps its rules**, its formatters, validators, hints, help texts, limits and the
  material suggestions. A dialog doesn't accept an invalid value, so no invalid value reaches the
  store.
- **Removed** are `TextInputCard`, `DropdownCard`, `BaseCard`, the form registry (`DetailForms`,
  `RegisterDetailForm`) and the header save's check of registered forms.

## Capabilities

### New Capabilities

- `edit-cards`: the two card families, how a detail page shows its fields as edit cards, and how
  each one is changed in a dialog.

### Modified Capabilities

<!-- None. -->

## Impact

- **Code**
  - New in `lib/feature/base/edit_card/`: the edit card, the field descriptions, the grouped grid
    and the dialogs for text, number, choice, material and text component fields.
  - The component card in `item_components_page.dart` moves to the edit card.
  - Rewritten: `font_general_page.dart`, `sound_general_page.dart` and
    `advancement_page_general.dart`.
  - `unsaved_changes_guard.dart` drops the `DetailForms.validateAll()` call.
  - Deleted: `base_card.dart`, `cards/text_input_card.dart`, `cards/dropdown_card.dart` and
    `unsaved/detail_forms.dart`.
- **Tests**: new tests for the edit card, the grid and every dialog. The font, sound and
  advancement page tests edit through the dialogs. The tests of the removed cards go with them.
- **No change** to the models, the actions, the API or the routes.
- **Supersedes** `replace-input-cards-with-dialogs`. Its property dialogs are a starting point, its
  card design is not.
