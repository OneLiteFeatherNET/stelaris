# Spec Delta

## Purpose

Lets the font, sound and notification pages edit their plain fields the way the rest of the app
edits: each field shows as a card, and a click opens a dialog for that field.

## ADDED Requirements

### Requirement: Fields show as cards
The General tabs of fonts and sounds and the notification page SHALL show each of their fields as a
card with the field's name and current value. A card SHALL show the field's hint text when the
value is empty, or "–" when the field has no hint. A field with a tooltip SHALL show it on its card.

#### Scenario: Font fields
- **WHEN** the user opens a font's General tab
- **THEN** it shows cards for provider, texture path, ascent and height with the font's values

#### Scenario: Empty field with a hint
- **WHEN** a notification has no material
- **THEN** the material card shows the hint `defaultMaterial`

### Requirement: A click opens a dialog for the field
Clicking a card SHALL open a dialog for that field only, filled in with the current value. A text
field's dialog SHALL focus its input. A choice field's dialog SHALL list the options and mark the
current one.

#### Scenario: Edit a text field
- **WHEN** the user clicks the sound key card
- **THEN** a dialog opens with the sound's key in a focused input

#### Scenario: Edit a choice field
- **WHEN** the user clicks the frame type card
- **THEN** a dialog lists all frame types and marks the notification's current one

### Requirement: The dialog stages the change
Saving a dialog with a changed value SHALL update the page's model in the store and mark it
unsaved. It SHALL NOT persist the model. The header's save button SHALL persist it. Saving an
unchanged value or cancelling SHALL leave the model and the unsaved state as they are.

#### Scenario: Save a changed value
- **WHEN** the user changes a font's ascent to 9 and saves the dialog
- **THEN** the font in the store has ascent 9
- **AND** the page is marked unsaved and the header's save button is active
- **AND** no request is sent until the header's save button is pressed

#### Scenario: Cancel
- **WHEN** the user changes the value and cancels the dialog
- **THEN** the model and the unsaved state are unchanged

### Requirement: Fields keep their rules
Each field SHALL keep its input formatters, validators, required check and length limit. A dialog
SHALL NOT accept an invalid value: it SHALL stay open and show the validation error.

#### Scenario: Invalid sound key
- **WHEN** the user enters a sound key that is not a resource location and saves
- **THEN** the dialog stays open with the invalid key message
- **AND** the sound in the store keeps its key

#### Scenario: Empty number
- **WHEN** the user clears a font's height and saves
- **THEN** the font's height becomes 0
