# Nextcloud Spreed Signaling Server for Debian 13 (trixie)

[![Daily build, scan and publish](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/actions/workflows/daily.yml)
[![Docker Hub pulls](https://img.shields.io/docker/pulls/dgcosenza/nextcloud-spreed-signaling.svg)](https://hub.docker.com/r/dgcosenza/nextcloud-spreed-signaling)
[![Image size](https://img.shields.io/docker/image-size/dgcosenza/nextcloud-spreed-signaling/latest.svg)](https://hub.docker.com/r/dgcosenza/nextcloud-spreed-signaling)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A hardened, continuously rebuilt **Debian 13 (trixie)** container image of the
[Nextcloud Talk High Performance Backend signaling server](https://github.com/strukturag/nextcloud-spreed-signaling)
(`strukturag/nextcloud-spreed-signaling`), compiled from official Go source
tags with the latest patched Go toolchain.

It is a **drop-in replacement** for `strukturag/nextcloud-spreed-signaling`:
same `CONFIG=/config/server.conf` path, same `/config/server.conf.in` template,
same `/entrypoint.sh` environment variables, same `/stop.sh` / `/wait.sh`
helpers and `STOPSIGNAL SIGUSR1`, same `spreedbackend` account (`850:850`), and
same `wget` healthcheck — built on Debian 13 slim and running **non-root by
default** under `tini`.

## Current versions

<!-- versions:start -->

| Component | Resolved version |
|---|---|
| Base OS | Debian `13.8` (`debian:trixie-slim`) |
| `nextcloud-spreed-signaling` | `v2.2.0` |
| `go` | `1.27.4` |
| Last verified build | `2026-11-25` |
| Fixable CRITICAL / HIGH CVEs | `0` (Trivy + Grype gate) |

Currently tracked unfixed upstream findings (no fix released): `CVE-2025-69720`, `CVE-2026-107494`, `CVE-2026-119373`, `CVE-2026-119374`, `CVE-2026-119379`, `CVE-2026-124709`, `CVE-2026-16742`, `CVE-2026-54369`, `CVE-2026-58471`, `CVE-2026-58472`.

<!-- versions:end -->

## Supported tags

| Tag | Meaning |
|---|---|
| `latest` | Newest successfully built, tested, and scanned image |
| `<version>` | Upstream signaling release, e.g. `2.2.0` (moves on daily rebuilds of that release) |
| `<version>-<YYYYMMDD>` | Immutable date-stamped build of that release |
| `sha-<short>` | Immutable build of a specific repository commit |

Pin production deployments by digest:

```bash
docker pull dgcosenza/nextcloud-spreed-signaling:latest
docker inspect --format='{{index .RepoDigests 0}}' dgcosenza/nextcloud-spreed-signaling:latest
# image: dgcosenza/nextcloud-spreed-signaling@sha256:...
```

## Quick start

```bash
docker run -d --name nextcloud_talk_signaling \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -e HTTP_LISTEN=:8080 \
  -e NATS_URL=nats://loopback \
  -e HASH_KEY="$(openssl rand -hex 16)" \
  -e BLOCK_KEY="$(openssl rand -hex 8)" \
  -e INTERNAL_SHARED_SECRET_KEY="$(openssl rand -hex 16)" \
  -e BACKENDS=cloud \
  -e BACKEND_CLOUD_URLS=https://cloud.example.com \
  -e BACKEND_CLOUD_SHARED_SECRET="$(openssl rand -hex 16)" \
  dgcosenza/nextcloud-spreed-signaling:latest
```

Verify the welcome endpoint:

```bash
docker exec nextcloud_talk_signaling wget -q -O - http://127.0.0.1:8080/api/v1/welcome
```

## Compose example

See [docker-compose.example.yml](docker-compose.example.yml) for a complete
compose definition running on an internal Docker network with secret injection
via environment substitution, `no-new-privileges:true`, and resource limits.

## Configuration

### Ports

| Port | Protocol | Purpose |
|---|---|---|
| `8080` | TCP | Default HTTP signaling and WebSocket API (`HTTP_LISTEN`) |
| `8443` | TCP | Optional HTTPS listener (`HTTPS_LISTEN`, when TLS is terminated inside the container) |
| `9090` | TCP | Optional gRPC listener (`GRPC_LISTEN`) |

### Volumes and paths

| Path | Purpose |
|---|---|
| `/config/server.conf` | Generated automatically from `/config/server.conf.in` + environment variables on first start, or mount your own pre-built `server.conf` read-only |
| `/etc/ssl/certs/ca-certificates.crt` | Debian CA trust bundle (override via read-only bind mount or `CA_CERTIFICATES_FOLDER`) |

### Environment variables

All environment variables handled by upstream `docker/server/entrypoint.sh` are
supported verbatim:

| Variable | Default | Description |
|---|---|---|
| `CONFIG` | `/config/server.conf` | Path to the signaling server configuration file |
| `HTTP_LISTEN` | *(commented in template)* | HTTP bind address, e.g. `:8080` |
| `NATS_URL` | `nats://loopback` | NATS server URL (`nats://loopback` uses the built-in in-process hub) |
| `HASH_KEY` | *(required)* | Session checksum key (32 or 64 bytes recommended) |
| `BLOCK_KEY` | *(required)* | AES block encryption key (16, 24, or 32 bytes) |
| `INTERNAL_SHARED_SECRET_KEY` | *(required)* | Shared secret for internal clients |
| `BACKENDS` | *(unset)* | Space-separated backend identifiers, e.g. `cloud` |
| `BACKEND_<NAME>_URLS` | *(unset)* | Comma-separated Nextcloud base URLs for backend `<NAME>` |
| `BACKEND_<NAME>_SHARED_SECRET` | *(unset)* | Shared secret matching Nextcloud Talk settings |
| `SKIP_VERIFY` | *(unset)* | Set `true` to skip TLS verification when connecting to backends |
| `USE_JANUS` / `JANUS_URL` | *(unset)* | Optional Janus WebRTC gateway integration |
| `TURN_API_KEY` / `TURN_SECRET` / `TURN_SERVERS` | *(unset)* | Optional TURN relay configuration |
| `TRUSTED_PROXIES` / `STATS_IPS` | *(unset)* | Reverse proxy and stats ACL CIDRs |
| `CA_CERTIFICATES_FOLDER` | *(unset)* | Directory of extra `.crt` files to import at startup (requires starting container with `--user 0`; entrypoint then drops to `spreedbackend` via `setpriv`) |
| `TZ` | `UTC` | Timezone for log timestamps |

### UID / GID

The image runs by default as the unprivileged `spreedbackend` user (`uid=850`,
`gid=850`), matching upstream's UID/GID. `/config` is owned by `850:850` so
`/entrypoint.sh` can generate `/config/server.conf` without root privileges.
If `CA_CERTIFICATES_FOLDER` is set so `update-ca-certificates` must run at
startup, start with `--user 0`; the entrypoint updates the CA store and then
drops privileges via `setpriv --reuid=spreedbackend --regid=spreedbackend --no-new-privs`.

## Healthcheck

```text
wget -q -O /dev/null http://127.0.0.1:8080/api/v1/welcome
```

Exercises the HTTP application layer (not merely a TCP port open check) every
30 s (10 s timeout, 30 s start period, 3 retries) and fails closed if the
signaling process stops.

## Upgrading and migrating from `strukturag/nextcloud-spreed-signaling`

1. Back up any custom `/config/server.conf` (or `.env` file defining
   `HASH_KEY`, `BLOCK_KEY`, `INTERNAL_SHARED_SECRET_KEY`, and
   `BACKEND_*_SHARED_SECRET`).
2. Replace `strukturag/nextcloud-spreed-signaling:latest` with
   `dgcosenza/nextcloud-spreed-signaling:<version>@sha256:<digest>`.
3. Recreate only the signaling service (`docker compose up -d talk_signaling`).
4. Confirm `healthy` status and verify `/api/v1/welcome` returns HTTP 200.

Rollback is immediate: restore the previous image digest in your compose file
and run `docker compose up -d talk_signaling`.

## Security

* **Base OS:** `debian:trixie-slim`, fully upgraded (`apt-get upgrade`) on
  every build with `--no-install-recommends` and cleaned APT lists.
* **Patched Go builds:** Compiled daily from the official upstream Git tag with
  `CGO_ENABLED=0` and the newest Go toolchain published on Debian 13.
* **Non-root default & minimal patch:** Runs as `spreedbackend` (`850:850`)
  under `tini` with `no-new-privileges:true` supported; the only entrypoint
  delta (`patches/0001-debian-setpriv.patch`) replaces Alpine `su-exec` with
  Debian `setpriv`.
* **Scan policy:** Every build must pass **Trivy** (`--ignore-unfixed`,
  `CRITICAL,HIGH`, scanning both OS packages and the Go binary) and **Grype**
  (`--only-fixed`, severity `high`) with **0 fixable CRITICAL or HIGH**
  vulnerabilities. Reports and a Syft SPDX SBOM are archived for 90 days; Trivy
  SARIF is uploaded to GitHub code scanning.
* **Current status:** see the CI badge above and "Current versions".

## Building locally

```bash
git clone https://github.com/dgcosenza/nextcloud-spreed-signaling-docker.git
cd nextcloud-spreed-signaling-docker
docker build -t dgcosenza/nextcloud-spreed-signaling:dev .
./tests/smoke.sh dgcosenza/nextcloud-spreed-signaling:dev
```

Build arguments:

| Argument | Default | Purpose |
|---|---|---|
| `DEBIAN_VERSION` | `trixie-slim` | Debian 13 base tag |
| `GO_VERSION` | tracked release | Official `golang:<ver>-trixie` builder toolchain |
| `SIGNALING_VERSION` | tracked release | `strukturag/nextcloud-spreed-signaling` Git tag |
| `SIGNALING_UID` / `SIGNALING_GID` | `850` / `850` | Unprivileged `spreedbackend` user/group IDs |
| `IMAGE_CREATED`, `IMAGE_REVISION`, `IMAGE_SOURCE` | empty / repo | OCI image metadata |

## Update policy

A GitHub Actions workflow (`.github/workflows/daily.yml`) runs **daily** (and on
every push to `main`, on pull requests, and on demand via `workflow_dispatch`),
gated first by `.github/workflows/public-check.yml`:

1. **Upstream check:** resolves the latest `strukturag/nextcloud-spreed-signaling`
   release via the authenticated GitHub API (`GH_TOKEN`) and the newest Go
   `trixie` release from Docker Hub, diffs against `versions.json`, and fetches
   upstream release notes for new releases.
2. **Clean rebuild:** compiles a static Go binary (`CGO_ENABLED=0`) and builds
   the Debian 13 slim runtime with `apt-get upgrade` and `--no-cache` on
   scheduled runs.
3. **Vulnerability fix and gate:** scans OS packages and Go modules with
   **Trivy** (table, JSON, SARIF to GitHub code scanning) and **Grype**; fails
   on any fixable **CRITICAL** or **HIGH** vulnerability, retains reports and
   an SPDX SBOM (Syft) for 90 days, and diffs findings against the prior build.
4. **Smoke test:** boots the container with environment-driven config, waits
   for `healthy`, verifies uid `850` execution and `/api/v1/welcome` JSON, and
   asserts graceful `/stop.sh` (`SIGUSR1`) shutdown causes healthcheck failure.
5. **Publish:** on non-PR runs with Docker Hub credentials configured, pushes
   `latest`, `<version>`, `<version>-<YYYYMMDD>` (immutable), and `sha-<short>`,
   recording the published digest.
6. **Automated documentation sync:** when versions, base OS, digest, or CVE
   status change, commits updated `versions.json`, the README "Current
   versions" block, and a dated `CHANGELOG.md` entry (`[skip ci]`), then syncs
   the README and short description to Docker Hub.
7. **Alerting:** on failure of any job on a scheduled or `main` run, opens or
   updates a single GitHub issue labeled `ci-failure` with the failing job and
   run link, and closes it automatically on the next green run.

## Design decisions

* **Debian 13 slim instead of Alpine.** Aligns OS packages, CA bundle
  management, and daily security patching with Debian 13 while preserving 100%
  entrypoint, helper script (`/stop.sh`, `/wait.sh`), and `wget` healthcheck
  compatibility.
* **Upstream entrypoint patched cleanly.** Rather than reimplementing the 340-line
  environment-to-INI generator, `docker/server/entrypoint.sh` is fetched from
  the tagged upstream release and adapted with a 1-hunk `setpriv` patch.
* **`tini` as PID 1 with `STOPSIGNAL SIGUSR1`.** Preserves upstream's graceful
  call-draining shutdown behavior while adding clean signal forwarding and
  zombie reaping.

## License

The packaging, patch, workflow, and documentation in this repository are
licensed under the **MIT License** (see [LICENSE](LICENSE)).

`strukturag/nextcloud-spreed-signaling` is licensed under the **GNU Affero
General Public License v3 or later (`AGPL-3.0-or-later`)**; upstream notices
are preserved in `/usr/share/doc/signaling-notices/LICENSE` and documented in
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Credits

* [struktur AG — nextcloud-spreed-signaling](https://github.com/strukturag/nextcloud-spreed-signaling) —
  standalone signaling server for Nextcloud Talk
* Container packaging, CI, and documentation: maintained by Daniel G. Cosenza from FNX Labs ([dgcosenza](https://github.com/dgcosenza))
