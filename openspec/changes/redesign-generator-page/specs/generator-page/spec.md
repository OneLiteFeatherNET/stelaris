# Spec Delta

## Purpose

Lets a maintainer of a Vulpes project test that project's generated code against a vulpes-base branch, publish a release or snapshot of it, and see the versions already published, from the generator page in the Build group of the navigation.

## ADDED Requirements

### Requirement: Generator page has three sections in order

The generator page SHALL be reached at `/generator` from the Build group of the navigation and SHALL show three sections in this order: "Test locally", "Publish" and "Published versions".

#### Scenario: Sections on open

- **WHEN** the user opens the generator page for a selected project
- **THEN** the page shows "Test locally", then "Publish", then "Published versions"

### Requirement: Shared vulpes-base branch selection

The page SHALL offer a vulpes-base branch dropdown populated from the branch list of the generator service, with `develop` selected by default when it exists. The same selection SHALL apply to "Test locally" and to "Publish".

#### Scenario: Default branch

- **WHEN** the branch list loads and contains `develop`
- **THEN** the dropdown shows `develop` as the selected branch

#### Scenario: Selection shared between sections

- **WHEN** the user selects `release/2.x` in the dropdown
- **THEN** "Test locally" and "Publish" both use `release/2.x` for the next action

#### Scenario: Branch list unavailable

- **WHEN** the branch list request fails
- **THEN** the dropdown shows an error with a retry action, and "Test locally" and "Publish" are disabled

#### Scenario: Branch list empty

- **WHEN** the branch list loads with no branches
- **THEN** "Test locally" and "Publish" are disabled and the page says that no vulpes-base branch is available

### Requirement: Test locally downloads a local build

The "Test locally" section SHALL offer one action that downloads the project's generated code for the selected branch as a file named `<project>-local.zip`. The section SHALL explain that the file is to be unzipped into the project root, which creates `vulpes/<project>/`, and that the Gradle plugin then uses it in place of the published version.

#### Scenario: Download succeeds

- **WHEN** the user activates the download action with a project and branch selected
- **THEN** the browser saves a file named `<project>-local.zip` and the page shows the unzip instructions

#### Scenario: Download in progress

- **WHEN** the download request is running
- **THEN** the action shows a loading indicator and cannot be activated again

#### Scenario: Download fails

- **WHEN** the download request fails
- **THEN** no file is saved and the section shows the error with a retry action

#### Scenario: No project selected

- **WHEN** no project is selected
- **THEN** the action is disabled and the section says that a project must be selected

### Requirement: Next version is proposed from the latest published Release

The "Publish" section SHALL propose a next version computed from the latest published Release, `X.Y.Z`. The user SHALL choose a major, minor or patch bump. When the project has no published Release, the Release proposal SHALL be `0.1.0` and the Snapshot proposal SHALL be `0.1.0-SNAPSHOT`.

#### Scenario: Minor bump from the latest release

- **WHEN** the latest published Release version is `1.4.2` and the user chooses minor
- **THEN** the proposed Release version is `1.5.0`

#### Scenario: Patch bump from the latest release

- **WHEN** the latest published Release version is `1.4.2` and the user chooses patch
- **THEN** the proposed Release version is `1.4.3`

#### Scenario: First release

- **WHEN** the project has no published Release version
- **THEN** the proposed Release version is `0.1.0`

#### Scenario: Version fields never produce a crash

- **WHEN** a published version is not in the form `X.Y.Z` or `X.Y.Z-SNAPSHOT`
- **THEN** no proposal is computed, the section explains that the version cannot be read, publishing is disabled, and the page stays usable

### Requirement: Release and snapshot channels

The "Publish" section SHALL offer the Release channel, which publishes `X.Y.Z`, and the Snapshot channel, which publishes `X.Y.Z-SNAPSHOT`. The Snapshot proposal SHALL be the proposal of the Release channel with `-SNAPSHOT` appended. Publishing a snapshot version that is already published SHALL replace it on the server.

#### Scenario: Snapshot from the latest release

- **WHEN** the latest published Release version is `1.4.2` and the user chooses minor on the Snapshot channel
- **THEN** the proposed snapshot version is `1.5.0-SNAPSHOT`

#### Scenario: Snapshot without a release

- **WHEN** the project has no published Release version and the user is on the Snapshot channel
- **THEN** the proposed snapshot version is `0.1.0-SNAPSHOT`

#### Scenario: Channel switch updates the proposal

- **WHEN** the user switches from Release to Snapshot
- **THEN** the proposal is recomputed for the Snapshot channel and the previous proposal is no longer offered

### Requirement: Publish shows the full version and asks for confirmation

Before anything is sent, the "Publish" section SHALL show the full version string, the channel and the vulpes-base branch, and SHALL ask the user to confirm. For a Snapshot version that is already published, the confirmation SHALL say that the existing snapshot is replaced. No publish request SHALL be sent without confirmation.

#### Scenario: Cancelled confirmation

- **WHEN** the user opens the confirmation and cancels it
- **THEN** no publish request is sent and the proposal is unchanged

#### Scenario: Confirmed publish

- **WHEN** the user confirms the publish of `1.5.0`
- **THEN** exactly one publish request is sent with the project id, version and selected vulpes-base branch

#### Scenario: Snapshot replacement is stated

- **WHEN** the user opens the confirmation for `1.5.0-SNAPSHOT` and that snapshot is already published
- **THEN** the confirmation says that publishing replaces the existing `1.5.0-SNAPSHOT`

### Requirement: Successful publish shows coordinates and a Gradle line

After a successful publish, the "Publish" section SHALL show the published coordinates, the revision, the vulpes-base commit, and a ready-to-copy Gradle dependency line of the form `vulpes("<coordinates>")`.

#### Scenario: Result shown

- **WHEN** the publish request succeeds
- **THEN** the section shows the coordinates, the revision and the vulpes-base commit returned by the service

#### Scenario: Base commit shortened with full copy

- **WHEN** the publish request succeeds with a 40-character vulpes-base commit
- **THEN** the section shows the first 10 characters of the commit and a copy action that copies the full 40-character value

#### Scenario: Copy the Gradle line

- **WHEN** the user activates the copy action on the Gradle line
- **THEN** the clipboard holds `vulpes("<coordinates>")` with the returned coordinates and the page confirms the copy

### Requirement: Compiler diagnostics on rejected publish

When the service rejects a publish because the generated code does not compile against the selected vulpes-base branch, the "Publish" section SHALL show the list of compiler diagnostics returned by the service and SHALL NOT report the version as published.

#### Scenario: Compile failure

- **WHEN** the publish request is rejected with diagnostics
- **THEN** the section lists every diagnostic returned, and the published versions list is unchanged

### Requirement: Existing version on conflict

When the service reports that the proposed version already exists, the "Publish" section SHALL say that the version exists, keep the user's channel and branch selection, and refresh the published versions list.

#### Scenario: Version already exists

- **WHEN** the publish request is rejected because the version exists
- **THEN** the section says the version already exists, the published versions list is requested again, and the user can change the version and publish again

### Requirement: Published versions list

The "Published versions" section SHALL list the project's published versions, newest first, with channel, coordinates, repository URL and two actions: download as a local build ZIP and copy the Gradle dependency line.

#### Scenario: Newest first

- **WHEN** the project has versions `1.4.2`, `1.5.0-SNAPSHOT` and `1.5.0`
- **THEN** the list shows `1.5.0`, then `1.5.0-SNAPSHOT`, then `1.4.2`

#### Scenario: Download a published version

- **WHEN** the user activates the download action of version `1.4.2`
- **THEN** the browser saves the local build ZIP of `1.4.2` for that project

#### Scenario: Copy a published version's Gradle line

- **WHEN** the user activates the copy action of version `1.4.2`
- **THEN** the clipboard holds `vulpes("<coordinates of 1.4.2>")`

### Requirement: Empty and unavailable states are distinct

The "Published versions" section SHALL show an empty state when the repository is reachable and has no versions, and a repository-unavailable error state, with a retry action, when the service answers 502 because it cannot read the repository. The two states SHALL NOT look the same.

#### Scenario: Repository has no versions

- **WHEN** the list request succeeds and returns no versions
- **THEN** the section shows the empty state and no error

#### Scenario: Repository unavailable

- **WHEN** the list request is answered with 502 because the repository cannot be read
- **THEN** the section shows the repository-unavailable error with a retry action and does not show the empty state

### Requirement: Every request shows loading and error states

Every request the page makes (branch list, local build download, publish, versions list) SHALL show a loading state while it runs and a mapped error state when it fails. A failed request SHALL NOT throw an unhandled exception and SHALL NOT leave a loading state running.

#### Scenario: Loading then error

- **WHEN** a request starts and then fails
- **THEN** the affected section shows a loading state first and then the error state for that request

#### Scenario: Unexpected failure

- **WHEN** a request fails with a status the page does not recognise
- **THEN** the section shows a generic error with the status and a retry action, and the rest of the page keeps working

### Requirement: Retired generator behaviours are absent

The page SHALL NOT offer searching for a build by commit, SHALL NOT call the generate endpoint with a branch, SHALL NOT show the vulpes-base GitHub release status header, and SHALL NOT let a version string that is not `X.Y.Z` stop the page from opening.

#### Scenario: No commit search

- **WHEN** the user looks for a way to build from a commit
- **THEN** no commit search control is present on the page

#### Scenario: No generate call

- **WHEN** the user runs any action on the page
- **THEN** no request is sent to the generate endpoint

#### Scenario: Page opens with an unreadable version

- **WHEN** the page is opened while a version string is not `X.Y.Z`
- **THEN** the page opens and the error is shown in the affected section only
