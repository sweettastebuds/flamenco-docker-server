# Dockerfile for Flamenco Manager on Ubuntu 20.04
FROM ubuntu:20.04
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y imagemagick \
    # && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install Flamenco Manager
WORKDIR /tmp

# Copy the flamenco and blender tarball into the image
COPY ./build/flamenco*.tar.gz /tmp/
COPY ./build/blender-3.3.3-linux-x64 /opt/blender
# Install Blender
RUN ln -s /opt/blender/blender /usr/local/bin/blender
# Unpack the tarball
RUN mkdir /flamenco \
    && tar -xzf /tmp/flamenco* -C /flamenco --strip-components=1 \
    && rm /tmp/flamenco* \
    && chmod +x /flamenco/flamenco-manager \
    && ln -s /flamenco/flamenco-manager /usr/local/bin/flamenco-manager

# Set environment variables
ENV FLAMENCO_MANAGER_PORT=8080

# Create a user to run the manager
# RUN useradd -m -d /flamenco flamenco
# USER flamenco
WORKDIR /flamenco
RUN ./flamenco-manager -write-config
EXPOSE ${FLAMENCO_MANAGER_PORT}
ENTRYPOINT [ "flamenco-manager" ]