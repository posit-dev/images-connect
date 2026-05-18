<a href="https://posit.co/products/enterprise/connect">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
  <img alt="Posit Connect Logo" src="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
</picture>
</a>

# Posit Connect container images

Container images for [Posit Connect](https://docs.posit.co/connect/).

[![Production CI Build Status](https://github.com/posit-dev/images-connect/actions/workflows/production.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/production.yml)
[![Development CI Build Status](https://github.com/posit-dev/images-connect/actions/workflows/development.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/development.yml)
[![Content CI Build Status](https://github.com/posit-dev/images-connect/actions/workflows/content.yml/badge.svg?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/content.yml)
[![Latest Version](https://img.shields.io/docker/v/posit/connect?sort=semver&label=latest)](https://hub.docker.com/r/posit/connect/tags)

## Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | Running containers locally | [Get Docker](https://docs.docker.com/get-docker/) |
| [Helm](https://helm.sh/docs/intro/install/) | Deploying on Kubernetes | [Install Helm](https://helm.sh/docs/intro/install/) |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Deploying on Kubernetes | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |
| Product license | Running Connect | [Licensing FAQ](https://docs.posit.co/licensing/licensing-faq.html), [Request a trial license](https://posit.co/trial-license/) |

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [connect](./connect/) | [`docker.io/posit/connect`](https://hub.docker.com/r/posit/connect) | [`ghcr.io/posit-dev/connect`](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| [connect-content](./connect-content/) | [`docker.io/posit/connect-content`](https://hub.docker.com/r/posit/connect-content) | [`ghcr.io/posit-dev/connect-content`](https://github.com/posit-dev/images-connect/pkgs/container/connect-content) |
| [connect-content-init](./connect-content-init/) | [`docker.io/posit/connect-content-init`](https://hub.docker.com/r/posit/connect-content-init) | [`ghcr.io/posit-dev/connect-content-init`](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

Posit publishes additional container images to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Running the images

For local Docker, you only need the `connect` image. The `connect-content` and `connect-content-init` images are for Kubernetes deployments, where published content runs in separate pods from the Connect server.

- [Connect](./connect/): the Connect server
- [Connect Content](./connect-content/): runtime images for executing content (Kubernetes)
- [Connect Content Init](./connect-content-init/): init container for Kubernetes deployments

See the [Connect installation guide](https://docs.posit.co/connect/admin/getting-started/) for full setup instructions.

## Deploying on Kubernetes

Use the [Posit Connect Helm chart](https://docs.posit.co/helm/charts/rstudio-connect/README.html) to deploy on Kubernetes. These images are the default in chart versions `>= 0.20.0`; see the [image migration guide](https://docs.posit.co/helm/docs/migrating-to-posit-images.html) if you are upgrading from an earlier chart version.

Content image tags follow the pattern `R{r_version}-python{python_version}-{os}`. Append `-pro` for images with Posit Professional Drivers. See the chart's [`executionEnvironments`](https://docs.posit.co/helm/charts/rstudio-connect/README.html) value for how to register content images for off-host execution.

## Build

You can build Open Container Initiative (OCI) container images from the definitions in this repository using one of the following container build tools:

* [docker buildx](https://github.com/docker/buildx#installing)
* [buildah](https://github.com/containers/buildah/blob/main/install.md)
* [podman](https://podman.io/docs/installation)

Each Containerfile uses the root of the repository as the build context.

```shell
PCT_VERSION="2026.04"

# Build the standard Connect image using docker
docker buildx build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2404.std \
    .

# Build the standard Connect image using buildah
buildah build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2404.std \
    .

# Build the standard Connect image using podman
podman build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2404.std \
    .
```

For builds using the `bakery` CLI, see the [contributing guide](CONTRIBUTING.md).

## Contributing

To build images with `bakery` or run the test suite, see the [contributing guide](CONTRIBUTING.md).

## Related repositories

This repository is part of the [Posit Container Images](https://github.com/posit-dev/images) ecosystem. To extend the Minimal image with additional languages or system dependencies, see the [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending). For shared build tooling and CI workflows, see [images-shared](https://github.com/posit-dev/images-shared).

## Share your feedback

We invite you to join us on [GitHub Discussions](https://github.com/posit-dev/images/discussions) to ask questions and share feedback.

## Issues

If you encounter any issues or have any questions, please [open an issue](https://github.com/posit-dev/images-connect/issues). We appreciate your feedback.

## Code of Conduct

We expect all contributors to adhere to the project's [Code of Conduct](CODE_OF_CONDUCT.md) and create a positive and inclusive community.

## License

Posit licenses these container images and associated tooling under the [MIT License](LICENSE.md).
