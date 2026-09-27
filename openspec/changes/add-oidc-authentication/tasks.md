# Tasks

## 1. Dependencies and runtime configuration

- [x] 1.1 Add `oidc` and `oidc_default_store` to `pubspec.yaml`, run `flutter pub get`, and verify
      `flutter analyze` is clean and `flutter build web` still succeeds
- [x] 1.2 Add an `AuthConfig` value type (issuer, clientId, scopes, optional audience, optional
      roleClaims) and parse an optional `auth` block in `lib/env/runtime_config.dart`, discarding an
      incomplete block whole and logging why — verify with new cases in
      `test/env/runtime_config_test.dart` covering absent, complete, incomplete and malformed blocks
- [x] 1.3 Default `roleClaims` to `roles`, `realm_access.roles`, `resource_access.<clientId>.roles`
      and `groups` when unset, and verify a configuration omitting the field parses to that default
      set while a configuration supplying it replaces the set rather than extending it
- [x] 1.5 Add `roleClaimsSource` to `AuthConfig`, parsing a list of `accessToken`, `idToken` and
      `userInfo` case-insensitively, defaulting to all three when unset and falling back to the
      default when nothing in the list is usable — verify with cases covering each of those
- [x] 1.4 Expose `RuntimeConfig.current.auth` as nullable and confirm existing
      `test/env/runtime_config_test.dart` cases still pass unchanged (a configuration without
      `auth` must parse exactly as before)

## 2. Auth session

- [x] 2.1 Add `web/redirect.html` as the redirect and post-logout target, and verify the built
      image serves it: `docker build` then request `/redirect.html` and assert 200 with
      `text/html`, not the app shell
- [x] 2.2 Implement `AuthSession` wrapping the `oidc` user manager — discovery from the configured
      issuer, Authorization Code Flow with PKCE, public client, no secret — and verify against a
      fake discovery document that the authorization request carries a code challenge and a state
- [x] 2.3 Reject a discovery document that does not advertise the authorization code grant with
      PKCE, naming what is missing, and verify the app does not fall through to unauthenticated
      operation
- [ ] 2.4 Reject an authorization response whose state does not match a pending request, and verify
      no token exchange is attempted in that case
- [x] 2.5 Implement session restore on startup and proactive renewal ahead of expiry, and verify a
      restored session does not trigger a redirect while renewable
- [x] 2.6 Implement renewal fallback as a full-page redirect when no refresh token is usable, and
      verify no hidden frame is created on that path
- [ ] 2.7 Implement sign-out against `end_session_endpoint` from discovery, always sending
      `id_token_hint`, and verify the local session and its tokens are discarded first
- [x] 2.8 Present a retryable error when authentication is configured but discovery fails, and
      verify the app does not fall through to unauthenticated operation
- [x] 2.9 Initialise `AuthSession` in `lib/main.dart` after `RuntimeConfig.load()` and before the
      store is built, and verify startup with no `auth` block performs no network call to any
      provider

## 3. Roles

- [x] 3.1 Implement a claims-to-roles mapper driven by the configured claim paths, resolving a
      nested path and flattening a string or list of strings, and verify with unit tests over
      recorded claim payloads for a flat claim, nested realm and client claims, a `groups` claim and
      a namespaced path
- [x] 3.2 Verify a claim path none of the defaults cover is picked up from configuration alone, with
      no change to the mapper — this is the test that proves the provider set is open
- [x] 3.3 Ignore a configured path that is absent or holds an unexpected shape, logging which path
      was skipped, and verify the remaining paths are still read and the session stays valid
- [x] 3.4 Return an empty role set for tokens carrying no role claim at any configured path, and
      verify the mapper does not throw and the session stays valid
- [x] 3.6 Give the mapper a claim bundle (access token, ID token, userinfo) and read only the
      configured sources in order, and verify roles found only in one source are picked up only
      when that source is configured
- [x] 3.7 Treat an access token that is not a JSON Web Token as an empty claim set, and verify the
      remaining sources are still read and nothing throws
- [x] 3.8 Add `roleAliases` to the configuration and apply it as roles are collected, matching
      exactly and then case-insensitively and passing unmapped values through — verify with unit
      tests over a group object id, an unmapped value, mixed case and an empty table
- [x] 3.9 Carry `roleAliases` through `values.yaml`, the config Secret and
      `docs/identity-provider.md`, and verify with a chart test that it renders and that an empty
      table leaves the document unchanged
- [x] 3.5 Add `AuthState` (status, display name, roles) to `AppState` with no token fields, and
      verify a round trip through `AppPersistor` produces a persisted document containing no token
      material

## 4. Authenticated backend calls

- [x] 4.1 Add an optional named token-source parameter to `ApiClient` and verify every existing
      test in `test/api/` still compiles and passes without modification
- [x] 4.2 Attach `Authorization: Bearer <access token>` in the existing `onRequest` hook when a
      token source is present, and verify with a mock adapter that the header carries the access
      token and never the ID token
- [x] 4.3 Implement renew-and-retry in the existing `401` branch, capped at one retry per request,
      and verify a second `401` ends the session instead of retrying again
- [x] 4.4 Verify that concurrent requests needing renewal produce exactly one renewal, using a
      counting fake token source driven through the `QueuedInterceptorsWrapper`, and add a comment
      recording why the queued variant is required
- [x] 4.5 Verify `403`, server errors and transport failures still produce the existing
      `ProblemDetail` output and trigger no renewal
- [x] 4.6 Wire the token source into `ApiService`'s backend and generator clients only, and verify
      that the `/config.json` fetch in `RuntimeConfig.load` carries no `Authorization` header
- [x] 4.7 Verify a deployment with no `auth` block sends no `Authorization` header and reports a
      `401` exactly as it does today

## 5. Routing and interface

- [x] 5.1 Add `authRedirect` as a top-level function in `lib/util/routes.dart` and compose it ahead
      of `projectSelectionRedirect` at the router's top-level `redirect`, verifying both orders of
      guard against an isolated `GoRouter` in `test/util/`
- [x] 5.2 Add the authorization-callback route and exempt it and the redirect page from the guard,
      and verify sign-in completes from a cold load of the callback URL
- [x] 5.3 Preserve the originally requested route across sign-in and verify a deep link to an item
      detail route returns to that route, while a sign-in from the root lands on the normal
      starting route
- [x] 5.4 Add the sign-in screen and the signed-in indicator with a sign-out action, and verify
      widget tests cover the signed-out, signed-in and session-expired states
- [x] 5.5 Gate role-restricted actions in the interface on the session's role set, and verify a
      widget test that an action is absent for a role set that does not permit it
- [x] 5.6 Report an expired session distinctly from a data error and send the person to sign in,
      and verify the message shown is the session message, not a `ProblemDetail`
- [x] 5.7 Add the new strings to `lib/l10n/stelaris_en.arb`, regenerate localisations, and verify
      `flutter analyze` reports no missing-key errors

## 6. Deployment

- [x] 6.1 Add `config.auth.*`, including `roleClaims`, to `charts/stelaris-ui/values.yaml`, render
      them into the existing config Secret, and verify with a new case in
      `charts/stelaris-ui/tests/config_test.yaml` that a chart without auth values renders the
      Secret exactly as it does today
- [x] 6.2 Verify via chart tests that setting the auth values renders a `config.json` whose `auth`
      block matches what `RuntimeConfig` parses, including a custom `roleClaims` list
- [x] 6.3 Document in `charts/stelaris-ui/README.md` and the CSP comments that a deployment
      narrowing `connect-src` must name the issuer origin, and verify the documented policy string
      is accepted by `nginx -t` in the built image
- [x] 6.5 Carry `roleClaimsSource` through `values.yaml`, the config Secret and
      `docs/identity-provider.md`, and verify with a chart test that it renders and that omitting it
      leaves the document unchanged
- [x] 6.4 Write `docs/` guidance for onboarding any OpenID Connect provider — the public-client
      registration, the redirect URIs per environment, how to make the provider issue a
      backend-validatable access token, and how to find the right `roleClaims` from a decoded token
      — and verify it carries worked examples for Entra ID (API app registration and exposed scope)
      and Keycloak (audience mapper) as instances of that procedure, not as the supported list

## 7. Verification against real providers

- [x] 7.1 Run the full flow against a local Keycloak realm — sign in, reload, renew, sign out — and
      record that configuration was the only thing that changed
- [ ] 7.2 Run the full flow against an Entra ID tenant with the API scope configured, and verify
      the access token is a JWT carrying the expected audience and that no code differed from 7.1
- [ ] 7.3 Run sign-in against a third provider that neither developer has configured before, using
      only `issuer`, `clientId`, `scopes` and `roleClaims`, and verify it works without a code
      change — this is the acceptance test for the provider-agnostic claim of this change
- [x] 7.4 Verify the rollout gate end to end: the same build with and without an `auth` block in
      `/config.json`, confirming the unauthenticated deployment is unchanged and that removing the
      block restores it without a rollout
