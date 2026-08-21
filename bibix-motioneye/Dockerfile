ARG BUILD_FROM=alpine:3.24.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install build dependencies and compile pycurl
RUN \
    set -o pipefail \
    \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        curl-dev \
        ffmpeg-dev \
        jpeg-dev \
        libmicrohttpd-dev \
        libwebp-dev \
        openssl-dev \
        python3-dev \
        py3-pip \
        py3-setuptools \
        v4l-utils-dev \
    \
    && PYCURL_SSL_LIBRARY=openssl \
       PYCURL_CURLCONFIG=/usr/bin/curl-config \
       pip install --no-cache-dir \
       --break-system-packages \
       --compile \
       "pycurl>=7.45,<8" \
    \
    && pip install --no-cache-dir \
       --break-system-packages \
       "https://github.com/motioneye-project/motioneye/archive/refs/tags/0.44.0.tar.gz" \
    \
    && apk del .build-deps \
    \
    && rm -rf /tmp/*

# Install runtime dependencies
ARG BUILD_ARCH=amd64
ARG BUILD_VERSION="0.44.0"

RUN \
    apk add --no-cache \
        cifs-utils \
        ffmpeg \
        ffmpeg-libs \
        libintl \
        libjpeg-turbo \
        libjpeg \
        libmicrohttpd \
        libwebp \
        mosquitto-clients \
        nginx \
        python3 \
        rsync \
        v4l-utils

# Environment variables
ENV \
    HOME="/root" \
    LANG="C.UTF-8" \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_EXTRA_INDEX_URL="https://wheels.home-assistant.io/musllinux-index/" \
    PIP_NO_CACHE_DIR=1 \
    PIP_PREFER_BINARY=1 \
    PS1="$(whoami)@$(hostname):$(pwd)$ " \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    TERM="xterm-256color"

# Copy root filesystem
COPY rootfs /

# Entrypoint & CMD
ENTRYPOINT ["/init"]

# Build arguments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY

# Labels
LABEL \
    io.hass.name="MotionEye" \
    io.hass.description="Simple, elegant and feature-rich CCTV/NVR for your cameras" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Bibix <opensource@bibix.fr>" \
    org.opencontainers.image.title="MotionEye" \
    org.opencontainers.image.description="Simple, elegant and feature-rich CCTV/NVR for your cameras" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Bibix <opensource@bibix.fr>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/Bibix-V/Motioneye-addon-HA" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
