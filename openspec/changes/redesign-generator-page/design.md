# Design

## Context

The generator page on `feat/generator-page` is a `StoreConnector` page (`lib/feature/build/generator_page.dart`) that dispatches `ReleaseFetchAction` and `BranchFetchAction` on init. Its state lives in `BuildViewModel` (`lib/api/state/factory/build/build_vm_state.dart`), which reads `releaseModel` and `branches` from `AppState` and derives `version` with a `'0.0.1'` fallback. `GenerateApi` (`lib/api/service/generate_api.dart`) exposes `generate`, `branches`, `download` (`/download?branch&projectId`) and `buildInformation` (`/build/data`). The Build tab's `BuildTrigger` computes the bumped version in `_updateVersion`, which throws `ArgumentError` on a non-`X.Y.Z` string and is called from `initState`; its button calls `generate(branch)` and never sends the version. `DownloadTrigger` offers the branch dropdown and the commit switch, whose `DevBuildOption` sends a 10-character commit as `branch`. Downloads are triggered in `download_helper_web.dart` by building a `data:` URI from base64 content.

Requirements are in `specs/generator-page/spec.md`; motivation is in proposal.md, "Why".

The companion APIs (vulpes-generator `add-editor-release-flow`) are all keyed by the project id (UUID): `GET /projects/{projectId}/local-build?baseBranch=`, `POST /generator/release` with body `{projectId, version, baseBranch}`, `GET /projects/{projectId}/releases` and `GET /projects/{projectId}/releases/{version}/local-build`. `/git/branches` is unchanged.

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

The three sections each have their own status (loading, loaded, error with kind) in `AppState`, replacing `releaseModel`, `isLoadingRelease` and the commit-related fields. Actions: `LoadBranchesAction`, `LoadPublishedVersionsAction(projectId)`, `DownloadLocalBuildAction(projectId, baseBranch)`, `DownloadPublishedVersionAction(projectId, version)`, `PublishReleaseAction(projectId, version, baseBranch)`. Each action's `reduce` sets loading first and then a final status, and catches every exception, mapping it to an error kind (see Error mapping). The view model exposes the derived proposal (`VersionProposal` from the pure function) and `canPublish`, so widgets hold no version logic.

Alternative considered: keep the state in local `StatefulWidget` fields as `BuildTrigger` does today. Rejected because the branch selection is shared between two sections and the publish result must survive a list refresh.

### API client: typed results instead of raw Responses

`GenerateApi` returns domain types: `List<String> branches()`, `LocalBuildFile(bytes, filename)` for both downloads, `PublishResult(coordinates, revision, baseCommit, repositoryUrl)` where `baseCommit` is the full 40-character SHA, and `List<PublishedVersion>` for the list. Non-2xx responses are converted to `GeneratorApiException(kind, message, diagnostics)` where `kind` is one of `versionExists` (409), `compileFailed` (422, with the diagnostics list), `repositoryUnavailable` (502), `unexpected(status)`, or `network`. The existing `generate`, `download` (`/download`) and `buildInformation` methods are deleted with their callers; `GenerateApi.generate` is the call the spec forbids.

Downloads use `ResponseType.bytes` as today. The filename is fixed to `<project>-local.zip` for Test locally, as the spec says; for published versions it is `<project>-<version>-local.zip`.

### Version computation as a pure function

`lib/feature/build/publish/version_proposal.dart` exposes:

```dart
sealed class VersionProposal { ... }   // Proposed(version) | Unreadable(raw)
VersionProposal proposeVersion({
  required Channel channel,            // release | snapshot
  required BumpPart bump,              // major | minor | patch
  required Iterable<String> published, // all published versions of the project
});
```

Rules, applied to the latest published Release (highest `X.Y.Z` by semver, ignoring `-SNAPSHOT` versions):
- Release: no published Release gives `0.1.0`; otherwise bump the `X.Y.Z` of the latest one (major resets minor and patch, minor resets patch). Proposed version is `X.Y.Z`.
- Snapshot: the same base as the Release proposal, then `-SNAPSHOT` appended. With no published Release the snapshot is `0.1.0-SNAPSHOT`; otherwise `1.4.2` with minor gives `1.5.0-SNAPSHOT`.
- Any published version that does not match `X.Y.Z` or `X.Y.Z-SNAPSHOT` is ignored for the proposal and reported through `Unreadable`, so the page explains it and disables Publish instead of throwing.

The function takes no clock and no I/O, so tests need no fakes.

Snapshot publishing replaces the snapshot of the same version on the server. The Publish confirmation says so, and the page does not compute a free snapshot number.

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
| versions list, repository unavailable (502) | Published versions | repository-unavailable error with retry |
| versions list, success with zero items | Published versions | empty state |
| any other failure | the affected section | generic error with status and retry |

## Risks / Trade-offs

- The companion contracts may differ in field names for diagnostics or coordinates. → Parse them into the typed results in one place, with tests built from the companion's documented JSON examples; a mismatch then fails in one test, not in the widgets.
- Blob downloads depend on the browser. → The app targets web only; the non-web branch reports an error state.
- Proposal logic duplicated between the page and the server. → The page proposes only; the server's 409 remains the authority, and the page refreshes the list on 409.
- Retaining `feat/generator-page` code that is then removed causes churn. → Removals are listed explicitly in tasks so reviewers can check them against the spec.

## Migration Plan

1. The generator page lands on `develop` first, as its own pull request (from `feat/generator-page`). The code PR is opened from a `develop` that contains `GeneratorPage`.
2. Ship the code PR behind no flag; the page is reachable only from the Build group, so the old commit-search path is never shipped.
3. Rollback: revert the code PR. The companion endpoints are additive, so reverting the page does not affect them.

## Open Questions

1. **Field names of the 422 and 409 bodies.** The diagnostics list and the conflict message are fields of the ProblemDetail responses defined by the vulpes-generator `add-editor-release-flow` proposal. This change consumes them as that proposal defines them; the exact names are confirmed when task 1.1 reads that proposal, and the parsing tests use its examples.

## Settled Decisions

The product owner settled these, which were open questions in the first draft:

- **Snapshot version format.** Snapshots are Maven `X.Y.Z-SNAPSHOT`, not `-dev.N`. The snapshot proposal is the latest Release with the chosen bump plus `-SNAPSHOT`. Publishing the same snapshot again replaces it on the server; the UI says so in the confirmation. There is no "next free N" logic.
- **Project identifier.** All generator endpoints use the project id (UUID). There is no separate project key.
- **Repository unavailable.** The releases endpoint answers 502 when the repository cannot be read; the page maps it to the "unavailable" state.
- **Base of the code PR.** The generator page lands on `develop` first, as its own PR. The code PR for this change builds on that `develop`.
- **Base commit display.** The vulpes-base commit is the full 40-character SHA. The page displays its first 10 characters and offers a copy action for the full value.
