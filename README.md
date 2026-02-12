# Posit Connect Container Images

Container images for [Posit Connect](https://docs.posit.co/connect/).

> [!IMPORTANT]
> These images are under active development and testing and are not yet supported by Posit.
>
> Please see [rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products) for officially supported images.

## Images

| Image | Docker Hub | GitHub Container Registry |
|:------|:-----------|:--------------------------|
| [connect](./connect/) | `docker.io/posit/connect` | [`ghcr.io/posit-dev/connect`](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| [connect-content-init](./connect-content-init/) | `docker.io/posit/connect-content-init` | [`ghcr.io/posit-dev/connect-content-init`](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

Additional Posit container images are published to [Docker Hub](https://hub.docker.com/u/posit) and [GitHub Container Registry](https://github.com/orgs/posit-dev/packages).

## Getting Started

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
PCT_VERSION="2025.12"

# Build the standard Connect image using docker
docker buildx build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2204.std \
    .

# Build the minimal Connect image using buildah
buildah build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2204.min \
    .

# Build the minimal Connect image using podman
podman build \
    --tag connect:${PCT_VERSION} \
    --file connect/${PCT_VERSION}/Containerfile.ubuntu2204.min \
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
* [pipx](https://pipx.pypa.io/stable/installation/)
* [docker buildx bake](https://github.com/docker/buildx#installing)
* [just](https://just.systems/man/en/prerequisites.html)
* [gh](https://github.com/cli/cli#installation) (required while repositories are private)
* `bakery`

    ```shell
    just install bakery
    ```

* `goss` and `dgoss` for running image validation tests

    ```shell
    just install-goss
    ```

### Build with `bakery`

By default, bakery creates a ephemeral JSON [bakefile](https://docs.bakefile.org/en/latest/language.html) to render all containers in parallel.

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
