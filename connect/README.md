<a href="https://posit.co/products/enterprise/connect">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
  <img alt="Posit PConnect Logo" src="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
</picture>
</a>

# Posit Connect container image

This container image provides [Posit Connect](https://docs.posit.co/connect/) (PCT), a publishing platform for the work your teams create in R and Python. Deploy Shiny applications, R Markdown documents, Plumber APIs, Python applications (Flask, Dash, FastAPI, Bokeh, Streamlit), Jupyter notebooks, Quarto documents, and more.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-connect)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-connect/production.yml?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/production.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/connect?sort=semver&label=latest)](https://hub.docker.com/r/posit/connect/tags)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/connect)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/connect/latest)

> [!NOTE]
> These images are in preview as Posit migrates container images from <a href="https://github.com/rstudio/rstudio-docker-products">rstudio/rstudio-docker-products</a>. The <a href="https://github.com/rstudio/rstudio-docker-products">rstudio-docker-products</a> images remain supported.

> [!TIP]
> Deploying on Kubernetes? Try the <a href="https://docs.posit.co/helm/charts/rstudio-connect/README.html">Posit Connect Helm chart</a>!

## Quick reference

|                           | |
|---------------------------|---|
| **Maintained by**         | [the Posit Docker team](https://github.com/posit-dev/images) |
| **Where to get help**     | [GitHub Issues](https://github.com/posit-dev/images-connect/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-connect/27), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues**  | [https://github.com/posit-dev/images-connect/issues](https://github.com/posit-dev/images-connect/issues) |
| **Source**                | [https://github.com/posit-dev/images-connect](https://github.com/posit-dev/images-connect) |
| **License**               | [MIT](https://github.com/posit-dev/images-connect/blob/main/LICENSE.md) |
| **Product documentation** | [Posit Connect documentation](https://docs.posit.co/connect/) |

## Related images

For Kubernetes deployments, Connect uses three images together. See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `connect-content` | Runtime images for executing published content | [posit/connect-content](https://hub.docker.com/r/posit/connect-content) | [posit-dev/connect-content](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |
| `connect-content-init` | Init container for Kubernetes deployments | [posit/connect-content-init](https://hub.docker.com/r/posit/connect-content-init) | [posit-dev/connect-content-init](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

## How to use this image

### Quick start

```bash
PCT_VERSION="2026.04.0"
PCT_IMAGE="ghcr.io/posit-dev/connect"  # or docker.io/posit/connect
PCT_LICENSE_FILE_HOST_PATH="/path/to/license.lic"
PCT_LICENSE_FILE_PATH="/etc/rstudio-connect/license.lic"
PCT_DATA_HOST_PATH="/data/connect"
docker run -d \
  --name connect \
  --privileged \
  -p 3939:3939 \
  -v ${PCT_LICENSE_FILE_HOST_PATH}:${PCT_LICENSE_FILE_PATH} \
  -v ${PCT_DATA_HOST_PATH}:/var/lib/rstudio-connect \
  ${PCT_IMAGE}:${PCT_VERSION}
```

Access Connect at `http://localhost:3939`.

> [!NOTE]
> Connect requires the `--privileged` flag to manage sandboxed content execution environments.

> [!IMPORTANT]
> To use Connect with more than one user, define `Server.Address` in the `rstudio-connect.gcfg` file. Set it to the URL that users will use to visit Connect, then start or restart the container.

### With a custom configuration file

```bash
PCT_VERSION="2026.04.0"
PCT_IMAGE="ghcr.io/posit-dev/connect"  # or docker.io/posit/connect
PCT_LICENSE_FILE_HOST_PATH="/path/to/license.lic"
PCT_LICENSE_FILE_PATH="/etc/rstudio-connect/license.lic"
PCT_DATA_HOST_PATH="/data/connect"
PCT_CONFIG_HOST_PATH="/path/to/rstudio-connect.gcfg"
docker run -d \
  --name connect \
  --privileged \
  -p 3939:3939 \
  -v ${PCT_LICENSE_FILE_HOST_PATH}:${PCT_LICENSE_FILE_PATH} \
  -v ${PCT_DATA_HOST_PATH}:/data \
  -v ${PCT_CONFIG_HOST_PATH}:/etc/rstudio-connect/rstudio-connect.gcfg:ro \
  ${PCT_IMAGE}:${PCT_VERSION}
```

### With Docker Compose

```yaml
services:
  connect:
    image: ghcr.io/posit-dev/connect:latest
    privileged: true
    ports:
      - "3939:3939"
    volumes:
      - /path/to/license.lic:/etc/rstudio-connect/license.lic
      - /path/to/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg:ro
      - connect-data:/var/lib/rstudio-connect
    restart: unless-stopped

volumes:
  connect-data:
```

## Image variants

Two variants are available:

| Variant          | Description                                                                                                                 |
|------------------|-----------------------------------------------------------------------------------------------------------------------------|
| Standard (`std`) | Opinionated image, runs out of the box. Bundles R, Python, Quarto, and Posit Professional Drivers alongside Connect.        |
| Minimal (`min`)  | Small image you can extend with desired dependencies. Does not run as is — Connect requires R, Python, and Quarto to serve published content. |

Each tagged image bundles a fixed set of dependencies. Both variants ship the `YYYY.MM` release of Connect at the latest patch release available when the image was built. The Standard variant additionally ships one R version, one Python version, and one Quarto version, locked to the latest available at release. The Containerfiles in this repository under `connect/<version>/` document the exact versions in any tag.

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/connect`
- GitHub Container Registry: `ghcr.io/posit-dev/connect`

Ubuntu 24.04 is the default OS.

Tag formats where `YYYY.MM.P` is any supported Connect version:
- `YYYY.MM.P` - Latest OS, standard variant
- `YYYY.MM.P-ubuntu-24.04` - Explicit OS, standard variant
- `YYYY.MM.P-ubuntu-24.04-std` - Explicit OS and variant
- `YYYY.MM.P-ubuntu-24.04-min` - Minimal variant
- `latest` - Latest version, default OS, standard variant

## Architectures

Posit publishes Connect images for `linux/amd64` and `linux/arm64`.  Pull the same tag from either platform; Docker selects the matching manifest automatically.

## Environment variables

| Variable                 | Description                                                          |
|--------------------------|----------------------------------------------------------------------|
| `PCT_LICENSE`            | License key for activation                                           |
| `PCT_LICENSE_SERVER`     | URL of floating license server                                       |
| `PCT_LICENSE_FILE_PATH`  | Path to license file (default: `/etc/rstudio-connect/license.lic`)   |
| `PCT_STARTUP_DEBUG` | Set to `1` for verbose startup logging                               |

If you are migrating from `rstudio/rstudio-connect`, see [Environment variables](#environment-variables-1) under the migration guide for the legacy `RSC_` names and deprecation timeline.

## Exposed ports

| Port | Description                |
|------|----------------------------|
| 3939 | HTTP web interface and API |

## Volumes

For persistent data, add these volume mounts to your `docker run` command:

```bash
-v /data/connect:/var/lib/rstudio-connect \
-v /data/connect-config:/etc/rstudio-connect
```

| Mount point                | Description                   |
|----------------------------|-------------------------------|
| `/var/lib/rstudio-connect` | Application data and database |
| `/etc/rstudio-connect`     | Configuration files           |

The data path is set by the `Server.DataDir` option in `rstudio-connect.gcfg` (default `/data`). If you change this option in a custom configuration, mount the persistent volume to the new path.

## Configuration

### License activation

Connect requires a [product license](https://docs.posit.co/licensing/licensing-faq.html). If you don't have a license yet, request a free 30-day trial at [posit.co/trial-license](https://posit.co/trial-license/).

Posit recommends activating with a license file. License files work well in all environments including ephemeral, container-based, or air-gapped environments. Choose one method:

#### Option 1: License file (recommended)

Mount the license file to any path in the container and set `PCT_LICENSE_FILE_PATH` to that path. The default search path is `/etc/rstudio-connect/license.lic`, so mounting to that path does not require setting the environment variable.

```bash
docker run --privileged -v /path/to/license.lic:/etc/rstudio-connect/license.lic ...
```

To ensure correct permissions on the license file, set the owner and mode on the host before mounting:

```bash
sudo chown root:root /path/to/license.lic
sudo chmod 0600 /path/to/license.lic
```

If the license file does not successfully activate, the container fails to start under most circumstances. See [Verify license activation status](#verify-license-activation-status) under Examples to confirm a successful activation in a running container.

#### Option 2: License key

```bash
docker run --privileged -e PCT_LICENSE="your-license-key" ...
```

License key activations can leak when a container shuts down ungracefully, consuming an activation slot that cannot be recovered through normal means. To help preserve license state across container restarts, mount these directories to persistent storage:

- `/var/lib/.local`
- `/var/lib/.prof`
- `/var/lib/rstudio-connect`

State files are hardware-locked and not transferable between hosts. Mounting these paths reduces the chance of a leak but does not eliminate it. To avoid the leak risk entirely, use a license file (Option 1). See the [License keys](#license-keys) caveat for more detail.

#### Option 3: Floating license server

```bash
docker run --privileged -e PCT_LICENSE_SERVER="license-server:port" ...
```

Floating license activations can also leak on ungraceful shutdown. To help preserve license state across container restarts, mount this directory to persistent storage:

- `/var/lib/.TurboFloat`

State files are hardware-locked and not transferable between hosts. To avoid the leak risk entirely, use a license file (Option 1).

### Custom configuration

Mount a custom configuration file:

```bash
docker run --privileged -v /path/to/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg ...
```

Make sure the configuration file sets these fields:

- `Server.Address` set to the exact URL that users will use to visit Connect
- `Server.DataDir` set to the same path as the data volume mount (default `/var/lib/rstudio-connect`)
- `HTTP.Listen` (or equivalent `HTTP`, `HTTPS`, or `HTTPRedirect` settings, which change how to map the container ports)
- `Python.Enabled` and `Python.Executable`

See the [configuration documentation](https://docs.posit.co/connect/admin/appendix/configuration/) for available options.

## Healthcheck

Connect exposes an unauthenticated health endpoint at `/__ping__` on port `3939` that returns `200 OK` once the application is ready to serve traffic.

```bash
curl http://localhost:3939/__ping__
```

The image declares a Docker `HEALTHCHECK` against this endpoint:

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl --fail --silent --output /dev/null http://localhost:3939/__ping__
```

Both variants inherit the same directive. The `min` variant will report unhealthy until extended with R, Python, and Quarto, since Connect does not serve content without them. To disable the directive in a derived image, add `HEALTHCHECK NONE`.

For Kubernetes liveness and readiness probes, or load balancer health checks, hit the same endpoint directly rather than relying on the Docker healthcheck.

## User

Connect runs with the `--privileged` flag. The container starts as `root` and Connect drops privileges to the `rstudio-connect` user (UID and GID `999`) for the server process and content sandboxing.

## Migrating from legacy image

This image replaces the legacy [`rstudio/rstudio-connect`](https://hub.docker.com/r/rstudio/rstudio-connect) image. Connect itself is unchanged — the application reads `rstudio-connect.gcfg`, listens on `3939`, writes data to `Server.DataDir`, requires `--privileged`, and uses the `rstudio-connect` user (UID/GID `999`) for content execution. Existing data and configuration volumes mount unchanged. The differences are in how the image is published and configured.

### Image references

The legacy image was published as `rstudio/rstudio-connect` on Docker Hub and `ghcr.io/rstudio/rstudio-connect` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Connect version, OS, and variant. See [Image tags](#image-tags) and [Architectures](#architectures).

### Variants

The legacy image shipped a single variant containing two R versions, two Python versions, Quarto, and Posit Professional Drivers. The Standard (`std`) variant is closest to the legacy image, containing one R version, one Python version, Quarto, and Posit Professional Drivers. The Minimal (`min`) variant has no equivalent in the legacy image. See [Image variants](#image-variants).

### Environment variables

License and debug environment variables now use the `PCT_` prefix:

| New variable            | Legacy variable         |
|-------------------------|-------------------------|
| `PCT_LICENSE`           | `RSC_LICENSE`           |
| `PCT_LICENSE_SERVER`    | `RSC_LICENSE_SERVER`    |
| `PCT_LICENSE_FILE_PATH` | `RSC_LICENSE_FILE_PATH` |
| `PCT_STARTUP_DEBUG`     | `STARTUP_DEBUG_MODE`    |

The image accepts the legacy `RSC_` license names as a fallback during the deprecation window.

> [!NOTE]
> Posit supports legacy `RSC_` variables for backward compatibility but plans to deprecate them. For more details and updates, see the <a href="https://docs.posit.co/connect/news/">Connect release notes</a>. For new deployments, use the `PCT_` prefix to ensure forward compatibility.

### Default data directory

The legacy image set `Server.DataDir` to `/data` by default, while this image sets it to `/var/lib/rstudio-connect` to align with the defaults used by Connect and its Helm chart. If you use the default configuration file that comes with the image, update your data volume mount to match the new path:

```bash
-v /data/connect:/var/lib/rstudio-connect
```

### What did not change

- Application port (`3939`)
- Configuration file path (`/etc/rstudio-connect/rstudio-connect.gcfg`)
- Service user (`rstudio-connect`, UID/GID `999`)
- `--privileged` flag requirement

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements should rebuild these images to meet their security standards.

Posit rebuilds published images for Posit product editions under active support weekly to pull in operating system patches.

### Privileged mode

Connect requires the `--privileged` flag to run containers. The flag is necessary for Connect to execute user content in isolated environments.

### License keys

License keys used in containers risk activation slot loss if containers are not gracefully stopped. The license deactivates on container exit, but ungraceful shutdowns (crashes, `docker kill`) can leave the activation slot consumed on the Posit license server.

To ensure proper license deactivation, use a sufficient stop timeout for both `docker run` and `docker stop`:

```bash
docker run -d --privileged --stop-timeout 120 -e PCT_LICENSE="your-license-key" ...
docker stop --time 120 <container>
```

For production deployments, use license files rather than license keys.

### Hardware locking

Connect hardware-locks license state files to a specific machine. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, can invalidate the license state, requiring reactivation.

To preserve license state across container restarts, mount these directories to persistent storage:

* License key
  * `/var/lib/.local`
  * `/var/lib/.prof`
  * `/var/lib/rstudio-connect`
* Floating license
  * `/var/lib/.TurboFloat`

Files in these directories are hardware-locked and not transferable between hosts. Posit advises gracefully shutting down containers and allowing license deactivation before changing any hardware or firmware on the host (for example, upgrading a network card or updating BIOS) or the container (for example, changing the network driver or allocated number of CPU cores).

## Documentation

- [Posit Connect Documentation](https://docs.posit.co/connect/)
- [Admin Guide](https://docs.posit.co/connect/admin/)
- [Configuration Reference](https://docs.posit.co/connect/admin/appendix/configuration/)
