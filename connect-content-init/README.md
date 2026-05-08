# Posit Connect Content Init container image

This container image is an "init container" that pulls runtime components into another container, which Posit Connect and Launcher can then use to build and run content. Kubernetes deployments primarily use this image, and the Connect Helm chart uses it by default.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The [rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products) images remain supported.

## Overview

The `connect-content-init` container provides runtime components that the init process copies into a shared volume during pod initialization. These components enable Connect to execute content in isolated Kubernetes pods via the Launcher.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `connect` | The Posit Connect server | [posit/connect](https://hub.docker.com/r/posit/connect) | [posit-dev/connect](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| `connect-content` | Runtime images for executing published content | [posit/connect-content](https://hub.docker.com/r/posit/connect-content) | [posit-dev/connect-content](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |
| `connect-content-init` | Init container for Kubernetes deployments | [posit/connect-content-init](https://hub.docker.com/r/posit/connect-content-init) | [posit-dev/connect-content-init](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for Helm configuration.

You can [extend this container to include additional content](https://docs.posit.co/helm/examples/connect/container-images/custom-images.html) beyond the default set.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/connect-content-init`
- GitHub Container Registry: `ghcr.io/posit-dev/connect-content-init`

The tag formats are:
- `2026.04.0` - Full version (Ubuntu 24.04)
- `2026.04.0-ubuntu-24.04` - Explicit OS
- `latest` - Latest stable release (Ubuntu 24.04)

## Usage

Use this image as an init container in Kubernetes. It copies runtime components to a shared volume that the content execution container then mounts.

### Kubernetes init container example

```yaml
initContainers:
  - name: connect-content-init
    image: ghcr.io/posit-dev/connect-content-init:2026.04.0
    volumeMounts:
      - name: connect-runtime
        mountPath: /opt/rstudio-connect-runtime
```

### Helm chart

The official Helm chart uses this image automatically when deploying Connect. For more information, see the [Connect Helm chart documentation](https://docs.posit.co/helm/charts/rstudio-connect/README.html).

## Differences from rstudio/rstudio-connect-content-init

This image differs from the legacy [`rstudio/rstudio-connect-content-init`](https://hub.docker.com/r/rstudio/rstudio-connect-content-init) image:

| Aspect           | This Image                      | rstudio/rstudio-connect-content-init |
|------------------|---------------------------------|--------------------------------------|
| Registry         | `posit/connect-content-init`    | `rstudio/rstudio-connect-content-init` |
| Base OS options  | Ubuntu 24.04, Ubuntu 22.04      | Ubuntu 22.04                         |

## Caveats

### Security

Review these images before production use. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements must rebuild these images to meet their security standards.

Posit rebuilds published images for Posit product editions under active support weekly to pull in operating system patches.

## Documentation

- [Posit Connect Documentation](https://docs.posit.co/connect/)
- [Posit Connect Helm Chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html)
- [Custom Container Images for Connect](https://docs.posit.co/helm/examples/connect/container-images/custom-images.html)
