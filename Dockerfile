ARG BUILD_FROM="ghcr.io/hassio-addons/base:19.2.0"
FROM $BUILD_FROM

# Upgrade all packages to sync versions
RUN apk upgrade --no-cache

# Install runtime dependencies
RUN apk add --no-cache \
    ffmpeg \
    imagemagick \
    libjpeg-turbo \
    libpq \
    libxml2 \
    libxslt \
    motion \
    py3-pip \
    pycurl \
    readline \
    sudo \
    supervisor \
    tini \
    tzdata \
    wget

# Install MotionEye 0.44.0 from GitHub (not on PyPI)
RUN pip3 install --no-cache-dir \
    babel \
    boto3 \
    jinja2 \
    pillow \
    pycurl \
    "tornado>=6.5.7" && \
    pip3 install --no-cache-dir \
    "https://github.com/motioneye-project/motioneye/archive/refs/tags/0.44.0.tar.gz"

# Copy rootfs
COPY rootfs /

# Set permissions
RUN chmod +x /etc/s6-overlay/s6-rc.d/user/contents.d/*
