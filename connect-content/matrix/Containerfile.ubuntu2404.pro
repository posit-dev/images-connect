# Build Python using uv in a separate stage
FROM ghcr.io/astral-sh/uv:debian-slim AS python-builder

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
ENV UV_PYTHON_INSTALL_DIR=/opt/python
ENV UV_PYTHON_PREFERENCE=only-managed

ARG PYTHON_VERSION
RUN uv python install $PYTHON_VERSION
RUN mv /opt/python/cpython-$PYTHON_VERSION-linux-*/ /opt/python/$PYTHON_VERSION


FROM docker.io/library/ubuntu:24.04
LABEL maintainer="Posit Docker <docker@posit.co>"
LABEL org.opencontainers.image.base.name="docker.io/library/ubuntu:24.04"

### ARG declarations ###
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILDARCH
ARG TARGETARCH=${BUILDARCH}
ARG R_VERSION
ARG PYTHON_VERSION
ARG QUARTO_VERSION

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

### Locale configuration ###
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ=UTC

### Install Apt Packages ###
RUN apt-get update -yqq --fix-missing && \
    apt-get upgrade -yqq && \
    apt-get dist-upgrade -yqq && \
    apt-get autoremove -yqq --purge && \
    apt-get install -yqq --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        tar && \
    bash -c "$(curl -1fsSL 'https://dl.posit.co/public/pro/setup.deb.sh')" && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

COPY connect-content/matrix/deps/ubuntu-24.04_packages.txt /tmp/ubuntu-24.04_packages.txt
RUN apt-get update -yqq && \
    xargs -a /tmp/ubuntu-24.04_packages.txt apt-get install -yqq --no-install-recommends && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

### Install Pro Drivers and ODBC ###
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        apt-get update -yqq && \
        apt-get install -yqq --no-install-recommends \
            rstudio-drivers && \
        apt-get clean -yqq && \
        rm -rf /var/lib/apt/lists/* && \
        cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini; \
    else \
        echo "Pro Drivers will not be installed for architecture: $TARGETARCH"; \
    fi

### Install R ###
RUN apt-get update -yqq && \
    RUN_UNATTENDED=1 R_VERSION=$R_VERSION bash -c "$(curl -fsSL https://rstd.io/r-install)" && \
    find . -type f -name '[rR]-$R_VERSION.*\.(deb|rpm)' -delete && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

### Install odbc R package ###
RUN /opt/R/$R_VERSION/bin/R -e 'install.packages("odbc", repos="https://p3m.dev/cran/__linux__/noble/latest")'

### Install Python from build stage ###
COPY --from=python-builder /opt/python /opt/python

### Upgrade setuptools ###
RUN /opt/python/$PYTHON_VERSION/bin/python -m pip install --no-cache-dir --break-system-packages --upgrade setuptools

### Install Quarto ###
RUN bash -c "$(curl -1fsSL 'https://dl.posit.co/public/open/setup.deb.sh')" && \
    apt-get install -yqq --no-install-recommends \
        quarto=$QUARTO_VERSION && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/*

### Install TinyTeX ###
# Caches won't invalidate correctly on new releases for TinyTeX installs.
# This ADD instruction is a workaround to bust the cache on new releases.
#
# TinyTeX is installed under HOME="/opt" so the install lands at /opt/.TinyTeX,
# which is readable by non-root runtime users. `--update-path` makes tlmgr
# symlink the TinyTeX binaries into /usr/local/bin.
# TODO: Remove `HOME="/opt"` once Quarto supports custom install locations
# for TinyTeX, see https://github.com/quarto-dev/quarto-cli/issues/11800.
ADD https://github.com/rstudio/tinytex-releases/releases/latest /tmp/tinytex-release.json
RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
        xz-utils && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/* && \
    HOME="/opt" /opt/quarto/bin/quarto install tinytex --no-prompt --quiet --update-path && \
    rm -f /tmp/tinytex-release.json
