# Proposal

## Why

Most of the detail pages already edit through "click, then a dialog": item components, enchantments,
lore lines, attributes and projects. Three pages still edit inline, in input cards: the General tabs
of fonts and sounds, and the notification page. These are the only users of `TextInputCard`,
`DropdownCard` and `BaseCard`, and of the form registry that the header's save button validates.

Moving the three pages to the dialog pattern gives the app one way of editing, and the card widgets
and the form registry can go.

## What Changes

- **Each field is a card that shows its value.** Clicking it opens a small dialog for just that
  field, the way a component card opens its dialog.
- **A dialog only stages the change.** "Save" in the dialog updates the page's model in the store
  and marks it unsaved. The header's save button still persists the model, and leaving with
  unsaved changes still asks first.
- **Pages describe their fields as data**: a list of text and choice properties, each with its
  label, value, rules and what to do on a change. A shared grid builds the cards and dialogs from
  that list. The pages keep reading their model and dispatching their own update actions.
- **Every field keeps its rules**: input formatters, validators, required fields, hint texts,
  help texts and the 30-character limit text inputs have today. A dialog doesn't accept an invalid
  value, so no invalid value reaches the store.
- **Removed**: `TextInputCard`, `DropdownCard`, `BaseCard`, the form registry (`DetailForms`,
  `RegisterDetailForm`) and the header save's check of registered forms.

## Capabilities

### New Capabilities

- `property-editing`: how a detail page shows its plain fields as cards and edits each one in a
  dialog, and that the change waits for the header's save.

### Modified Capabilities

<!-- None. -->

## Impact

- **Code**:
  - New in `lib/feature/base/property/`: the property descriptions, `PropertyGrid`,
    `PropertyCard` and the text and choice dialogs.
  - Rewritten: `font_general_page.dart`, `sound_general_page.dart` and
    `notification_page_general.dart`.
  - `unsaved_changes_guard.dart` drops the `DetailForms.validateAll()` call.
  - Deleted: `base_card.dart`, `cards/text_input_card.dart`, `cards/dropdown_card.dart` and
    `unsaved/detail_forms.dart`.
- **Tests**:
  - New tests for the shared property widgets.
  - The font, sound and notification detail page tests edit through the dialogs.
  - `text_input_card_test.dart` and `text_input_card_focus_test.dart` go with the card.
- **No change** to the models, the actions, the API or the routes.
