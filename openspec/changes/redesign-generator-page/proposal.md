# Proposal

Commit type and scope: `feat(build)`. The code ships as `feat(build): build, test locally and list releases on the generator page`.

## Why

The generator page (moved out of the build dialog into the "Build" rail group at `/generator`, on the unpushed branch `feat/generator-page`) only half works for the Vulpes Gradle plugin. Its "search by commit" switch sends a commit hash as a branch name and can never succeed. Its build button calls `GET /generate?branch=master|develop`, which never receives the version the maintainer picked, so the version bump the page shows does not reach the build. The header reports the vulpes-base GitHub release, not what the project has published. A version string that is not `X.Y.Z` crashes the page on open. A maintainer who wants to try a change to a project's generated code, or publish a new release of it, has no working path from the page.

The product owner needs the page to work end to end for the Vulpes Gradle plugin until the full redesign lands. The vulpes-generator and vulpes-gradle-plugin companion changes provide the API and the local-override mechanism; this change is the page that uses them.

## What Changes

- The generator page shows three sections, in order: **Test locally**, **Publish**, **Published versions**.
- A vulpes-base branch dropdown, filled from `/git/branches` with `develop` as the default, is shared by Test locally and Publish.
- **Test locally** downloads `<project>-local.zip` for the selected branch and explains where to unzip it (project root, giving `vulpes/<project>/`) and that the Gradle plugin then prefers it over the published version.
- **Publish** proposes the next version from the latest published version of the selected channel (major, minor or patch bump; first release `0.1.0`), offers the Release (`X.Y.Z`) or Snapshot (`X.Y.Z-dev.N`) channel, shows the full version, asks for confirmation, and on success shows coordinates, revision, the vulpes-base commit and a copyable `vulpes("<coordinates>")` line. A 422 shows the compiler diagnostics; a 409 says the version exists and refreshes the list.
- **Published versions** lists versions newest first with channel, coordinates, repository URL and the actions download as local ZIP and copy Gradle line. The empty state and the repository-unavailable error state are distinct.
- Removed (never released; not a breaking change): the "search by commit" switch, the `GET /generate` call, the vulpes-base GitHub release status header, and the crash on a version string that is not `X.Y.Z`.
- Every request shows a loading state and a mapped error state; no request error escapes as an unhandled exception.

## Capabilities

### New Capabilities

- `generator-page`: the generator page in the Build group: local test download, publishing a release or snapshot of a project's generated code to vulpes-base, and listing the project's published versions.

### Modified Capabilities

None. No existing spec under `openspec/specs/` covers the generator page.

## Dependencies and sequencing

- Companion proposals, referenced and not implemented here: vulpes-generator `add-editor-release-flow` (the new `local-build`, `generator/release` and `releases` endpoints) and vulpes-gradle-plugin `add-local-content-override` (the plugin reads `vulpes/<project>/` before the Maven artifact).
- The generator page exists only on the unpushed `feat/generator-page` (commit `5451ef1e`). The code PR must branch from a `develop` that already contains that page. Whether that branch lands first, or is folded into the code PR, is an open question (see design.md).
- This proposal's PR merges before the code PR is opened.

## Impact

- Code (`stelaris`, later): `lib/feature/build/**`, `lib/api/service/generate_api.dart`, `lib/api/state/actions/build/build_actions.dart`, `lib/api/state/factory/build/build_vm_state.dart`, l10n strings in `lib/l10n/`, and tests under `test/feature/build/` and `test/api/`.
- API: calls the new vulpes-generator endpoints listed above; the `/generate`, `/download` and `/build/data` calls of the current client are no longer used by the page.
- No change to the navigation entry, route, or other pages.
- No new third-party dependency expected.
