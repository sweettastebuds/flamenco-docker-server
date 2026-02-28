## Docker Image for Flamenco and Blender

This Docker image includes Flamenco 3.2 and Blender 3.3.6 on an Ubuntu 20.04 base.
By default, the docker-compose.yml file in this repository uses this image to run a Flamenco Manager server. Also provided is a docker-compose-worker.yml file that can be used to run a Flamenco Worker, but currently can only render in CPU mode. GPU rendering is not supported.

[![Docker](https://github.com/sweettastebuds/flamenco-docker-server/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sweettastebuds/flamenco-docker-server/actions/workflows/docker-publish.yml)
### To Do

- [ ] Add support for GPU rendering in the Flamenco Worker.

### Building the Image

To build the Docker image, use the following command:

```bash
docker build -t flamenco_docker_server .
```

Replace `flamenco_docker_server` with the desired name for your Docker image.

You can override the default Flamenco or Blender versions at build time using build arguments:

```bash
docker build \
  --build-arg FLAMENCO_VERSION=3.3 \
  --build-arg BLENDER_VERSION=3.4.1 \
  --build-arg BLENDER_MAJOR_MINOR=3.4 \
  -t flamenco_docker_server .
```

### Running a Container

To run a container from the image, use the following command:

```bash
docker run -d -p 8080:8080 flamenco_docker_server
```

This will run the container in detached mode (`-d`) and map port 8080 of the container to port 8080 of the host machine (`-p 8080:8080`).

The Flamenco Manager should be accessible at http://localhost:8080 from your host machine's web browser.

### Dockerfile Details

The Dockerfile begins from an Ubuntu 20.04 image, and it performs the following actions:

1. Installs necessary dependencies: ImageMagick, curl, tar, and xz-utils.
2. Creates a non-root `flamenco` system user to run the Flamenco Manager securely.
3. Downloads and installs Flamenco Manager from the specified URL and sets up a symlink for it.
4. Downloads and installs Blender from the specified URL and sets up a symlink for it.
5. Sets an environment variable for the Flamenco Manager port.
6. Runs the Flamenco Manager configuration and transfers ownership of relevant directories to the `flamenco` user.
7. Switches to the non-root `flamenco` user.
8. Configures a health check that polls the Flamenco Manager API every 30 seconds.
9. Sets the Flamenco Manager as the entry point of the container.

### Notes

- This Docker image is designed to be used as a base image. You may want to extend this Dockerfile or create another Dockerfile using this image to add any additional software or configuration that your application requires.
- The Flamenco Manager and Blender versions can be customised at build time via the `FLAMENCO_VERSION`, `BLENDER_VERSION`, and `BLENDER_MAJOR_MINOR` build arguments. The defaults are `3.2`, `3.3.6`, and `3.3` respectively.
- The container runs as the non-root `flamenco` user for improved security.
- A `HEALTHCHECK` is configured to poll `http://localhost:${FLAMENCO_MANAGER_PORT}/api/v3/version` every 30 seconds (with a 15-second start-up grace period). By default, `FLAMENCO_MANAGER_PORT` is `8080`.
