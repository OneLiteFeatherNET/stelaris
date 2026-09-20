# Connecting an identity provider

Stelaris UI authenticates through OpenID Connect. It has no built-in list of
providers: everything it needs, it reads from the issuer's discovery document at
startup or from `config.json`. Keycloak and Entra ID appear below as worked
examples because they are the two this has been run against, not because they
are the supported set. Any provider that implements discovery and the
authorization code flow with PKCE for public clients works the same way.

Leaving `auth` out of `config.json` deploys the app without authentication,
exactly as it behaved before this existed. That is the default, and it is how a
deployment runs while its backend does not yet validate tokens.

## What the app needs

| | |
|---|---|
| Discovery | `<issuer>/.well-known/openid-configuration` reachable **from the browser** |
| Client type | Public, browser-based. No client secret — a SPA cannot keep one |
| Grant | Authorization code with PKCE (S256) |
| Redirect URI | `<app origin>/redirect.html` |
| Post-logout redirect URI | `<app origin>/redirect.html` |
| CORS | The token endpoint must answer cross-origin requests from the app origin |
| Access token | A **JWT** the backend can validate — see [step 2](#step-2-make-the-access-token-validatable) |

The redirect target is a real HTML page in the bundle, not a route. It is the
same URL for sign-in and sign-out.

## Step 1: register a public client

Register the app as a browser-based public client and give it the redirect URI
for **every environment**, including local development. They are exact-match on
every provider worth using:

```
http://localhost:8080/redirect.html       # flutter run / local container
https://stelaris.staging.example/redirect.html
https://stelaris.example/redirect.html
```

A wildcard is not worth the argument with whoever owns the tenant, and some
providers refuse one for public clients anyway.

Then fill in the chart:

```yaml
config:
  auth:
    issuer: https://idp.example/realms/stelaris
    clientId: stelaris-ui
    scopes:
      - openid
      - profile
      - offline_access
```

`offline_access` is what gets a refresh token. Without it the session ends when
the access token expires and the person is redirected to sign in again — which
works, but noticeably.

> **Keycloak:** requesting `offline_access` fails with
> `{"error":"not_allowed","error_description":"Offline tokens not allowed for the user or client"}`
> unless the user holds the realm role of the same name. It is a default role
> in a stock realm, so this bites realms built from an import that replaced the
> defaults. Grant `offline_access` to the users, or to a group they are in.

**The issuer's origin also belongs in the Content-Security-Policy** if the
deployment narrowed `connect-src` away from the shipped `https:` default.
Discovery, the key set, the token exchange and every refresh are fetches to that
origin. Forgetting it produces a sign-in that fails with nothing in the
application logs — only a CSP violation in the browser console. See
[the chart README](../charts/stelaris-ui/README.md#tightening-the-content-security-policy).

## Step 2: make the access token validatable

This is the step that goes wrong, and it goes wrong invisibly: the UI cannot
tell a validatable token from an unvalidatable one. The access token is opaque
to the UI by design — only the backend inspects it. So sign-in succeeds, the
person lands in the app, and the first backend call returns 401.

What it takes is provider-specific. Two examples:

### Keycloak

Keycloak issues a JWT by default, but its `aud` claim does not name your backend
unless you say so, and a backend validating the audience will reject every
request. (Verified against Keycloak 26.4: a stock public client's access token
carries no audience for your API at all.)

1. Clients → your client → **Client scopes** → `<client>-dedicated`
2. **Add mapper** → *By configuration* → **Audience**
3. *Included Client Audience*: the backend's client id (or *Included Custom
   Audience* for a plain string), **Add to access token**: on

Then add that audience to `scopes` if the backend expects it requested
explicitly, and to `config.auth.audience` if it expects it named.

### Microsoft Entra ID

Entra ID issues an **opaque** access token unless the requested scope belongs to
an API app registration of your own. A token for Microsoft Graph scopes is not a
JWT you can validate, and no backend configuration fixes that.

1. Register a **second** app registration for the API (separate from the SPA)
2. *Expose an API* → set the Application ID URI (`api://<api-app-id>`) → **Add a
   scope**, e.g. `access_as_user`
3. In the SPA registration: *API permissions* → add that scope
4. In the SPA registration: *Authentication* → add the redirect URIs under the
   **Single-page application** platform, not Web — the Web platform expects a
   client secret and does not enable CORS on the token endpoint

   Getting this wrong fails late and confusingly: the authorization request
   succeeds, the person signs in, and only the code redemption is refused with

   ```
   AADSTS9002326: Cross-origin token redemption is permitted only for the
   'Single-Page Application' client-type.
   ```

   The same URI cannot be registered under both platforms — delete it from Web
   before adding it under Single-page application.

```yaml
config:
  auth:
    issuer: https://login.microsoftonline.com/<tenant-id>/v2.0
    clientId: <spa-app-id>
    scopes:
      - openid
      - profile
      - offline_access
      - api://<api-app-id>/access_as_user
```

Entra ID caps SPA refresh tokens at 24 hours and makes them single-use. After
that the app performs a full-page redirect to the authorization endpoint; while
the Entra session is alive the person sees nothing. It is not a bug.

### Any other provider

Find the equivalent of "issue a JWT for my own API": most call it an API,
a resource, or an audience. Then verify it rather than assuming:

```sh
# paste the access token from the browser's network tab
cut -d. -f2 <<< "$TOKEN" | base64 -d 2>/dev/null | python3 -m json.tool
```

Three dot-separated segments and a readable payload means a JWT. One opaque
blob means step 2 is not done. Check `aud` against what the backend validates.

## Step 3: find the role claim paths

OpenID Connect standardises none of this, so it is configuration. Unset,
`config.auth.roleClaims` uses defaults covering the common shapes:

| Path | Seen on |
|---|---|
| `roles` | Entra ID, Auth0 (unnamespaced) |
| `realm_access.roles` | Keycloak realm roles |
| `resource_access.<clientId>.roles` | Keycloak client roles |
| `groups` | Okta, Authentik, Zitadel |

Verified against Keycloak 26.4: realm roles arrive in the **access token** under
`realm_access.roles` and are **absent from the ID token**. A deployment that sets
`roleClaimsSource: [idToken]` there gets an empty role set from a perfectly good
session — which is why the default searches all three.

If roles come back empty, decode the access token as above and look for where
the names actually are. Then name that path:

```yaml
config:
  auth:
    roleClaims:
      - https://stelaris.example/roles     # Auth0 namespaced custom claim
```

Setting `roleClaims` **replaces** the defaults, it does not extend them: list
every path you want read. A path that is absent from the token contributes
nothing; a path holding something other than a string or a list of strings is
skipped and logged.

### When the claim holds identifiers instead of names

Some providers put an identifier where a name would be useful. Entra ID's group
claim emits a group **object id** per group, and only emits readable names for
groups synced from an on-premises directory — a cloud-only group falls back to
the id even with the claim set to `sAMAccountName`. Object ids differ per
tenant, so no code can be written against one.

`roleAliases` maps them to names the application gates on:

```yaml
config:
  auth:
    roleClaims:
      - roles
      - groups
    roleAliases:
      6dbd7a4d-d61c-47f5-8f7d-db368e3f9dae: stelaris.admin
      fa9833d5-4ec9-4b70-afc4-c85bde6a4601: stelaris.editor
```

A value nobody mapped comes through unchanged, so a token carrying real names
and opaque ids at once stays legible in both halves. Matching is exact first,
then case-insensitive — these get copied out of a portal by hand.

**Prefer app roles where the provider has them.** On Entra ID, *App roles* on
the registration let you choose the value (`stelaris.admin`), it arrives in the
`roles` claim, and it is the same string in every tenant. The alias table is for
where that is not an option — group membership that already governs access, or
a provider with no equivalent.

### And which token to read them from

A path says where in a claim set to look. `roleClaimsSource` says which claim
set — providers disagree about that just as much:

| Source | Holds roles on |
|---|---|
| `accessToken` | Keycloak (realm and client roles), Entra ID |
| `idToken` | Entra ID, Keycloak with a role mapper added |
| `userInfo` | Providers that only return group membership from the endpoint |

Unset searches all three, which is the right default for a deployment that has
not had to think about it. Naming them is also how you exclude one:

```yaml
config:
  auth:
    roleClaimsSource:
      - accessToken
      - idToken
```

The access token is **parsed, never validated** — the claims decide what the
interface offers, and the backend decides what it permits. A forged role claim
therefore buys a visible button and a 403, nothing more. An opaque access token
contributes nothing from that source and the others are still read, so a
provider that has not finished [step 2](#step-2-make-the-access-token-validatable)
still shows roles if they reach the ID token.

## Rolling it out

The `auth` block is read from `/config.json`, which nginx serves per request
from a mounted Secret. It takes effect without rebuilding the image and without
rolling the pods:

1. Ship the UI with no `auth` block. Nothing changes.
2. Add `auth` to the staging Secret. Sign-in becomes active; the backend still
   ignores the bearer header.
3. Backend enables validation in staging. Now the token matters.
4. Repeat 2 and 3 for production.

**Rollback is removing the `auth` block from the Secret.** No rollout, no
redeploy.

Between steps 2 and 3 the sign-in is cosmetic: anyone who can reach the backend
directly still gets in without a token. That window is fine while the backend is
not publicly reachable, and is worth closing quickly when it is.

## When it does not work

| Symptom | Usually |
|---|---|
| Blank page after the provider redirects back | Redirect URI mismatch — must be exactly `<origin>/redirect.html` |
| Sign-in never starts, CSP violation in the console | Issuer origin missing from `connect-src` |
| CORS error on the token endpoint | Client registered as a web/confidential client instead of a SPA |
| `AADSTS9002326` after signing in | Entra ID: redirect URI is under the Web platform; move it to Single-page application |
| Signed in, but every backend call is 401 | Step 2 — opaque token, or wrong `aud` |
| Signed in, but no roles | Step 3 — decode the token, find the real path, check `roleClaimsSource` names the token it is in |
| Roles are a list of GUIDs | A group claim emitting object ids — map them with `roleAliases`, or use app roles |
| Signed out again after roughly a day | Provider refresh-token lifetime. Expected on Entra ID |
| App runs with no sign-in at all | `auth` block absent or incomplete — it is discarded as a unit and logged |
