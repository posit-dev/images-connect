# Posit Connect Container Image

This container image provides [Posit Connect](https://docs.posit.co/connect/) (PCT), a publishing platform that connects you and the work you do with others. Deploy Shiny applications, R Markdown documents, Plumber APIs, Python applications (Flask, Dash, FastAPI, Bokeh, Streamlit), Jupyter notebooks, Quarto documents, and more.

> [!IMPORTANT]
> This image is under active development and testing and is not yet supported by Posit.
>
> Please see [rstudio-connect image](https://github.com/rstudio/rstudio-docker-products/tree/main/connect) in `rstudio/rstudio-docker-products` for the officially supported image.

## Quick Start

```bash
PCT_VERSION="2025.12.1"
docker run -d \
  --name connect \
  --privileged \
  -p 3939:3939 \
  -v /path/to/license.lic:/etc/rstudio-connect/license.lic \
  posit/connect:${PCT_VERSION}-ubuntu-22.04
```

Access Posit Connect at `http://localhost:3939`.

> IMPORTANT: To use Posit Connect with more than one user, you will need to
> define `Server.Address` in the `rstudio-connect.gcfg` file. Update your
> configuration file with the URL that users will use to visit Connect,
> then start or restart the container.

## Image Variants

Two variants are available:

| Variant | Description |
|---------|-------------|
| `std` (Standard) | Opinionated image with R, Python, and Quarto pre-installed, runs out of the box |
| `min` (Minimal) | Small image you can extend with desired dependencies, *will not run as is* |

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on the Minimal image.

## Image Tags

Images are published to:
- Docker Hub: `docker.io/posit/connect`
- GitHub Container Registry: `ghcr.io/posit-dev/connect`

Tag formats:
- `2025.12.1` - Full version (standard variant, Ubuntu 22.04)
- `2025.12.1-ubuntu-22.04-std` - Explicit OS and variant
- `2025.12.1-ubuntu-22.04-min` - Minimal variant
- `latest` - Latest stable release (standard variant, Ubuntu 22.04)

## Configuration

### License Activation

A valid license is required. Posit Connect must also run with the `--privileged` flag. Choose one license activation method:

**Option 1: License File (Recommended)**
```bash
docker run --privileged -v /path/to/license.lic:/etc/rstudio-connect/license.lic ...
```

**Option 2: License Key**
```bash
docker run --privileged -e PCT_LICENSE="your-license-key" ...
```

**Option 3: Floating License Server**
```bash
docker run --privileged -e PCT_LICENSE_SERVER="license-server:port" ...
```

### Environment Variables

| Variable              | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `PCT_LICENSE`         | License key for activation                                    |
| `PCT_LICENSE_SERVER`  | URL of floating license server                                |
| `PCT_LICENSE_FILE_PATH` | Path to license file (default: `/etc/rstudio-connect/license.lic`) |
| `STARTUP_DEBUG_MODE`  | Set to `1` for verbose startup logging                        |

#### Legacy Environment Variables

| Legacy Variable        | Preferred Equivalent   | Notes         |
|------------------------|------------------------|---------------|
| `RSC_LICENSE`          | `PCT_LICENSE`          | Same behavior |
| `RSC_LICENSE_SERVER`   | `PCT_LICENSE_SERVER`   | Same behavior |
| `RSC_LICENSE_FILE_PATH`| `PCT_LICENSE_FILE_PATH`| Same behavior |

**Note:** Legacy `RSC_` variables are supported for backward compatibility but are planned for deprecation. For more details and updates, see the [Posit Connect release notes](https://docs.posit.co/connect/news/). For new deployments, always use the `PCT_` prefix to ensure forward compatibility.

### Volume Mounts

For persistent data, add these volume mounts to your `docker run` command:

```bash
-v /data/connect:/data \
-v /data/connect-config:/etc/rstudio-connect
```

| Mount Point             | Description         |
|-------------------------|---------------------|
| `/data`                 | Application data and database |
| `/etc/rstudio-connect`  | Configuration files |

### Custom Configuration

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

## Exposed Ports

| Port | Description |
|------|-------------|
| 3939 | HTTP web interface and API |

## User

Runs as the `rstudio-connect` user (UID/GID 999).

## Differences from rstudio/rstudio-connect

This image differs from the legacy [`rstudio/rstudio-connect`](https://hub.docker.com/r/rstudio/rstudio-connect) image:

| Aspect           | This Image                             | rstudio/rstudio-connect                                       |
|------------------|----------------------------------------|---------------------------------------------------------------|
| Registry         | `posit/connect`                        | `rstudio/rstudio-connect`                                     |
| License env vars | `PCT_` prefix                          | `RSC_` prefix                                                 |
| Variants         | `std` (with R/Python), `min` (minimal) | Single variant; multiple tags for different R/Python versions |
| Base OS options  | Ubuntu 22.04                           | Ubuntu 22.04                                                  |

## Caveats

### Security

These images should be reviewed before production use. Organizations with specific CVE or vulnerability requirements should rebuild these images to meet their security standards.

Published images for Posit Product editions under active support are re-built on a weekly basis to pull in operating system patches.

### Privileged Mode

Posit Connect requires the `--privileged` flag to run containers. This is necessary for Connect to execute user content in isolated environments.

### License Keys

License keys used in containers risk activation slot loss if containers aren't gracefully stopped. The license deactivates on container exit, but ungraceful shutdowns (crashes, `docker kill`) may leave the activation slot consumed on Posit's license server.

To avoid "leaking" licenses, use a sufficient stop timeout:

```bash
docker run -d \
  --privileged \
  --stop-timeout 120 \
  -e PCT_LICENSE="your-license-key" \
  ...
```

For production deployments, license files are recommended over license keys.

To preserve license state data across container restarts, mount these directories to persistent storage:

* License Key
  * `/var/lib/.local`
  * `/var/lib/.prof`
  * `/var/lib/rstudio-connect`
* Floating License
  * `/var/lib/.TurboFloat`

### Hardware Locking

License state files are hardware-locked. Changes to MAC addresses, hostnames, or container orchestration platforms, such as Kubernetes, may invalidate existing license state, requiring reactivation.

## Documentation

- [Posit Connect Documentation](https://docs.posit.co/connect/)
- [Admin Guide](https://docs.posit.co/connect/admin/)
- [Configuration Reference](https://docs.posit.co/connect/admin/appendix/configuration/)
