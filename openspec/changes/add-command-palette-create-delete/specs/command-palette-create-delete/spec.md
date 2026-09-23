# Spec Delta

## Purpose

Lets people create a model and delete an entity from the command palette through the same dialogs,
confirmations and role requirements as the rest of the interface.

## ADDED Requirements

### Requirement: Models can be created from the palette

The system SHALL offer one create command per model kind (items, fonts, sounds, notifications and
attributes) under a Create heading in the default and command modes. Each SHALL open the same
create dialog as that kind's Add button. When a model has been created, the system SHALL show that
kind's list page, unless the user is already on it. Cancelling the dialog SHALL change nothing.

#### Scenario: Create an item from another page

- **WHEN** the user is on the Fonts page, runs "New item", and submits a name and key
- **THEN** the item is added and the Items list page is shown

#### Scenario: Cancel creating

- **WHEN** the user runs "New font" and cancels the dialog
- **THEN** nothing is added and the page is unchanged

### Requirement: Entities can be deleted from the drill-down

The system SHALL offer "Delete…" as the last entry when the user steps into an item, font, sound,
notification or attribute. Entities without tabs SHALL be steppable for this entry. Choosing it
SHALL open the same delete dialog as the detail page's delete button, including typing the name to
confirm. The entity SHALL be deleted only after that confirmation.

#### Scenario: Delete an attribute

- **WHEN** the user steps into "Max Mana", chooses "Delete…" and confirms by typing its name
- **THEN** "Max Mana" is deleted

#### Scenario: Confirmation not given

- **WHEN** the user chooses "Delete…" and cancels the dialog
- **THEN** nothing is deleted

### Requirement: The open model can be deleted from its detail page

The system SHALL offer "Delete this item…" (and correspondingly for fonts, sounds and
notifications) while that kind's detail page is open. It SHALL behave exactly like the page's own
delete button: the same confirmation, unsaved edits of the model discarded, and the list shown
after deleting.

#### Scenario: Delete the open item

- **WHEN** the user is on an item's detail page, runs "Delete this item…" and confirms
- **THEN** the item is deleted and the Items list page is shown

#### Scenario: Not on a detail page

- **WHEN** the user is on the Items list page
- **THEN** "Delete this item…" is not listed

### Requirement: Creating and deleting follow the roles

The system SHALL offer the create commands only to sessions holding `stelaris.editor`, and every
delete entry only to sessions holding `stelaris.admin`. A deployment without an identity provider
SHALL offer both.

#### Scenario: Editor without admin

- **WHEN** the signed-in user holds `stelaris.editor` but not `stelaris.admin`
- **THEN** the create commands are listed, and no delete entry is listed or found by searching

#### Scenario: No identity provider

- **WHEN** the deployment has no identity provider
- **THEN** the create commands and the delete entries are listed
