#!/usr/bin/env bash
# Smoke test for dgcosenza/nextcloud-spreed-signaling.
#
# Verifies container startup with environment-generated server.conf, healthy
# /api/v1/welcome JSON response, non-root execution (uid 850), graceful SIGUSR1
# shutdown via /stop.sh, and negative healthcheck failure once stopped.
#
# Usage: tests/smoke.sh [image]
#        IMAGE=dgcosenza/nextcloud-spreed-signaling:latest tests/smoke.sh
set -euo pipefail

IMAGE="${1:-${IMAGE:-dgcosenza/nextcloud-spreed-signaling:latest}}"
NAME="${NAME:-signaling-smoke}"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "$NAME" \
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

echo "== waiting for healthcheck"
for _ in $(seq 1 45); do
  status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$NAME")"
  [ "$status" = "healthy" ] && break
  [ "$status" = "unhealthy" ] && { docker logs "$NAME"; exit 1; }
  sleep 2
done
test "$(docker inspect -f '{{.State.Health.Status}}' "$NAME")" = "healthy"

echo "== verify non-root execution (spreedbackend 850:850)"
test "$(docker exec "$NAME" id -u)" = "850"
test "$(docker exec "$NAME" id -g)" = "850"
docker exec "$NAME" ps -o user= -C nextcloud-spreed-signaling | grep -q 'spreedbackend'

echo "== verify /api/v1/welcome payload and binary version"
welcome="$(docker exec "$NAME" wget -q -O - http://127.0.0.1:8080/api/v1/welcome)"
echo "welcome: ${welcome}"
printf '%s' "$welcome" | grep -q '"nextcloud-spreed-signaling"'
printf '%s' "$welcome" | grep -q '"version"'
docker exec "$NAME" /usr/bin/nextcloud-spreed-signaling -version

echo "== negative test: graceful /stop.sh shutdown and healthcheck failure"
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
