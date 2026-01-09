# Posit Connect Content Init Container Image

This container image is an "init container" used to pull runtime components into another container, which can then be used with Posit Connect and Launcher to build and run content. This image is primarily used in Kubernetes deployments and is leveraged by the Posit Connect Helm chart.

> [!IMPORTANT]
> This image is under active development and testing and is not yet supported by Posit.
>
> Please see [rstudio-connect-content-init image](https://github.com/rstudio/rstudio-docker-products/tree/main/connect-content-init) in `rstudio/rstudio-docker-products` for the officially supported image.

## Overview

The Content Init container provides runtime components that are copied into a shared volume during pod initialization. These components enable Posit Connect to execute content in isolated Kubernetes pods via the Launcher.

This container [can be extended to include additional content](https://docs.posit.co/helm/examples/connect/container-images/custom-images.html) beyond what is provided by default.

## Image Tags

Images are published to:
- Docker Hub: `docker.io/posit/connect-content-init`
- GitHub Container Registry: `ghcr.io/posit-dev/connect-content-init`

Tag formats:
- `2025.11.0` - Full version (Ubuntu 22.04)
- `2025.11.0-ubuntu-22.04` - Explicit OS
- `latest` - Latest stable release (currently 2025.11.0, Ubuntu 22.04)

## Usage

This image is designed to be used as an init container in Kubernetes. It copies runtime components to a shared volume that is then mounted by the content execution container.

### Kubernetes Init Container Example

```yaml
initContainers:
  - name: connect-content-init
    image: posit/connect-content-init:2025.11.0
    volumeMounts:
      - name: connect-runtime
        mountPath: /opt/rstudio-connect-runtime
```

### Helm Chart

This image is used automatically when deploying Posit Connect via the official Helm chart. For more information, see the [Posit Connect Helm Chart documentation](https://docs.posit.co/helm/charts/rstudio-connect/README.html).

## Differences from rstudio/rstudio-connect-content-init

This image differs from the legacy [`rstudio/rstudio-connect-content-init`](https://hub.docker.com/r/rstudio/rstudio-connect-content-init) image:

| Aspect           | This Image                      | rstudio/rstudio-connect-content-init |
|------------------|---------------------------------|--------------------------------------|
| Registry         | `posit/connect-content-init`    | `rstudio/rstudio-connect-content-init` |
| Base OS options  | Ubuntu 22.04                    | Ubuntu 22.04                         |

## Caveats

### Security

These images should be reviewed before production use. Organizations with specific CVE or vulnerability requirements should rebuild these images to meet their security standards.

Published images for Posit Product editions under active support are re-built on a weekly basis to pull in operating system patches.

## Documentation

- [Posit Connect Documentation](https://docs.posit.co/connect/)
- [Posit Connect Helm Chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html)
- [Custom Container Images for Connect](https://docs.posit.co/helm/examples/connect/container-images/custom-images.html)
