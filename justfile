#!/usr/bin/env just --justfile

setup:
  pre-commit --version || (echo "pre-commit not found, install with: uv tool install pre-commit" && exit 1)
  pre-commit install --install-hooks

install-bakery *OPTS:
  #!/bin/bash
  # Install the latest released posit-bakery from PyPI.
  # For an unreleased development version, install from GitHub:
  #   uv tool install 'git+ssh://git@github.com/posit-dev/images-shared.git@main#egg=posit-bakery&subdirectory=posit-bakery'
  uv tool install {{OPTS}} posit-bakery

install-goss:
  #!/bin/bash
  set -euo pipefail
  # dgoss copies goss into the container under test, so the binary must be a Linux build.
  # The installer ends by running goss on the host, which fails on macOS before dgoss is written.
  tools="{{justfile_directory()}}/tools"
  mkdir -p "$tools"
  curl -fsSL https://goss.rocks/install | GOSS_DST="$tools" sh || true
  test -s "$tools/goss" || { echo "ERROR: goss was not installed to $tools/goss" >&2; exit 1; }
  chmod +rx "$tools/goss"
  curl -fsSL https://github.com/goss-org/goss/releases/latest/download/dgoss -o "$tools/dgoss"
  chmod +rx "$tools/dgoss"

init: install-bakery install-goss
