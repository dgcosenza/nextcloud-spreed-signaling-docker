# Security policy

Maintainer: Daniel G. Cosenza from FNX Labs.

## Supported versions

Only the `latest` tag and the newest `<signaling-version>` tag are supported.
The image is rebuilt daily from `debian:trixie-slim` with a full
`apt-get upgrade` and compiled with the latest patched Go toolchain on Debian
13.

## Reporting a vulnerability

Open a private security advisory at
<https://github.com/dgcosenza/nextcloud-spreed-signaling-docker/security/advisories/new>.
Please do not open a public issue for an undisclosed vulnerability.

## What this repository covers

This repository owns the container packaging layer: the Dockerfile, entrypoint
patch, smoke tests, CI pipeline, and published tags. Vulnerabilities in the
signaling server itself should also be reported upstream via
<https://github.com/strukturag/nextcloud-spreed-signaling/security>.

## Scanning and gates

* **Trivy:** the build fails on any fixable **CRITICAL** or **HIGH** finding
  across Debian OS packages and Go modules/stdlib. Full reports are retained
  for 90 days and SARIF results are uploaded to GitHub code scanning.
* **Grype:** runs as a blocking gate (`--only-fixed`, severity high/critical),
  with reports archived for 90 days.
* **SBOM:** an SPDX JSON software bill of materials is generated with Syft and
  archived for 90 days.
* **Non-root execution:** runs as unprivileged user `spreedbackend` (`850:850`)
  by default under `tini`, with `setpriv` privilege drop if started as root to
  import custom CAs via `CA_CERTIFICATES_FOLDER`.

## Hardening recommendations

* Pin production deployments by `@sha256:<digest>`.
* Run with `security_opt: [no-new-privileges:true]`.
* Keep the signaling container on an internal backend network behind a TLS
  reverse proxy, and supply `HASH_KEY`, `BLOCK_KEY`,
  `INTERNAL_SHARED_SECRET_KEY`, and `BACKEND_*_SHARED_SECRET` via `.env` or
  secret management rather than committing them.
