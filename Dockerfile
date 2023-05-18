FROM ubuntu:20.04

# Install dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y imagemagick curl tar \
    && rm -rf /var/lib/apt/lists/*

# Set working directories
WORKDIR /opt

# Define URLs for Flamenco and Blender downloads
ENV FLAMENCO_URL=https://flamenco.blender.org/downloads/flamenco-3.2-linux-amd64.tar.gz
ENV BLENDER_URL=https://mirrors.ocf.berkeley.edu/blender/release/Blender3.3/blender-3.3.6-linux-x64.tar.xz

# Download and install Flamenco Manager
RUN curl -L ${FLAMENCO_URL} -o flamenco.tar.gz \
    && mkdir flamenco \
    && tar -xzf flamenco.tar.gz -C flamenco --strip-components=1 \
    && rm flamenco.tar.gz \
    && chmod +x flamenco/flamenco-manager \
    && ln -s /opt/flamenco/flamenco-manager /usr/local/bin/flamenco-manager

# Download and install Blender
RUN curl -L ${BLENDER_URL} -o blender.tar.xz \
    && tar -xf blender.tar.xz -C /opt/ \
    && rm blender.tar.xz \
    && ln -s /opt/blender/blender /usr/local/bin/blender

# Set environment variables
ENV FLAMENCO_MANAGER_PORT=8080

WORKDIR /opt/flamenco
RUN ./flamenco-manager -write-config
EXPOSE ${FLAMENCO_MANAGER_PORT}
ENTRYPOINT [ "flamenco-manager" ]
