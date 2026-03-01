FROM ubuntu:24.04

# Install dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt install -y imagemagick curl tar xz-utils \
    && apt install -y libxi6 libxrender1 libxxf86vm1 libfontconfig1 libgl1 libgl1-mesa-dri libxkbcommon0 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run Flamenco
RUN useradd --system --create-home --home-dir /home/flamenco --shell /bin/bash flamenco

# Set working directories
WORKDIR /opt

# Build-time arguments for versioning
ARG FLAMENCO_VERSION=3.2
ARG BLENDER_VERSION=3.3.6
# ARG BLENDER_MAJOR_MINOR=3.3

# Download and install Flamenco Manager
RUN curl -L "https://flamenco.blender.org/downloads/flamenco-${FLAMENCO_VERSION}-linux-amd64.tar.gz" -o flamenco.tar.gz \
    && mkdir flamenco \
    && tar -xzf flamenco.tar.gz -C flamenco --strip-components=1 \
    && rm flamenco.tar.gz \
    && chmod +x flamenco/flamenco-manager flamenco/flamenco-worker \
    && ln -s /opt/flamenco/flamenco-manager /usr/local/bin/flamenco-manager \
    && ln -s /opt/flamenco/flamenco-worker /usr/local/bin/flamenco-worker

# Download and install Blender
RUN export BLENDER_MAJOR_MINOR=$(echo ${BLENDER_VERSION} | cut -d. -f1,2) \
    && curl -L "https://mirrors.ocf.berkeley.edu/blender/release/Blender${BLENDER_MAJOR_MINOR}/blender-${BLENDER_VERSION}-linux-x64.tar.xz" -o blender.tar.xz \
    && tar -xf blender.tar.xz -C /opt/ \
    && rm blender.tar.xz \
    && chmod +x /opt/blender-${BLENDER_VERSION}-linux-x64/blender \
    && ln -s /opt/blender-${BLENDER_VERSION}-linux-x64 /opt/blender \
    && ln -s /opt/blender/blender /usr/local/bin/blender

# Set environment variables
ENV FLAMENCO_MANAGER_PORT=8080

WORKDIR /home/flamenco
RUN ./flamenco-manager -write-config \
    && chown -R flamenco:flamenco /opt/flamenco /home/flamenco /opt/blender /opt/blender-${BLENDER_VERSION}-linux-x64

USER flamenco

EXPOSE ${FLAMENCO_MANAGER_PORT}

ENTRYPOINT [ "flamenco-manager" ]