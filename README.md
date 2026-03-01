## Docker Image for Flamenco and Blender

This Docker image includes Flamenco 3.8.2 and Blender 5.0.1 on an Ubuntu 24.04 base.
By default, the docker-compose.yml file in this repository uses this image to run a Flamenco Manager and Worker. A standalone docker-compose-worker.yml is also provided for running just a worker. GPU rendering is supported for NVIDIA, AMD, and Intel GPUs via compose override files.

[![Docker](https://github.com/sweettastebuds/flamenco-docker-server/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sweettastebuds/flamenco-docker-server/actions/workflows/docker-publish.yml)

### Building the Image

To build the Docker image, use the following command:

```bash
docker build -t flamenco_docker_server .
```

Replace `flamenco_docker_server` with the desired name for your Docker image.

You can override the default Flamenco or Blender versions at build time using build arguments:

```bash
docker build \
  --build-arg FLAMENCO_VERSION=3.8.2 \
  --build-arg BLENDER_VERSION=5.0.1 \
  -t flamenco_docker_server .
```

### Running with Docker Compose

Start both the manager and worker:

```bash
docker compose up -d
```

Start only the worker (connecting to an external manager):

```bash
docker compose -f docker-compose-worker.yml up -d
```

The Flamenco Manager should be accessible at <http://localhost:780> from your host machine's web browser.

### GPU Rendering

By default, the worker renders using CPU only. To enable GPU rendering, use the appropriate override file for your GPU vendor:

| GPU Vendor | Override File               | Host Requirements                                                                              |
|------------|-----------------------------|------------------------------------------------------------------------------------------------|
| NVIDIA     | `docker-compose.nvidia.yml` | [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/) |
| AMD        | `docker-compose.amd.yml`    | AMD GPU drivers with [ROCm](https://rocm.docs.amd.com/)                                        |
| Intel      | `docker-compose.intel.yml`  | [Intel GPU drivers](https://dgpu-docs.intel.com/)                                              |

#### NVIDIA GPU

```bash
docker compose -f docker-compose.yml -f docker-compose.nvidia.yml up -d
```

Verify the toolkit is working on your host first:

```bash
docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu24.04 nvidia-smi
```

#### AMD GPU

```bash
docker compose -f docker-compose.yml -f docker-compose.amd.yml up -d
```

#### Intel GPU

```bash
docker compose -f docker-compose.yml -f docker-compose.intel.yml up -d
```

#### Standalone Worker with GPU

Substitute `docker-compose-worker.yml` for `docker-compose.yml`:

```bash
docker compose -f docker-compose-worker.yml -f docker-compose.nvidia.yml up -d
```

### Configuration

The Flamenco Manager configuration is stored in `build/flamenco-manager.yaml` and mounted into the container at startup. You can edit this file to change settings such as the manager name, storage paths, task timeouts, and Blender variables. The configuration can also be updated through the Manager's web interface at the Settings tab, which will overwrite this file inside the container.

The Flamenco Worker configuration is stored in `build/flamenco-worker.yaml`. Update the `manager_url` to point to your manager's address.

For a full reference of available configuration options, see the [Flamenco documentation](https://flamenco.blender.org/usage/manager-configuration/).

### Dockerfile Details

The Dockerfile begins from an Ubuntu 24.04 image, and it performs the following actions:

1. Installs necessary dependencies: ImageMagick, curl, tar, xz-utils, and X11/Mesa libraries for headless rendering.
2. Creates a non-root `flamenco` system user to run Flamenco securely.
3. Downloads and installs Flamenco Manager and Worker from the specified URL.
4. Downloads and installs Blender from the specified URL.
5. Sets the environment variable for the manager port.
6. Runs the Flamenco Manager configuration and transfers ownership of relevant directories to the `flamenco` user.
7. Switches to the non-root `flamenco` user.
8. Sets the Flamenco Manager as the entry point of the container.

### Notes

- This Docker image is designed to be used as a base image. You may want to extend this Dockerfile or create another Dockerfile using this image to add any additional software or configuration that your application requires.
- The Flamenco Manager and Blender versions can be customised at build time via the `FLAMENCO_VERSION` and `BLENDER_VERSION` build arguments. The defaults are `3.2` and `3.3.6` respectively, but the compose files override these to `3.8.2` and `5.0.1`.
- The container runs as the non-root `flamenco` user for improved security.
