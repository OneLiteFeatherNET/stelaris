# Spec Delta

## Purpose

Tells the cards that open a page apart from the cards that change a value, and lets the detail
pages edit every plain field through an edit card and its dialog.

## ADDED Requirements

### Requirement: Cards look like what a click does

The system SHALL show a model in a list as a navigation card, which opens the model's page. The
system SHALL show a field of a detail page and an item component as an edit card, which opens a
dialog. Edit cards SHALL share one look that differs from navigation cards. Edit cards SHALL NOT
show a "last edited" footer, notes or a model menu.

#### Scenario: A model card opens a page

- **WHEN** the user clicks an item in the item list
- **THEN** the item's page opens

#### Scenario: A field card opens a dialog

- **WHEN** the user clicks the "Ascent" card on a font's General tab
- **THEN** a dialog for the ascent opens and the page stays

### Requirement: An edit card puts the value first

An edit card SHALL show the field's value as its main text and the label as a smaller text above
it. It SHALL show an icon for the kind of field. It SHALL show the field's rule or hint in a footer
when the field has one. An empty value SHALL show a placeholder in a muted color. The card SHALL be
as high as its content, without a fixed minimum height.

#### Scenario: A set value

- **WHEN** a font's ascent is 7
- **THEN** its card shows "7" as the main text and "Ascent" above it

#### Scenario: An empty value

- **WHEN** a sound has no subtitle
- **THEN** its card shows a muted placeholder instead of the value

### Requirement: Text components show their formatting

A field holding a text component SHALL span the full width of its section and SHALL show its text
with its formatting, on the background and in the default color of where it appears in game. Its
dialog SHALL be the MiniMessage editor.

#### Scenario: A formatted title

- **WHEN** an advancement's title is `<gold>First <b>Kill`
- **THEN** its card shows "First Kill" in gold with "Kill" in bold

#### Scenario: The description follows the frame

- **WHEN** an advancement's frame is changed from task to challenge
- **THEN** its description card shows the text in dark purple instead of green

### Requirement: Fields are grouped

A detail page SHALL show its edit cards in sections, each with a heading. Within a section, short
fields SHALL be laid out in as many columns as fit, and text components SHALL take a full row.

#### Scenario: The advancement page

- **WHEN** the user opens an advancement
- **THEN** its fields appear under the headings "Display", "Text" and "Position"

### Requirement: A dialog stages the change

Saving in a field's dialog SHALL update the model in the store and mark the page as unsaved. It
SHALL NOT send the model to the backend. Cancelling SHALL change nothing. The header's save button
SHALL persist the model, and leaving the page with unsaved changes SHALL still ask first.

#### Scenario: Change and leave

- **WHEN** the user changes a sound's subtitle in its dialog and then leaves the page
- **THEN** the app asks whether to save, discard or stay

#### Scenario: Cancel

- **WHEN** the user changes a font's height in its dialog and cancels
- **THEN** the height and the unsaved state are as before

### Requirement: Fields keep their rules

A field's dialog SHALL apply the field's input formatters, validators, hint, help text and length
limit. Material fields SHALL suggest materials while typing. A dialog SHALL NOT save an invalid
value.

#### Scenario: An invalid material

- **WHEN** the user enters "Diamond Sword" as an advancement's material and saves
- **THEN** the dialog shows the material error and stays open

#### Scenario: A number field

- **WHEN** the user types letters into a font's ascent dialog
- **THEN** the letters are not accepted
