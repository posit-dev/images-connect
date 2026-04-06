# Posit Connect Container Images

[![Build](https://github.com/posit-dev/images-connect/actions/workflows/production.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/production.yml)
[![Content](https://github.com/posit-dev/images-connect/actions/workflows/content.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/content.yml)
[![Latest](https://img.shields.io/docker/v/posit/connect?sort=semver&label=latest)](https://hub.docker.com/r/posit/connect/tags)

Container images for [Posit Connect](https://docs.posit.co/connect/).

> [!NOTE]
> These images are in preview as Posit migrates container images from [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products). The existing images remain supported.

## Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | Running containers locally | [Get Docker](https://docs.docker.com/get-docker/) |
| [Helm](https://helm.sh/docs/intro/install/) | Deploying on Kubernetes | [Install Helm](https://helm.sh/docs/intro/install/) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Deploying on Kubernetes | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |
| Product license | Running Posit Connect | [Licensing FAQ](https://docs.posit.co/licensing/licensing-faq.html) |

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [connect](./connect/) | [`docker.io/posit/connect`](https://hub.docker.com/r/posit/connect) | [`ghcr.io/posit-dev/connect`](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| [connect-content](./connect-content/) | [`docker.io/posit/connect-content`](https://hub.docker.com/r/posit/connect-content) | [`ghcr.io/posit-dev/connect-content`](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |
| [connect-content-init](./connect-content-init/) | [`docker.io/posit/connect-content-init`](https://hub.docker.com/r/posit/connect-content-init) | [`ghcr.io/posit-dev/connect-content-init`](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

Additional Posit container images are published to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Running the Images

For local Docker, you only need the `connect` image. The `connect-content` and `connect-content-init` images are for Kubernetes deployments, where published content runs in separate pods from the Connect server.

- [Posit Connect](./connect/) — The Connect server
- [Connect Content](./connect-content/) — Runtime images for executing content (Kubernetes)
- [Connect Content Init](./connect-content-init/) — Init container for Kubernetes deployments

See the [Connect installation guide](https://docs.posit.co/connect/admin/getting-started/) for full setup instructions.

## Deploying on Kubernetes

Use the [Posit Connect Helm chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html) to deploy on Kubernetes.

```bash
helm repo add rstudio https://helm.rstudio.com
helm repo update
```

Create a Kubernetes secret from your license file, then configure the chart in your `values.yaml`:

```bash
kubectl create secret generic posit-connect-license \
  --from-file=license.lic=/path/to/license.lic
```

The `executionEnvironments` list uses [declarative management](https://docs.posit.co/connect/admin/appendix/off-host/execution-environments/#declarative-management). Unlike the legacy `customRuntimeYaml`, changes take effect on every `helm upgrade` without requiring a pod restart or database reset. Setting `customRuntimeYaml` to an empty images list prevents the chart from bootstrapping its default set of 12 content images on first start.

```yaml
image:
  repository: ghcr.io/posit-dev/connect
  tag: "2026.03.1"

license:
  file:
    secret: posit-connect-license

launcher:
  # Suppress the default runtime.yaml bootstrap so only
  # executionEnvironments images are registered.
  customRuntimeYaml: |
    name: Kubernetes
    images: []
  defaultInitContainer:
    repository: ghcr.io/posit-dev/connect-content-init
    tag: "2026.03.1"

executionEnvironments:
  - name: ghcr.io/posit-dev/connect-content:R4.5.2-python3.14.3-ubuntu-24.04
    title: "R 4.5.2 / Python 3.14.3"
    matching: any
    r:
      installations:
        - version: "4.5.2"
          path: /opt/R/4.5.2/bin/R
    python:
      installations:
        - version: "3.14.3"
          path: /opt/python/3.14.3/bin/python3
    quarto:
      installations:
        - version: "1.8.27"
          path: /opt/quarto/1.8.27/bin/quarto
  - name: ghcr.io/posit-dev/connect-content:R4.4.3-python3.12.12-ubuntu-24.04
    title: "R 4.4.3 / Python 3.12.12"
    matching: any
    r:
      installations:
        - version: "4.4.3"
          path: /opt/R/4.4.3/bin/R
    python:
      installations:
        - version: "3.12.12"
          path: /opt/python/3.12.12/bin/python3
    quarto:
      installations:
        - version: "1.8.27"
          path: /opt/quarto/1.8.27/bin/quarto
```

Content image tags follow the pattern `R{r_version}-python{python_version}-{os}`. Append `-pro` for images with Posit Professional Drivers.

Install the chart:

```bash
helm upgrade --install connect rstudio/rstudio-connect --values values.yaml
```

See the [full chart documentation](https://docs.posit.co/helm/charts/rstudio-connect/README.html) for all available values.

## Building from Source

You can interact with this repository in multiple ways:

* [Build container images directly](#build) from the Containerfile.
* [Use the `bakery` CLI](#using-bakery) to manage and build container images.
* Extend the functionality by using the Minimal base image (see [examples](https://github.com/posit-dev/images-examples)).

## Build

You can build OCI container images from the definitions in this repository using one of the following container build tools:

* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [docker buildx](https://github.com/docker/buildx#installing)

The root of the bakery project is used as the build context for each Containerfile.
Here, the [`bakery.yaml`](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/CONFIGURATION.md#bakery-configuration) file, or project, is in the root of this repository.

```shell
PCT_VERSION="2026.03"

# Build the standard Connect image using docker
docker buildx build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2404.std \
    .

# Build the minimal Connect image using buildah
buildah build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2404.min \
    .

# Build the minimal Connect image using podman
podman build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2404.min \
    .
```

## Using `bakery`

The structure and contents of this repository were created following the steps in [bakery usage](https://github.com/posit-dev/images-shared/tree/main/posit-bakery#usage).

Additional documentation:
- [Configuration Reference](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/CONFIGURATION.md) — `bakery.yaml` schema and options
- [Templating Reference](https://github.com/posit-dev/images-shared/blob/main/posit-bakery/TEMPLATING.md) — Jinja2 macros for Containerfile templates
- [CI Workflows](https://github.com/posit-dev/images-shared/blob/main/CI.md) — Shared GitHub Actions workflows for building and pushing images

### Prerequisites

Build prerequisites

* [python](https://docs.astral.sh/uv/guides/install-python/)
* [uv](https://docs.astral.sh/uv/getting-started/installation/)
* [docker buildx bake](https://github.com/docker/buildx#installing)
* [just](https://just.systems/man/en/prerequisites.html)
* `bakery`

    ```shell
    just install bakery
    ```

* `goss` and `dgoss` for running image validation tests

    ```shell
    just install-goss
    ```

### Build with `bakery`

By default, bakery creates an ephemeral JSON [bakefile](https://docs.bakefile.org/en/latest/language.html) to render all containers in parallel.

```shell
bakery build
```

You can view the bake plan using `bakery build --plan`.

You can use CLI flags to build only a subset of images in the project.

### Test images

After building the container images, run the test suite for all images:

```shell
bakery run dgoss
```

You can use CLI flags to limit the tests to run against a subset of images.

## Related Repositories

This repository is part of the [Posit Container Images](https://github.com/posit-dev/images) ecosystem. To extend the Minimal image with additional languages or system dependencies, see the [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending). For shared build tooling and CI workflows, see [images-shared](https://github.com/posit-dev/images-shared).

## Share your Feedback

We invite you to join us on [GitHub Discussions](https://github.com/posit-dev/images/discussions) to ask questions and share feedback.

## Issues

If you encounter any issues or have any questions, please [open an issue](https://github.com/posit-dev/images-connect/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit Container Images and associated tooling are licensed under the [MIT License](LICENSE.md)
