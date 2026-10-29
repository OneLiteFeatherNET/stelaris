# Spec Delta

## Purpose

Lets any list of items use the grid and the card look of the model list pages, with or without the
actions of a model.

## ADDED Requirements

### Requirement: A grid for any kind of item

The app SHALL offer a grid that lays out cards of any kind of item in as many columns as cards of at
most 320 px fit, at most four, with a fixed card height and spacing. It SHALL show a loading footer
while more items load and SHALL ask for more items when the user scrolls near the end. The model
list pages SHALL use this grid.

#### Scenario: Columns follow the width

- **WHEN** the grid is 1400 px wide
- **THEN** it shows four columns

#### Scenario: Narrow grid

- **WHEN** the grid is narrower than two cards
- **THEN** it shows one column

### Requirement: A card frame without model actions

The app SHALL offer the look of a model card on its own: a filled card that reacts to a tap, with
content and an optional trailing widget at the top, an optional summary line, and an optional footer
with an icon and a text below a divider. The model cards SHALL use this frame and keep their actions.

#### Scenario: Card without actions

- **WHEN** a card frame has content and a footer text but no trailing widget
- **THEN** it shows the content, a divider and the footer, and no actions

#### Scenario: Model list unchanged

- **WHEN** the user opens the items page
- **THEN** the cards show the same content, actions, notes line and footer as before
