# syntax=docker/dockerfile:1

# ── Stage 1: Build motion from source ────────────────────────────────────────
FROM alpine:3.22 AS builder
ARG MOTION_VERSION="4.7.1"
ARG MOTIONEYE_VERSION="0.44.0"

RUN apk add --no-cache --virtual .build-deps \
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
    && apk add --no-cache \
        ffmpeg-libs \
        libmicrohttpd \
        libwebp \
        mosquitto-clients \
        v4l-utils \
    \
    && curl -fsSL -o /tmp/motion.tar.gz \
        "https://github.com/Motion-Project/motion/archive/release-${MOTION_VERSION}.tar.gz" \
    && mkdir -p /tmp/motion \
    && tar zxf /tmp/motion.tar.gz -C /tmp/motion --strip-components=1 \
    && cd /tmp/motion \
    && autoreconf -fiv \
    && ./configure \
            --without-pgsql \
            --without-mysql \
            --without-sqlite3 \
            --prefix=/usr \
            --sysconfdir=/etc \
    && make -j$(nproc) install \
    \
    && pip install --no-cache-dir \
        "https://github.com/motioneye-project/motioneye/archive/${MOTIONEYE_VERSION}.tar.gz" \
    \
    && apk del --no-cache --purge .build-deps \
    && rm -rf /tmp/motion /root/.cache/pip /root/.cache/pip-build

# ── Stage 2: Final addon image ──────────────────────────────────────────────
ARG BUILD_ARCH
FROM homeassistant/${BUILD_ARCH}-base:2026.08.2

ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Install only extra packages not in base image
RUN apk add --no-cache \
        ffmpeg \
        jq \
        libjpeg-turbo \
        nginx \
        openssl \
        rsync \
        wget \
        ffmpeg-libs \
        libmicrohttpd \
        libwebp \
        mosquitto-clients \
        v4l-utils \
    \
    && addgroup -g 900 -S motioneye \
    && adduser -u 900 -S -h /tmp -s /sbin/nologin -G motioneye motioneye \
    && mkdir -p /data/motioneye /run/motioneye /tmp/motioneye \
    && chown -R motioneye:motioneye /data/motioneye /run/motioneye /tmp/motioneye

# Copy compiled motion binary
COPY --from=builder /usr/bin/motion /usr/bin/motion

# Copy compiled motioneye (Python package)
COPY --from=builder /usr/lib/python3.13/site-packages/motioneye /usr/lib/python3.13/site-packages/motioneye

# Copy rootfs (s6-overlay init system, nginx, motioneye configs)
COPY rootfs/ /

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

CMD ["/init"]
