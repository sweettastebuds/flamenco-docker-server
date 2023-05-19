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
2. Downloads and installs Flamenco Manager from the specified URL and sets up a symlink for it.
3. Downloads and installs Blender from the specified URL and sets up a symlink for it.
4. Sets an environment variable for the Flamenco Manager port.
5. Runs the Flamenco Manager configuration.
6. Sets the Flamenco Manager as the entry point of the container.

### Notes

- This Docker image is designed to be used as a base image. You may want to extend this Dockerfile or create another Dockerfile using this image to add any additional software or configuration that your application requires.
- The Flamenco Manager and Blender versions, as well as the URLs for their tarballs, are hard-coded in this Dockerfile. If you want to use different versions, you need to modify the URLs accordingly. Also, you will need to ensure that the extraction commands (`tar -xzf` and `tar -xf`) are appropriate for the type of file you are downloading. Different versions of Flamenco Manager and Blender may be packaged differently.
- This Dockerfile does not include instructions to create a non-root user to run the Flamenco Manager and Blender. Depending on your security requirements, you may want to add such instructions.
