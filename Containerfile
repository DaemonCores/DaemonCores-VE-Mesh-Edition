#####################################################################################
# Base image
#####################################################################################
FROM ghcr.io/daemoncores/daemoncores-ve:latest
STOPSIGNAL SIGRTMIN+3

# Environement Setup
LABEL org.opencontainers.image.title="DaemonCores VE Mesh Edition"
LABEL org.opencontainers.image.description="DaemonCores VE Mesh — Debian 13 Trixie"
LABEL org.opencontainers.image.base.name="ghcr.io/daemoncores/debian-bootc:latest"
LABEL org.opencontainers.image.source="https://github.com/DaemonCores/DaemonCores-VE-Mesh-Edition"
LABEL org.opencontainers.image.licenses="LGPL-2.1"
LABEL containers.bootc=1
LABEL ostree.bootable=1

# SHA-256 checksums of the APT repository signing keys fetched below.
ARG DAEMONCORES_VE_MESH_GPG_SHA256=4920000cfcd8f5a618822c8e57222a3c10768d2efb8c0250a71a19ba0c76ff55
ARG PVE_GPG_SHA256=136673be77aba35dcce385b28737689ad64fd785a797e57897589aed08db6e45
# Setup all environement variables
ENV DEBIAN_FRONTEND=noninteractive
# Default shell: fail build on error. Honored with `--format docker` in CI.
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Mesh install
COPY ./src/pvepreinstall /
RUN chmod +x /usr/sbin/policy-rc.d \
    && wget \
        -O /usr/share/keyrings/daemoncores-ve-mesh-edition-keyring.gpg \
        https://daemoncores.github.io/DaemonCores-VE-Mesh-Edition/gpg.key \
    && printf '%s  /usr/share/keyrings/daemoncores-ve-mesh-edition-keyring.gpg\n' "${DAEMONCORES_VE_MESH_GPG_SHA256}" \
        | sha256sum -c - \
    && apt update \
    && apt upgrade -y \
    && apt update \
    && apt install -y \
        curl # for exemple

COPY ./assets/banner/etc /etc/

# Mesh post install
COPY ./src/pvepostinstall /
RUN rm -f /etc/apt/sources.list.d/pve-install-repo.sources \
        /tmp/* \
        /var/tmp/* \
        /usr/sbin/policy-rc.d

# bootc images are updated in-place via ostree; no runtime healthcheck applies.
HEALTHCHECK NONE
