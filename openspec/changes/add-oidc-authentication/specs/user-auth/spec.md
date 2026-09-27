# Spec Delta

## Purpose

Establishes who is using Stelaris UI: how a person signs in through whichever OpenID Connect
provider a deployment configures, how that session is kept alive and ended, what the application is
allowed to remember about it, and which roles the signed-in person holds.

## ADDED Requirements

### Requirement: Authentication is activated by runtime configuration

The application SHALL require authentication only when the runtime configuration declares a
complete identity-provider configuration: an issuer, a client identifier and at least one scope.
No provider is privileged: the same three fields activate any of them.
When that configuration is absent, the application SHALL behave exactly as an unauthenticated
build: no sign-in, no guarded routes, no role evaluation. An incomplete configuration SHALL be
treated as absent and SHALL be reported as a diagnostic, because a half-configured provider that
silently enables authentication cannot be signed in to.

#### Scenario: No identity provider configured

- **WHEN** the served runtime configuration contains no identity-provider configuration
- **THEN** the application starts without prompting for sign-in
- **AND** every route is reachable as it is today

#### Scenario: Identity provider configured

- **WHEN** the served runtime configuration declares an issuer, a client identifier and scopes
- **THEN** an unauthenticated visitor is sent to the provider before any application route renders

#### Scenario: Incomplete identity-provider configuration

- **WHEN** the served runtime configuration declares an issuer but no client identifier
- **THEN** the application starts unauthenticated
- **AND** a diagnostic records that the identity-provider configuration was ignored and why

### Requirement: Any conformant provider works without a code change

The application SHALL work with any identity provider that implements OpenID Connect discovery and
the Authorization Code Flow with PKCE for public clients. It SHALL obtain every endpoint -
authorization, token, JWKS and end-session - from the issuer's discovery document, and SHALL NOT
compile in an endpoint, a tenant or realm identifier, or a provider-specific URL shape. Changing
provider SHALL be a change to the served configuration and nothing else. Microsoft Entra ID and
Keycloak are named below as worked examples, not as the supported set.

#### Scenario: A tenant-shaped issuer, such as Microsoft Entra ID

- **WHEN** the configured issuer is an Entra ID tenant endpoint
- **THEN** sign-in, renewal and sign-out use the endpoints that tenant's discovery document
  advertises

#### Scenario: A realm-shaped issuer, such as Keycloak

- **WHEN** the configured issuer is a Keycloak realm endpoint
- **THEN** sign-in, renewal and sign-out use the endpoints that realm's discovery document
  advertises
- **AND** no code path differs from the previous scenario

#### Scenario: A provider nobody has configured before

- **WHEN** the configured issuer belongs to a provider this application has never been run against,
  and its discovery document advertises the authorization, token and JWKS endpoints and support for
  the authorization code grant with PKCE
- **THEN** sign-in succeeds without any change to the application

#### Scenario: A provider that says it cannot do the required flow

- **WHEN** the discovery document advertises the code challenge methods it supports and S256 is not
  among them, or it does not advertise the authorization code grant, an authorization endpoint or a
  token endpoint
- **THEN** the application reports that the configured provider cannot be used and names what is
  missing
- **AND** the application does NOT fall back to unauthenticated operation

#### Scenario: A provider that advertises no code challenge methods at all

- **WHEN** the discovery document omits the supported code challenge methods entirely
- **THEN** the application proceeds, sending S256 as it would have anyway
- **AND** a diagnostic records that the provider's support could not be confirmed

Silence and refusal are deliberately different answers. A live Microsoft Entra ID v2.0 document
omits this field while accepting S256, so treating omission as a refusal would reject a provider
that works.

#### Scenario: Discovery document unreachable

- **WHEN** authentication is configured but the discovery document cannot be retrieved
- **THEN** the application presents a retryable error
- **AND** the application does NOT fall back to unauthenticated operation

### Requirement: Sign-in uses Authorization Code Flow with PKCE

The application SHALL authenticate using the OpenID Connect Authorization Code Flow with PKCE as a
public client. It SHALL NOT hold or transmit a client secret, and SHALL reject an authorization
response whose state does not match the request that started the flow.

#### Scenario: Successful sign-in

- **WHEN** an unauthenticated person requests an application route and completes authentication at
  the provider
- **THEN** the application exchanges the authorization code using the PKCE verifier it generated
- **AND** the person is signed in

#### Scenario: Authorization response with a mismatched state

- **WHEN** an authorization response arrives whose state does not match a pending request
- **THEN** the response is rejected and no token exchange takes place
- **AND** the person remains unauthenticated

### Requirement: The originally requested route survives sign-in

A person who is sent to the provider from a deep link SHALL return to that route after signing in,
not to a default landing page. A person who signs in from the application's entry point SHALL land
on the application's normal starting route.

#### Scenario: Deep link into a detail route

- **WHEN** an unauthenticated person opens a project detail route directly and signs in
- **THEN** that detail route is shown after the authorization response is processed

#### Scenario: Sign-in from the entry point

- **WHEN** an unauthenticated person opens the application root and signs in
- **THEN** the application's normal starting route is shown

### Requirement: Roles are read from configured claim paths

OpenID Connect does not standardise where role names live, so both the claim paths to read and the
claim sets to read them from SHALL be part of the runtime configuration. The application SHALL
search the configured claim sets - the access token, the ID token and the userinfo response - in the
order given, collect role names from every configured path present in them, flattening a list of
strings and ignoring a path that is absent, and normalise the result into one role set that feature
code consults without knowing the provider.

When no claim sets are configured, all three SHALL be searched. A claim set that cannot be read -
an access token that is not a JSON Web Token, a userinfo response the provider did not return -
SHALL contribute nothing and SHALL NOT prevent the others from being read.

Reading an access token this way is not validation and SHALL NOT be treated as any: the claims
decide only what the interface offers. The backend remains the authority over what is permitted.

When no paths are configured, a default set SHALL be used that covers the common shapes: a flat
`roles` claim, `realm_access.roles`, `resource_access.<clientId>.roles`, and `groups`. A path
SHALL be able to address a nested claim, so that a provider placing roles under a namespaced or
nested key is supported by configuration alone.

A role value MAY be renamed on the way in, through a table of raw value to name that is part of the
runtime configuration. Providers that emit identifiers rather than names - a group object id, for
one - are otherwise ungateable, because such an identifier differs per tenant and no code can name
it. A value the table does not cover SHALL pass through unchanged, so a claim carrying names and
identifiers at once stays usable in both halves.

Absent role claims SHALL yield an empty role set, not an error: a provider that grants no roles is
a valid state.

#### Scenario: A flat role claim, such as Entra ID's

- **WHEN** the access token carries a flat list of role names under `roles`
- **THEN** those names form the signed-in person's role set

#### Scenario: Nested realm and client claims, such as Keycloak's

- **WHEN** the access token carries realm roles and roles for the configured client
- **THEN** both contribute to the signed-in person's role set

#### Scenario: Roles that live only in the access token

- **WHEN** the configured claim sets include the access token, and role names are present there but
  not in the ID token
- **THEN** those names form the signed-in person's role set

#### Scenario: Roles that live only in the userinfo response

- **WHEN** the configured claim sets include the userinfo response, and role names are present only
  there
- **THEN** those names form the signed-in person's role set

#### Scenario: An access token that is not a JSON Web Token

- **WHEN** the configured claim sets include the access token and the provider issued an opaque one
- **THEN** that claim set contributes nothing
- **AND** the remaining configured claim sets are still read
- **AND** the session remains valid

#### Scenario: A claim set the configuration excludes

- **WHEN** a claim set is not named in the configuration and role names are present only there
- **THEN** those names do NOT form part of the role set

#### Scenario: A provider-specific claim path

- **WHEN** the configuration names a claim path that none of the defaults cover, and the token
  carries role names at that path
- **THEN** those names form the signed-in person's role set
- **AND** no change to the application was required to support that provider

#### Scenario: A configured path that the token does not carry

- **WHEN** a configured claim path is absent from the token
- **THEN** that path contributes nothing
- **AND** the remaining configured paths are still read

#### Scenario: A configured path holding something other than role names

- **WHEN** a configured claim path holds a value that is not a string or a list of strings
- **THEN** that path contributes nothing
- **AND** a diagnostic records which path was ignored and why
- **AND** the session remains valid

#### Scenario: A claim value that is an identifier rather than a name

- **WHEN** the configuration maps a raw claim value to a role name, and a token carries that value
- **THEN** the signed-in person holds the mapped name
- **AND** the raw value is not part of the role set

#### Scenario: A claim value the table does not cover

- **WHEN** a token carries a value the alias table does not name
- **THEN** that value forms part of the role set unchanged

#### Scenario: No role claims present

- **WHEN** the access token carries no role claim at any configured path
- **THEN** the signed-in person holds an empty role set
- **AND** the application remains usable for everything that does not require a role

### Requirement: The interface reflects the signed-in person's roles

Actions the signed-in person's roles do not permit SHALL NOT be offered in the interface. This is a
presentation rule, not an enforcement boundary: the backend remains the authority, and the
application SHALL handle a rejection from it even for an action it chose to offer.

#### Scenario: An action the roles do not permit

- **WHEN** the signed-in person lacks the role a destructive action requires
- **THEN** that action is not offered in the interface

#### Scenario: The backend rejects an offered action

- **WHEN** the backend refuses an action the interface offered
- **THEN** the person is told the action was not permitted
- **AND** the application stays usable

### Requirement: A session survives a page reload

A signed-in person SHALL remain signed in across a page reload and across opening the application
in a new tab of the same browser, for as long as the session can be renewed without interaction.

#### Scenario: Reload with a live session

- **WHEN** a signed-in person reloads the page
- **THEN** the application restores the session without sending them to the provider

#### Scenario: Reload after the session can no longer be renewed

- **WHEN** a signed-in person reloads the page and the session can no longer be renewed
- **THEN** the person is sent to the provider to sign in again

### Requirement: Tokens are kept out of persisted application state

Access tokens, refresh tokens and ID tokens SHALL NOT be written into the application state that is
persisted for the user interface. That state is serialised in full to browser storage alongside
preferences, and the application runs under a Content-Security-Policy that Flutter forces to permit
inline and evaluated script, so anything placed there is reachable by injected script. Only
non-secret facts about the session - whether someone is signed in, their display name and their
roles - SHALL be exposed to the interface.

#### Scenario: Persisted state after sign-in

- **WHEN** a person signs in and the application persists its state
- **THEN** the persisted document contains no access token, refresh token or ID token

#### Scenario: What the interface can read

- **WHEN** interface code reads the application state
- **THEN** it can determine whether someone is signed in, their display name and their roles
- **AND** it cannot read any token

### Requirement: Sign-out ends both sessions

Signing out SHALL discard the local session and its tokens and SHALL end the session at the
provider through the end-session endpoint from the discovery document, so that returning to the
application does not silently sign the person back in. After sign-out the application SHALL be in
its signed-out state with no residual session data.

#### Scenario: Person signs out

- **WHEN** a signed-in person signs out
- **THEN** the local session and its tokens are discarded
- **AND** the provider's end-session endpoint is invoked
- **AND** the application returns to its signed-out state

#### Scenario: Returning after sign-out

- **WHEN** a person navigates back to the application after signing out
- **THEN** they are unauthenticated and must sign in again

### Requirement: An expired session is reported, not swallowed

When a session ends because it can no longer be renewed, the application SHALL tell the person that
the session expired and SHALL send them to sign in again. It SHALL NOT present the resulting
failures as ordinary errors from the data they were editing.

#### Scenario: Session expires while the application is open

- **WHEN** a signed-in person's session can no longer be renewed
- **THEN** the person is told the session expired
- **AND** the person is sent to sign in again
