ARG BUILD_FROM=alpine:3.24.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install s6-overlay, bashio, and tempio (same as app-base)
ARG BUILD_ARCH=amd64
ARG BASHIO_VERSION="v0.19.0"
ARG S6_OVERLAY_VERSION="3.2.3.2"
ARG TEMPIO_VERSION="2026.07.0"

RUN \
    set -o pipefail \
    \
    && apk add --no-cache --virtual .build-dependencies \
        tar=1.35-r5 \
        xz=5.8.3-r0 \
    \
    && apk add --no-cache \
        libcrypto3=3.5.7-r0 \
        libssl3=3.5.7-r0 \
        musl-utils=1.2.6-r2 \
        musl=1.2.6-r2 \
    \
    && apk add --no-cache \
        bash=5.3.9-r1 \
        curl=8.21.0-r0 \
        jq=1.8.1-r0 \
        tzdata=2026c-r0 \
    \
    && S6_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "amd64" ]; then S6_ARCH="x86_64"; fi \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf \
        /tmp/bashio.tar.gz \
        --strip 1 -C /tmp/bashio \
    \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    \
    && curl -L -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/tempio \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -f -r \
        /tmp/*

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
    && echo "=== Recherche relayevent.sh ===" \
    && find /usr/lib /usr/local/lib \
        -type f \
        -name 'relayevent.sh' \
        -print \
        -exec echo "===== CONTENU relayevent.sh =====" \; \
        -exec sed -n '1,260p' {} \; \
        2>/dev/null || true \
    \
    && echo "=== Recherche _relay_event dans le package motioneye ===" \
    && grep -R "_relay_event" \
        /usr/lib/python*/site-packages/motioneye \
        /usr/local/lib/python*/site-packages/motioneye \
        2>/dev/null || true \
    \
    && apk del .build-deps \
    \
    && rm -rf /tmp/*

# Install runtime dependencies
ARG BUILD_VERSION="0.44.0"

RUN \
    echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" \
        >> /etc/apk/repositories \
    && apk add --no-cache \
        cifs-utils \
        ffmpeg \
        ffmpeg-libs \
        libintl \
        libjpeg-turbo \
        libjpeg \
        libmicrohttpd \
        libwebp \
        mosquitto-clients \
        motion@testing \
        nginx \
        python3 \
        rsync \
        v4l-utils

# Verify Motion installation
RUN \
    echo "=== Motion installation check ===" \
    && command -v motion \
    && motion -h >/dev/null 2>&1 || true \
    && ls -l "$(command -v motion)"

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

# Copier le répertoire s6-overlay officiel (manifestes et scripts core)
COPY s6-overlay /tmp/s6-overlay-official

# Copier root filesystem
COPY rootfs /

# Copier les manifestes et scripts s6-overlay officiels vers /etc/s6-overlay/
# (ne pas écraser les manifestes personnalisés de rootfs)
RUN mkdir -p /etc/s6-overlay/s6-rc/scripts /etc/s6-overlay/s6-rc/sources && \
    cp -r /tmp/s6-overlay-official/etc/s6-rc/sources/* /etc/s6-overlay/s6-rc/sources/ && \
    cp -r /tmp/s6-overlay-official/etc/s6-rc/scripts/* /etc/s6-overlay/s6-rc/scripts/

# Rendre les scripts s6-overlay exécutables
RUN chmod -R 755 /etc/s6-overlay/s6-rc.d/ && \
    chmod -R 755 /etc/s6-overlay/s6-rc/scripts/ && \
    chmod -R 755 /etc/s6-overlay/s6-rc/sources/

# Copier les scripts et manifestes s6-overlay vers le package directory attendu par le runtime
RUN mkdir -p /package/admin/s6-overlay-${S6_OVERLAY_VERSION}/s6-rc.d/ && \
    cp -r /etc/s6-overlay/s6-rc.d/* /package/admin/s6-overlay-${S6_OVERLAY_VERSION}/s6-rc.d/

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
