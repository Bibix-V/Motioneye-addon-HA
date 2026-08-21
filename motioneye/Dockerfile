ARG BUILD_FROM=alpine:3.24.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

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

# Set shell
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install base system
ARG BUILD_ARCH=amd64
ARG BASHIO_VERSION="v0.19.0"
ARG S6_OVERLAY_VERSION="3.2.3.2"
ARG TEMPIO_VERSION="2026.07.0"
ARG MOTION_VERSION="4.7.1"
ARG MOTIONEYE_VERSION="0.44.0"
RUN \
    set -o pipefail \
    \
    && apk add --no-cache --virtual .build-dependencies \
        tar=1.35-r5 \
        xz=5.8.3-r0 \
        autoconf=2.72-r1 \
        automake=1.17-r1 \
        build-base=0.5-r3 \
        curl-dev=8.21.0-r0 \
        ffmpeg-dev=7.1.2-r0 \
        gettext-dev=0.24.1-r0 \
        git=2.49.1-r0 \
        jpeg-dev=9f-r0 \
        libjpeg-turbo-dev=3.1.0-r0 \
        libmicrohttpd-dev=1.0.4-r0 \
        libwebp-dev=1.5.0-r0 \
        linux-headers=6.14.2-r0 \
        musl-dev=1.2.6-r2 \
        python3-dev=3.13.5-r0 \
        v4l-utils-dev=1.28.1-r1 \
    \
    && apk add --no-cache \
        cifs-utils=7.3-r0 \
        ffmpeg-libs=7.1.2-r2 \
        ffmpeg=7.1.2-r2 \
        libintl=0.24.1-r0 \
        libjpeg-turbo=3.1.0-r0 \
        libjpeg=9f-r0 \
        libmicrohttpd=1.0.4-r0 \
        libwebp=1.5.0-r0 \
        mosquitto-clients=2.0.21-r0 \
        nginx=1.28.0-r3 \
        py3-pip=25.1.1-r0 \
        python3=3.13.5-r0 \
        rsync=3.4.1-r1 \
        v4l-utils=1.28.1-r1 \
    \
    && curl -J -L -o /tmp/motion.tar.gz \
        "https://github.com/Motion-Project/motion/archive/release-${MOTION_VERSION}.tar.gz" \
    && mkdir -p /tmp/motion \
    && tar zxf /tmp/motion.tar.gz -C \
        /tmp/motion --strip-components=1 \
    && cd /tmp/motion \
    && autoreconf -fiv \
    && ./configure \
            --without-pgsql \
            --without-mysql \
            --without-sqlite3 \
            --prefix=/usr \
            --sysconfdir=/etc \
    && make install \
    \
    && pip install --no-cache-dir \
        "https://github.com/motioneye-project/motioneye/archive/${MOTIONEYE_VERSION}.tar.gz" \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -f -r /tmp/*

# Copy root filesystem
COPY rootfs /

# Copy s6-overlay adjustments
COPY s6-overlay /package/admin/s6-overlay-${S6_OVERLAY_VERSION}/

# Entrypoint & CMD
ENTRYPOINT ["/init"]

# Build arguments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
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
