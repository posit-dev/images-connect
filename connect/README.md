# Posit Connect container image

This container image provides [Posit Connect](https://docs.posit.co/connect/) (PCT), a publishing platform that connects you and the work you do with others. Deploy Shiny applications, R Markdown documents, Plumber APIs, Python applications (Flask, Dash, FastAPI, Bokeh, Streamlit), Jupyter notebooks, Quarto documents, and more.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The [rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products) images remain supported.

## Related images

For Kubernetes deployments, Connect uses all three images together. See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `connect-content` | Runtime images for executing published content | [posit/connect-content](https://hub.docker.com/r/posit/connect-content) | [posit-dev/connect-content](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |
| `connect-content-init` | Init container for Kubernetes deployments | [posit/connect-content-init](https://hub.docker.com/r/posit/connect-content-init) | [posit-dev/connect-content-init](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

## Quick start

```bash
PCT_VERSION="2026.04.0"
PCT_IMAGE="ghcr.io/posit-dev/connect"  # or docker.io/posit/connect
PCT_LICENSE="/path/to/license.lic"
docker run -d \
  --name connect \
  --privileged \
  -p 3939:3939 \
  -v ${PCT_LICENSE}:/etc/rstudio-connect/license.lic \
  ${PCT_IMAGE}:${PCT_VERSION}
```

Access Connect at `http://localhost:3939`.

> [!NOTE]
> Connect requires the `--privileged` flag to manage sandboxed content execution environments.
> This example does not mount a data volume. Application data will not persist when the container stops. See [Volume mounts](#volume-mounts) for persistent storage.

> [!IMPORTANT]
> To use Connect with more than one user, define `Server.Address` in
> the `rstudio-connect.gcfg` file. Set it to the URL that users will use to
> visit Connect, then start or restart the container.

## Image variants

Two variants are available:

| Variant | Description |
|---------|-------------|
| `std` (Standard) | Opinionated image with R, Python, and Quarto pre-installed, runs out of the box |
| `min` (Minimal) | Small image you can extend with desired dependencies; will not run as is |

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/connect`
- GitHub Container Registry: `ghcr.io/posit-dev/connect`

Ubuntu 24.04 is the default OS.

The tag formats are:
- `2026.04.0` - Latest OS, standard variant
- `2026.04.0-ubuntu-24.04` - Explicit OS, standard variant
- `2026.04.0-ubuntu-24.04-std` - Explicit OS and variant
- `2026.04.0-ubuntu-24.04-min` - Minimal variant
- `latest` - Latest version, default OS, standard variant

## Configuration

### License activation

Connect requires a [product license](https://docs.posit.co/licensing/licensing-faq.html). Posit recommends license file activation. Connect must also run with the `--privileged` flag. Choose one activation method:

#### Option 1: License file (recommended)

```bash
docker run --privileged -v /path/to/license.lic:/etc/rstudio-connect/license.lic ...
```

#### Option 2: License key

```bash
docker run --privileged -e PCT_LICENSE="your-license-key" ...
```

#### Option 3: Floating license server

```bash
docker run --privileged -e PCT_LICENSE_SERVER="license-server:port" ...
```

### Environment variables

| Variable              | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `PCT_LICENSE`         | License key for activation                                    |
| `PCT_LICENSE_SERVER`  | URL of floating license server                                |
| `PCT_LICENSE_FILE_PATH` | Path to license file (default: `/etc/rstudio-connect/license.lic`) |
| `STARTUP_DEBUG_MODE`  | Set to `1` for verbose startup logging                        |

#### Legacy environment variables

| Legacy Variable        | Preferred Equivalent   | Notes         |
|------------------------|------------------------|---------------|
| `RSC_LICENSE`          | `PCT_LICENSE`          | Same behavior |
| `RSC_LICENSE_SERVER`   | `PCT_LICENSE_SERVER`   | Same behavior |
| `RSC_LICENSE_FILE_PATH`| `PCT_LICENSE_FILE_PATH`| Same behavior |

> [!NOTE]
> Connect supports legacy `RSC_` variables for backward compatibility but plans to deprecate them. For more details and updates, see the [Connect release notes](https://docs.posit.co/connect/news/). For new deployments, always use the `PCT_` prefix to ensure forward compatibility.

### Volume mounts

For persistent data, add these volume mounts to your `docker run` command:

```bash
-v /data/connect:/data \
-v /data/connect-config:/etc/rstudio-connect
```

| Mount Point             | Description         |
|-------------------------|---------------------|
| `/data`                 | Application data and database |
| `/etc/rstudio-connect`  | Configuration files |

### Custom configuration

Mount a custom configuration file:

```bash
docker run --privileged -v /path/to/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg ...
```

Be sure the config file has these fields:

- `Server.Address` set to the exact URL that users will use to visit Connect
- `Server.DataDir` set to `/data/`
- `HTTP.Listen` (or equivalent `HTTP`, `HTTPS`, or `HTTPRedirect` settings)
- `Python.Enabled` and `Python.Executable`

See the [configuration documentation](https://docs.posit.co/connect/admin/appendix/configuration/) for available options.

## Exposed ports

| Port | Description |
|------|-------------|
| 3939 | HTTP web interface and API |

## User

Runs as the `rstudio-connect` user (UID and GID 999).

## Differences from rstudio/rstudio-connect

This image differs from the legacy [`rstudio/rstudio-connect`](https://hub.docker.com/r/rstudio/rstudio-connect) image:

| Aspect           | This Image                             | rstudio/rstudio-connect                                       |
|------------------|----------------------------------------|---------------------------------------------------------------|
| Registry         | `posit/connect`                        | `rstudio/rstudio-connect`                                     |
| License env vars | `PCT_` prefix                          | `RSC_` prefix                                                 |
| Variants         | `std` (with R/Python), `min` (minimal) | Single variant; multiple tags for different R/Python versions |
| Base OS options  | Ubuntu 24.04, Ubuntu 22.04             | Ubuntu 22.04                                                  |

## Caveats

### Security

Review these images before production use. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements must rebuild these images to meet their security standards.

Posit rebuilds published images for Posit product editions under active support weekly to pull in operating system patches.

### Privileged mode

Connect requires the `--privileged` flag to run containers. This is necessary for Connect to execute user content in isolated environments.

### License keys

License keys used in containers risk activation slot loss if containers are not gracefully stopped. The license deactivates on container exit, but ungraceful shutdowns (crashes, `docker kill`) might leave the activation slot consumed on the Posit license server.

To avoid "leaking" licenses, use a sufficient stop timeout:

```bash
docker run -d \
  --privileged \
  --stop-timeout 120 \
  -e PCT_LICENSE="your-license-key" \
  ...
```

For production deployments, Posit recommends license files over license keys.

To preserve license state data across container restarts, mount these directories to persistent storage:

* License Key
  * `/var/lib/.local`
  * `/var/lib/.prof`
  * `/var/lib/rstudio-connect`
* Floating License
  * `/var/lib/.TurboFloat`

### Hardware locking

Connect hardware-locks license state files. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, might invalidate the license state, requiring reactivation.

## Documentation

- [Posit Connect Documentation](https://docs.posit.co/connect/)
- [Admin Guide](https://docs.posit.co/connect/admin/)
- [Configuration Reference](https://docs.posit.co/connect/admin/appendix/configuration/)
