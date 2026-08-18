ARG BUILD_FROM="ghcr.io/hassio-addons/base:19.2.0"
FROM $BUILD_FROM

# Install motion (pre-compiled) and motioneye dependencies
RUN \
    apk add --no-cache \
        motion \
        py3-pip \
        python3 \
        libjpeg-turbo-dev \
        ffmpeg \
    && pip3 install --no-cache-dir motioneye==0.44.0 \
    && mkdir -p /etc/motion \
    && mkdir -p /data/motioneye

# Copy rootfs
COPY rootfs/ /
