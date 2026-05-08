# Posit Connect Content container image

These container images provide the runtime environments for executing content deployed to [Posit Connect](https://docs.posit.co/connect/) in Kubernetes. Each image includes a specific combination of R, Python, and Quarto.

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The [rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products) images remain supported.

## Overview

When [Connect](https://docs.posit.co/connect/) runs on Kubernetes with the Job Launcher, published content (Shiny apps, Plumber APIs, Quarto documents, Jupyter notebooks, etc.) executes inside content containers. Each `connect-content` image provides a specific R and Python version pair.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `connect` | The Posit Connect server | [posit/connect](https://hub.docker.com/r/posit/connect) | [posit-dev/connect](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| `connect-content` | Runtime images for executing published content | [posit/connect-content](https://hub.docker.com/r/posit/connect-content) | [posit-dev/connect-content](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |
| `connect-content-init` | Init container for Kubernetes deployments | [posit/connect-content-init](https://hub.docker.com/r/posit/connect-content-init) | [posit-dev/connect-content-init](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for Helm configuration.

## Image variants

| Variant | Tag Suffix | Description |
|---------|------------|-------------|
| Base | (none) | Open-source R and Python |
| Pro | `-pro` | Includes Posit Professional Drivers for database connectivity |

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/connect-content`
- GitHub Container Registry: `ghcr.io/posit-dev/connect-content`

The tag format is: `R{r_version}-python{python_version}-{os}[-pro]`

Examples:
- `R4.5.2-python3.14.3-ubuntu-24.04` — R 4.5.2, Python 3.14.3, Ubuntu 24.04
- `R4.4.3-python3.12.12-ubuntu-24.04-pro` — Same versions with pro drivers

## Available versions

The standard set of content images covers a matrix of R and Python versions:

| R Version | Python Versions |
|-----------|----------------|
| 4.5.2 | 3.14.3, 3.13.12, 3.12.12, 3.11.14 |
| 4.4.3 | 3.14.3, 3.13.12, 3.12.12, 3.11.14 |
| 4.3.3 | 3.14.3, 3.13.12, 3.12.12, 3.11.14 |

## Usage

Do not run these images directly. Configure them as execution environments in Connect, either through:

1. **Helm chart values:** The `rstudio/rstudio-connect` Helm chart includes a default set of content images. See the [repository README](../README.md#deploying-on-kubernetes) for configuration details.
2. **Connect admin dashboard:** Manage execution environments in the Connect UI under **Admin > Execution environments**.
3. **runtime.yaml:** A YAML configuration file that defines available execution environments.

## Installed software

Each image includes:

| Component | Path |
|-----------|------|
| R | `/opt/R/{version}/bin/R` |
| Python | `/opt/python/{version}/bin/python3` |
| Quarto | `/opt/quarto/{version}/bin/quarto` |

## Documentation

- [Posit Connect Content Images](https://docs.posit.co/connect/admin/runtimes/content-images/)
- [Posit Connect Documentation](https://docs.posit.co/connect/)
- [Posit Connect Helm Chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html)
