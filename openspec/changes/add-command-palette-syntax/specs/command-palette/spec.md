# Spec Delta

## ADDED Requirements

### Requirement: Available commands are offered, the current page marked

The system SHALL list a command only when it can run in the current context: its required role,
if it declares one, is granted to the current session, and its availability condition on the
current page and application state holds. A deployment without an identity provider grants every
role, consistent with the rest of the interface. The "Go to" command for the page the user is on,
or whose detail page they are on, SHALL be listed and marked as the current page, the way the side
navigation marks it.

#### Scenario: Role not granted

- **WHEN** a command requires a role the signed-in user does not have
- **THEN** that command is not listed and cannot be found by searching

#### Scenario: No identity provider configured

- **WHEN** the deployment has no identity provider and a command requires a role
- **THEN** that command is listed

#### Scenario: Context-dependent command on an unrelated page

- **WHEN** the user opens the palette on a page without a model list
- **THEN** "Reload current list" is not listed

#### Scenario: Current page is marked

- **WHEN** the user opens the palette on the Fonts page
- **THEN** "Go to Fonts" is listed and marked as the current page, and "Go to Items" is listed
  without the mark

#### Scenario: From a detail page back to its list

- **WHEN** the user is on a font's detail page and chooses the marked "Go to Fonts"
- **THEN** the Fonts list page is shown

## REMOVED Requirements

### Requirement: Only available commands are offered

**Reason**: It hid the "Go to" command for the current page, so the palette gave no sense of where
the user is and offered no way from a detail page back to its list. Replaced by "Available
commands are offered, the current page marked", which keeps the role and availability rules
unchanged and lists the current page with a mark instead.

**Migration**: None for users. `isAvailable` on the "Go to" commands no longer excludes the current
page; `isCurrent` marks it.
