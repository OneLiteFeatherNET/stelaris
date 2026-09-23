# Proposal

## Why

The command palette can find and open everything, but creating a model or deleting one still means
finding the Add button on the right list or the delete button on the right card. Those are the two
actions people want most after navigating. This change brings both into the palette. It keeps the
dialogs the app already uses, so creating asks for a name and key as before, and deleting still
requires typing the model's name.

It builds on `add-command-palette-syntax` and `add-command-palette-drilldown`.

## What Changes

- **Create commands**: "New item", "New font", "New sound", "New notification" and "New
  attribute", in a Create section of the default and command modes. Each opens the same create
  dialog as the list's Add button. After a model is created, the palette shows that kind's list,
  unless the user is already on it.
- **Delete from the drill-down**: stepping into an entity (Arrow Right) offers "Delete…" after its
  tabs. Attributes and notifications, which have no tabs, can now be stepped into for this entry
  alone. It opens the same delete dialog as the detail page, with the name confirmation.
- **Delete on a detail page**: "Delete this item…" (and the same for fonts, sounds and
  notifications) while that detail page is open. It behaves exactly like the page's delete button,
  including returning to the list afterwards.
- **Roles**: creating requires `stelaris.editor`, deleting requires `stelaris.admin`, as `Roles`
  documents. Without an identity provider both are offered, as everywhere else.
- **Shared dialogs**: the five lists' create dialogs and the detail page's delete flow move into
  shared functions that both the pages and the palette call. The pages behave as before.
- Not in this change: deleting without the confirmation dialog, deleting several models, and role
  gating for the existing delete buttons outside the palette. Those buttons are currently ungated;
  that is noted, not changed here.

## Capabilities

### New Capabilities

- `command-palette-create-delete`: creating models and deleting entities from the command palette,
  with the existing dialogs and role requirements.

### Modified Capabilities

<!-- None. The open add-command-palette-drilldown change words its Arrow Right requirement in terms
     of "entries without sub-entries" (adjusted in that change), so attributes and notifications
     gaining a "Delete…" sub-entry does not contradict it. -->

## Impact

- **Code**:
  - `lib/feature/model/model_create.dart` and `lib/feature/model/model_delete.dart` hold the shared
    create dialog and delete flow.
  - The five list pages and `ModelDetailActions` call them.
  - `lib/feature/command_palette/` gains the create commands, the delete children and the
    detail-page delete commands.
- **Localization**: command titles, and the Create section heading.
- **Dependencies / backend**: none; the existing add and remove actions are used.
