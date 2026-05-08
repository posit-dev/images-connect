<a href="https://posit.co/products/enterprise/connect">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
  <img alt="Posit PConnect Logo" src="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
</picture>
</a>

# Posit Connect Content Init container image

This container image is an init container for Posit Connect that pulls runtime components into a shared volume. The Connect Launcher then uses those components to build and run published content in separate pods. This image is for Off-Host Execution (OHE) deployments on Kubernetes and is the default init container in the Connect Helm chart.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-connect)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-connect/production.yml?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/production.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/connect-content-init?sort=semver&label=latest)](https://hub.docker.com/r/posit/connect-content-init/tags)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/posit/connect-content-init)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/connect-content-init/latest)

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The [rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products) images remain supported.

> [!TIP]
> Deploying on Kubernetes? Try the [Posit Connect Helm chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html), which uses this image by default.

## Supported tags

- [`2026.04.0`, `2026.04.0-ubuntu-24.04`, `latest`, `ubuntu-24.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2026.04/Containerfile.ubuntu2404)
- [`2026.04.0-ubuntu-22.04`, `ubuntu-22.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2026.04/Containerfile.ubuntu2204)
- [`2026.03.1`, `2026.03.1-ubuntu-24.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2026.03/Containerfile.ubuntu2404)
- [`2026.02.1`, `2026.02.1-ubuntu-24.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2026.02/Containerfile.ubuntu2404)
- [`2026.01.1`, `2026.01.1-ubuntu-24.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2026.01/Containerfile.ubuntu2404)
- [`2025.12.1`, `2025.12.1-ubuntu-24.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2025.12/Containerfile.ubuntu2404)
- [`2025.11.0`, `2025.11.0-ubuntu-22.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2025.11/Containerfile.ubuntu2204)
- [`2025.09.1`, `2025.09.1-ubuntu-22.04`](https://github.com/posit-dev/images-connect/blob/main/connect-content-init/2025.09/Containerfile.ubuntu2204)

For a full list of available tags, see the [Tags tab](https://hub.docker.com/r/posit/connect-content-init/tags) on Docker Hub.

## Quick reference

| | |
|---|---|
| **Maintained by** | [the Posit Docker team](https://github.com/posit-dev/images) |
| **Where to get help** | [GitHub Issues](https://github.com/posit-dev/images-connect/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-connect/27), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues** | [https://github.com/posit-dev/images-connect/issues](https://github.com/posit-dev/images-connect/issues) |
| **Source** | [https://github.com/posit-dev/images-connect](https://github.com/posit-dev/images-connect) |
| **License** | [MIT](https://github.com/posit-dev/images-connect/blob/main/LICENSE.md) |

## Related images

For Kubernetes deployments, Connect uses three images together. See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `connect` | The Connect server | [posit/connect](https://hub.docker.com/r/posit/connect) | [posit-dev/connect](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| `connect-content` | Runtime images for executing published content | [posit/connect-content](https://hub.docker.com/r/posit/connect-content) | [posit-dev/connect-content](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |

## How to use this image

### With the Connect Helm chart

The [Connect Helm chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html) uses this image by default for OHE deployments. Pin the image with the `launcher.defaultInitContainer` value:

```yaml
launcher:
  defaultInitContainer:
    repository: ghcr.io/posit-dev/connect-content-init
    tag: "2026.04.0"
```

See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for a full chart example.

### As a Kubernetes init container

To wire the image up directly in a pod spec, mount a shared volume at `/mnt/rstudio-connect-runtime`. The entrypoint copies the runtime components from `/opt/rstudio-connect-runtime` in the image into that path. The Connect content container then mounts the same volume to consume the runtime.

```yaml
initContainers:
  - name: connect-content-init
    image: ghcr.io/posit-dev/connect-content-init:2026.04.0
    volumeMounts:
      - name: connect-runtime
        mountPath: /mnt/rstudio-connect-runtime
volumes:
  - name: connect-runtime
    emptyDir: {}
```

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/connect-content-init`
- GitHub Container Registry: `ghcr.io/posit-dev/connect-content-init`

Ubuntu 24.04 is the default OS.

Tag formats where `YYYY.MM.P` is any supported Connect version:
- `YYYY.MM.P` - Default OS
- `YYYY.MM.P-ubuntu-24.04` - Explicit OS
- `YYYY.MM.P-ubuntu-22.04` - Older OS
- `latest` - Latest version, default OS

## Architectures

Posit publishes multi-arch images for both `linux/amd64` and `linux/arm64`. Pull the same tag from either platform; Docker selects the matching manifest automatically.

## Volumes

The init container copies runtime components from `/opt/rstudio-connect-runtime` in the image into `/mnt/rstudio-connect-runtime` on the shared volume.

| Mount point                     | Description                                            |
|---------------------------------|--------------------------------------------------------|
| `/mnt/rstudio-connect-runtime`  | Shared volume populated with the Connect runtime files |

The content execution container mounts the same volume to consume the runtime files at the path Connect expects.

## User

The container starts as `root` so the entrypoint can write files into the shared volume with the permissions Connect expects. The init container exits after the copy completes.

## Examples

### Extending with custom content

You can extend this image to include additional content beyond the default set. For example, you can add custom R packages, Python packages, or system dependencies that your published content requires. See [Custom Container Images for Connect](https://docs.posit.co/helm/examples/connect/container-images/custom-images.html).

## Migrating from rstudio/rstudio-connect-content-init

This image replaces the legacy [`rstudio/rstudio-connect-content-init`](https://hub.docker.com/r/rstudio/rstudio-connect-content-init) image. The init container behavior is unchanged — the entrypoint copies runtime components into a shared volume at `/mnt/rstudio-connect-runtime` for the Connect content container to consume. The differences are in how the image is published.

### Image references

The legacy image was published as `rstudio/rstudio-connect-content-init` on Docker Hub and `ghcr.io/rstudio/rstudio-connect-content-init` on GHCR, tagged by OS (`jammy`, `ubuntu2204`, `jammy-<version>`, `ubuntu2204-<version>`) for `linux/amd64` only. Update your image reference to one of the new locations and pick a tag that pins to your desired Connect version and OS. See [Image tags](#image-tags) and [Architectures](#architectures).

### Base OS options

The legacy image shipped Ubuntu 22.04 only. This image adds Ubuntu 24.04 as the default OS while still publishing Ubuntu 22.04 tags. See [Image tags](#image-tags).

### What did not change

- Source path for runtime components (`/opt/rstudio-connect-runtime`)
- Target path on the shared volume (`/mnt/rstudio-connect-runtime`)
- Entrypoint behavior (one-shot copy, then exit)
- Compatibility with the Connect Helm chart and Connect Launcher

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements should rebuild these images to meet their security standards.

Posit rebuilds published images for Posit product editions under active support weekly to pull in operating system patches.