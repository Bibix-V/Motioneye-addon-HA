FROM alpine:3.22

# Install s6-overlay
ENV S6_OVERLAY_VERSION=3.2.0.0
RUN apk add --no-cache curl && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" | tar Jx -C /usr/local/share && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" | tar Jx -C /usr/local/share && \
    tar Jx -f /usr/local/share/s6-overlay-noarch.tar.xz -C / && \
    tar Jx -f /usr/local/share/s6-overlay-x86_64.tar.xz -C / && \
    rm -rf /usr/local/share/s6-overlay*.tar.xz /var/cache/apk/*

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
