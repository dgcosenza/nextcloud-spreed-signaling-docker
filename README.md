# Nextcloud Spreed Signaling Server for Debian 13 (trixie-slim)

[![Daily Nextcloud Spreed Signaling image](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/LICENSE)
[![Upstream License: AGPL-3.0-or-later](https://img.shields.io/badge/upstream-AGPL--3.0--or--later-green.svg)](https://github.com/strukturag/nextcloud-spreed-signaling/blob/master/LICENSE)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/nextcloud-spreed-signaling-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/nextcloud-spreed-signaling-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/nextcloud-spreed-signaling)](https://hub.docker.com/r/dgcosenza/nextcloud-spreed-signaling)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/nextcloud-spreed-signaling/latest)](https://hub.docker.com/r/dgcosenza/nextcloud-spreed-signaling)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/nextcloud-spreed-signaling-docker?label=version)](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/releases)

A source-built, multi-arch, rootless **Debian 13 (`trixie-slim`)** container image of the [Nextcloud Talk High Performance Backend signaling server](https://github.com/strukturag/nextcloud-spreed-signaling) (`strukturag/nextcloud-spreed-signaling`), maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/nextcloud-spreed-signaling`](https://hub.docker.com/r/dgcosenza/nextcloud-spreed-signaling)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/nextcloud-spreed-signaling`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/pkgs/container/nextcloud-spreed-signaling) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/nextcloud-spreed-signaling-docker`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker)
- **Upstream Application:** [`strukturag/nextcloud-spreed-signaling`](https://github.com/strukturag/nextcloud-spreed-signaling) (`AGPL-3.0-or-later`)

---

## Overview

`dgcosenza/nextcloud-spreed-signaling` compiles official upstream Go release tags (`CGO_ENABLED=0`) with the latest Go toolchain on **Debian 13 (`trixie-slim`)** for both `linux/amd64` and `linux/arm64`:

- **Drop-in replacement for `strukturag/nextcloud-spreed-signaling`:** Preserves `CONFIG=/config/server.conf`, `/config/server.conf.in`, `/entrypoint.sh`, `/stop.sh`, `/wait.sh`, `STOPSIGNAL SIGUSR1`, `spreedbackend` (`850:850`), all upstream environment variables, and the `wget` healthcheck.
- **Rootless & read-only rootfs ready:** Defaults to `USER spreedbackend` (`850:850`) under `tini`, and is verified natively on both architectures under `--read-only --cap-drop ALL --security-opt no-new-privileges:true` (using `CONFIG=/tmp/server.conf` on `tmpfs`).
- **Hardened supply chain:** Hadolint + Gitleaks preflight, native multi-arch smoke tests, strict Dive efficiency gate (`>= 95%`, `<= 5%` wasted), Syft SPDX + CycloneDX SBOMs, Trivy + Grype (SBOM) zero-fixable High/Critical gates, Cosign keyless OIDC signatures & SBOM attestations, SLSA Build L3 provenance, dual-registry publishing, and signed GitHub Releases.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| nextcloud-spreed-signaling | `v2.2.0` |
| Go toolchain | `1.27.4` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Last verified build (UTC) | `2026-11-25` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable Critical/High** |
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical multi-arch OCI digests are published to **Docker Hub** (`dgcosenza/nextcloud-spreed-signaling`) and **GHCR** (`ghcr.io/dgcosenza/nextcloud-spreed-signaling`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/releases):

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `2.2.0-20261125`) | **Immutable** | Date-stamped daily rebuild pinning the signaling release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `2.2.0`) | Moving | Latest verified Debian 13 + Go security rebuild of that signaling release. |
| `latest` | Moving | Latest verified build tracking the newest official signaling release. |

**Production pinning:** Pin by immutable digest:

```yaml
image: dgcosenza/nextcloud-spreed-signaling:2.2.0@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/nextcloud-spreed-signaling:2.2.0@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built with latest Go `trixie` toolchain, smoke-tested (both default and `--read-only --cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Built with latest Go `trixie` toolchain, smoke-tested (both default and `--read-only --cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

---

## Quick Start

### `docker run` (hardened, rootless, read-only)

```bash
docker run -d --name nextcloud_talk_signaling \
  --restart unless-stopped \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp:noexec,nosuid,size=16m \
  -e CONFIG=/tmp/server.conf \
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

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/docker-compose.example.yml) for a hardened compose definition running rootless with `read_only: true`, `cap_drop: [ALL]`, `no-new-privileges:true`, `/tmp` `tmpfs`, and an internal network.

---

## Configuration

### Ports & Paths

| Resource | Details | Purpose |
| --- | --- | --- |
| `8080/tcp` | Default HTTP/WS | Signaling API (`HTTP_LISTEN`) |
| `8443/tcp` | Optional TLS | Direct HTTPS listener (`HTTPS_LISTEN`) |
| `9090/tcp` | Optional gRPC | gRPC listener (`GRPC_LISTEN`) |
| `/config/server.conf` | Generated or mounted `:ro` | Runtime INI config (set `CONFIG=/tmp/server.conf` for read-only rootfs) |
| `/etc/ssl/certs/ca-certificates.crt` | Read-only | Debian CA trust bundle |

### Environment Variables

| Variable | Default | Description |
| --- | --- | --- |
| `CONFIG` | `/config/server.conf` | Signaling configuration file path (`CONFIG=/tmp/server.conf` enables `read_only: true`) |
| `HTTP_LISTEN` | *(commented)* | HTTP bind address, e.g. `:8080` |
| `NATS_URL` | `nats://loopback` | NATS hub URL (`nats://loopback` uses built-in in-process hub) |
| `HASH_KEY` / `BLOCK_KEY` | *(required)* | Session checksum and AES block encryption keys |
| `INTERNAL_SHARED_SECRET_KEY` | *(required)* | Shared secret for internal clients |
| `BACKENDS` | *(unset)* | Space-separated backend identifiers, e.g. `cloud` |
| `BACKEND_<NAME>_URLS` | *(unset)* | Comma-separated Nextcloud URLs for backend `<NAME>` |
| `BACKEND_<NAME>_SHARED_SECRET` | *(unset)* | Shared secret matching Nextcloud Talk settings |
| `SKIP_VERIFY` | *(unset)* | Set `true` to skip backend TLS verification |
| `USE_JANUS` / `JANUS_URL` | *(unset)* | Optional Janus WebRTC gateway integration |
| `TURN_API_KEY` / `TURN_SECRET` / `TURN_SERVERS` | *(unset)* | Optional TURN relay configuration |
| `TRUSTED_PROXIES` / `STATS_IPS` | *(unset)* | Reverse proxy and stats ACL CIDRs |
| `CA_CERTIFICATES_FOLDER` | *(unset)* | Extra `.crt` folder imported at start (requires `--user 0`; drops to `850:850` via `setpriv`) |
| `TZ` | `UTC` | Timezone for log timestamps |

### UID / GID

Runs by default as non-root `spreedbackend` (`850:850`).

---

## Healthcheck

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD ["wget", "-q", "-O", "/dev/null", "http://127.0.0.1:8080/api/v1/welcome"]
```

Probes the HTTP signaling layer directly and fails closed if the signaling process stops.

---

## Upgrading and Migrating from `strukturag/nextcloud-spreed-signaling`

1. Back up any custom `/config/server.conf` and `.env` secrets.
2. Replace `strukturag/nextcloud-spreed-signaling:latest` with `dgcosenza/nextcloud-spreed-signaling:<version>@sha256:<digest>` (or `ghcr.io/dgcosenza/nextcloud-spreed-signaling:<version>@sha256:<digest>`).
3. Recreate only the signaling service (`docker compose up -d talk_signaling`) and confirm `healthy` plus `/api/v1/welcome` HTTP `200`.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/nextcloud-spreed-signaling-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/nextcloud-spreed-signaling:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/nextcloud-spreed-signaling-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/nextcloud-spreed-signaling:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/nextcloud-spreed-signaling-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/nextcloud-spreed-signaling@sha256:<arch-digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/nextcloud-spreed-signaling:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and PR runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across git history, and **public-content/attribution/license** checks.
- **Patched Go builds:** Compiled daily from official upstream tags with `CGO_ENABLED=0` and the newest Go `trixie` toolchain (`GOTOOLCHAIN=local`).
- **Rootless & read-only ready:** Defaults to `spreedbackend` (`850:850`) under `tini`, verified with `--read-only --cap-drop ALL --security-opt no-new-privileges:true`.
- **Vulnerability & efficiency gates:** Each architecture generates **Syft** SPDX + CycloneDX SBOMs, passes a strict **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), and must pass **Trivy** (table, JSON, SARIF to Code Scanning, blocking `--ignore-unfixed`) and **Grype** scanning the SPDX SBOM (`--only-fixed --fail-on high`) with **0 fixable Critical/High** vulnerabilities.
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/SECURITY.md) for vulnerability reporting.

---

## Build Locally

```bash
git clone https://github.com/dgcosenza/nextcloud-spreed-signaling-docker.git
cd nextcloud-spreed-signaling-docker

docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg IMAGE_CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg IMAGE_REVISION="$(git rev-parse HEAD)" \
  -t dgcosenza/nextcloud-spreed-signaling:local \
  .

./tests/smoke.sh dgcosenza/nextcloud-spreed-signaling:local
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `GO_BASE` | `golang:1.27.4-trixie@sha256:...` | Digest-pinned official Go builder image (refreshed daily by CI) |
| `DEBIAN_BASE` | `debian:trixie-slim@sha256:...` | Digest-pinned Debian 13 runtime base image (refreshed daily by CI) |
| `GO_VERSION` | `1.27.4` | Go toolchain version metadata |
| `SIGNALING_VERSION` | `v2.2.0` | `strukturag/nextcloud-spreed-signaling` Git tag |
| `SIGNALING_UID` / `SIGNALING_GID` | `850` / `850` | Unprivileged `spreedbackend` account IDs |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:40 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; resolves the latest `strukturag/nextcloud-spreed-signaling` release via authenticated GitHub API plus latest Go `trixie` and `debian:trixie-slim` digests; diffs against `versions.json` and emits `upstream-changes.md`.
2. **Multi-arch no-cache rebuild:** Compiles static Go binaries natively on `linux/amd64` and `linux/arm64` runners with `--no-cache` on schedule and full Debian 13 `apt-get upgrade`.
3. **Smoke, Dive & vulnerability gates:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/tests/smoke.sh) natively on both architectures (default + `--read-only --cap-drop ALL`, `/api/v1/welcome`, graceful `/stop.sh` `SIGUSR1`), enforces the strict **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), generates **Syft** SPDX + CycloneDX SBOMs, and gates publication on **0 fixable Critical/High** in both **Trivy** and **Grype** (SBOM scan).
4. **Dual-registry publish & signing:** Assembles the multi-arch OCI index on **GHCR** (`ghcr.io/dgcosenza/nextcloud-spreed-signaling`) and mirrors the identical digest to **Docker Hub** (`dgcosenza/nextcloud-spreed-signaling`) with tags `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>`; keyless-signs digests and attaches SPDX/CycloneDX SBOM attestations via **Cosign** OIDC; emits **SLSA Build L3** provenance; and publishes a signed **GitHub Release**.
5. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` (`[skip ci]`), then syncs the Docker Hub overview and short description.
6. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and closes it automatically on the next green run.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) instead of Alpine:** Aligns OS packages, CA bundle handling, and daily security updates with Debian 13 while preserving upstream `/entrypoint.sh`, `/stop.sh`, `/wait.sh`, and `STOPSIGNAL SIGUSR1` via a one-hunk `setpriv` patch (`patches/0001-debian-setpriv.patch`).
- **Two-layer zero-waste runtime layout:** Upgrading Debian 13 inside an `os-base` stage and assembling the final image with cleanly separated OS and compiled-binary layers eliminates overwritten base-layer files so Dive stays at ~100% efficiency and ~0% wasted space across daily security rebuilds.
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Debian 13 security updates via `apt-get` rather than pinning stale package versions.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, patch, CI workflows, scripts, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — `strukturag/nextcloud-spreed-signaling` (`upstream: AGPL-3.0-or-later`):** Copyright struktur AG and contributors — licensed under the [GNU Affero General Public License v3 or later (`AGPL-3.0-or-later`)](https://github.com/strukturag/nextcloud-spreed-signaling/blob/master/LICENSE).

Full notices are preserved inside the image (`/usr/share/doc/signaling-notices/LICENSE`) and in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/blob/main/THIRD-PARTY-NOTICES.md).

---

## Credits

- [struktur AG — nextcloud-spreed-signaling](https://github.com/strukturag/nextcloud-spreed-signaling)
- Container packaging, CI, and documentation: maintained by **Daniel G. Cosenza from FNX Labs** ([dgcosenza](https://github.com/dgcosenza))
