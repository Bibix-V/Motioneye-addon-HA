ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
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
    s6-overlay \
    sudo \
    supervisor \
    tini \
    tzdata \
    wget

# Install MotionEye 0.44.0
RUN pip3 install --no-cache-dir \
    babel \
    boto3 \
    jinja2 \
    pillow \
    pycurl \
    tornado>=6.5.7 \
    motioneye==0.44.0

# Copy rootfs
COPY rootfs /

# Set permissions
RUN chmod +x /etc/s6-overlay/s6-rc.d/user/contents.d/*
