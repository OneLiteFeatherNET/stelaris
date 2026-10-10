# Spec Delta

## Purpose

Helps people enter valid Minecraft material, item and block ids by suggesting known ones while they
type, without taking away the freedom to enter any other id.

## ADDED Requirements

### Requirement: Suggestions are limited and shown only for a query

The system SHALL show at most five suggestions below a material field while the user types, each
with the material's display name and its key. The system SHALL show no suggestions while the field
is empty or blank, or when nothing matches.

#### Scenario: Many matches

- **WHEN** the user types `diamond` into an item key field
- **THEN** at most five suggestions are shown

#### Scenario: Empty field

- **WHEN** the field is empty
- **THEN** no suggestions are shown

#### Scenario: No match

- **WHEN** the user types an id that matches no material
- **THEN** no suggestions are shown

### Requirement: Taking a suggestion enters its key

The system SHALL, when the user picks a suggestion with the mouse, or with the arrow keys and
Enter, put its key (for example `minecraft:diamond_sword`) into the field and handle the change
exactly like typed text.

#### Scenario: Pick with the mouse

- **WHEN** the user types `diamond sword` and clicks the `Diamond Sword` suggestion
- **THEN** the field holds `minecraft:diamond_sword` and the field's change handler receives it

#### Scenario: Pick with the keyboard

- **WHEN** the user types `diamond sword` and presses Enter while the first suggestion is
  highlighted
- **THEN** the field holds `minecraft:diamond_sword`

#### Scenario: Notification material

- **WHEN** the user picks a suggestion in the notification material card
- **THEN** the card saves the suggestion's key like it does when editing finishes

### Requirement: Free text stays valid

The system SHALL keep any text the user types, whether or not it matches a suggestion, and SHALL
NOT change the field's validation.

#### Scenario: Custom id

- **WHEN** the user types `mymod:custom_item` into an item key field
- **THEN** the value is kept and passes validation

#### Scenario: Missing key

- **WHEN** the field is empty and the form is validated
- **THEN** the field reports that a key is required, as before

### Requirement: Suggestions follow the registry

The system SHALL suggest every material for key fields of the `item` registry, only blocks for the
`block` registry, and nothing for any other registry.

#### Scenario: Block registry

- **WHEN** the user types `sword` into a block key field
- **THEN** no suggestions are shown

#### Scenario: Other registry

- **WHEN** the user types `diamond` into a `sound_event` key field
- **THEN** no suggestions are shown
