# Spec Delta

## Purpose

Describes the settings dialog: how it looks like the other dialogs, which sections it has, how
each setting is changed and reset, and what the account section shows.

## ADDED Requirements

### Requirement: Settings are a dialog with the shared chrome

The system SHALL show the settings in a dialog with a title row and a close icon, as the other form
dialogs do. The dialog SHALL be at most about 560 px wide, show one column, and have no
confirm/cancel row, because a setting applies as soon as it is changed. The content SHALL be
grouped into sections with a muted heading, in the order Account, Project, Appearance,
Accessibility and About. Each setting SHALL be an outlined card with a leading icon.

#### Scenario: The dialog opens

- **WHEN** the user opens the settings from the app bar or the `ui.open-settings` command
- **THEN** a dialog titled "Settings" opens with a close icon
- **AND** it shows the sections Project, Appearance, Accessibility and About in that order
- **AND** it shows no Save or Cancel button

#### Scenario: Closing the dialog

- **WHEN** the user taps the close icon
- **THEN** the dialog closes
- **AND** every setting changed so far stays changed

### Requirement: The theme mode is one choice

The system SHALL offer the theme mode as one choice of System, Light and Dark. Choosing System
SHALL make the app follow the platform brightness. Choosing Light or Dark SHALL fix the brightness.
The choice SHALL be stored in the existing theme settings fields without changing their shape.

#### Scenario: Choosing Dark

- **WHEN** the user chooses Dark
- **THEN** the app uses the dark theme
- **AND** the theme settings have `useSystemTheme` off and `isDarkMode` on

#### Scenario: Choosing System

- **WHEN** the user chooses System while the platform is dark
- **THEN** the app uses the dark theme
- **AND** the theme settings have `useSystemTheme` on

#### Scenario: The current choice is marked

- **WHEN** the theme settings have `useSystemTheme` off and `isDarkMode` off
- **THEN** Light is shown as the selected choice

### Requirement: The color is chosen from a list

The system SHALL offer a fixed list of seed colors as swatches, mark the current one, and apply a
chosen one to the whole app at once.

#### Scenario: Choosing a color

- **WHEN** the user taps the red swatch
- **THEN** the theme settings' primary color is red
- **AND** the red swatch is marked as selected

### Requirement: The font size previews while dragging

The system SHALL offer the font size as a slider with a sample text. While the user drags, the
sample text SHALL follow the slider and the stored font scale SHALL NOT change. When the user
releases, the system SHALL store the chosen scale once.

#### Scenario: Dragging

- **WHEN** the user drags the slider to 1.4 and has not released it
- **THEN** the sample text is shown at 1.4
- **AND** the stored font scale is unchanged

#### Scenario: Releasing

- **WHEN** the user releases the slider at 1.4
- **THEN** the stored font scale is 1.4

### Requirement: A section can go back to its defaults

The system SHALL offer a reset for the Appearance section and for the Accessibility section, which
restores the values of `ThemeSettings.defaultSettings()` for the settings in that section only. The
reset SHALL be disabled when the section already has its defaults.

#### Scenario: Resetting the appearance

- **WHEN** the theme mode is Dark, the color is red, the font scale is 1.4, and the user resets
  Appearance
- **THEN** the theme mode is System and the color is the default blue
- **AND** the font scale is still 1.4

#### Scenario: Nothing to reset

- **WHEN** the font scale is 1.0
- **THEN** the reset of the Accessibility section is disabled

### Requirement: The account section shows the session

The system SHALL show the signed-in person's name, their roles and a sign-out button in the Account
section, using the existing session state and sign-out. It SHALL show an explanation instead when an
identity provider is configured and no one is signed in. It SHALL NOT show the section when no
identity provider is configured.

#### Scenario: Signed in

- **WHEN** a person named "Ada" with the roles `editor` and `admin` is signed in
- **THEN** the Account section shows "Ada" and the roles
- **AND** it shows a "Sign out" button

#### Scenario: Signing out

- **WHEN** the user taps "Sign out"
- **THEN** the session's sign-out runs once

#### Scenario: Not signed in

- **WHEN** an identity provider is configured and no one is signed in
- **THEN** the Account section says that no one is signed in
- **AND** it shows no sign-out button

#### Scenario: Authentication is off

- **WHEN** no identity provider is configured
- **THEN** the dialog shows no Account section and no Account heading

### Requirement: The project is a choice, also when there is none

The system SHALL show the active project in the Project section and let the user choose another
from a list. Switching SHALL still ask for confirmation and still ask before dropping unsaved
changes. The section SHALL show an empty state when there are no projects.

#### Scenario: Switching the project

- **WHEN** the user chooses another project and confirms the switch
- **THEN** the other project becomes the selected project

#### Scenario: Declining the switch

- **WHEN** the user chooses another project and cancels the confirmation
- **THEN** the selected project is unchanged

#### Scenario: No projects

- **WHEN** there are no projects
- **THEN** the Project section is still shown
- **AND** it says that there are no projects

### Requirement: About holds the app's information and links

The system SHALL show the app version, the licences, a link to the issue tracker and a link to the
help wiki in the About section. It SHALL show a footer with the current year, taken from the
injected clock and not written in the code.

#### Scenario: The footer year

- **WHEN** the clock reads a date in 2031
- **THEN** the footer shows 2031

#### Scenario: Issues and help

- **WHEN** the user opens the About section
- **THEN** one card links to the issue tracker for bug reports and suggestions
- **AND** one card links to the wiki
