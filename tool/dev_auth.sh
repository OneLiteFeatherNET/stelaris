#!/usr/bin/env bash
# Runs the app against a local Keycloak so sign-in can be tried without a
# real identity provider. See docs/identity-provider.md#try-it-locally.
#
# What it does:
#   1. starts Keycloak (docker compose), importing docker/keycloak/realm
#   2. waits for its discovery document, bounded, not with a fixed sleep
#   3. copies docker/keycloak/config.local.json to web/config.json (gitignored:
#      it never ships and never becomes another dev's default) so the dev web
#      server serves an `auth` block
#   4. runs `fvm flutter run -d web-server` on the port Keycloak's client is
#      registered for
#
# Stopping the app (Ctrl+C) leaves Keycloak running so the next run is fast.
# Stop it explicitly with:
#   docker compose -f docker/keycloak/compose.yaml down
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYCLOAK_DIR="$ROOT/docker/keycloak"
WEB_CONFIG="$ROOT/web/config.json"
WEB_PORT="${WEB_PORT:-8080}"
KEYCLOAK_PORT="${KEYCLOAK_PORT:-8081}"
DISCOVERY_URL="http://localhost:${KEYCLOAK_PORT}/realms/stelaris/.well-known/openid-configuration"
MAX_WAIT_SECONDS=90

cleanup() {
  # The dev config is a copy the script made; remove it so a plain
  # `flutter run` afterwards goes back to unauthenticated, the default for
  # everyone who has not run this script.
  rm -f "$WEB_CONFIG"
}
trap cleanup EXIT

echo "==> Starting Keycloak (docker compose)..."
docker compose -f "$KEYCLOAK_DIR/compose.yaml" up -d

echo "==> Waiting for the realm to be ready at $DISCOVERY_URL"
waited=0
until curl --silent --fail --output /dev/null "$DISCOVERY_URL"; do
  waited=$((waited + 1))
  if [ "$waited" -ge "$MAX_WAIT_SECONDS" ]; then
    echo "Keycloak did not become ready within ${MAX_WAIT_SECONDS}s." >&2
    echo "Check it with: docker compose -f $KEYCLOAK_DIR/compose.yaml logs" >&2
    exit 1
  fi
  sleep 1
done
echo "==> Keycloak is ready."

echo "==> Writing $WEB_CONFIG"
cp "$KEYCLOAK_DIR/config.local.json" "$WEB_CONFIG"

cat <<EOF
==> Demo users (realm "stelaris"):
      admin  / admin   (stelaris.admin)
      editor / editor  (stelaris.editor)
      viewer / viewer  (no app role)

    Keycloak admin console: http://localhost:${KEYCLOAK_PORT}/admin (admin/admin)
    App:                    http://localhost:${WEB_PORT}

    No backend is started by this script. Sign-in, the roles shown in the
    account menu, and sign-out all work without one; anything that calls the
    Stelaris API (projects, items, ...) will show a connection error until
    one is running at the backendUrl configured in
    docker/keycloak/config.local.json (http://localhost:8085 by default).
EOF

echo "==> Starting the app (fvm flutter run -d web-server --web-port ${WEB_PORT})"
cd "$ROOT"
fvm flutter run -d web-server --web-port "$WEB_PORT"
