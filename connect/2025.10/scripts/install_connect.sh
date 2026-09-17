#!/bin/bash
set -eou pipefail

# Output delimiter
d="===="

# Pre-create rstudio-connect so the deb postinst preserves UID/GID 999.
if ! getent group rstudio-connect >/dev/null; then
    groupadd --system --gid 999 rstudio-connect
fi
if ! getent passwd rstudio-connect >/dev/null; then
    useradd --system --uid 999 --gid rstudio-connect \
        --no-create-home --home-dir /var/lib/rstudio-connect \
        --shell /usr/sbin/nologin \
        rstudio-connect
fi
if [ "$(id -u rstudio-connect)" != 999 ] || [ "$(id -g rstudio-connect)" != 999 ]; then
    echo "ERROR: rstudio-connect must be uid/gid 999, got uid=$(id -u rstudio-connect) gid=$(id -g rstudio-connect)" >&2
    exit 1
fi

apt-get update -yq

echo "$d Installing Posit Connect 2025.10.0 $d"

RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf rstudio-connect=2025.10.0-1
apt-mark hold rstudio-connect

mv /tmp/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg
if [ "$IMAGE_VARIANT" != "Minimal" ]; then
cat << EOF >> /etc/rstudio-connect/rstudio-connect.gcfg
[R]
Enabled = true
Executable = /opt/R/4.5.1/bin/R

[Python]
Enabled = true
Executable = /opt/python/3.14.0/bin/python

[Quarto]
Enabled = true
Executable = /opt/quarto/bin/quarto
EOF
else
cat << EOF >> /etc/rstudio-connect/rstudio-connect.gcfg
[Quarto]
Enabled = false

[TensorFlow]
Enabled = false
EOF
fi

# clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
