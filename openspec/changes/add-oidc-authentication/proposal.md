# Proposal

## Why

Stelaris UI has no authentication at all: anyone who can reach the deployment can read and edit
every project, item, font, sound and notification, and every request to the backend goes out
unauthenticated. The backend will start validating JWTs, so the UI has to obtain one and send it.

Which identity provider issues that token is an operator's decision, not this project's. Microsoft
Entra ID and Keycloak are the two named so far, but they are examples - a deployment may put any
OpenID Connect provider behind the same configuration. The client is therefore built against the
specification rather than against a product: everything providers vary - endpoints, claim names,
token lifetimes - is discovered at runtime or configured, never compiled in.

Doing this now also protects the deployment model: the image is built once and promoted across
environments, so every environment-specific value has to arrive through `/config.json`. Adding
authentication later, after provider details have leaked into the bundle, is the expensive version
of this change.

## What Changes

- **Sign-in via OpenID Connect Authorization Code Flow with PKCE.** The app is a browser-only
  Flutter build (`.metadata` lists `web` as its sole platform), so it is a public client with no
  client secret. Provider endpoints come from the issuer's discovery document, never from
  hardcoded URLs.
- **Runtime configuration gains an `auth` block** (`issuer`, `clientId`, `scopes`, optional
  `audience`, `roleClaims` and `roleClaimsSource`). Switching providers is a change to the mounted
  Secret - no rebuild, no code change, including for a provider nobody has tried yet.
- **Authentication is config-gated.** A `config.json` without an `auth` block leaves the app
  behaving exactly as it does today: no sign-in, no bearer header. This lets the UI and the
  backend's JWT validation ship in separate releases, and keeps `flutter run` usable without a
  reachable identity provider. Not a breaking change for existing deployments.
- **Backend calls carry `Authorization: Bearer <access token>`**, renewed before expiry and
  refreshed on a `401`. The access token is sent, not the ID token.
- **Roles from the token drive the UI.** Where a provider puts role names is the one thing OpenID
  Connect does not standardise. The claim paths to read are therefore configuration, with defaults
  covering the common shapes - a flat `roles` (Entra ID), `realm_access.roles` and
  `resource_access.<client>.roles` (Keycloak), a plain `groups` (Okta, Authentik and others). They
  are normalised into one role set, so feature code never branches on the provider and an
  unforeseen provider is a configuration entry rather than a code change. Which token the paths are
  read from - access token, ID token, userinfo response - is configured alongside them, because
  providers disagree about that too, and a table maps raw values to names for providers that emit
  identifiers where names would be useful.
- **Routes are guarded.** An unauthenticated visit to any app route lands on sign-in and returns
  to the originally requested route afterwards, following the redirect pattern already used for
  project selection.
- **Sign-out** ends both the local session and the provider session via `end_session_endpoint`.
- **Deployment surface grows**: the Helm chart carries the `auth` fields in its config Secret, and
  the documented Content-Security-Policy has to name the issuer origin once a deployment tightens
  `connect-src` away from `https:`.

## Capabilities

### New Capabilities

- `user-auth`: How a person signs in, stays signed in and signs out - the OpenID Connect flow, the
  session and its renewal, the role set derived from token claims, route guarding, and the
  configuration that turns all of it on or off.
- `api-authentication`: How outgoing backend requests are authenticated - bearer attachment, token
  renewal ahead of expiry, and what happens to a request the backend rejects with `401`.

### Modified Capabilities

<!-- None. The project has no specs yet (`openspec list --specs` reports none), so both
     capabilities above are the first in the repository. -->

## Impact

**Affected code**

- `lib/env/runtime_config.dart` - parse and expose the optional `auth` block; an absent or
  incomplete block means authentication stays off.
- `lib/api/api_client.dart` - the existing `QueuedInterceptorsWrapper` gains bearer attachment in
  `onRequest` and refresh-and-retry in its `401` branch. The queued variant is what keeps
  concurrent requests from triggering parallel refreshes.
- `lib/api/api_service.dart` - the singleton's `late final` clients have to receive the auth
  dependency without being constructed before configuration is loaded.
- `lib/util/routes.dart` - an auth guard alongside `projectSelectionRedirect`, plus the callback
  route.
- `lib/main.dart` - initialise the auth session after `RuntimeConfig.load()` and before the store
  is built.
- `lib/api/state/` - authentication status, display name and roles enter `AppState`; tokens must
  not, because `AppPersistor` serialises the whole state into `localStorage`.
- `lib/l10n/` - strings for sign-in, sign-out, session expiry and access-denied.
- `web/` - a redirect landing page for the authorization response.

**Dependencies**

- One new package for the OpenID Connect client. `flutter_appauth` is not a candidate: it has no
  web support.

**Deployment**

- `charts/stelaris-ui` - `config.auth.*` values, rendered into the existing config Secret, plus
  chart tests.
- `docker/nginx/snippets/content-security-policy.conf` and the chart's
  `nginx.contentSecurityPolicy` documentation - a deployment that names its origins must include
  the issuer.
- Redirect URIs have to be registered with each provider per environment.

**Provider-side prerequisites, outside this repository**

Every provider needs a client registered as a browser-based public client carrying the deployment's
redirect URIs, and has to be made to issue an access token the backend can validate. The second
part is provider-specific and is what costs calendar time rather than code:

- Entra ID issues a JWT access token only for a scope exposed by an API app registration
  (`api://<api-app-id>/...`). Without one the token is opaque and no backend can validate it. That
  registration is tenant-administration work.
- Keycloak needs an audience mapper on the client, or `aud` defaults to `account`.
- Any other provider needs its own equivalent.

The UI cannot detect the difference - an opaque or wrongly-scoped token looks like a successful
sign-in right up until the backend rejects it - so this belongs in the deployment documentation,
not in a runtime check.
