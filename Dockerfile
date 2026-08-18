ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache \
    curl-dev \
    ffmpeg \
    imagemagick \
    libffi-dev \
    libjpeg-turbo-dev \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    musl-dev \
    openssl-dev \
    postgresql-dev \
    py3-cffi \
    py3-pip \
    python3-dev \
    readline-dev \
    redis \
    s6-overlay \
    sudo \
    supervisor \
    tini \
    tzdata \
    wget

# Install Motion
RUN wget -q https://github.com/MotionProject/motion-release/releases/download/4.7.1/motion-4.7.1.tar.gz \
    && tar -xzf motion-4.7.1.tar.gz \
    && cd motion-4.7.1 \
    && ./configure --with-v4l \
    && make \
    && make install \
    && cd .. \
    && rm -rf motion-4.7.1 motion-4.7.1.tar.gz

# Install MotionEye
RUN pip3 install --no-cache-dir \
    babel \
    boto3 \
    jinja2 \
    pillow \
    pycurl \
    tornado>=6.5.7 \
    motioneye

# Copy rootfs
COPY rootfs /

# Set permissions
RUN chmod +x /etc/s6-overlay/s6-rc.d/user/contents.d/*
