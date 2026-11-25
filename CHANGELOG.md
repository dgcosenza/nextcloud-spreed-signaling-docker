# Changelog

Maintained by Daniel G. Cosenza from FNX Labs.

All notable changes to this image are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and image tags track
the upstream `strukturag/nextcloud-spreed-signaling` release version.

## [2.2.0] - 2026-11-25

### Automated Daily Build
- Verified components: nextcloud-spreed-signaling `v2.2.0`, Go toolchain `1.27.4`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: refreshed base OS, dependencies, and supply-chain attestations.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (15 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/nextcloud-spreed-signaling@sha256:61375db8ec6cc767513504be6f946c00094eebd05b3b93a61b310520c7189272` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
## [2.2.0] - 2026-11-25

### Changed

- Rebuilt on Debian `13.8` (`debian:trixie-slim`) with nextcloud-spreed-signaling `v2.2.0`, go `1.27.4`.
- Verified `0` fixable CRITICAL/HIGH vulnerabilities in Trivy and Grype.
- Published digest: `dgcosenza/nextcloud-spreed-signaling@sha256:99a2771023c047b8ca1d68a9e4f77d9f0030981154cba3973ba70a542e7b5086`.
## [2.2.0] - 2026-11-24

### Added

- Initial public build: `strukturag/nextcloud-spreed-signaling` `v2.2.0`
  compiled from official Go source (`CGO_ENABLED=0`) on Debian 13 (trixie) slim.
- Drop-in compatibility with `strukturag/nextcloud-spreed-signaling`: same
  `CONFIG=/config/server.conf`, `/config/server.conf.in`, `/entrypoint.sh`,
  `/stop.sh`, `/wait.sh`, `STOPSIGNAL SIGUSR1`, `spreedbackend` user
  (`850:850`), all upstream environment variables, and `wget` healthcheck.
- Minimal 1-hunk Debian entrypoint patch (`patches/0001-debian-setpriv.patch`)
  replacing Alpine `su-exec` with Debian `setpriv`, running non-root by default
  under `tini`.
- Automated 7-step daily CI pipeline: upstream release and Go toolchain check,
  clean `--no-cache` build, Trivy and Grype blocking gates, SPDX SBOM,
  functional and negative smoke tests, Docker Hub publishing, automated
  README/CHANGELOG sync, and failure alerting.
