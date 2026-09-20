# Design

## Context

See `proposal.md` - Why. The constraints that actually shape the approach:

- **Browser-only.** `.metadata` lists `web` as the sole platform and only `web/` exists. There is
  no native shell, so the client is a public client: no secret, PKCE mandatory, and any package
  that depends on platform channels (`flutter_appauth`) is out.
- **Build once, promote.** `lib/env/runtime_config.dart` fetches `/config.json` at startup from a
  path nginx serves out of a mounted Secret. Nothing environment-specific may be compiled in, so
  the issuer cannot be either.
- **One interceptor already sits in the right place.** `lib/api/api_client.dart` installs a
  `QueuedInterceptorsWrapper` whose `onRequest` is an empty pass-through and whose `onError`
  already singles out `401` and rejects it. Both hooks exist; they are unimplemented.
- **`AppPersistor` serialises the entire `AppState` into `localStorage`**
  (`lib/api/state/app_persistor.dart:21`). Anything that reaches the Redux state reaches browser
  storage.
- **The CSP cannot be hardened much.** `docker/nginx/snippets/content-security-policy.conf`
  documents why `unsafe-inline` and `unsafe-eval` are non-negotiable for a Flutter bundle. Script
  injection is therefore a threat the CSP does not fully close, which is what makes token
  placement a design decision rather than a detail.
- **The router has one top-level redirect.** `lib/util/routes.dart:139` passes a single function,
  `projectSelectionRedirect`. A guard has to compose with it, not replace it.
- **No dependency injection.** The project wires collaborators through singletons
  (`ApiService._internal()`) and `async_redux`. Introducing a container is out of proportion.
- **20+ existing tests construct `ApiClient('http://backend.test/api')` positionally.** The
  constructor has to stay source-compatible.

## Goals / Non-Goals

**Goals:**

- One code path for any OpenID Connect provider a deployment configures. Entra ID and Keycloak are
  the two available to verify against; nothing in the design may assume they are the only ones.
- Authentication that can be switched on per environment without rebuilding the image, and that is
  off by default so the UI and the backend's validation can ship independently.
- Token material that never lands in `localStorage` by way of the persisted application state.
- A change to `ApiClient` that does not break its existing call sites or tests.

**Non-Goals:**

- A Backend-for-Frontend. Considered and rejected below.
- Enforcement in the user interface. Role gating is presentation; the backend is the authority.
- Offline or multi-account sessions. One signed-in person, online.
- Provider-specific adapters. A provider that cannot be accommodated by discovery plus configured
  claim paths is out of scope until one actually turns up; the mapper is the single seam for it.
- Token *validation* in the client beyond what the flow requires. The client checks the ID token's
  signature and claims as part of sign-in. It never validates the access token - that is the
  backend's job and the backend's alone. Reading claims out of a token it did not validate, to
  decide what to put on screen, is a different act and is in scope: see D5a.
- Changing how `AppPersistor` works. Tokens stay out of the state rather than the persistor
  learning to redact.

## Decisions

### D1: Public client holding the token, not a Backend-for-Frontend

The SPA performs Authorization Code Flow with PKCE and holds the tokens; the backend becomes a
plain resource server validating a bearer JWT.

*Alternative: a BFF* that terminates OIDC server-side and gives the browser an `HttpOnly` session
cookie. It is strictly better against script injection - no token is reachable from JavaScript.
It was rejected because it contradicts the deployment model this repository is built around: the
nginx in this image serves static files, is read-only, holds no secrets and is promoted unchanged
between environments (`docker/nginx/conf.d/default.conf`, `charts/stelaris-ui`). A BFF makes it
stateful, secret-bearing and environment-specific, and adds a component to operate. For an
internal model editor whose backend is the real authority, that price is not justified.

The residual risk is real and recorded under Risks. If the threat model changes - public exposure,
or data that matters outside the team - D1 is the decision to revisit, and the rest of this design
survives it: only the token acquisition and attachment change.

### D2: `oidc` + `oidc_default_store` as the client

*Alternatives:* `flutter_appauth` (no web support - disqualified), `openid_client` (web support
exists but session lifecycle, front-channel logout and renewal are left to the caller),
`oauth2_client` (OAuth2-shaped, thin on OIDC discovery and session handling), hand-rolling the flow
(PKCE, state, nonce, discovery, JWKS, rotation - a security-critical amount of code to own).

`oidc` gives discovery, PKCE, refresh with rotation, front-channel logout and a web store in one
maintained package, and is specification-driven rather than provider-driven. That is the property
that matters here: it makes every conformant provider the same code path, rather than making two
known ones work.

The web integration requires a real HTML page as the redirect target. It is added as
`web/redirect.html`. It needs no nginx change: `.html` is not in the asset-extension location in
`docker/nginx/conf.d/default.conf`, so the request falls through to `location /`, where
`try_files $uri ...` finds the file. Worth an explicit check against the built image rather than an
assumption.

### D3: Tokens live in the package store; the Redux state holds only facts about the session

`AppState` gains an `AuthState` carrying `status`, `displayName` and `roles` - no tokens, ever.
Tokens stay in the `oidc` store.

*Alternative: keep tokens in memory only.* It would defeat script injection through storage, but
it breaks reload survival (`user-auth` - "A session survives a page reload"): every refresh would
be a redirect round-trip. The refresh token in browser storage is the accepted cost of D1, not an
oversight; putting it in `AppState` as well would additionally expose it through the persisted
document, which is the part that is avoidable and therefore avoided.

### D4: Configuration is a nested block that is complete or ignored

`config.json` gains:

```json
{ "auth": { "issuer": "...", "clientId": "...", "scopes": ["..."], "audience": "..." } }
```

`RuntimeConfig` today falls back field-by-field (`_valueOr`). Authentication deliberately does not:
a block missing `issuer`, `clientId` or `scopes` is discarded whole and logged, because a
half-configured provider produces a sign-in that cannot succeed, which is worse than no sign-in at
all. `audience` is optional - providers that need it named explicitly use it, others ignore it.

Absence of the block means authentication is off. That is what makes the rollout in Migration Plan
possible, and it keeps `flutter run` working without a reachable provider.

### D5: Role claim paths are configuration, not a provider discriminator

Discovery covers everything OpenID Connect standardises. Role names are the conspicuous exception:
the specification says nothing about where they live, and every provider chose differently - a flat
`roles` (Entra ID), `realm_access.roles` and `resource_access.<clientId>.roles` (Keycloak), `groups`
(Okta, Authentik), a namespaced URI (Auth0), a nested object keyed by project (Zitadel). So
`auth.roleClaims` is a list of claim paths, each addressing a nested key, defaulting to the common
shapes above when unset.

*Alternative 1: a `provider: entra | keycloak | ...` discriminator selecting a built-in mapper.*
Rejected. It makes the supported provider set a property of the bundle, so every new provider is a
release - which is the opposite of the reason the issuer is configured rather than compiled in.

*Alternative 2: union of the known shapes, no configuration* (what this design said before the
provider set was understood to be open). Rejected for the same reason: it works until provider
number three, then needs code.

*Alternative 3: a claim-mapping expression language.* Rejected as disproportionate - a list of
dotted paths reading strings or lists of strings covers every shape found above, and the failure
mode of a richer language is a configuration that cannot be debugged from a log line.

A path holding something unexpected contributes nothing and is logged rather than failing the
session: a role claim that is not the shape we expect is a configuration problem for an operator to
see, not a reason to lock someone out.

### D5a: Which token the paths are read from is configuration too

Implementation surfaced a gap D5 had left: a path says *where in a claim set* to look, not *which
claim set*. The providers disagree about that as well. Keycloak puts realm and client roles in the
access token and needs an extra mapper to copy them into the ID token; Entra ID emits `roles` in
both; several providers expose group membership only from the userinfo endpoint. Reading the wrong
one produces an empty role set that looks exactly like a permissions problem.

So `auth.roleClaimsSource` is a list of claim sets - `accessToken`, `idToken`, `userInfo` - searched
in the order given, defaulting to all three when unset. The deployment states where its roles live;
the application does not guess.

Reading the access token this way means parsing a JWT the client did not validate. That is sound
for this purpose and only this purpose: the claims decide what the interface offers, never what it
permits. The backend validates the same token and refuses anything the roles did not really allow,
so a forged claim buys a person a visible button and a 403. An access token that is opaque - Entra
ID without an API scope - simply yields nothing from that source, and the remaining sources are
still read.

*Alternative 1: read every source unconditionally, with no field.* The original plan. Rejected once
it was clear that "where roles live" is a real per-deployment fact: searching everywhere hides a
misconfiguration instead of surfacing it, and silently reads tokens a deployment may not want read.

*Alternative 2: a source prefix on each path* (`access_token:realm_access.roles`). More precise, and
rejected as more configuration syntax than the problem needs - no provider found so far requires two
different sources for two different paths.

### D6: The bearer is scoped structurally, not by a URL check

Only the clients built for the backend and generator (`ApiService._createApiClient`,
`_createGeneratorClient`) get the auth interceptor. `RuntimeConfig.load` already uses its own bare
`Dio`, and `oidc` uses its own transport for discovery and token calls. So "the token goes only to
the configured services" holds because nothing else runs through an authenticated client - not
because a matcher decides per request. Structural beats a matcher: there is no rule to get wrong
when a new call site appears, only a client to pick.

`ApiClient` takes the token source as a **named optional** parameter. Omitted, it behaves exactly
as today, which is what keeps the existing tests compiling and gives tests a seam to inject a fake.

### D7: Renewal rides the existing `QueuedInterceptorsWrapper`

The queued variant serialises interception, so a burst of concurrent requests cannot start
concurrent renewals - which matters because both providers rotate refresh tokens and a token
presented twice kills the session. This is the reason to keep `QueuedInterceptorsWrapper` rather
than "simplify" it to `InterceptorsWrapper` later; the choice gets a comment saying so.

Renewal is proactive (before expiry) with `401`-triggered renew-and-retry as the fallback, capped
at one retry per request. No hidden-frame silent renew: browsers block the third-party cookies it
depends on, so the fallback when refresh is unavailable is a full-page redirect - seamless while
the provider session lives.

### D8: Startup order and lazy wiring

`main()` runs `RuntimeConfig.load()`, then initialises the auth session when configuration demands
it, then builds the store. `ApiService`'s clients are already `late final`, so they are constructed
on first use - after startup - and can read the initialised session through the same singleton
pattern the project already uses. No container, no change to how the app is composed.

### D9: The guard composes with the existing redirect

`routes.dart:139` becomes `redirect: (context, state) => authRedirect(context, state) ?? projectSelectionRedirect(context, state)`.
Authentication is evaluated first: bouncing an unauthenticated visitor to `/projects` and only then
to sign-in would lose the route they asked for. `authRedirect` is a top-level function like its
neighbours, for the same reason the existing ones are - so it can be tested against an isolated
`GoRouter`.

The callback route and `web/redirect.html` are exempt from the guard, or sign-in cannot complete.

### D10: Sign-out always sends `id_token_hint`

Keycloak has required it at `end_session_endpoint` since version 18; Entra ID accepts it. Sending
it unconditionally is one code path instead of two.

### D5b: Identifiers are renamed by a table, not resolved against a directory

Entra ID's group claim emits a group object id per group, readable names only for groups synced
from an on-premises directory. Those ids differ per tenant, so gating code cannot name one.
`auth.roleAliases` maps raw value to name, applied as roles are collected.

*Alternative: resolve the ids at runtime against the provider's directory API.* Rejected, and worth
saying why at length, because it is the obvious idea:

- It is provider-specific by construction. Microsoft Graph is not an OpenID Connect endpoint and has
  no equivalent anywhere else, so this would be the first thing in the client that knows which
  product is on the other end - against the point of the whole change.
- It needs a second access token, for a different audience, with its own consent
  (`GroupMember.Read.All` is admin-consent in many tenants). A person who can sign in would be shown
  no roles until an administrator agrees, and the failure looks like a permissions bug.
- It adds a network round trip to every sign-in, on a path that currently cannot fail.
- It widens the CSP to a host the app otherwise never talks to.

*Alternative: fetch a mapping document from a configured URL* (`roleAliasesUrl`), so something
outside the app can generate it - a nightly job against whatever directory a deployment runs.
Deferred rather than rejected: it keeps the client provider-agnostic and is additive to this design,
the same table arriving by a different route. Not built because nobody has asked for a table big
enough to need it.

## Risks / Trade-offs

- **Script injection can steal the refresh token** → Not eliminated, bounded. Tokens stay out of
  `AppState` (D3), access-token lifetimes stay short, refresh rotation is on, and the chart's
  `nginx.contentSecurityPolicy` lets each environment narrow `connect-src` from `https:` to named
  origins. The structural fix is the BFF in D1, deliberately deferred.

- **Providers impose token lifetimes the application does not control** → Entra ID, for one, caps
  SPA refresh tokens at 24 hours and makes them single-use, after which the app performs a
  full-page redirect to the authorization endpoint. While the provider session is alive this is
  invisible; when it is not, the person signs in again. The design assumes no minimum lifetime, so
  a stricter provider costs redirects, not correctness. Documented so it is not diagnosed as a bug.

- **A discovery document can understate what a provider supports** → Entra ID v2.0 omits both
  `code_challenge_methods_supported` and `grant_types_supported` while supporting S256 and the
  authorization code grant. The capability check therefore refuses only what a provider explicitly
  rules out, and treats silence as "proceed and log". The cost is that a provider which silently
  ignores the code challenge is not caught here - it degrades to a plain authorization code flow,
  which is what a provider without PKCE would have given anyway.

- **A provider can issue an access token the backend cannot validate, and the UI cannot tell** →
  An opaque token, or one carrying the wrong audience, produces a sign-in that looks entirely
  successful until the first backend call. Entra ID does this unless a scope from an API app
  registration is requested; Keycloak does it unless an audience mapper is configured; others have
  their own variant. There is no client-side check worth building - the access token is opaque to
  the UI by design - so the mitigation is deployment documentation naming the requirement per
  provider, and verifying it once per environment.

- **An unforeseen provider puts roles somewhere the defaults do not reach** → Roles come back
  empty, which looks like a permissions problem. Mitigated by D5 making the paths configurable, by
  logging which configured paths yielded nothing, and by surfacing the empty role set in the
  interface rather than silently hiding every gated action.

- **A misdeployed Secret silently disables authentication** → This is the cost of D4's
  fail-open-by-absence. Mitigated by the diagnostic on an incomplete block and by the deployment
  documentation, not by the code: fail-closed would make every `flutter run` and every
  not-yet-migrated environment unusable, which is the outcome the config gate exists to avoid.

- **`web/redirect.html` interacts with nginx rules written for a bundle without extra HTML pages**
  → Reasoned through in D2 and expected to work unchanged; verified against the built image rather
  than asserted.

- **`ApiClient`'s constructor is load-bearing for 20+ tests** → Additive named parameter only
  (D6). A required parameter would be a mechanical but repo-wide edit for no benefit.

## Migration Plan

1. Ship the UI with no `auth` block in any `config.json`. Behaviour is unchanged; the code is in
   place and dormant.
2. Add the `auth` block to the staging Secret. Sign-in becomes active; the backend still ignores
   the bearer header.
3. The backend enables JWT validation in staging. Now the credential matters. Verify against both
   providers here.
4. Repeat 2 and 3 for production.

**Rollback**: remove the `auth` block from the Secret. nginx re-reads `/config.json` per request,
so it takes effect without a rollout and without redeploying the image. This is the reason
authentication is configuration-gated rather than compiled in.

## Open Questions

- **Which role names does the application gate on?** The mapper and the gating mechanism do not
  depend on the answer; only the constants and which widgets consult them do. Answerable when the
  roles are defined in whichever provider a deployment uses.
- **Does the generator service accept the same audience as the backend?** Assumed yes - one token,
  both clients. If it needs its own audience, the fix is additive: acquire a second token for that
  scope and give the generator client its own source. That does not change D6 or the task
  structure, which is why it is not resolved here.
