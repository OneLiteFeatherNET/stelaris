# Spec Delta

## Purpose

Gives each navigation section an icon taken from Minecraft's own imagery in Material's style, so
users recognise the section at a glance in the navigation rail and in the command palette.

## ADDED Requirements

### Requirement: Each section has a themed icon
Each navigation section SHALL show its own icon, and no two sections SHALL share one:

| Section       | Motif                                  |
|---------------|----------------------------------------|
| Attributes    | heart                                  |
| Items         | pickaxe                                |
| Notifications | advancement toast frame with a star    |
| Fonts         | the letters "Aa"                       |
| Sound         | note block                             |

#### Scenario: Rail shows the section icons
- **WHEN** the navigation rail is shown
- **THEN** each of the five sections shows the icon of its motif above
- **AND** no two sections show the same icon

### Requirement: Outline when inactive, filled when selected
Each section's icon SHALL come in an outline form and a filled form of the same motif. The
navigation rail SHALL show the filled form for the current section and the outline form for all
others. A detail page SHALL count as its list's section.

#### Scenario: The current section is filled
- **WHEN** the user is on `/items`
- **THEN** Items shows the filled pickaxe
- **AND** the other four sections show their outline icons

#### Scenario: A detail page marks its section
- **WHEN** the user is on `/fonts/detail`
- **THEN** Fonts shows the filled "Aa"

### Requirement: Palette uses the navigation icons
The command palette's "go to" command for a section SHALL show the same outline icon as that
section in the rail. When the command marks the current section, it SHALL show the filled icon.

#### Scenario: Go-to command shows the section icon
- **WHEN** the palette lists "Go to Sound" while the user is elsewhere
- **THEN** the command shows the outline note block

#### Scenario: Marked command shows the filled icon
- **WHEN** the palette lists "Go to Fonts" while the user is on `/fonts`
- **THEN** the command shows the filled "Aa"

### Requirement: Icons follow the theme
The section icons SHALL be single-coloured and take their colour and size from the surrounding
icon theme, like the Material icons around them do. This covers the selected and unselected colours
and light and dark mode.

#### Scenario: Selected colour in dark mode
- **WHEN** the app is in dark mode and Attributes is selected
- **THEN** the filled heart is drawn in the rail's selected icon colour for dark mode

#### Scenario: Same size as other icons
- **WHEN** the navigation rail is shown
- **THEN** each section icon renders at the rail's icon size, with no cropping or scaling artefacts
