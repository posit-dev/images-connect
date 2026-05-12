<a href="https://posit.co/products/enterprise/connect">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-reverse.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
  <img alt="Posit Connect Logo" src="https://cdn.posit.co/platform/containers/logos/logo_connecttag-fullcolor.svg">
</picture>
</a>

# Posit Connect Content container image

These container images provide the runtime environments for executing content deployed to [Posit Connect](https://docs.posit.co/connect/) in Kubernetes. Each image bundles a specific combination of R, Python, and Quarto so that content runs in an environment matching its language requirements.

[![GitHub Repository](https://img.shields.io/badge/github-repo?logo=github&color=grey)](https://github.com/posit-dev/images-connect)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/posit-dev/images-connect/content.yml?branch=main)](https://github.com/posit-dev/images-connect/actions/workflows/content.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/posit/connect-content)
![Docker Image Size](https://img.shields.io/docker/image-size/posit/connect-content/latest)
<!--
TODO: Try this again after the [deterministic push order PR is merged](https://github.com/posit-dev/images-shared/pull/505)
[![Latest Version](https://img.shields.io/docker/v/posit/connect-content?sort=date&label=latest)](https://hub.docker.com/r/posit/connect-content/tags)
-->

> [!NOTE]
> These images are in preview as Posit migrates container images from <a href="https://github.com/rstudio/rstudio-docker-products">rstudio/rstudio-docker-products</a>. The previous `rstudio/content-base` and `rstudio/content-pro` images remain supported.

> [!TIP]
> Deploying on Kubernetes? Try the <a href="https://docs.posit.co/helm/charts/rstudio-connect/README.html">Posit Connect Helm chart</a>!

## Quick reference

|                           |                                                                                                                                                                                                                                                                                                       |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Maintained by**         | [the Posit Docker team](https://github.com/posit-dev/images)                                                                                                                                                                                                                                          |
| **Where to get help**     | [GitHub Issues](https://github.com/posit-dev/images-connect/issues), [Images Discussion Board](https://github.com/posit-dev/images/discussions), [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-connect/27), [Posit Support](https://support.posit.co/hc/en-us) |
| **Where to file issues**  | [https://github.com/posit-dev/images-connect/issues](https://github.com/posit-dev/images-connect/issues)                                                                                                                                                                                              |
| **Source**                | [https://github.com/posit-dev/images-connect](https://github.com/posit-dev/images-connect)                                                                                                                                                                                                            |
| **License**               | [MIT](https://github.com/posit-dev/images-connect/blob/main/LICENSE.md)                                                                                                                                                                                                                               |
| **Product documentation** | [Posit Connect documentation](https://docs.posit.co/connect/), [Content execution environment documentation](https://docs.posit.co/connect/admin/appendix/off-host/execution-environments/)                                                                                                           |

## Related images

For Kubernetes deployments, Connect uses three images together. See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for Helm configuration.

| Image | Description | Docker Hub | GHCR |
|:------|:------------|:-----------|:-----|
| `connect` | The Posit Connect server | [posit/connect](https://hub.docker.com/r/posit/connect) | [posit-dev/connect](https://github.com/posit-dev/images-connect/pkgs/container/connect) |
| `connect-content-init` | Init container for Kubernetes deployments | [posit/connect-content-init](https://hub.docker.com/r/posit/connect-content-init) | [posit-dev/connect-content-init](https://github.com/posit-dev/images-connect/pkgs/container/connect-content-init) |

## How to use this image

Do not run these images directly. Connect's Job Launcher schedules them as content execution pods when published content runs on Kubernetes. Each pod executes Shiny applications, Plumber APIs, Quarto documents, Jupyter notebooks, and other Connect content using the R and Python versions baked into the image.

Configure these images as execution environments in Connect through any of the following methods:

1. **Helm chart values:** The `rstudio/rstudio-connect` Helm chart includes a default set of content images defined by `executionEnvironments`. See the [repository README](https://github.com/posit-dev/images-connect#deploying-on-kubernetes) for configuration details.
2. **Connect admin dashboard:** Manage execution environments in the Connect UI under **Admin > Execution environments**.
3. **Connect API:** Manage execution environments programmatically through the [Connect Environments API endpoints](https://docs.posit.co/connect/api/#environments).

## Image variants

Two variants are available:

| Variant       | Description                                                                                                                  |
|---------------|------------------------------------------------------------------------------------------------------------------------------|
| Base (`base`) | Open-source R and Python with system dependencies for popular R packages.                                                    |
| Pro (`pro`)  | Builds on the Base variant and adds Posit Professional Drivers and the `odbc` R package for ODBC database connectivity.      |

Each tagged image bundles a fixed set of dependencies. Both variants ship one R version, one Python version, and one Quarto version, for a collection of minor versions at their latest patch version available at build time. The Containerfiles in this repository under `connect-content/matrix/` document the exact versions in any tag.

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for how to build on these images.

## Image tags

Posit publishes images to:
- Docker Hub: `docker.io/posit/connect-content`
- GitHub Container Registry: `ghcr.io/posit-dev/connect-content`

Ubuntu 24.04 is the default OS.

The tag format is: `R{r_version}-python{python_version}-{os}[-pro]`

Examples:
- `R4.5.2-python3.14.3-ubuntu-24.04` — R 4.5.2, Python 3.14.3, Ubuntu 24.04, Base variant
- `R4.4.3-python3.12.12-ubuntu-24.04-pro` — R 4.4.3, Python 3.12.12, Ubuntu 24.04, Pro variant
- `R4.3.3-python3.11.14-ubuntu-22.04` — R 4.3.3, Python 3.11.14, Ubuntu 22.04, Base variant

## Architectures

Posit publishes Ubuntu 24.04 content images for both `linux/amd64` and `linux/arm64`. Pull the same tag from either platform; Docker selects the matching manifest automatically. Ubuntu 22.04 content images are published for `linux/amd64` only.

## Installed software

Each image includes:

| Component | Path                                |
|-----------|-------------------------------------|
| R         | `/opt/R/{version}/bin/R`            |
| Python    | `/opt/python/{version}/bin/python3` |
| Quarto    | `/opt/quarto/bin/quarto`  |

The Pro variant also installs Posit Professional Drivers under `/opt/rstudio-drivers/` and the `odbc` R package, with the bundled `odbcinst.ini` copied to `/etc/odbcinst.ini`.

## User

These images do not declare a `USER`. Containers start as `root`. Connect's Job Launcher manages the runtime user when scheduling content pods, dropping privileges as configured by the Connect administrator.

## Examples

### Extending an image with additional R packages

Use any tag as a base for a derived image with additional dependencies. For example, a Pro-variant image with Tidyverse pre-installed:

```dockerfile
FROM ghcr.io/posit-dev/connect-content:R4.5.2-python3.14.3-ubuntu-24.04-pro

RUN /opt/R/4.5.2/bin/R -e 'install.packages("tidyverse", repos = "https://p3m.dev/cran/__linux__/noble/latest")'
```

See [extending examples](https://github.com/posit-dev/images-examples/tree/main/extending) for additional patterns.

## Migrating from legacy image

These images replace the legacy [`rstudio/content-base`](https://hub.docker.com/r/rstudio/content-base) and [`rstudio/content-pro`](https://hub.docker.com/r/rstudio/content-pro) images. The runtime tools are mostly unchanged. R and Python install at the same versioned paths under `/opt`, and Connect schedules content into these images the same way. Quarto moved from versioned to flat install under `/opt/quarto/bin/quarto`, but remains symlinked to `PATH` and is otherwise unchanged. The differences mostly lie in how Posit publishes and tags the image.

### Image references

The legacy images were published as `rstudio/content-base` and `rstudio/content-pro` on Docker Hub and `ghcr.io/rstudio/content-base` and `ghcr.io/rstudio/content-pro` on GHCR, tagged with patterns like `r{r_version}-py{python_version}-bionic` or `r{r_version}-py{python_version}-jammy` for `linux/amd64` only. Update your image references to one of the new locations and pick a tag that pins to your desired R, Python, OS, and variant. See [Image tags](#image-tags) and [Architectures](#architectures).

### Variants

The legacy images split content runtimes into two separate repositories — `rstudio/content-base` for the open-source build and `rstudio/content-pro` for the build with Posit Professional Drivers. The replacement images publish both as variants of a single `connect-content` repository: the Base variant matches `content-base` and the Pro (`-pro`) variant matches `content-pro`. See [Image variants](#image-variants).

### Tag format

Legacy tags followed `r{r_version}-py{python_version}-{codename}`, for example `r4.1.0-py3.9.2-jammy`. Replacement tags follow `R{r_version}-python{python_version}-{os}[-pro]`, for example `R4.5.2-python3.14.3-ubuntu-24.04`. Both forms encode the same information.

### What did not change

- R, Python, and Quarto installation paths under `/opt`
- The role of these images as content execution environments managed by Connect
- The system dependencies bundled to support popular R packages

## Caveats

### Security

Review these images before using them in production. Organizations with specific Common Vulnerabilities and Exposures (CVE) or vulnerability requirements should rebuild these images to meet their security standards.

Posit rebuilds published images weekly for Posit product editions under active support to pull in operating system patches.

### Image dependency licenses

These images contain third-party software (R, Python, Quarto, system libraries, and their transitive dependencies) under various licenses. Image users are responsible for ensuring that use of these images and any of their dependent layers complies with all relevant licenses for the contained software.
