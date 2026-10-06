# Spec Delta

## Purpose

Describes the item stack itself, its material and amount, as Stelaris components, and its display
name and model data as vanilla components, so an item is one list of components that the interface
edits through the schema editor.

## ADDED Requirements

### Requirement: Every item has a material component

The system SHALL create the component `stelaris:material` with the value `minecraft:dirt` when an
item is created. The system SHALL reject removing `stelaris:material` from an item or changing its
key, and removing all components of an item SHALL keep it.

#### Scenario: New item

- **WHEN** the user creates an item
- **THEN** the item has the component `stelaris:material` with `minecraft:dirt`

#### Scenario: Remove the material

- **WHEN** a client deletes the `stelaris:material` component of an item
- **THEN** the request is rejected and the component stays

### Requirement: The amount is optional

The system SHALL treat an item without `stelaris:amount` as an amount of 1. The value of
`stelaris:amount` SHALL be described as a whole number from 1 to 99.

#### Scenario: Add an amount

- **WHEN** a client adds `stelaris:amount` with `5` to an item
- **THEN** the item lists the component with the value `5`

### Requirement: Only known Stelaris components are stored

The system SHALL reject creating or updating a component whose key is in the `stelaris` namespace
but isn't one of the Stelaris components.

#### Scenario: Unknown key

- **WHEN** a client adds the component `stelaris:foo`
- **THEN** the request is rejected

### Requirement: Name and model data are plain components

The system SHALL store the display name and the custom model data only as the components
`minecraft:custom_name` and `minecraft:custom_model_data`, and SHALL accept them like any other
vanilla component. The item SHALL have no flags.

#### Scenario: Set a custom name

- **WHEN** a client adds `minecraft:custom_name` with a text to an item
- **THEN** the component is stored and the item has no other name field

### Requirement: Copies keep their material

The system SHALL copy all components of an item when the copy includes components, and SHALL copy
the required components in every case.

#### Scenario: Copy without components

- **WHEN** the user copies an item without choosing to copy its components
- **THEN** the copy has the same `stelaris:material` and no other component

### Requirement: The interface shows Stelaris components as custom

The components tab SHALL list the Stelaris components in a "Custom" section before the vanilla
categories and mark their cards as custom. It SHALL offer no remove action for a required
component. The picker SHALL offer `stelaris:amount` while the item doesn't have it. The General tab
SHALL show no material, amount, display name or model data input.

#### Scenario: Material card

- **WHEN** the user opens the components tab of an item
- **THEN** the material card is in the Custom section, is marked as custom and has no remove action

#### Scenario: Add an amount

- **WHEN** the item has no amount and the user opens the picker
- **THEN** Amount is offered under Custom, and Material is not

### Requirement: Default components follow the material component

The components tab SHALL mark the components the material has by default based on the value of
`stelaris:material`.

#### Scenario: Change the material

- **WHEN** the user changes `stelaris:material` from `minecraft:dirt` to `minecraft:diamond_sword`
- **THEN** the default marks follow the components of `minecraft:diamond_sword`
