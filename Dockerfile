FROM ubuntu:24.04

# Install dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y imagemagick curl tar xz-utils \
    && apt-get install -y libxi6 libxrender1 libxxf86vm1 libxfixes3 libfontconfig1 libgl1 libgl1-mesa-dri libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run Flamenco
RUN useradd --system --create-home --home-dir /home/flamenco --shell /bin/bash flamenco

# Set working directories
WORKDIR /opt

# Build-time arguments for versioning and integrity verification
ARG FLAMENCO_VERSION=3.8.2
ARG FLAMENCO_SHA256=7a88e7fab8239cd626ba30b69019de1e5d058ad7f12260206b0f892c3e0f2de3
ARG BLENDER_VERSION=5.0.1
ARG BLENDER_SHA256=8019580ee1b7262e505f4196a00237ccf743c88d205b38d34201510676e60b09

# Download and install Flamenco Manager
RUN curl -fL "https://flamenco.blender.org/downloads/flamenco-${FLAMENCO_VERSION}-linux-amd64.tar.gz" -o flamenco.tar.gz \
    && echo "${FLAMENCO_SHA256}  flamenco.tar.gz" | sha256sum --check --strict \
    && mkdir flamenco \
    && tar -xzf flamenco.tar.gz -C flamenco --strip-components=1 \
    && rm flamenco.tar.gz \
    && chmod +x flamenco/flamenco-manager flamenco/flamenco-worker \
    && ln -s /opt/flamenco/flamenco-manager /usr/local/bin/flamenco-manager \
    && ln -s /opt/flamenco/flamenco-worker /usr/local/bin/flamenco-worker

# Download and install Blender
RUN export BLENDER_MAJOR_MINOR=$(echo ${BLENDER_VERSION} | cut -d. -f1,2) \
    && curl -fL "https://download.blender.org/release/Blender${BLENDER_MAJOR_MINOR}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" -o blender.tar.xz \
    && echo "${BLENDER_SHA256}  blender.tar.xz" | sha256sum --check --strict \
    && tar -xf blender.tar.xz -C /opt/ \
    && rm blender.tar.xz \
    && chmod +x /opt/blender-${BLENDER_VERSION}-linux-x64/blender \
    && ln -s /opt/blender-${BLENDER_VERSION}-linux-x64 /opt/blender \
    && ln -s /opt/blender/blender /usr/local/bin/blender

# Set environment variables
ENV FLAMENCO_MANAGER_PORT=8080

WORKDIR /home/flamenco
RUN flamenco-manager -write-config \
    && chown -R flamenco:flamenco /opt/flamenco /home/flamenco /opt/blender /opt/blender-${BLENDER_VERSION}-linux-x64

USER flamenco

EXPOSE ${FLAMENCO_MANAGER_PORT}

ENTRYPOINT [ "flamenco-manager" ]