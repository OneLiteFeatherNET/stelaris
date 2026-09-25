# Recorded provider output

`keycloak_discovery.json` and `keycloak_claims.json` were recorded from a real
Keycloak 26.4 realm driven through the authorization code flow with PKCE, using
the same `config.json` shape a deployment uses. `keycloak_fixture_test.dart`
runs the application's own parsing, capability check and role mapping against
them.

**Claims, not tokens.** The signed tokens they came from are deliberately not
here: a JWT in a repository is a high-entropy blob that secret scanners flag,
correctly, because they cannot tell a prop from a credential. Nothing in these
tests needs a signature - the application never verifies an access token, that
being the backend's job - so `jwt_builder.dart` reassembles an unsigned token
around the recorded claims where the decoding path needs one.

Recorded rather than hand-written on purpose: hand-written claims agree with
whatever we believed when we wrote them. These caught the thing that made
`roleClaimsSource` necessary — Keycloak puts realm roles in the **access token**
and leaves them out of the ID token entirely.

## Re-recording

`keycloak-realm.json` is the realm that produced them: a public client, a user
`ada`, and the `offline_access` realm role the `offline_access` scope requires.

```sh
docker run --rm -p 18081:8080 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
  -v "$PWD/test/auth/fixtures/keycloak-realm.json":/opt/keycloak/data/import/realm.json:ro \
  quay.io/keycloak/keycloak:26.4 start-dev --import-realm
```

Then run the flow against `http://localhost:18081/realms/stelaris`, decode the
access and ID tokens, and save their claims. Do not save the tokens themselves.
