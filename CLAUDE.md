# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Posit Connect container images built with [Posit Bakery](https://github.com/posit-dev/images-shared/tree/main/posit-bakery). Contains `connect` (Standard/Minimal variants), `connect-content` (matrix of R x Python), and `connect-content-init`.

## Sibling Repositories

This project is part of a multi-repo ecosystem for Posit container images. Sibling repos
are configured as additional directories (see `.claude/settings.json`). **Read the CLAUDE.md
in each affected sibling repo before making changes there.**

- `../images-shared/` - Posit Bakery CLI tool for building, testing, and managing container images. Jinja2 templates, macros, and shared build tooling.
- `../images/` - Meta repository with documentation, design principles, and links across all image repos.
- `../images-examples/` - Examples for using and extending Posit container images.
- `../helm/` - Helm charts for Posit products: Connect, Workbench, Package Manager, and Chronicle.

### Worktrees for Cross-Repo Changes

When making changes across repositories, use worktrees to isolate work from `main`. Multiple
sessions may be running concurrently, so never work directly on `main` in any repo.

- **Primary repo:** Use `EnterWorktree` with a descriptive name.
- **Sibling repos:** Create worktrees via `git worktree add` before making changes. Store
  them in `.claude/worktrees/<name>` within each repo (matching the `EnterWorktree` convention).

```bash
# Create a worktree in a sibling repo
git -C ../images-shared worktree add .claude/worktrees/<name> -b <branch-name>
```

Read and write files via the worktree path (e.g., `../images-shared/.claude/worktrees/<name>/`)
instead of the repo root. Clean up when finished:

```bash
git -C ../images-shared worktree remove .claude/worktrees/<name>
```

> **Note:** The `additionalDirectories` in `.claude/settings.json` point to the sibling repo
> roots, not to worktree paths. File reads and writes via those directories will access the
> repo root (typically on `main`). Always use the full worktree path when reading or writing
> files in a sibling worktree.

## Product Naming

| Current Name | Legacy Name | ENV Prefix | Legacy Prefix |
|---|---|---|---|
| Posit Connect | RStudio Connect | `PCT_` | `RSC_` |
| Posit Workbench | RStudio Workbench | `PWB_` | `RSW_`, `RSP_` |
| Posit Package Manager | RStudio Package Manager | `PPM_` | `RSPM_` |

## Images

### connect

The main Posit Connect server image. Two variants:

- **Standard** (`std`, primary) — includes R, Python, and Quarto. Goss tests run the Connect server process.
- **Minimal** (`min`) — base image for customers to extend.

**Key env vars** (set in Containerfile, consumed by `startup.sh`):
- `PCT_LICENSE` — license key (falls back to `RSC_LICENSE`)
- `PCT_LICENSE_SERVER` — floating license server URL (falls back to `RSC_LICENSE_SERVER`)
- `PCT_LICENSE_FILE_PATH` — path to license file, default `/etc/rstudio-connect/license.lic`
- `STARTUP_DEBUG_MODE` — set to `1` for verbose startup logging

All license env vars are unset after activation to prevent child process inheritance.

### connect-content

Content execution images for Connect's Launcher. Uses a **matrix** of R x Python versions
(e.g., `R4.5.2-python3.14.3`). Two variants:

- **base** (primary) — standard content runtime
- **pro** — adds Posit Professional Drivers for database connectivity

### connect-content-init

Initialization image for Connect content pods. Single variant, no dependencies.
Supports multi-platform builds (`linux/amd64`, `linux/arm64`) on recent versions.

## Template Pipeline

**Always edit Jinja2 templates in `template/`, never rendered files in version directories.**

After changing templates, re-render: `bakery update files`

```
connect/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu2204.jinja2
│   ├── Containerfile.ubuntu2404.jinja2
│   ├── conf/rstudio-connect.gcfg.jinja2
│   ├── deps/ubuntu-{22.04,24.04}_packages.txt.jinja2
│   ├── scripts/{install_connect,startup}.sh.jinja2
│   └── test/goss.yaml.jinja2
├── 2026.02/                           # Rendered (do not edit)
├── 2026.01/
└── ...

connect-content/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu{2204,2404}.jinja2
│   ├── deps/ubuntu-{22.04,24.04}_packages.txt.jinja2
│   └── test/goss.yaml.jinja2
└── matrix/                            # Rendered (do not edit)

connect-content-init/
├── template/                          # EDIT THESE
│   ├── Containerfile.ubuntu{2204,2404}.jinja2
│   └── scripts/entrypoint.sh          # Note: not a template
├── 2026.02/                           # Rendered (do not edit)
└── ...
```

### Macros imported in templates

All Containerfile templates import from Bakery's shared macros:
```jinja2
{%- import "apt.j2" as apt -%}
{%- import "python.j2" as python -%}
{%- import "quarto.j2" as quarto -%}
{%- import "r.j2" as r -%}
```

Key macro usage: `python.build_stage()` for multi-stage UV builds, `apt.run_install()` for
system packages, `r.run_install()` for R, `quarto.install()` for Quarto + TinyTeX.

### Template variables

- `Image.Version`, `Image.Variant`, `Image.OS`, `Image.IsDevelopmentVersion`
- `Dependencies.python`, `Dependencies.R`, `Dependencies.quarto` (lists of version strings)
- `Path.Version`, `Path.Image`

## Build and Test

```bash
# Install bakery and goss
just init

# Preview the build plan
bakery build --plan

# Build all images
bakery build

# Build a specific image/version/variant
bakery build --image-name connect --image-version 2026.02.0 --image-variant Standard

# Run goss tests
bakery run dgoss
bakery run dgoss --image-name connect

# Re-render templates after changes
bakery update files
bakery update files --image-name connect --image-version 2026.02.0
```

## CI Workflows

All workflows call shared reusable workflows from `images-shared`:

| Workflow | Schedule | What it builds | Shared workflow |
|---|---|---|---|
| `production.yml` | Weekly (Sun 03:15 UTC), PR, push to main | `connect` + `connect-content-init` (excludes dev/matrix) | `bakery-build-native.yml` |
| `development.yml` | Daily (04:45 UTC), PR, push to main | Dev versions only (daily stream previews) | `bakery-build-native.yml` |
| `content.yml` | Weekly (Sun 04:15 UTC), PR, push to main | `connect-content` matrix images only | `bakery-build.yml` |

Images push to `docker.io/posit` and `ghcr.io/posit-dev` on main merges and scheduled runs.
Dev preview images push to `ghcr.io/posit-dev/connect-preview`.

### CI failure checklist

1. **Check which workflow failed** — production vs development vs content have different scopes
2. **Read the failing step** — usually Build or Test
3. **Common failures:**
   - Python version not available in UV — a new Python minor version may not be in UV's release metadata yet
   - Goss test timeout — Connect Standard variant needs `wait: 20` for server startup
   - Registry auth — Docker Hub push requires `DOCKER_HUB_ACCESS_TOKEN` secret
4. **Cache issues** — builds use `--cache-registry ghcr.io/posit-dev` for layer caching; stale caches can cause unexpected behavior

## Helm Integration

The corresponding Helm chart is `rstudio-connect` in `../helm/charts/rstudio-connect/`.

- Chart `appVersion` in `Chart.yaml` drives the default image tag
- Image tag pattern: `{appVersion}-{os}` (e.g., `2026.02.0-ubuntu-24.04`)
- `values.yaml` references `ghcr.io/posit-dev/connect`, `connect-content-init`, and `connect-content`
- Content runtime images (R x Python matrix) are defined in `default-runtime.yaml`

When bumping image versions, coordinate updates to the helm chart's `appVersion` and `default-runtime.yaml`.
