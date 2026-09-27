# Spec Delta

## Purpose

Governs how requests leaving Stelaris UI prove who is making them: which credential travels with a
backend call, when it is renewed, where it must never be sent, and what happens to a request the
backend refuses as unauthenticated.

## ADDED Requirements

### Requirement: Backend requests carry the access token as a bearer credential

While a session is active, every request to the configured backend and generator services SHALL
carry an `Authorization: Bearer` header holding the **access token**. The ID token SHALL NOT be
sent to any service: it identifies the person to this application, not this application to the
backend.

#### Scenario: Request while signed in

- **WHEN** the application calls the backend while a session is active
- **THEN** the request carries an `Authorization: Bearer` header holding the access token

#### Scenario: The ID token is never sent

- **WHEN** any outgoing request is inspected
- **THEN** no request carries the ID token

### Requirement: The bearer credential goes only to the configured services

The access token SHALL be attached only to requests addressed to the configured backend and
generator services. Requests to any other destination - the application's own runtime
configuration document, the provider's discovery document and JSON Web Key Set, and anything else -
SHALL be sent without it, so that a misconfigured or substituted URL cannot collect a credential.

#### Scenario: Fetching the runtime configuration

- **WHEN** the application fetches its runtime configuration document
- **THEN** the request carries no `Authorization` header

#### Scenario: Fetching provider metadata

- **WHEN** the application fetches the discovery document or the key set
- **THEN** the request carries no `Authorization` header

#### Scenario: A destination that is not a configured service

- **WHEN** a request is addressed to an origin that is neither the backend nor the generator
- **THEN** the request carries no `Authorization` header

### Requirement: Requests do not go out with an expired access token

The application SHALL renew the access token before it expires and SHALL NOT dispatch a request
carrying an access token that has already expired. Renewal SHALL use the refresh token when the
provider supports it, and SHALL fall back to an interactive redirect rather than to a hidden frame,
because browsers block the third-party cookies a hidden-frame renewal depends on.

#### Scenario: Request made shortly before expiry

- **WHEN** a request is made while the access token is within its renewal window
- **THEN** the token is renewed first
- **AND** the request carries the renewed token

#### Scenario: Renewal without a usable refresh token

- **WHEN** the access token must be renewed and no refresh token can be used
- **THEN** the person is sent to the provider through a full navigation
- **AND** no hidden frame is used to attempt renewal

### Requirement: Concurrent requests trigger at most one renewal

When several requests need a renewed token at the same time, the application SHALL perform a single
renewal and let all of them proceed with its result. It SHALL NOT issue one renewal per request:
providers that rotate refresh tokens invalidate the session when a rotated token is presented
twice.

#### Scenario: Several requests race an expiring token

- **WHEN** multiple backend requests are dispatched while the access token needs renewal
- **THEN** exactly one renewal is performed
- **AND** every request proceeds with the renewed token

### Requirement: A rejected request is retried once after renewal

A backend response of `401` SHALL cause at most one renewal-and-retry of that request. If the
retried request is refused again, or renewal fails, the session SHALL end and the person SHALL be
sent to sign in. The application SHALL NOT retry in a loop.

#### Scenario: Rejection that renewal resolves

- **WHEN** the backend answers a request with `401` and renewal succeeds
- **THEN** the request is retried once with the renewed token
- **AND** its result is delivered to the caller as if the rejection had not happened

#### Scenario: Rejection that renewal does not resolve

- **WHEN** the backend answers the retried request with `401` as well
- **THEN** no further retry is attempted
- **AND** the session ends and the person is sent to sign in

#### Scenario: Rejection while renewal is impossible

- **WHEN** the backend answers with `401` and the token cannot be renewed
- **THEN** the session ends and the person is sent to sign in

### Requirement: Existing error reporting is unchanged

Responses other than `401` SHALL keep producing the problem details the application already
surfaces. Transport failures, timeouts and server errors SHALL NOT be reinterpreted as
authentication problems, and a `403` SHALL be reported as a refusal rather than triggering a
renewal: the credential was accepted, the action was not.

#### Scenario: Server error

- **WHEN** the backend answers with a server error
- **THEN** the existing problem detail is reported unchanged
- **AND** no renewal is attempted

#### Scenario: Forbidden

- **WHEN** the backend answers with `403`
- **THEN** the person is told the action was not permitted
- **AND** no renewal is attempted and the session continues

#### Scenario: Connection failure

- **WHEN** a request fails before a response arrives
- **THEN** the existing problem detail is reported unchanged
- **AND** the session is unaffected

### Requirement: Unauthenticated deployments send no credential

When the runtime configuration declares no identity provider, requests SHALL be dispatched exactly
as they are today, with no `Authorization` header and no renewal machinery in the path, so that a
deployment whose backend does not yet validate tokens is unaffected by this capability.

#### Scenario: No identity provider configured

- **WHEN** the application calls the backend in a deployment without an identity provider
- **THEN** the request carries no `Authorization` header
- **AND** a `401` from the backend is reported as it is today
