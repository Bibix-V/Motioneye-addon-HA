ARG BUILD_FROM="ghcr.io/hassio-addons/base:19.0.0"
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
ARG MOTION_VERSION="4.7.1"
ARG MOTIONEYE_VERSION="0.44.0"

# Upgrade system packages first to align with APKINDEX
# The base image 19.0.0 pins older versions that conflict with -dev packages
# (e.g., musl=1.2.5-r10 vs musl-dev requiring musl=1.2.5-r12)
RUN \
    apk upgrade --no-cache \
    \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl-dev \
        ffmpeg-dev \
        gettext-dev \
        git \
        jpeg-dev \
        libjpeg-turbo-dev \
        libmicrohttpd-dev \
        libwebp-dev \
        linux-headers \
        musl-dev \
        pkgconf \
        python3-dev \
        v4l-utils-dev \
    \
    && apk add --no-cache \
        cifs-utils \
        ffmpeg-libs \
        ffmpeg \
        libintl \
        libjpeg-turbo \
        libjpeg \
        libmicrohttpd \
        libwebp \
        mosquitto-clients \
        nginx \
        py3-pip \
        python3 \
        rsync \
        v4l-utils \
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
    && apk del --no-cache --purge .build-deps \
    && rm -f -r /tmp/*

# Copy root filesystem
COPY rootfs/ /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Bibix <bibix@elpis>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Bibix <bibix@elpis>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/Bibix-V/motioneye-addon" \
    org.opencontainers.image.documentation="https://github.com/Bibix-V/motioneye-addon/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
