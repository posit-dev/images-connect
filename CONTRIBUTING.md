# Contributing to Posit Connect container images

This guide covers how to build and test the Connect container images locally, and how to
perform common maintenance tasks. To build images directly with Docker, Buildah, or
Podman, see the [README](README.md#build). To deploy or run pre-built images, see the
[README](README.md#running-the-images).

## Build and test

### Prerequisites

| Tool | Install |
|---|---|
| [python](https://docs.astral.sh/uv/guides/install-python/) + [uv](https://docs.astral.sh/uv/getting-started/installation/) | Required for `bakery` |
| [docker buildx bake](https://github.com/docker/buildx#installing) | Required for builds |
| [just](https://just.systems/man/en/prerequisites.html) | Task runner |

```shell
# Install bakery and goss
just init

# Install pre-commit hooks
just setup
```

### Build

```shell
# Preview the build plan
bakery build --plan

# Build all images
bakery build

# Build a specific image, version, and variant
bakery build --image-name connect --image-version 2026.05 --image-variant Standard
```

### Test

```shell
# Run goss tests for all images
bakery run dgoss

# Run goss tests for a specific image
bakery run dgoss --image-name connect
```

### Re-render templates

After changing any file in a `template/` directory, re-render the version directories:

```shell
# Omitting filters re-renders every image and version; --help shows available filters
bakery update files --help
bakery update files --image-name connect --image-version 2026.05
```

## Maintainer tasks

Each section below has Connect-specific context and a concrete example. The linked
procedure in the [shared maintainer guide](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md)
covers the full workflow.

### Add a version

Connect versions are dispatched automatically from `posit-dev/connect` via the
`posit-connect-projects` GitHub App, which triggers this repo's `release.yml` workflow.
Use manual steps only for hotfixes or if the automated dispatch fails.

```bash
# Create a new version manually (e.g., a hotfix to 2026.05)
bakery create version 2026.05.2 --image-name connect --image-name connect-content-init
bakery update files --image-name connect --image-version 2026.05
bakery update files --image-name connect-content-init --image-version 2026.05
```

`connect-content` is a matrix image. Its versions are managed via
`matrix.dependencyConstraints` in `bakery.yaml`, not with `bakery create version`.

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#add-a-version)

### Add an image

This repo has three images: `connect` (server), `connect-content` (R×Python matrix for
Launcher), and `connect-content-init` (Kubernetes init container). Adding a new image
requires coordination with the Connect product team to define the new service role.

```bash
# Scaffold a new image directory and template
bakery create image <new-image-name>
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#add-an-image)

### Update dependencies

`connect` uses `dependencyConstraints: latest: true` for R, Python, and Quarto — bakery
resolves the current latest at build time. `connect-content-init` has no dependency
constraints.

`connect-content` is a matrix image. Its R×Python combinations are defined in
`bakery.yaml` under `matrix.dependencyConstraints`. To add a new R or Python version to
the matrix, update the image's `matrix.dependencyConstraints` block in `bakery.yaml` and
re-render:

```bash
bakery update files --image-name connect-content
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#update-dependencies)

### Update older versions

```bash
# Edit the template, then re-render a specific edition
bakery update files --image-name connect --image-version 2026.04
bakery update files --image-name connect-content-init --image-version 2026.04

# Build and test before opening a PR
bakery build --image-name connect --image-version 2026.04
bakery run dgoss --image-name connect --image-version 2026.04
```

→ [Shared procedure](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#update-older-versions)

### Footguns

- **Connect Standard goss needs `wait: 20`.** The Connect server takes ~20 seconds to start. The Standard variant's `options` block in `bakery.yaml` sets `wait: 20`. Lowering or removing it causes flaky goss failures on slower runners.

- **`connect-content` has no version directories.** It renders into `connect-content/matrix/`. Do not create `connect-content/<edition>/` directories manually.

→ [Shared footguns](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#footguns)

### Diagnose a build failure

| Workflow | Schedule | Builds |
|---|---|---|
| `production.yml` | Weekly Sun 02:15 UTC, push to main, dispatch | `connect` + `connect-content-init` (excludes dev and matrix) |
| `development.yml` | Daily 08:45 UTC, push to main, dispatch | Dev stream previews → `ghcr.io/posit-dev/connect-preview` |
| `content.yml` | Weekly Sun 02:45 UTC, push to main, dispatch | `connect-content` matrix images only |

All workflows use `bakery-build-native.yml` (native amd64 + arm64 runners).

Connect-specific failure: goss timeout on the Standard variant. The Connect server
takes ~20s to start. If goss probes fail immediately, check that `options.wait: 20` is
still set in `bakery.yaml`.

→ [Shared failure scenarios](https://github.com/posit-dev/images-shared/blob/main/CONTRIBUTING.md#diagnose-a-build-failure)
