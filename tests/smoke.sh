#!/usr/bin/env bash
# Smoke test for dgcosenza/nextcloud-spreed-signaling.
#
# Verifies both default drop-in startup (/config/server.conf) and hardened
# rootless + read-only + cap_drop ALL startup (CONFIG=/tmp/server.conf),
# healthy /api/v1/welcome JSON response, non-root execution (uid 850),
# graceful SIGUSR1 shutdown via /stop.sh, and negative healthcheck failure.
#
# Usage: tests/smoke.sh [image]
#        IMAGE=dgcosenza/nextcloud-spreed-signaling:latest tests/smoke.sh
set -euo pipefail

IMAGE="${1:-${IMAGE:-dgcosenza/nextcloud-spreed-signaling:latest}}"
NAME="${NAME:-signaling-smoke}"
NAME_RO="${NAME_RO:-signaling-smoke-ro}"

cleanup() {
  docker rm -f "$NAME" "$NAME_RO" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "== 1. Default drop-in run (/config/server.conf, uid 850)"
docker run -d --name "$NAME" \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  -e HTTP_LISTEN=:8080 \
  -e NATS_URL=nats://loopback \
  -e HASH_KEY=0123456789abcdef0123456789abcdef \
  -e BLOCK_KEY=0123456789abcdef \
  -e INTERNAL_SHARED_SECRET_KEY=ci-smoke-internal-secret \
  -e BACKENDS=cloud \
  -e BACKEND_CLOUD_URLS=https://example.invalid \
  -e BACKEND_CLOUD_SHARED_SECRET=ci-smoke-backend-secret \
  "$IMAGE"

for _ in $(seq 1 45); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$NAME")"
  [ "$status" = "healthy" ] && break
  [ "$status" = "unhealthy" ] && { docker logs "$NAME"; exit 1; }
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' "$NAME")" = "healthy"
test "$(docker exec "$NAME" id -u)" = "850"
test "$(docker exec "$NAME" id -g)" = "850"
docker exec "$NAME" ps -o user= -C nextcloud-spreed-signaling | grep -q 'spreedbackend'

welcome="$(docker exec "$NAME" wget -q -O - http://127.0.0.1:8080/api/v1/welcome)"
echo "welcome: ${welcome}"
printf '%s' "$welcome" | grep -q '"nextcloud-spreed-signaling"'
printf '%s' "$welcome" | grep -q '"version"'
docker exec "$NAME" /usr/bin/nextcloud-spreed-signaling -version

echo "== 2. Hardened rootless + read-only rootfs run (CONFIG=/tmp/server.conf)"
docker run -d --name "$NAME_RO" \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp:noexec,nosuid,size=16m \
  -e CONFIG=/tmp/server.conf \
  -e HTTP_LISTEN=:8080 \
  -e NATS_URL=nats://loopback \
  -e HASH_KEY=0123456789abcdef0123456789abcdef \
  -e BLOCK_KEY=0123456789abcdef \
  -e INTERNAL_SHARED_SECRET_KEY=ci-smoke-internal-secret \
  -e BACKENDS=cloud \
  -e BACKEND_CLOUD_URLS=https://example.invalid \
  -e BACKEND_CLOUD_SHARED_SECRET=ci-smoke-backend-secret \
  "$IMAGE"

for _ in $(seq 1 45); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$NAME_RO")"
  [ "$status" = "healthy" ] && break
  [ "$status" = "unhealthy" ] && { docker logs "$NAME_RO"; exit 1; }
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' "$NAME_RO")" = "healthy"
test "$(docker exec "$NAME_RO" id -u)" = "850"

echo "== 3. Negative test: graceful /stop.sh shutdown and healthcheck failure"
docker exec "$NAME" /stop.sh
for _ in $(seq 1 20); do
  running="$(docker inspect -f '{{.State.Running}}' "$NAME")"
  [ "$running" = "false" ] && break
  sleep 1
done
test "$(docker inspect -f '{{.State.Running}}' "$NAME")" = "false"
if docker exec "$NAME" wget -q -O /dev/null http://127.0.0.1:8080/api/v1/welcome >/dev/null 2>&1; then
  echo "ERROR: healthcheck succeeded after signaling server stopped" >&2
  exit 1
fi

echo "Smoke test passed."
