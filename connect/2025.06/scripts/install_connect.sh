#!/bin/bash
set -eou pipefail

# Output delimiter
d="===="

apt-get update -yq

echo "$d Installing Posit Connect 2025.06.0 $d"

RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 apt-get install -yf rstudio-connect=2025.06.0
apt-mark hold rstudio-connect

mv /tmp/rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg
if [ "$IMAGE_VARIANT" != "Minimal" ]; then
cat << EOF >> /etc/rstudio-connect/rstudio-connect.gcfg
[R]
Enabled = true
Executable = /opt/R/4.4.0/bin/R

[Python]
Enabled = true
Executable = /opt/python/cpython-3.12.1-linux-x86_64-gnu/bin/python

[Quarto]
Enabled = true
Executable = /opt/quarto/1.4.557/bin/quarto

[TensorFlow]
Enabled = true
Executable = /usr/bin/tensorflow_model_server
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
