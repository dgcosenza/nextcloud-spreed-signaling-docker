# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Nextcloud Talk HPB Signaling Server (strukturag/nextcloud-spreed-signaling)
# compiled from official Go source on Debian 13 (trixie) slim.
#
# Drop-in compatible with strukturag/nextcloud-spreed-signaling: same
# CONFIG=/config/server.conf, /config/server.conf.in, /entrypoint.sh,
# /stop.sh, /wait.sh, STOPSIGNAL SIGUSR1, spreedbackend user (850:850),
# all upstream environment variables, and wget healthcheck.
#
# Every version below is a documented default; CI overrides them with the
# latest upstream release and Go toolchain (.github/workflows/daily.yml).
# ---------------------------------------------------------------------------

ARG GO_VERSION=1.27.4
ARG DEBIAN_VERSION=trixie-slim

ARG SIGNALING_VERSION=v2.2.0
ARG SIGNALING_UID=850
ARG SIGNALING_GID=850

ARG IMAGE_CREATED=""
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/nextcloud-spreed-signaling-docker"

# ---- Stage 1: compile signaling binary from official upstream tag ----------
FROM golang:${GO_VERSION}-trixie AS builder

ARG SIGNALING_VERSION
ARG TARGETOS=linux
ARG TARGETARCH=amd64

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

RUN git clone --depth 1 --branch "${SIGNALING_VERSION}" \
    https://github.com/strukturag/nextcloud-spreed-signaling.git .

COPY patches/0001-debian-setpriv.patch /tmp/0001-debian-setpriv.patch
RUN patch -p1 < /tmp/0001-debian-setpriv.patch \
    && touch /.dockerenv \
    && CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" make server

# ---- Stage 2: hardened Debian 13 runtime -----------------------------------
FROM debian:${DEBIAN_VERSION}

ARG DEBIAN_VERSION
ARG GO_VERSION
ARG SIGNALING_VERSION
ARG SIGNALING_UID
ARG SIGNALING_GID
ARG IMAGE_CREATED
ARG IMAGE_REVISION
ARG IMAGE_SOURCE

LABEL org.opencontainers.image.title="Nextcloud Spreed Signaling (Debian 13)" \
      org.opencontainers.image.description="Hardened, up-to-date Debian 13 (trixie) build of Nextcloud Talk HPB signaling server from official Go source, drop-in compatible with strukturag/nextcloud-spreed-signaling." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/nextcloud-spreed-signaling" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${SIGNALING_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.licenses="AGPL-3.0-or-later" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      io.github.dgcosenza.nextcloud_spreed_signaling.upstream_version="${SIGNALING_VERSION}" \
      io.github.dgcosenza.nextcloud_spreed_signaling.go_version="${GO_VERSION}" \
      io.github.dgcosenza.nextcloud_spreed_signaling.base="debian:${DEBIAN_VERSION}"

ENV DEBIAN_FRONTEND=noninteractive \
    CONFIG=/config/server.conf

RUN apt-get update \
    && apt-get -y --no-install-recommends upgrade \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        procps \
        psmisc \
        tini \
        tzdata \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Fixed unprivileged account matching upstream (850:850).
RUN groupadd --system --gid "${SIGNALING_GID}" spreedbackend \
    && useradd --system --uid "${SIGNALING_UID}" --gid spreedbackend \
        --home-dir /nonexistent --no-create-home --shell /usr/sbin/nologin spreedbackend \
    && install -d -o spreedbackend -g spreedbackend -m 0755 /config

COPY --from=builder /workdir/bin/signaling /usr/bin/nextcloud-spreed-signaling
COPY --from=builder --chown=spreedbackend:spreedbackend /workdir/server.conf.in /config/server.conf.in
COPY --from=builder --chmod=0755 /workdir/docker/server/entrypoint.sh /entrypoint.sh
COPY --from=builder --chmod=0755 /workdir/docker/server/stop.sh /stop.sh
COPY --from=builder --chmod=0755 /workdir/docker/server/wait.sh /wait.sh
COPY --from=builder /workdir/LICENSE /usr/share/doc/signaling-notices/LICENSE

RUN /usr/bin/nextcloud-spreed-signaling -version

USER spreedbackend
EXPOSE 8080/tcp

STOPSIGNAL SIGUSR1

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD ["wget", "-q", "-O", "/dev/null", "http://127.0.0.1:8080/api/v1/welcome"]

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
