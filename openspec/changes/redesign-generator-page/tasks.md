# Tasks

Each task names how to verify it. Tests are unit or widget tests: no network, no real `ApiService`, no sleeps, no reads of the system clock. Run targeted tests first; run the full unit suite under `flock ~/.cache/claude-heavy.lock` only at the end of a group.

## 1. Prerequisite and API client

- [ ] 1.1 Read the vulpes-generator `add-editor-release-flow` proposal and confirm the field names of the 422 diagnostics and 409 bodies it defines; record them in design.md before 1.2 starts; verify design.md names them
- [ ] 1.2 Add typed result models (`LocalBuildFile`, `PublishResult`, `PublishedVersion`) and `GeneratorApiException` with kinds `versionExists` (409), `compileFailed` (422), `repositoryUnavailable` (502), `unexpected`, `network`; verify unit tests map each kind from a scripted Dio response, including the diagnostics list on 422 and the full 40-character base commit in `PublishResult`
- [ ] 1.3 Implement `GenerateApi.branches`, `localBuild(projectId, baseBranch)`, `publish(projectId, version, baseBranch)` (body `{projectId, version, baseBranch}`), `publishedVersions(projectId)` and `publishedVersionBuild(projectId, version)` against the companion endpoints; verify tests with a fake `Dio` adapter check URL, query, method and body for each call
- [ ] 1.4 Remove `generate`, `download` (`/download`) and `buildInformation` from `GenerateApi` and every caller; verify `rg -n "generateApi.generate|/generate|/build/data|/download\b" lib` finds nothing in the generator code and the analyzer reports no unused import

## 2. Version computation (pure)

- [ ] 2.1 Write failing unit tests for `proposeVersion` covering: first Release gives `0.1.0`; minor and patch bumps from `1.4.2`; major bump resets minor and patch; Snapshot is the Release proposal with `-SNAPSHOT` (`1.5.0-SNAPSHOT` from `1.4.2` with minor); Snapshot with no Release gives `0.1.0-SNAPSHOT`; snapshot versions are ignored as the Release base; unreadable published strings are reported as `Unreadable`, not thrown; verify the tests fail before implementation
- [ ] 2.2 Implement `lib/feature/build/publish/version_proposal.dart` with `proposeVersion`, the `VersionProposal` sealed type and the semver ordering helper; verify all tests from 2.1 pass and no code path throws for any input string
- [ ] 2.3 Add a unit test that the newest-first ordering of published versions puts `1.5.0` above `1.5.0-SNAPSHOT` above `1.4.2`, and implement the ordering helper it covers; verify the test passes

## 3. State: actions and view model

- [ ] 3.1 Write failing action tests with a fake generator API: branch load sets loading then loaded, and a failure sets the error kind; each action sets loading first and never leaves loading set after a failure; verify tests fail first
- [ ] 3.2 Replace `ReleaseFetchAction`, `BranchFetchAction` and the commit-related fields of `AppState` with the generator-page actions and per-section status (`LoadBranchesAction`, `LoadPublishedVersionsAction`, `DownloadLocalBuildAction`, `DownloadPublishedVersionAction`, `PublishReleaseAction`), each taking the API through its constructor; verify the tests from 3.1 pass
- [ ] 3.3 Map every exception in the actions to a `GeneratorApiException` kind, with unknown exceptions becoming `unexpected`; verify a test throws a non-API error from the fake and sees the `unexpected` state without an unhandled exception
- [ ] 3.4 Rewrite `BuildStateFactory` and `BuildViewModel` to expose statuses, the derived `VersionProposal`, and `canPublish`; remove `version`'s `'0.0.1'` fallback; verify factory tests cover disabled publish when the proposal is `Unreadable` and when no project is selected

## 4. Test locally section

- [ ] 4.1 Write failing widget tests: the section shows the download action and unzip instructions; the action is disabled without a project; a loading indicator shows while the request runs; a failure shows the error with retry and saves no file; verify tests fail first
- [ ] 4.2 Implement the Test locally section reading the shared branch selection; verify the widget tests from 4.1 pass
- [ ] 4.3 Replace `download_helper_web.dart` with a Blob and object-URL download that revokes the URL after the click, and make the non-web stub report an error instead of throwing; verify a unit test with a fake download helper receives the filename `<project>-local.zip`

## 5. Publish section

- [ ] 5.1 Write failing widget tests: bump selector and channel switch update the proposal; a confirmation dialog shows the full version and channel before any request, and says that an existing snapshot is replaced; cancelling sends nothing; verify tests fail first
- [ ] 5.2 Implement the bump and channel controls and the confirmation step, reusing `proposeVersion`; verify the widget tests from 5.1 pass and no request is sent without confirmation
- [ ] 5.3 Write failing widget tests for the publish outcomes: success shows coordinates, revision, base commit (first 10 characters, with a copy action for the full 40-character value) and the `vulpes("<coordinates>")` line with a copy action; 422 lists every diagnostic; 409 says the version exists and reloads the versions list; verify tests fail first
- [ ] 5.4 Implement the success, diagnostics and conflict views on the Publish section; verify the widget tests from 5.3 pass
- [ ] 5.5 Write a widget test that an `Unreadable` published version explains the problem and disables Publish without an exception; implement it; verify the test passes

## 6. Published versions section

- [ ] 6.1 Write failing widget tests: newest first ordering; each row shows channel, coordinates and repository URL; the download action calls the published-version build with the right version; the copy action copies `vulpes("<coordinates>")`; verify tests fail first
- [ ] 6.2 Implement the Published versions table and its two row actions; verify the widget tests from 6.1 pass
- [ ] 6.3 Write failing widget tests that the empty state and the repository-unavailable state render different text and that only the unavailable state offers retry; implement both; verify the tests pass

## 7. Page assembly and removals

- [ ] 7.1 Write a widget test that the generator page renders the sections in the order Test locally, Publish, Published versions, and that the page renders with an unreadable version string without throwing; verify the test fails before 7.2
- [ ] 7.2 Replace `GeneratorPage`, `BuildDialog` references and the `BuildTabs` usage with the three sections; delete `download_trigger.dart`, `download_commit_option.dart`, `build_trigger.dart`, `release_status_section.dart`, `release_metadata_display.dart`, `build_version_display.dart` and their now-unused l10n keys; verify the widget test from 7.1 passes and the analyzer reports no unused files
- [ ] 7.3 Add widget tests that no commit-search control and no generate call exist on the page (fake API records calls); verify the tests pass

## 8. Localisation and documentation

- [ ] 8.1 Add the English l10n keys for the three section titles, the unzip instructions, the channel and bump labels, the confirmation text, the diagnostics and conflict messages, and the two empty and error states to `lib/l10n/stelaris_en.arb`, and regenerate the localisation Dart files; verify `flutter gen-l10n` succeeds and no key is used without a definition
- [ ] 8.2 Add the same keys in the other supported locale files with the English text as placeholder where no translation exists, and note it in the PR description; verify the locale-consistency check (if present in CI) passes

## 9. Final verification and pull request

- [ ] 9.1 Run the full unit suite once under `flock ~/.cache/claude-heavy.lock` with `flutter test`; verify it passes and that no test in the new suites uses `Thread.sleep`-equivalent delays, system time, or the network
- [ ] 9.2 Open the code pull request `feat(build): build, test locally and list releases on the generator page` against `develop`, filling `.github/pull_request_template.md`; verify the PR exists, its title is that Conventional Commit, and it contains no file under `openspec/`

## Workflow follow-up

- After the code PR is merged, a separate follow-up PR ticks the tasks in this file and, when the maintainer asks, archives the change (`docs(openspec): archive redesign-generator-page`).
