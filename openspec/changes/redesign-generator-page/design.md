# Design

## Context

The generator page on `feat/generator-page` is a `StoreConnector` page (`lib/feature/build/generator_page.dart`) that dispatches `ReleaseFetchAction` and `BranchFetchAction` on init. Its state lives in `BuildViewModel` (`lib/api/state/factory/build/build_vm_state.dart`), which reads `releaseModel` and `branches` from `AppState` and derives `version` with a `'0.0.1'` fallback. `GenerateApi` (`lib/api/service/generate_api.dart`) exposes `generate`, `branches`, `download` (`/download?branch&projectId`) and `buildInformation` (`/build/data`). The Build tab's `BuildTrigger` computes the bumped version in `_updateVersion`, which throws `ArgumentError` on a non-`X.Y.Z` string and is called from `initState`; its button calls `generate(branch)` and never sends the version. `DownloadTrigger` offers the branch dropdown and the commit switch, whose `DevBuildOption` sends a 10-character commit as `branch`. Downloads are triggered in `download_helper_web.dart` by building a `data:` URI from base64 content.

Requirements are in `specs/generator-page/spec.md`; motivation is in proposal.md, "Why".

The companion APIs (vulpes-generator `add-editor-release-flow`) provide `GET /projects/{projectId}/local-build?baseBranch=`, `POST /generator/release`, `GET /projects/{projectKey}/releases` and `GET /projects/{projectKey}/releases/{version}/local-build`. `/git/branches` is unchanged.

## Goals / Non-Goals

Goals:
- The three sections and their states as specified, with each request's loading, success and error state driven by store state.
- Version computation as a pure, unit-tested function that never throws.
- Errors from the API mapped to a small set of UI outcomes, so that the widgets never see raw exceptions.

Non-Goals:
- Changing the vulpes-generator or the Gradle plugin behaviour.
- Redesigning other build-related pages or the navigation entry.
- Persisting the selected branch or channel across visits.
- Ticking tasks or archiving; that happens in a follow-up PR.

## Decisions

### State: one generator-page slice in the store

The three sections each have their own status (loading, loaded, error with kind) in `AppState`, replacing `releaseModel`, `isLoadingRelease` and the commit-related fields. Actions: `LoadBranchesAction`, `LoadPublishedVersionsAction(projectKey)`, `DownloadLocalBuildAction(projectId, baseBranch)`, `DownloadPublishedVersionAction(projectKey, version)`, `PublishReleaseAction(projectKey, version, baseBranch)`. Each action's `reduce` sets loading first and then a final status, and catches every exception, mapping it to an error kind (see Error mapping). The view model exposes the derived proposal (`PublishProposal?` from the pure function) and `canPublish`, so widgets hold no version logic.

Alternative considered: keep the state in local `StatefulWidget` fields as `BuildTrigger` does today. Rejected because the branch selection is shared between two sections and the publish result must survive a list refresh.

### API client: typed results instead of raw Responses

`GenerateApi` returns domain types: `List<String> branches()`, `LocalBuildFile(bytes, filename)` for both downloads, `PublishResult(coordinates, revision, baseCommit, repositoryUrl)`, and `List<PublishedVersion>` for the list. Non-2xx responses are converted to `GeneratorApiException(kind, message, diagnostics)` where `kind` is one of `versionExists` (409), `compileFailed` (422, with the diagnostics list), `repositoryUnavailable` (see Open Questions), `unexpected(status)`, or `network`. The existing `generate`, `download` (`/download`) and `buildInformation` methods are deleted with their callers; `GenerateApi.generate` is the call the spec forbids.

Downloads use `ResponseType.bytes` as today. The filename is fixed to `<project>-local.zip` for Test locally, as the spec says; for published versions it is `<project>-<version>-local.zip`.

### Version computation as a pure function

`lib/feature/build/publish/version_proposal.dart` exposes:

```dart
sealed class VersionProposal { ... }   // Proposed(version) | Unreadable(raw)
VersionProposal proposeVersion({
  required Channel channel,            // release | snapshot
  required BumpPart bump,              // major | minor | patch
  required Iterable<String> published, // versions of the selected channel
});
```

Rules, applied to the latest published version of the selected channel (highest by semver, ignoring `-dev.N` for the Release channel):
- Release: no published Release version gives `0.1.0`; otherwise bump the `X.Y.Z` of the latest one (major resets minor and patch, minor resets patch).
- Snapshot: take the base `X.Y.Z` of the latest published snapshot (or `0.1.0` when none); bump it the same way; then N is the smallest integer ≥ 1 with `base-dev.N` not published. Snapshot bumping applies to the snapshot base, not to Release versions.
- Any published version that does not match `X.Y.Z` or `X.Y.Z-dev.N` is ignored for the proposal and reported through `Unreadable`, so the page explains it and disables Publish instead of throwing.

The function takes no clock and no I/O, so tests need no fakes.

Alternative considered: derive the snapshot base from the latest Release. Rejected because it would reset the snapshot numbering whenever a Release is published, and the spec asks that each channel's latest version drive its own proposal. Open question 4 asks for confirmation.

### Download on web

`download_helper_web.dart` creates a `Blob` from the bytes, an object URL, clicks an anchor with `download` set to the filename, and revokes the object URL after the click. This replaces the base64 `data:` URI, which roughly doubles the memory of a large ZIP. The stub keeps the same signature; on non-web platforms the action reports an error state rather than throwing.

### Dependency injection for tests

The actions take the generator API through their constructor, defaulting to `ApiService().generateApi`. Tests pass a fake that returns scripted results or throws scripted exceptions. No test reaches the network or the real `ApiService`.

### Error mapping to UI

| Source | Section | Shown as |
| --- | --- | --- |
| branch list failure | branch dropdown | error with retry; Test locally and Publish disabled |
| local-build download failure | Test locally | error with retry; no file saved |
| 422 publish | Publish | diagnostics list; version not published |
| 409 publish | Publish | "version exists" message; versions list reloaded |
| other publish failure | Publish | generic error with status and retry |
| versions list, repository unavailable | Published versions | repository-unavailable error with retry |
| versions list, success with zero items | Published versions | empty state |
| any other failure | the affected section | generic error with status and retry |

## Risks / Trade-offs

- The companion contracts may differ in field names for diagnostics or coordinates. → Parse them into the typed results in one place, with tests built from the companion's documented JSON examples; a mismatch then fails in one test, not in the widgets.
- Blob downloads depend on the browser. → The app targets web only; the non-web branch reports an error state.
- Proposal logic duplicated between the page and the server. → The page proposes only; the server's 409 remains the authority, and the page refreshes the list on 409.
- Retaining `feat/generator-page` code that is then removed causes churn. → Removals are listed explicitly in tasks so reviewers can check them against the spec.

## Migration Plan

1. Land or rebase onto the generator page (open question 1) so `develop` contains `GeneratorPage`.
2. Ship the code PR behind no flag; the page is reachable only from the Build group, so the old commit-search path is never shipped.
3. Rollback: revert the code PR. The companion endpoints are additive, so reverting the page does not affect them.

## Open Questions

1. **Base of the code PR (blocks the code PR, not this proposal).** The generator page exists only on the unpushed `feat/generator-page` (`5451ef1e`). Should that branch land on `develop` first, or should the code PR include it? The code PR cannot be opened from a `develop` that lacks the page.
2. **Project identifier.** The local-build endpoint takes `projectId`, the releases endpoints take `projectKey`. Is `projectKey` the same value as `Project.id` in the app, or a separate field to read from the project?
3. **Repository-unavailable status.** Which HTTP status does the releases endpoint return when the repository cannot be read (503 assumed here)? The design depends on it only for the error mapping; confirm with the vulpes-generator change.
4. **Snapshot base.** Confirm that the Snapshot proposal is based on the latest published snapshot base, not on the latest Release, as described in Decisions.
5. **422 and 409 body shape.** Confirm the field names for the diagnostics list and the conflict message in the vulpes-generator ProblemDetail responses.
